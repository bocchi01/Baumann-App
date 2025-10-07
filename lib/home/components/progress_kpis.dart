// progress_kpis.dart
// Indicatori chiave di performance (aderenza + comfort)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import '../models.dart';

/// Widget KPI per mostrare progresso settimanale
/// Aderenza + trend comfort
class ProgressKpis extends StatelessWidget {
  const ProgressKpis({
    required this.stats,
    super.key,
  });

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final int percentage = (stats.completionRatio * 100).round();

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
                CupertinoIcons.chart_bar,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              SizedBox(width: 8),
              Text(
                'Progressi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Aderenza
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Completate',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              Text(
                '${stats.completed}/${stats.planned}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: stats.completionRatio,
                backgroundColor: CupertinoColors.systemGrey4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(percentage),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stats.percentFormatted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _getProgressColor(percentage),
            ),
          ),

          const SizedBox(height: 16),

          // Trend comfort
          Row(
            children: <Widget>[
              Icon(
                _getComfortIcon(stats.comfortTrend),
                size: 18,
                color: _getComfortColor(stats.comfortTrend),
              ),
              const SizedBox(width: 8),
              const Text(
                'Comfort:',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                stats.comfortTrend.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _getComfortColor(stats.comfortTrend),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Colore progress bar basato su percentuale
  Color _getProgressColor(int percentage) {
    if (percentage >= 75) {
      return CupertinoColors.systemGreen;
    } else if (percentage >= 50) {
      return CupertinoColors.activeBlue;
    } else if (percentage > 0) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.systemGrey;
    }
  }

  /// Icona per trend comfort
  IconData _getComfortIcon(ComfortTrendValue trend) {
    switch (trend) {
      case ComfortTrendValue.better:
        return CupertinoIcons.arrow_up_circle_fill;
      case ComfortTrendValue.same:
        return CupertinoIcons.arrow_right_circle_fill;
      case ComfortTrendValue.worse:
        return CupertinoIcons.arrow_down_circle_fill;
    }
  }

  /// Colore per trend comfort
  Color _getComfortColor(ComfortTrendValue trend) {
    switch (trend) {
      case ComfortTrendValue.better:
        return CupertinoColors.systemGreen;
      case ComfortTrendValue.same:
        return CupertinoColors.systemYellow;
      case ComfortTrendValue.worse:
        return CupertinoColors.systemOrange;
    }
  }
}
