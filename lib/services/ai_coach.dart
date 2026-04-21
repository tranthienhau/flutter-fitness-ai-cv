import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/physique_analysis.dart';
import '../models/workout_plan.dart';
import '../models/meal_plan.dart';

class AiCoachService {
  static const String _claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _claudeModel = 'claude-sonnet-4-20250514';
  static const _uuid = Uuid();

  String? _apiKey;

  void setApiKey(String key) => _apiKey = key;

  /// Generate a personalized workout plan based on user profile and physique analysis.
  Future<WorkoutPlan> generateWorkoutPlan({
    required UserProfile profile,
    required PhysiqueAnalysis? latestAnalysis,
    int weekNumber = 1,
    WorkoutPlan? previousPlan,
  }) async {
    final systemPrompt = '''You are an expert personal trainer creating a weekly workout plan.
Return ONLY valid JSON matching this structure:
{
  "planName": "string",
  "aiRationale": "string explaining the plan design",
  "estimatedCaloriesBurnedPerWeek": number,
  "difficulty": "beginner|intermediate|advanced|expert",
  "days": [
    {
      "dayOfWeek": 1-7,
      "focusArea": "string",
      "isRestDay": boolean,
      "warmupNotes": "string",
      "cooldownNotes": "string",
      "exercises": [
        {
          "name": "string",
          "muscleGroup": "string",
          "sets": number,
          "reps": "string (e.g. '8-12' or '30sec')",
          "weightKg": number or null,
          "restBetweenSetsSec": number,
          "estimatedDurationSeconds": number,
          "notes": "string",
          "type": "compound|isolation|cardio|stretching|plyometric"
        }
      ]
    }
  ]
}''';

    final userContext = _buildUserContext(profile, latestAnalysis);
    final progressContext = previousPlan != null
        ? '\n\nPrevious plan was: ${previousPlan.planName}. Apply progressive overload.'
        : '';

    final response = await _callClaude(
      systemPrompt: systemPrompt,
      userMessage:
          'Create a ${profile.workoutDaysPerWeek}-day workout plan for week $weekNumber.\n$userContext$progressContext\n\nTarget ${profile.workoutMinutesPerSession} minutes per session. Available equipment: ${profile.availableEquipment.join(', ')}.',
    );

    final planJson = jsonDecode(response) as Map<String, dynamic>;

    return WorkoutPlan(
      id: _uuid.v4(),
      userId: profile.id,
      planName: planJson['planName'] as String,
      weekNumber: weekNumber,
      generatedAt: DateTime.now(),
      days: (planJson['days'] as List)
          .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      aiRationale: planJson['aiRationale'] as String,
      difficulty: DifficultyLevel.values
          .byName(planJson['difficulty'] as String),
      estimatedCaloriesBurnedPerWeek:
          planJson['estimatedCaloriesBurnedPerWeek'] as int,
    );
  }

