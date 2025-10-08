import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/onboarding_data.dart';
import '../onboarding_controller.dart';

/// Step 3: Selezione tempo disponibile
class TimeAvailabilityStep extends ConsumerWidget {
  const TimeAvailabilityStep({super.key});

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
            'Quanto tempo puoi dedicare?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Scegli la durata ideale per le tue sessioni quotidiane',
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.secondaryLabel,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          ...TimeAvailability.values.map((time) {
            final isSelected = state.data.timeAvailability == time;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TimeCard(
                label: time.label,
                description: time.description,
                minutes: time.minutes,
                isSelected: isSelected,
                onTap: () => controller.setTimeAvailability(time),
              ),
            );
          }),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.lightbulb,
                  color: Color(0xFF0A84FF),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Consigliamo almeno 10 minuti al giorno per risultati visibili',
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

class _TimeCard extends StatelessWidget {
  final String label;
  final String description;
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeCard({
    required this.label,
    required this.description,
    required this.minutes,
    required this.isSelected,
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
              ? const Color(0xFF0A84FF).withValues(alpha: 0.1)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0A84FF)
                : CupertinoColors.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0A84FF).withValues(alpha: 0.15)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: const Icon(
                  CupertinoIcons.clock,
                  color: Color(0xFF0A84FF),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                          ? const Color(0xFF0A84FF)
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
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: Color(0xFF0A84FF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
