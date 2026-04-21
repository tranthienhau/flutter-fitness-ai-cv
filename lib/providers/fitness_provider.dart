import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/physique_analysis.dart';
import '../models/workout_plan.dart';
import '../models/meal_plan.dart';
import '../services/physique_analyzer.dart';
import '../services/ai_coach.dart';

const _uuid = Uuid();

// ── User Profile ──

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _box = Hive.box('user_profile');

  Future<void> _load() async {
    try {
      final raw = _box.get('profile');
      if (raw != null) {
        final profile = UserProfile.fromJson(Map<String, dynamic>.from(
          jsonDecode(raw as String),
        ));
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put('profile', jsonEncode(profile.toJson()));
    state = AsyncValue.data(profile);
  }

  Future<UserProfile> createProfile({
    required String name,
    required int age,
    required double weightKg,
    required double heightCm,
    required Gender gender,
    required FitnessGoal primaryGoal,
    required ExperienceLevel experienceLevel,
    List<String> allergies = const [],
    List<String> dietaryPreferences = const [],
    int workoutDaysPerWeek = 4,
    int workoutMinutesPerSession = 60,
    List<String> availableEquipment = const [],
  }) async {
    final profile = UserProfile(
      id: _uuid.v4(),
      name: name,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      gender: gender,
      primaryGoal: primaryGoal,
      experienceLevel: experienceLevel,
      allergies: allergies,
      dietaryPreferences: dietaryPreferences,
      workoutDaysPerWeek: workoutDaysPerWeek,
      workoutMinutesPerSession: workoutMinutesPerSession,
      availableEquipment: availableEquipment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveProfile(profile);
    return profile;
  }
}

// ── Physique Analysis ──

final physiqueAnalyzerProvider = Provider<PhysiqueAnalyzerService>((ref) {
  return PhysiqueAnalyzerService();
});

final physiqueHistoryProvider =
    StateNotifierProvider<PhysiqueHistoryNotifier, List<PhysiqueAnalysis>>(
        (ref) {
  return PhysiqueHistoryNotifier();
});

class PhysiqueHistoryNotifier extends StateNotifier<List<PhysiqueAnalysis>> {
  PhysiqueHistoryNotifier() : super([]) {
    _load();
  }

  final _box = Hive.box('physique_history');

  void _load() {
    final raw = _box.get('history');
    if (raw != null) {
      final list = (jsonDecode(raw as String) as List)
          .map((e) => PhysiqueAnalysis.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      list.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      state = list;
    }
  }

  Future<void> addAnalysis(PhysiqueAnalysis analysis) async {
    state = [analysis, ...state];
    await _box.put(
      'history',
      jsonEncode(state.map((a) => a.toJson()).toList()),
    );
  }

  PhysiqueAnalysis? get latestAnalysis => state.isNotEmpty ? state.first : null;

  double? get bodyFatTrend {
    if (state.length < 2) return null;
    return state.first.estimatedBodyFatPercentage -
        state[1].estimatedBodyFatPercentage;
  }
}

// ── Workout Plan ──

final workoutPlanProvider =
    StateNotifierProvider<WorkoutPlanNotifier, AsyncValue<WorkoutPlan?>>(
        (ref) {
  return WorkoutPlanNotifier();
});

class WorkoutPlanNotifier extends StateNotifier<AsyncValue<WorkoutPlan?>> {
  WorkoutPlanNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _box = Hive.box('workout_plans');

  void _load() {
    try {
      final raw = _box.get('current_plan');
      if (raw != null) {
        final plan = WorkoutPlan.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw as String)),
        );
        state = AsyncValue.data(plan);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePlan(WorkoutPlan plan) async {
    await _box.put('current_plan', jsonEncode(plan.toJson()));
    state = AsyncValue.data(plan);
  }
}

// ── Meal Plan ──

final mealPlanProvider =
    StateNotifierProvider<MealPlanNotifier, AsyncValue<MealPlan?>>((ref) {
  return MealPlanNotifier();
});

class MealPlanNotifier extends StateNotifier<AsyncValue<MealPlan?>> {
  MealPlanNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _box = Hive.box('meal_plans');

  void _load() {
    try {
      final raw = _box.get('current_plan');
      if (raw != null) {
        final plan = MealPlan.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw as String)),
        );
        state = AsyncValue.data(plan);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePlan(MealPlan plan) async {
    await _box.put('current_plan', jsonEncode(plan.toJson()));
    state = AsyncValue.data(plan);
  }
}

// ── AI Coach ──

final aiCoachProvider = Provider<AiCoachService>((ref) {
  return AiCoachService();
});

// ── Chat Messages ──

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(String content, {required bool isUser}) {
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void clear() => state = [];
}

// ── Loading States ──

final isAnalyzingProvider = StateProvider<bool>((ref) => false);
final isGeneratingPlanProvider = StateProvider<bool>((ref) => false);
