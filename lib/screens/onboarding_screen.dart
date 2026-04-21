import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_profile.dart';
import '../providers/fitness_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  Gender _gender = Gender.male;
  FitnessGoal _goal = FitnessGoal.buildMuscle;
  ExperienceLevel _experience = ExperienceLevel.intermediate;
  final List<String> _allergies = [];
  final List<String> _dietaryPreferences = [];
  int _workoutDays = 4;
  int _sessionMinutes = 60;
  final List<String> _equipment = [];

  static const _allergyOptions = [
    'Dairy', 'Gluten', 'Nuts', 'Soy', 'Eggs', 'Shellfish', 'Fish',
  ];

  static const _dietOptions = [
    'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Mediterranean', 'High Protein',
  ];

  static const _equipmentOptions = [
    'Barbell', 'Dumbbells', 'Pull-up Bar', 'Resistance Bands',
    'Cable Machine', 'Kettlebell', 'Bench', 'Squat Rack', 'Bodyweight Only',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  _buildBasicInfoPage(theme),
                  _buildGoalPage(theme),
                  _buildExperiencePage(theme),
                  _buildDietPage(theme),
                  _buildEquipmentPage(theme),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _currentPage < 4 ? _nextPage : _completeOnboarding,
                    child: Text(_currentPage < 4 ? 'Next' : 'Start'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About You', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'We need some basic info to personalize your plan.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<Gender>(
            segments: Gender.values
                .map((g) => ButtonSegment(
                      value: g,
                      label: Text(g.name[0].toUpperCase() + g.name.substring(1)),
                    ))
                .toList(),
            selected: {_gender},
            onSelectionChanged: (v) => setState(() => _gender = v.first),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Goal', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'What do you want to achieve?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...FitnessGoal.values.map((goal) {
            final labels = {
              FitnessGoal.loseWeight: ('Lose Weight', 'Reduce body fat while preserving muscle'),
              FitnessGoal.buildMuscle: ('Build Muscle', 'Gain lean muscle mass'),
              FitnessGoal.bodyRecomposition: ('Body Recomposition', 'Lose fat and gain muscle simultaneously'),
              FitnessGoal.improveEndurance: ('Improve Endurance', 'Boost cardiovascular fitness'),
              FitnessGoal.generalFitness: ('General Fitness', 'Overall health and wellness'),
              FitnessGoal.competitionPrep: ('Competition Prep', 'Prepare for physique competition'),
            };
            final (title, subtitle) = labels[goal]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _goal == goal
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                selected: _goal == goal,
                title: Text(title),
                subtitle: Text(subtitle),
                onTap: () => setState(() => _goal = goal),
                trailing: _goal == goal
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExperiencePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience Level', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          ...ExperienceLevel.values.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _experience == level
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                selected: _experience == level,
                title: Text(level.name[0].toUpperCase() + level.name.substring(1)),
                onTap: () => setState(() => _experience = level),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text('Workout days per week', style: theme.textTheme.titleMedium),
          Slider(
            value: _workoutDays.toDouble(),
            min: 2,
            max: 7,
            divisions: 5,
            label: '$_workoutDays days',
            onChanged: (v) => setState(() => _workoutDays = v.round()),
          ),
          Text('Session duration (minutes)', style: theme.textTheme.titleMedium),
          Slider(
            value: _sessionMinutes.toDouble(),
            min: 30,
            max: 120,
            divisions: 6,
            label: '$_sessionMinutes min',
            onChanged: (v) => setState(() => _sessionMinutes = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diet & Allergies', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('Allergies', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergyOptions.map((a) {
              final selected = _allergies.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _allergies.add(a) : _allergies.remove(a);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Dietary Preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietOptions.map((d) {
              final selected = _dietaryPreferences.contains(d);
              return FilterChip(
                label: Text(d),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _dietaryPreferences.add(d) : _dietaryPreferences.remove(d);
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Equipment', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'What equipment do you have access to?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentOptions.map((e) {
              final selected = _equipment.contains(e);
              return FilterChip(
                label: Text(e),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _equipment.add(e) : _equipment.remove(e);
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.createProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 25,
      weightKg: double.tryParse(_weightController.text) ?? 70,
      heightCm: double.tryParse(_heightController.text) ?? 175,
      gender: _gender,
      primaryGoal: _goal,
      experienceLevel: _experience,
      allergies: _allergies,
      dietaryPreferences: _dietaryPreferences,
      workoutDaysPerWeek: _workoutDays,
      workoutMinutesPerSession: _sessionMinutes,
      availableEquipment: _equipment,
    );

    if (mounted) {
      context.go('/capture');
    }
  }
}
