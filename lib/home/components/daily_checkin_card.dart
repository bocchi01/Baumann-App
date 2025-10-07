// daily_checkin_card.dart
// Card per il check-in quotidiano "Come ti senti oggi?"

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Card per il check-in quotidiano
/// Permette all'utente di esprimere come si sente
class DailyCheckinCard extends StatefulWidget {
  const DailyCheckinCard({
    required this.checkin,
    required this.onCheckin,
    super.key,
  });

  final DailyCheckin checkin;
  final ValueChanged<DailyFeelingValue> onCheckin;

  @override
  State<DailyCheckinCard> createState() => _DailyCheckinCardState();
}

class _DailyCheckinCardState extends State<DailyCheckinCard> {
  DailyFeelingValue? _selectedFeeling;

  @override
  void initState() {
    super.initState();
    _selectedFeeling = widget.checkin.todayFeeling;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCheckedIn = widget.checkin.hasCheckedInToday;

    return Container(
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
          // Header
          Row(
            children: <Widget>[
              Icon(
                hasCheckedIn
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.heart,
                color: hasCheckedIn
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemPink,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasCheckedIn ? 'Check-in completato' : 'Come ti senti oggi?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
          
          if (!hasCheckedIn) ...<Widget>[
            const SizedBox(height: 12),
            const Text(
              'Il tuo feedback ci aiuta a personalizzare il percorso',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Opzioni feeling
          if (hasCheckedIn && _selectedFeeling != null)
            // Mostra solo la scelta fatta
            _buildFeelingChip(
              feeling: _selectedFeeling!,
              isSelected: true,
              enabled: false,
            )
          else
            // Mostra tutte le opzioni
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildFeelingChip(
                    feeling: DailyFeelingValue.good,
                    isSelected: _selectedFeeling == DailyFeelingValue.good,
                    enabled: !hasCheckedIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFeelingChip(
                    feeling: DailyFeelingValue.stiff,
                    isSelected: _selectedFeeling == DailyFeelingValue.stiff,
                    enabled: !hasCheckedIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFeelingChip(
                    feeling: DailyFeelingValue.sore,
                    isSelected: _selectedFeeling == DailyFeelingValue.sore,
                    enabled: !hasCheckedIn,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Singolo chip per opzione feeling
  Widget _buildFeelingChip({
    required DailyFeelingValue feeling,
    required bool isSelected,
    required bool enabled,
  }) {
    // Emoji e colore per ogni opzione
    final String emoji;
    final Color color;

    switch (feeling) {
      case DailyFeelingValue.good:
        emoji = '😊';
        color = CupertinoColors.systemGreen;
        break;
      case DailyFeelingValue.stiff:
        emoji = '😐';
        color = CupertinoColors.systemYellow;
        break;
      case DailyFeelingValue.sore:
        emoji = '😕';
        color = CupertinoColors.systemOrange;
        break;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled
          ? () {
              setState(() => _selectedFeeling = feeling);
              widget.onCheckin(feeling);
              _showCheckinFeedback();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : CupertinoColors.separator,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              feeling.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Feedback dopo il check-in
  void _showCheckinFeedback() {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✓ Grazie per il feedback!',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    // Chiudi automaticamente
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}
