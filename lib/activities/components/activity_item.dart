// activity_item.dart
// Widget per mostrare singola voce del registro attività

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Widget per mostrare una voce del registro
/// Icona stato + dettagli + azioni rapide
class ActivityItem extends StatelessWidget {
  const ActivityItem({
    required this.entry,
    required this.onTap,
    required this.onEdit,
    super.key,
  });

  final ActivityEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoTheme.brightnessOf(context) == Brightness.dark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemGrey6.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoTheme.brightnessOf(context) == Brightness.dark
                ? CupertinoColors.separator.darkColor
                : CupertinoColors.separator.color,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header: icona status + titolo + durata
            Row(
              children: <Widget>[
                // Icona status
                _buildStatusIcon(entry.status),
                const SizedBox(width: 12),

                // Titolo
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),

                // Durata
                Text(
                  '${entry.durationMin} min',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Data + ora
            Row(
              children: <Widget>[
                const Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 6),
                Text(
                  entry.formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  CupertinoIcons.clock,
                  size: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 6),
                Text(
                  entry.formattedTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),

            // Comfort level (se presente)
            if (entry.comfort != null) ...<Widget>[
              const SizedBox(height: 8),
              _buildComfortRow(entry.comfort!),
            ],

            // Note (se presenti)
            if (entry.notes != null && entry.notes!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                entry.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Azioni rapide (solo per sessioni completate)
            if (entry.status == ActivityStatus.done) ...<Widget>[
              const SizedBox(height: 12),
              _buildQuickActions(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Icona status con colore appropriato
  Widget _buildStatusIcon(ActivityStatus status) {
    final IconData icon;
    final Color color;

    switch (status) {
      case ActivityStatus.done:
        icon = CupertinoIcons.check_mark_circled_solid;
        color = CupertinoColors.systemGreen;
        break;
      case ActivityStatus.skipped:
        icon = CupertinoIcons.minus_circled;
        color = CupertinoColors.systemOrange;
        break;
      case ActivityStatus.stopped:
        icon = CupertinoIcons.xmark_circle;
        color = CupertinoColors.systemRed;
        break;
      case ActivityStatus.planned:
        icon = CupertinoIcons.circle;
        color = CupertinoColors.systemGrey;
        break;
    }

    return Icon(icon, size: 28, color: color);
  }

  /// Riga comfort level con emoji
  Widget _buildComfortRow(ComfortLevel comfort) {
    final String emoji;
    final Color color;

    switch (comfort) {
      case ComfortLevel.better:
        emoji = '😊';
        color = CupertinoColors.systemGreen;
        break;
      case ComfortLevel.same:
        emoji = '😐';
        color = CupertinoColors.systemYellow;
        break;
      case ComfortLevel.worse:
        emoji = '😕';
        color = CupertinoColors.systemRed;
        break;
    }

    return Row(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          'Comfort: ${comfort.label}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Azioni rapide (Ripeti, Condividi)
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            onPressed: onEdit,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  CupertinoIcons.arrow_clockwise,
                  size: 16,
                  color: CupertinoColors.activeBlue,
                ),
                SizedBox(width: 6),
                Text(
                  'Ripeti',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: CupertinoColors.systemGrey5,
            onPressed: () => _shareActivity(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  CupertinoIcons.share,
                  size: 16,
                  color: CupertinoColors.label,
                ),
                SizedBox(width: 6),
                Text(
                  'Condividi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Condividi attività (stub)
  void _shareActivity(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Condividi Attività'),
          content: Text('Condividi "${entry.title}" con i tuoi contatti?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
              child: const Text('Condividi'),
            ),
          ],
        );
      },
    );
  }
}
