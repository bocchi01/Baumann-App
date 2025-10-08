import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/onboarding_data.dart';
import '../onboarding_controller.dart';

/// Step 4: Selezione condizioni di dolore (opzionale, multi-select)
class PainConditionsStep extends ConsumerWidget {
  const PainConditionsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          const Text(
            'Hai dolori o disagi particolari?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Selezione multipla opzionale per personalizzare il tuo percorso',
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.secondaryLabel,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          ...PainCondition.values.map((condition) {
            final isSelected = state.data.painConditions.contains(condition);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PainConditionCard(
                label: condition.label,
                description: condition.description,
                isSelected: isSelected,
                isNone: condition == PainCondition.none,
                onTap: () => controller.togglePainCondition(condition),
              ),
            );
          }),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.systemYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'In caso di dolore persistente, ti consigliamo di consultare un medico prima di iniziare',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PainConditionCard extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final bool isNone;
  final VoidCallback onTap;

  const _PainConditionCard({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.isNone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isNone
                  ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
                  : const Color(0xFF0A84FF).withValues(alpha: 0.1))
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isNone ? CupertinoColors.systemGreen : const Color(0xFF0A84FF))
                : CupertinoColors.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox/Icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isNone
                        ? CupertinoColors.systemGreen
                        : const Color(0xFF0A84FF))
                    : CupertinoColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isNone
                          ? CupertinoColors.systemGreen
                          : const Color(0xFF0A84FF))
                      : CupertinoColors.systemGrey4,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: CupertinoColors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Testo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isNone
                              ? CupertinoColors.systemGreen
                              : const Color(0xFF0A84FF))
                          : CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                      height: 1.3,
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
}