  /// Generate a personalized meal plan based on user profile and physique analysis.
  Future<MealPlan> generateMealPlan({
    required UserProfile profile,
    required PhysiqueAnalysis? latestAnalysis,
    int weekNumber = 1,
  }) async {
    final systemPrompt = '''You are an expert sports nutritionist creating a weekly meal plan.
Return ONLY valid JSON matching this structure:
{
  "aiRationale": "string",
  "dailyMacroTargets": {
    "calories": number,
    "proteinGrams": number,
    "carbsGrams": number,
    "fatGrams": number,
    "fiberGrams": number,
    "waterMl": number
  },
  "shoppingList": ["string"],
  "days": [
    {
      "dayOfWeek": 1-7,
      "actualMacros": { same as dailyMacroTargets },
      "meals": [
        {
          "name": "string",
          "type": "breakfast|morningSnack|lunch|afternoonSnack|dinner|eveningSnack",
          "calories": number,
          "proteinGrams": number,
          "carbsGrams": number,
          "fatGrams": number,
          "prepTimeMinutes": number,
          "prepNotes": "string",
          "items": [
            { "name": "string", "quantity": number, "unit": "string", "calories": number }
          ]
        }
      ]
    }
  ]
}''';

    final userContext = _buildUserContext(profile, latestAnalysis);
    final allergyNote = profile.allergies.isNotEmpty
        ? '\n\nALLERGIES (MUST AVOID): ${profile.allergies.join(', ')}'
        : '';
    final dietNote = profile.dietaryPreferences.isNotEmpty
        ? '\nDietary preferences: ${profile.dietaryPreferences.join(', ')}'
        : '';

    final response = await _callClaude(
      systemPrompt: systemPrompt,
      userMessage:
          'Create a 7-day meal plan for week $weekNumber.\n$userContext$allergyNote$dietNote\n\nDesign meals that support the workout plan and ${profile.primaryGoal.name} goal.',
    );

    final planJson = jsonDecode(response) as Map<String, dynamic>;

    return MealPlan(
      id: _uuid.v4(),
      userId: profile.id,
      weekNumber: weekNumber,
      generatedAt: DateTime.now(),
      dailyMacroTargets:
          MacroTargets.fromJson(planJson['dailyMacroTargets']),
      days: (planJson['days'] as List)
          .map((d) => MealDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      aiRationale: planJson['aiRationale'] as String,
      shoppingList: List<String>.from(planJson['shoppingList'] ?? []),
    );
  }

  /// Compare two physique analyses and generate a progress report.
  Future<String> generateProgressReport({
    required PhysiqueAnalysis previous,
    required PhysiqueAnalysis current,
    required UserProfile profile,
  }) async {
    final systemPrompt =
        'You are an encouraging fitness coach reviewing a client\'s progress between two physique assessments. Provide actionable insights.';

    return _callClaude(
      systemPrompt: systemPrompt,
      userMessage: '''Compare these two physique assessments:

PREVIOUS (${previous.analyzedAt.toIso8601String()}):
- Body fat: ${previous.estimatedBodyFatPercentage}%
- Muscle avg score: ${previous.muscleDevelopment.averageScore.toStringAsFixed(1)}/10
- Strengths: ${previous.strengths.join(', ')}
- Areas to improve: ${previous.areasForImprovement.join(', ')}

CURRENT (${current.analyzedAt.toIso8601String()}):
- Body fat: ${current.estimatedBodyFatPercentage}%
- Muscle avg score: ${current.muscleDevelopment.averageScore.toStringAsFixed(1)}/10
- Strengths: ${current.strengths.join(', ')}
- Areas to improve: ${current.areasForImprovement.join(', ')}

User goal: ${profile.primaryGoal.name}

Provide:
1. Key improvements observed
2. Areas still needing work
3. Recommended adjustments to training/nutrition
4. Motivational closing''',
    );
  }

  /// Chat with the AI coach for training/nutrition questions.
  Future<String> chat({
    required String message,
    required UserProfile profile,
    required List<Map<String, String>> conversationHistory,
    PhysiqueAnalysis? latestAnalysis,
  }) async {
    final systemPrompt = '''You are a knowledgeable, supportive AI fitness coach.
User profile: ${profile.name}, ${profile.age}yo, ${profile.weightKg}kg, ${profile.heightCm}cm, ${profile.gender.name}.
Goal: ${profile.primaryGoal.name}. Experience: ${profile.experienceLevel.name}.
${latestAnalysis != null ? 'Latest body fat: ${latestAnalysis.estimatedBodyFatPercentage}%. ${latestAnalysis.aiSummary}' : ''}
Allergies: ${profile.allergies.join(', ')}.

Give concise, evidence-based advice. If asked about medical conditions, recommend consulting a healthcare professional.''';

    final messages = [
      ...conversationHistory.map((m) => {
            'role': m['role']!,
            'content': m['content']!,
          }),
      {'role': 'user', 'content': message},
    ];

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Claude API key not configured');
    }

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _claudeModel,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Claude API error: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body);
    return responseJson['content'][0]['text'] as String;
  }

  String _buildUserContext(
      UserProfile profile, PhysiqueAnalysis? analysis) {
    final buffer = StringBuffer()
      ..writeln('User: ${profile.name}, ${profile.age}yo ${profile.gender.name}')
      ..writeln(
          'Stats: ${profile.weightKg}kg, ${profile.heightCm}cm, BMI ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})')
      ..writeln('Goal: ${profile.primaryGoal.name}')
      ..writeln('Experience: ${profile.experienceLevel.name}');

    if (analysis != null) {
      buffer
        ..writeln(
            'Body fat: ${analysis.estimatedBodyFatPercentage}% (${analysis.bodyFatCategory.name})')
        ..writeln(
            'Muscle dev avg: ${analysis.muscleDevelopment.averageScore.toStringAsFixed(1)}/10')
        ..writeln('Strengths: ${analysis.strengths.join(', ')}')
        ..writeln('Weak areas: ${analysis.areasForImprovement.join(', ')}');
    }

    return buffer.toString();
  }

  Future<String> _callClaude({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Claude API key not configured');
    }

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _claudeModel,
        'max_tokens': 4096,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Claude API error: ${response.statusCode} - ${response.body}');
    }

    final responseJson = jsonDecode(response.body);
    return responseJson['content'][0]['text'] as String;
  }
}
