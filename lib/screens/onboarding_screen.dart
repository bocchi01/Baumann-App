import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../controllers/onboarding_controller.dart';
import '../theme/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pageCount = 3;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleNext(OnboardingState state) {
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
    } else {
      ref.read(onboardingControllerProvider.notifier).submitOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benvenuto in Posture Coach'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                  },
                  children: <Widget>[
                    _GoalPage(selectedValue: state.goal),
                    _LifestylePage(selectedValue: state.lifestyle),
                    _TimePage(selectedValue: state.time),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pageCount,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                  dotColor: colorScheme.primary.withValues(alpha: 0.2),
                  activeDotColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      state.isSubmitting ? null : () => _handleNext(state),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          _currentPage == _pageCount - 1
                              ? 'Crea il mio percorso'
                              : 'Avanti',
                        ),
                ),
              ),
              if (_currentPage > 0)
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _goToPage(_currentPage - 1),
                  child: const Text('Indietro'),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalPage extends ConsumerWidget {
  const _GoalPage({required this.selectedValue});

  final String? selectedValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<_AnswerOption> options = <_AnswerOption>[
      _AnswerOption(label: 'Prevenire futuri dolori', value: 'prevenzione'),
      _AnswerOption(label: 'Alleviare un dolore attuale', value: 'alleviare'),
      _AnswerOption(
          label: 'Migliorare la postura generale', value: 'migliorare'),
    ];

    return _QuestionLayout(
      title: 'Qual è il tuo obiettivo principale?',
      description: 'Aiutaci a personalizzare il tuo percorso posturale.',
      options: options,
      selectedValue: selectedValue,
      onSelect: (String value) =>
          ref.read(onboardingControllerProvider.notifier).setGoal(value),
    );
  }
}

class _LifestylePage extends ConsumerWidget {
  const _LifestylePage({required this.selectedValue});

  final String? selectedValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<_AnswerOption> options = <_AnswerOption>[
      _AnswerOption(label: 'Prevalentemente sedentario', value: 'sedentario'),
      _AnswerOption(label: 'Moderatamente attivo', value: 'moderato'),
      _AnswerOption(label: 'Molto attivo', value: 'attivo'),
    ];

    return _QuestionLayout(
      title: 'Come descriveresti il tuo stile di vita?',
      description:
          'Capire il tuo livello di attività ci aiuta ad adattare il ritmo.',
      options: options,
      selectedValue: selectedValue,
      onSelect: (String value) =>
          ref.read(onboardingControllerProvider.notifier).setLifestyle(value),
    );
  }
}

class _TimePage extends ConsumerWidget {
  const _TimePage({required this.selectedValue});

  final String? selectedValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<_AnswerOption> options = <_AnswerOption>[
      _AnswerOption(label: '15 minuti al giorno', value: '15min'),
      _AnswerOption(label: '30 minuti al giorno', value: '30min'),
      _AnswerOption(label: '45+ minuti al giorno', value: '45min'),
    ];

    return _QuestionLayout(
      title: 'Quanto tempo puoi dedicare al giorno?',
      description: 'Scegli una durata realistica per la tua routine.',
      options: options,
      selectedValue: selectedValue,
      onSelect: (String value) =>
          ref.read(onboardingControllerProvider.notifier).setTime(value),
    );
  }
}

class _QuestionLayout extends StatelessWidget {
  const _QuestionLayout({
    required this.title,
    required this.description,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  final String title;
  final String description;
  final List<_AnswerOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final _AnswerOption option = options[index];
              final bool isSelected = option.value == selectedValue;
              return _OptionTile(
                label: option.label,
                isSelected: isSelected,
                onTap: () => onSelect(option.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnswerOption {
  const _AnswerOption({required this.label, required this.value});

  final String label;
  final String value;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surface,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
