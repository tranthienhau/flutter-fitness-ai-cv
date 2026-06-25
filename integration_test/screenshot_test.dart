import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_fitness_ai_cv/screens/onboarding_screen.dart';
import 'package:flutter_fitness_ai_cv/theme/app_theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  testWidgets('capture AI fitness onboarding flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildKineticTheme(),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Page 1 - About You: seed the basic info form so it looks real.
    await tester.enterText(find.byType(TextField).at(0), 'Alex Carter');
    await tester.enterText(find.byType(TextField).at(1), '28');
    await tester.enterText(find.byType(TextField).at(2), '78');
    await tester.enterText(find.byType(TextField).at(3), '182');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await shoot(tester, '01-about-you');

    // Page 2 - Your Goal.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build Muscle'));
    await tester.pumpAndSettle();
    await shoot(tester, '02-goal');

    // Page 3 - Experience Level + training volume sliders.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await shoot(tester, '03-experience');

    // Page 4 - Diet & Allergies chips.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High Protein'));
    await tester.tap(find.text('Gluten'));
    await tester.pumpAndSettle();
    await shoot(tester, '04-diet');

    // Page 5 - Equipment chips.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell'));
    await tester.tap(find.text('Dumbbells'));
    await tester.tap(find.text('Squat Rack'));
    await tester.pumpAndSettle();
    await shoot(tester, '05-equipment');
  });
}
