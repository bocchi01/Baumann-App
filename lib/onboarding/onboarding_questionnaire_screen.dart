import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/main_screen.dart';
import 'onboarding_controller.dart';
import 'steps/goal_step.dart';
import 'steps/lifestyle_step.dart';
import 'steps/pain_conditions_step.dart';
import 'steps/time_availability_step.dart';

/// Schermata principale del questionario onboarding multi-step
class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final state = ref.read(onboardingControllerProvider);

    if (!state.canProceedToNext) {
      _showValidationError();
      return;
    }

    if (state.currentStep < OnboardingState.totalSteps - 1) {
      controller.nextStep();
      _pageController.animateToPage(
        state.currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Ultimo step: completa onboarding
      _completeOnboarding();
    }
  }

  void _handleBack() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final state = ref.read(onboardingControllerProvider);

    if (state.currentStep > 0) {
      controller.previousStep();
      _pageController.animateToPage(
        state.currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showValidationError() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Selezione Obbligatoria'),
        content: const Text('Seleziona un\'opzione per continuare.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final success = await controller.completeOnboarding();

    if (!mounted) return;

    if (success) {
      // Naviga a MainScreen
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      // Mostra errore
      final state = ref.read(onboardingControllerProvider);
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Errore'),
          content: Text(state.errorMessage ?? 'Errore sconosciuto'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: state.currentStep > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: state.isLoading ? null : _handleBack,
                child: const Icon(CupertinoIcons.back),
              )
            : null,
        middle: const Text('Configurazione'),
        trailing: Text(
          '${state.currentStep + 1}/${OnboardingState.totalSteps}',
          style: const TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 15,
          ),
        ),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _ProgressBar(progress: state.progress),

            // PageView con gli step
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  GoalStep(),
                  LifestyleStep(),
                  TimeAvailabilityStep(),
                  PainConditionsStep(),
                ],
              ),
            ),

            // Bottom navigation buttons
            _BottomNavigation(
              currentStep: state.currentStep,
              totalSteps: OnboardingState.totalSteps,
              canProceed: state.canProceedToNext,
              isLoading: state.isLoading,
              onNext: _handleNext,
              onBack: _handleBack,
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar animato
class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      color: CupertinoColors.systemGrey5,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          color: const Color(0xFF0A84FF),
        ),
      ),
    );
  }
}

/// Bottom navigation con pulsanti Avanti/Indietro
class _BottomNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _BottomNavigation({
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Pulsante Indietro (solo se non è il primo step)
            if (currentStep > 0)
              Expanded(
                child: CupertinoButton(
                  onPressed: isLoading ? null : onBack,
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Indietro',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            if (currentStep > 0) const SizedBox(width: 16),

            // Pulsante Avanti/Completa
            Expanded(
              flex: currentStep > 0 ? 1 : 2,
              child: CupertinoButton.filled(
                onPressed: isLoading || !canProceed ? null : onNext,
                disabledColor: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : Text(
                        isLastStep ? 'Completa' : 'Avanti',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
