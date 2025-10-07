// adherence_bar.dart
// Widget per mostrare aderenza settimanale con progress bar

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import '../models.dart';

/// Widget che mostra l'aderenza settimanale
/// Barra di progresso + microcopy motivazionale
class AdherenceBar extends StatelessWidget {
  const AdherenceBar({
    required this.data,
    super.key,
  });

  final AdherenceData data;

  @override
  Widget build(BuildContext context) {
    final int percentage = (data.percent * 100).round();
    
    // Microcopy motivazionale basato su performance
    final String message = _getMotivationalMessage(percentage);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Aderenza questa settimana',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              Text(
                '${data.completedThisWeek}/${data.plannedThisWeek}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: data.percent,
                backgroundColor: CupertinoColors.systemGrey4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(percentage),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Microcopy motivazionale
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Messaggio motivazionale basato su performance
  String _getMotivationalMessage(int percentage) {
    if (percentage >= 100) {
      return 'Eccellente! Hai completato tutte le sessioni programmate 🎉';
    } else if (percentage >= 75) {
      return 'Grande lavoro! Stai mantenendo un\'ottima costanza 💪';
    } else if (percentage >= 50) {
      return 'Buon progresso! Cerca di mantenere il ritmo';
    } else if (percentage > 0) {
      return 'Continua così! Ogni sessione è un passo avanti';
    } else {
      return 'Inizia la tua prima sessione questa settimana';
    }
  }

  /// Colore progress bar basato su performance
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
}
