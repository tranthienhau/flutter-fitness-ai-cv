import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/onboarding_screen.dart';
import 'screens/photo_capture_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/weekly_checkin_screen.dart';
import 'screens/ai_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('user_profile');
  await Hive.openBox('workout_plans');
  await Hive.openBox('meal_plans');
  await Hive.openBox('physique_history');

  runApp(const ProviderScope(child: FitnessAIApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/capture',
        builder: (context, state) => const PhotoCaptureScreen(),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final analysisId = state.extra as String?;
          return AnalysisScreen(analysisId: analysisId ?? '');
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const WeeklyCheckinScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
});

class FitnessAIApp extends ConsumerWidget {
  const FitnessAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AI Fitness Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: router,
    );
  }
}
