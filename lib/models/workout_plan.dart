class WorkoutPlan {
  final String id;
  final String userId;
  final String planName;
  final int weekNumber;
  final DateTime generatedAt;
  final List<WorkoutDay> days;
  final String aiRationale;
  final DifficultyLevel difficulty;
  final int estimatedCaloriesBurnedPerWeek;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.planName,
    required this.weekNumber,
    required this.generatedAt,
    required this.days,
    required this.aiRationale,
    required this.difficulty,
    required this.estimatedCaloriesBurnedPerWeek,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'planName': planName,
        'weekNumber': weekNumber,
        'generatedAt': generatedAt.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(),
        'aiRationale': aiRationale,
        'difficulty': difficulty.name,
        'estimatedCaloriesBurnedPerWeek': estimatedCaloriesBurnedPerWeek,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planName: json['planName'] as String,
      weekNumber: json['weekNumber'] as int,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      days: (json['days'] as List)
          .map((d) => WorkoutDay.fromJson(d))
          .toList(),
      aiRationale: json['aiRationale'] as String,
      difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
      estimatedCaloriesBurnedPerWeek:
          json['estimatedCaloriesBurnedPerWeek'] as int,
    );
  }
}

class WorkoutDay {
  final int dayOfWeek;
  final String focusArea;
  final List<Exercise> exercises;
  final int restDayMinutes;
  final bool isRestDay;
  final String warmupNotes;
  final String cooldownNotes;

  const WorkoutDay({
    required this.dayOfWeek,
    required this.focusArea,
    required this.exercises,
    this.restDayMinutes = 0,
    this.isRestDay = false,
    this.warmupNotes = '',
    this.cooldownNotes = '',
  });

  int get totalDuration =>
      exercises.fold(0, (sum, e) => sum + e.estimatedDurationSeconds) ~/ 60;

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'focusArea': focusArea,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'restDayMinutes': restDayMinutes,
        'isRestDay': isRestDay,
        'warmupNotes': warmupNotes,
        'cooldownNotes': cooldownNotes,
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      dayOfWeek: json['dayOfWeek'] as int,
      focusArea: json['focusArea'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      restDayMinutes: json['restDayMinutes'] as int? ?? 0,
      isRestDay: json['isRestDay'] as bool? ?? false,
      warmupNotes: json['warmupNotes'] as String? ?? '',
      cooldownNotes: json['cooldownNotes'] as String? ?? '',
    );
  }
}

class Exercise {
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final double? weightKg;
  final int restBetweenSetsSec;
  final int estimatedDurationSeconds;
  final String? notes;
  final String? videoUrl;
  final ExerciseType type;

  const Exercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    this.weightKg,
    required this.restBetweenSetsSec,
    required this.estimatedDurationSeconds,
    this.notes,
    this.videoUrl,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'restBetweenSetsSec': restBetweenSetsSec,
        'estimatedDurationSeconds': estimatedDurationSeconds,
        'notes': notes,
        'videoUrl': videoUrl,
        'type': type.name,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      restBetweenSetsSec: json['restBetweenSetsSec'] as int,
      estimatedDurationSeconds: json['estimatedDurationSeconds'] as int,
      notes: json['notes'] as String?,
      videoUrl: json['videoUrl'] as String?,
      type: ExerciseType.values.byName(json['type'] as String),
    );
  }
}

enum DifficultyLevel { beginner, intermediate, advanced, expert }

enum ExerciseType { compound, isolation, cardio, stretching, plyometric }
