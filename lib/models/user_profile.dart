class UserProfile {
  final String id;
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final Gender gender;
  final FitnessGoal primaryGoal;
  final ExperienceLevel experienceLevel;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final int workoutDaysPerWeek;
  final int workoutMinutesPerSession;
  final List<String> availableEquipment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.primaryGoal,
    required this.experienceLevel,
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.workoutDaysPerWeek = 4,
    this.workoutMinutesPerSession = 60,
    this.availableEquipment = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'gender': gender.name,
        'primaryGoal': primaryGoal.name,
        'experienceLevel': experienceLevel.name,
        'allergies': allergies,
        'dietaryPreferences': dietaryPreferences,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'workoutMinutesPerSession': workoutMinutesPerSession,
        'availableEquipment': availableEquipment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        age: json['age'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        gender: Gender.values.byName(json['gender'] as String),
        primaryGoal: FitnessGoal.values.byName(json['primaryGoal'] as String),
        experienceLevel:
            ExperienceLevel.values.byName(json['experienceLevel'] as String),
        allergies: List<String>.from(json['allergies'] ?? []),
        dietaryPreferences:
            List<String>.from(json['dietaryPreferences'] ?? []),
        workoutDaysPerWeek: json['workoutDaysPerWeek'] as int? ?? 4,
        workoutMinutesPerSession:
            json['workoutMinutesPerSession'] as int? ?? 60,
        availableEquipment:
            List<String>.from(json['availableEquipment'] ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  UserProfile copyWith({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    FitnessGoal? primaryGoal,
    ExperienceLevel? experienceLevel,
    List<String>? allergies,
    List<String>? dietaryPreferences,
    int? workoutDaysPerWeek,
    int? workoutMinutesPerSession,
    List<String>? availableEquipment,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      workoutMinutesPerSession:
          workoutMinutesPerSession ?? this.workoutMinutesPerSession,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

enum Gender { male, female, other }

enum FitnessGoal {
  loseWeight,
  buildMuscle,
  bodyRecomposition,
  improveEndurance,
  generalFitness,
  competitionPrep,
}

enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
  athlete,
}
