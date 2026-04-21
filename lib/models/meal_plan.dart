class MealPlan {
  final String id;
  final String userId;
  final int weekNumber;
  final DateTime generatedAt;
  final MacroTargets dailyMacroTargets;
  final List<MealDay> days;
  final String aiRationale;
  final List<String> shoppingList;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.weekNumber,
    required this.generatedAt,
    required this.dailyMacroTargets,
    required this.days,
    required this.aiRationale,
    this.shoppingList = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'weekNumber': weekNumber,
        'generatedAt': generatedAt.toIso8601String(),
        'dailyMacroTargets': dailyMacroTargets.toJson(),
        'days': days.map((d) => d.toJson()).toList(),
        'aiRationale': aiRationale,
        'shoppingList': shoppingList,
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekNumber: json['weekNumber'] as int,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      dailyMacroTargets: MacroTargets.fromJson(json['dailyMacroTargets']),
      days: (json['days'] as List).map((d) => MealDay.fromJson(d)).toList(),
      aiRationale: json['aiRationale'] as String,
      shoppingList: List<String>.from(json['shoppingList'] ?? []),
    );
  }
}

class MacroTargets {
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int fiberGrams;
  final int waterMl;

  const MacroTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams = 30,
    this.waterMl = 3000,
  });

  double get proteinCalories => proteinGrams * 4.0;
  double get carbCalories => carbsGrams * 4.0;
  double get fatCalories => fatGrams * 9.0;

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'fiberGrams': fiberGrams,
        'waterMl': waterMl,
      };

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      calories: json['calories'] as int,
      proteinGrams: json['proteinGrams'] as int,
      carbsGrams: json['carbsGrams'] as int,
      fatGrams: json['fatGrams'] as int,
      fiberGrams: json['fiberGrams'] as int? ?? 30,
      waterMl: json['waterMl'] as int? ?? 3000,
    );
  }
}

class MealDay {
  final int dayOfWeek;
  final List<Meal> meals;
  final MacroTargets actualMacros;

  const MealDay({
    required this.dayOfWeek,
    required this.meals,
    required this.actualMacros,
  });

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'meals': meals.map((m) => m.toJson()).toList(),
        'actualMacros': actualMacros.toJson(),
      };

  factory MealDay.fromJson(Map<String, dynamic> json) {
    return MealDay(
      dayOfWeek: json['dayOfWeek'] as int,
      meals: (json['meals'] as List).map((m) => Meal.fromJson(m)).toList(),
      actualMacros: MacroTargets.fromJson(json['actualMacros']),
    );
  }
}

class Meal {
  final String name;
  final MealType type;
  final List<FoodItem> items;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final String? prepNotes;
  final int prepTimeMinutes;

  const Meal({
    required this.name,
    required this.type,
    required this.items,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.prepNotes,
    this.prepTimeMinutes = 15,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'items': items.map((i) => i.toJson()).toList(),
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'prepNotes': prepNotes,
        'prepTimeMinutes': prepTimeMinutes,
      };

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String,
      type: MealType.values.byName(json['type'] as String),
      items:
          (json['items'] as List).map((i) => FoodItem.fromJson(i)).toList(),
      calories: json['calories'] as int,
      proteinGrams: json['proteinGrams'] as int,
      carbsGrams: json['carbsGrams'] as int,
      fatGrams: json['fatGrams'] as int,
      prepNotes: json['prepNotes'] as String?,
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 15,
    );
  }
}

class FoodItem {
  final String name;
  final double quantity;
  final String unit;
  final int calories;

  const FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'calories': calories,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      calories: json['calories'] as int,
    );
  }
}

enum MealType { breakfast, morningSnack, lunch, afternoonSnack, dinner, eveningSnack }
