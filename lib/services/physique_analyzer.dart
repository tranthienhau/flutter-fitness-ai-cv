import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/physique_analysis.dart' as models;
import '../models/user_profile.dart';

class PhysiqueAnalyzerService {
  static const String _claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _claudeModel = 'claude-sonnet-4-20250514';

  // In production, this would be fetched from secure storage / env
  String? _apiKey;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.single,
      model: PoseDetectionModel.accurate,
    ),
  );

  void setApiKey(String key) => _apiKey = key;

  /// Analyze physique from front, side, and back photos.
  /// Uses ML Kit Pose Detection for landmark extraction, then sends
  /// the landmark data + base64 images to Claude for body composition analysis.
  Future<models.PhysiqueAnalysis> analyzePhysique({
    required String frontPhotoPath,
    required String sidePhotoPath,
    required String backPhotoPath,
    required UserProfile userProfile,
  }) async {
    // Step 1: Detect pose landmarks in each photo
    final frontLandmarks = await _detectPoseLandmarks(frontPhotoPath);
    final sideLandmarks = await _detectPoseLandmarks(sidePhotoPath);
    final backLandmarks = await _detectPoseLandmarks(backPhotoPath);

    // Step 2: Calculate body proportions from landmarks
    final proportions = _calculateProportions(frontLandmarks, sideLandmarks);

    // Step 3: Encode images as base64 for Claude vision analysis
    final frontB64 = base64Encode(File(frontPhotoPath).readAsBytesSync());
    final sideB64 = base64Encode(File(sidePhotoPath).readAsBytesSync());
    final backB64 = base64Encode(File(backPhotoPath).readAsBytesSync());

    // Step 4: Send to Claude API for AI-powered body composition analysis
    final aiAnalysis = await _requestClaudeAnalysis(
      frontB64: frontB64,
      sideB64: sideB64,
      backB64: backB64,
      landmarks: {
        'front': _landmarksToJson(frontLandmarks),
        'side': _landmarksToJson(sideLandmarks),
        'back': _landmarksToJson(backLandmarks),
      },
      userProfile: userProfile,
      proportions: proportions,
    );

    // Step 5: Parse the AI response and build the analysis model
    return _buildAnalysisFromAiResponse(
      aiAnalysis: aiAnalysis,
      frontPhotoPath: frontPhotoPath,
      sidePhotoPath: sidePhotoPath,
      backPhotoPath: backPhotoPath,
      userId: userProfile.id,
      allLandmarks: [...frontLandmarks, ...sideLandmarks, ...backLandmarks],
      proportions: proportions,
    );
  }

  Future<List<models.PoseLandmark>> _detectPoseLandmarks(
      String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isEmpty) return [];

    final pose = poses.first;
    return pose.landmarks.entries.map((entry) {
      final lm = entry.value;
      return models.PoseLandmark(
        name: entry.key.name,
        x: lm.x,
        y: lm.y,
        z: lm.z,
        confidence: lm.likelihood,
      );
    }).toList();
  }

  models.BodyProportions _calculateProportions(
    List<models.PoseLandmark> frontLandmarks,
    List<models.PoseLandmark> sideLandmarks,
  ) {
    double shoulderWidth = _distanceBetween(
      frontLandmarks, 'leftShoulder', 'rightShoulder',
    );
    double waistWidth = _distanceBetween(
      frontLandmarks, 'leftHip', 'rightHip',
    );
    double hipWidth = waistWidth * 1.15; // approximation

    double torsoLength = _distanceBetween(
      frontLandmarks, 'leftShoulder', 'leftHip',
    );
    double legLength = _distanceBetween(
      frontLandmarks, 'leftHip', 'leftAnkle',
    );
    double armSpan = shoulderWidth +
        _distanceBetween(frontLandmarks, 'leftShoulder', 'leftWrist') +
        _distanceBetween(frontLandmarks, 'rightShoulder', 'rightWrist');
    double height = torsoLength + legLength + (torsoLength * 0.2); // head est.

    return models.BodyProportions(
      shoulderToWaistRatio:
          waistWidth > 0 ? shoulderWidth / waistWidth : 1.0,
      waistToHipRatio: hipWidth > 0 ? waistWidth / hipWidth : 1.0,
      torsoToLegRatio: legLength > 0 ? torsoLength / legLength : 1.0,
      armSpanToHeightRatio: height > 0 ? armSpan / height : 1.0,
    );
  }

  double _distanceBetween(
    List<models.PoseLandmark> landmarks,
    String name1,
    String name2,
  ) {
    final lm1 = landmarks.where((l) => l.name == name1).firstOrNull;
    final lm2 = landmarks.where((l) => l.name == name2).firstOrNull;
    if (lm1 == null || lm2 == null) return 0;
    return sqrt(pow(lm2.x - lm1.x, 2) + pow(lm2.y - lm1.y, 2));
  }

  List<Map<String, dynamic>> _landmarksToJson(
      List<models.PoseLandmark> landmarks) {
    return landmarks.map((l) => l.toJson()).toList();
  }

  Future<Map<String, dynamic>> _requestClaudeAnalysis({
    required String frontB64,
    required String sideB64,
    required String backB64,
    required Map<String, List<Map<String, dynamic>>> landmarks,
    required UserProfile userProfile,
    required models.BodyProportions proportions,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Claude API key not configured');
    }

    final systemPrompt = '''You are an expert fitness coach and body composition analyst.
Analyze the three physique photos (front, side, back) along with the detected pose landmarks and body proportions.

Provide a JSON response with:
- estimatedBodyFatPercentage (number, e.g. 18.5)
- bodyFatCategory (one of: essential, athletic, fitness, average, aboveAverage, obese)
- muscleDevelopment: object with scores 1-10 for: shoulders, chest, arms, core, back, glutes, quads, hamstrings, calves, overallSymmetry
- fatDistribution: object with relative scores 1-10 for: abdominal, lowerBack, chest, arms, thighs, hips, and pattern (android/gynoid/mixed)
- aiSummary: 2-3 sentence overall assessment
- strengths: array of 3-5 strong points
- areasForImprovement: array of 3-5 areas to work on
- measurementEstimates: object with estimated measurements in cm (chest, waist, hips, bicep, thigh)

Consider the user's stats: age ${userProfile.age}, weight ${userProfile.weightKg}kg, height ${userProfile.heightCm}cm, gender ${userProfile.gender.name}.
Detected proportions: shoulder-to-waist ${proportions.shoulderToWaistRatio.toStringAsFixed(2)}, waist-to-hip ${proportions.waistToHipRatio.toStringAsFixed(2)}.

Return ONLY valid JSON, no markdown.''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _claudeModel,
        'max_tokens': 2048,
        'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': frontB64,
                },
              },
              {'type': 'text', 'text': 'Front pose photo'},
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': sideB64,
                },
              },
              {'type': 'text', 'text': 'Side pose photo'},
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': backB64,
                },
              },
              {'type': 'text', 'text': 'Back pose photo'},
              {
                'type': 'text',
                'text':
                    'Pose landmarks: ${jsonEncode(landmarks)}\n\nAnalyze this physique and return the JSON assessment.',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Claude API error: ${response.statusCode} - ${response.body}');
    }

    final responseJson = jsonDecode(response.body);
    final content = responseJson['content'][0]['text'] as String;
    return jsonDecode(content) as Map<String, dynamic>;
  }

  models.PhysiqueAnalysis _buildAnalysisFromAiResponse({
    required Map<String, dynamic> aiAnalysis,
    required String frontPhotoPath,
    required String sidePhotoPath,
    required String backPhotoPath,
    required String userId,
    required List<models.PoseLandmark> allLandmarks,
    required models.BodyProportions proportions,
  }) {
    final muscleDev = aiAnalysis['muscleDevelopment'] as Map<String, dynamic>;
    final fatDist = aiAnalysis['fatDistribution'] as Map<String, dynamic>;

    return models.PhysiqueAnalysis(
      id: const Uuid().v4(),
      userId: userId,
      analyzedAt: DateTime.now(),
      estimatedBodyFatPercentage:
          (aiAnalysis['estimatedBodyFatPercentage'] as num).toDouble(),
      bodyFatCategory: models.BodyFatCategory.values.byName(
        aiAnalysis['bodyFatCategory'] as String,
      ),
      muscleDevelopment: models.MuscleDevScores(
        shoulders: (muscleDev['shoulders'] as num).toDouble(),
        chest: (muscleDev['chest'] as num).toDouble(),
        arms: (muscleDev['arms'] as num).toDouble(),
        core: (muscleDev['core'] as num).toDouble(),
        back: (muscleDev['back'] as num).toDouble(),
        glutes: (muscleDev['glutes'] as num).toDouble(),
        quads: (muscleDev['quads'] as num).toDouble(),
        hamstrings: (muscleDev['hamstrings'] as num).toDouble(),
        calves: (muscleDev['calves'] as num).toDouble(),
        overallSymmetry: (muscleDev['overallSymmetry'] as num).toDouble(),
      ),
      fatDistribution: models.FatDistribution(
        abdominal: (fatDist['abdominal'] as num).toDouble(),
        lowerBack: (fatDist['lowerBack'] as num).toDouble(),
        chest: (fatDist['chest'] as num).toDouble(),
        arms: (fatDist['arms'] as num).toDouble(),
        thighs: (fatDist['thighs'] as num).toDouble(),
        hips: (fatDist['hips'] as num).toDouble(),
        pattern: models.FatDistributionPattern.values
            .byName(fatDist['pattern'] as String),
      ),
      proportions: proportions,
      detectedLandmarks: allLandmarks,
      frontPhotoPath: frontPhotoPath,
      sidePhotoPath: sidePhotoPath,
      backPhotoPath: backPhotoPath,
      aiSummary: aiAnalysis['aiSummary'] as String,
      strengths: List<String>.from(aiAnalysis['strengths'] ?? []),
      areasForImprovement:
          List<String>.from(aiAnalysis['areasForImprovement'] ?? []),
      measurementEstimates: Map<String, double>.from(
        (aiAnalysis['measurementEstimates'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
    );
  }

  void dispose() {
    _poseDetector.close();
  }
}
