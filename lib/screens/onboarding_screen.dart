import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_profile.dart';
import '../providers/fitness_provider.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : const SizedBox.shrink(),
        title: const Text('Onboarding'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Pill progress indicator + step label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(_totalPages, (i) {
                      final filled = i <= _currentPage;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          margin: EdgeInsets.only(right: i == _totalPages - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: filled
                                ? AppColors.primaryContainer
                                : AppColors.fieldFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_currentPage + 1} of $_totalPages',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildBasicInfoPage(theme),
                  _buildGoalPage(theme),
                  _buildExperiencePage(theme),
                  _buildDietPage(theme),
                  _buildEquipmentPage(theme),
                ],
              ),
            ),

            // Transactional footer
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                    )
                  else
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip for now'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? _nextPage
                        : _completeOnboarding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_currentPage < _totalPages - 1 ? 'Next' : 'Start'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Page headers --------------------------------------------------------

  Widget _pageHeader(ThemeData theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ---- Step 1: About You ---------------------------------------------------

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(theme, 'About You',
              'We need some basic info to personalize your fitness plan and optimize your results.'),
          const SizedBox(height: 24),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Name'),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Alex Carter'),
                ),
                const SizedBox(height: 16),
                _FieldLabel('Age'),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '28'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Weight (kg)'),
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: '78'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Height (cm)'),
                          TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: '182'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _FieldLabel('Gender'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Gender.values.map((g) {
                    final label = g.name[0].toUpperCase() + g.name.substring(1);
                    return _PillChip(
                      label: label,
                      selected: _gender == g,
                      onTap: () => setState(() => _gender = g),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Step 2: Your Goal ---------------------------------------------------

  Widget _buildGoalPage(ThemeData theme) {
    const labels = {
      FitnessGoal.loseWeight: ('Lose Weight', 'Reduce body fat while preserving muscle'),
      FitnessGoal.buildMuscle: ('Build Muscle', 'Gain lean muscle mass'),
      FitnessGoal.bodyRecomposition: ('Body Recomposition', 'Lose fat and gain muscle simultaneously'),
      FitnessGoal.improveEndurance: ('Improve Endurance', 'Boost cardiovascular fitness'),
      FitnessGoal.generalFitness: ('General Fitness', 'Overall health and wellness'),
      FitnessGoal.competitionPrep: ('Competition Prep', 'Prepare for physique competition'),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(theme, 'Your Goal', 'What do you want to achieve?'),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.92,
            children: FitnessGoal.values.map((goal) {
              final (title, subtitle) = labels[goal]!;
              return _SelectableCard(
                selected: _goal == goal,
                onTap: () => setState(() => _goal = goal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: _goal == goal
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---- Step 3: Experience Level --------------------------------------------

  Widget _buildExperiencePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(theme, 'Experience Level',
              'Tell us how long you have been training.'),
          const SizedBox(height: 24),
          ...ExperienceLevel.values.map((level) {
            final label =
                level.name[0].toUpperCase() + level.name.substring(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectableCard(
                selected: _experience == level,
                onTap: () => setState(() => _experience = level),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: _experience == level
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (_experience == level)
                      const Icon(Icons.check_circle,
                          color: AppColors.primaryContainer),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SliderRow(
                  label: 'Workout days per week',
                  value: '$_workoutDays days',
                ),
                Slider(
                  value: _workoutDays.toDouble(),
                  min: 2,
                  max: 7,
                  divisions: 5,
                  onChanged: (v) => setState(() => _workoutDays = v.round()),
                ),
                const SizedBox(height: 8),
                _SliderRow(
                  label: 'Session duration',
                  value: '$_sessionMinutes min',
                ),
                Slider(
                  value: _sessionMinutes.toDouble(),
                  min: 30,
                  max: 120,
                  divisions: 6,
                  onChanged: (v) => setState(() => _sessionMinutes = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Step 4: Diet & Allergies --------------------------------------------

  Widget _buildDietPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(theme, 'Diet & Allergies',
              'We will tailor your meal plan around these.'),
          const SizedBox(height: 24),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Allergies'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergyOptions.map((a) {
                    return _PillChip(
                      label: a,
                      selected: _allergies.contains(a),
                      onTap: () => setState(() {
                        _allergies.contains(a)
                            ? _allergies.remove(a)
                            : _allergies.add(a);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _FieldLabel('Dietary Preferences'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dietOptions.map((d) {
                    return _PillChip(
                      label: d,
                      selected: _dietaryPreferences.contains(d),
                      onTap: () => setState(() {
                        _dietaryPreferences.contains(d)
                            ? _dietaryPreferences.remove(d)
                            : _dietaryPreferences.add(d);
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Step 5: Equipment ---------------------------------------------------

  Widget _buildEquipmentPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(theme, 'Equipment',
              'What equipment do you have access to?'),
          const SizedBox(height: 24),
          _Card(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((e) {
                return _PillChip(
                  label: e,
                  selected: _equipment.contains(e),
                  onTap: () => setState(() {
                    _equipment.contains(e)
                        ? _equipment.remove(e)
                        : _equipment.add(e);
                  }),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Navigation ----------------------------------------------------------

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
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

// ---- Reusable kinetic widgets ----------------------------------------------

/// White card with the soft, blue-tinted ambient shadow.
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        boxShadow: kAmbientShadow,
      ),
      child: child,
    );
  }
}

/// Tappable card with a selected state (primary border + 10% tint).
class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.child,
    required this.selected,
    required this.onTap,
  });
  final Widget child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryContainer.withOpacity(0.10)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.outlineVariant,
          width: 2,
        ),
        boxShadow: kAmbientShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}

/// Pill-shaped selectable chip (white default, primary tint when selected).
class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer.withOpacity(0.10)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryContainer,
          ),
        ),
      ],
    );
  }
}
