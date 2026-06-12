# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (lib-only project) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_fitness_ai_cv
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 17"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs plus `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - pumps `OnboardingScreen` directly inside a `ProviderScope` + `MaterialApp` (avoiding the heavier `main()` init), seeds the first page with sample stats (name, age, weight, height), then taps the `Next` button to walk the `PageView` through each onboarding step (Your Goal, Experience, Diet, Equipment), selecting chips and list items so each screen shows real content. At each step it calls `binding.convertFlutterSurfaceToImage()` + `pumpAndSettle()` + `binding.takeScreenshot('NN-name')`.

## Note

To keep the simulator build green on Apple-Silicon iOS 26 (where `google_mlkit_pose_detection` ships no arm64-simulator slice), the pose-detection native pod is temporarily stubbed out of the build during capture only. The committed source keeps the full ML Kit integration intact.
