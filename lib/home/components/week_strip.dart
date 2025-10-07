// week_strip.dart
// Striscia orizzontale con i 7 giorni della settimana

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Striscia settimanale con status dei 7 giorni
/// Mostra visivamente il progresso settimanale
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.days,
    required this.onDayTap,
    super.key,
  });

  final List<WeekDayStatus> days;
  final ValueChanged<WeekDayStatus> onDayTap;

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.calendar,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              SizedBox(width: 8),
              Text(
                'Questa Settimana',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Striscia giorni
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days
                .map((day) => _buildDayItem(context, day))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Singolo elemento giorno
  Widget _buildDayItem(BuildContext context, WeekDayStatus day) {
    // Colore e icona basati su status
    final Color color;
    final IconData icon;

    switch (day.status) {
      case WeekDayStatusValue.done:
        color = CupertinoColors.systemGreen;
        icon = CupertinoIcons.check_mark_circled_solid;
        break;
      case WeekDayStatusValue.skipped:
        color = CupertinoColors.systemOrange;
        icon = CupertinoIcons.minus_circled;
        break;
      case WeekDayStatusValue.planned:
        color = CupertinoColors.systemGrey;
        icon = CupertinoIcons.circle;
        break;
      case WeekDayStatusValue.recover:
        color = CupertinoColors.systemBlue;
        icon = CupertinoIcons.arrow_clockwise_circle;
        break;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onDayTap(day),
      child: Container(
        width: 44, // Touch target minimo
        height: 66,
        decoration: BoxDecoration(
          color: day.isToday
              ? color.withValues(alpha: 0.15)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: day.isToday ? color : CupertinoColors.separator,
            width: day.isToday ? 2 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Nome giorno
            Text(
              day.dayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
                color: day.isToday
                    ? color
                    : CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 4),

            // Numero giorno
            Text(
              '${day.dayNumber}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: day.isToday
                    ? color
                    : CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 4),

            // Icona status
            Icon(
              icon,
              size: 18,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
