// week_card.dart
// Card riutilizzabile per mostrare i dati di una settimana
// Design pulito stile Runna con focus su progressi e azioni

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'models.dart';
import '../shared/widgets/glass_surface.dart';

/// Card per visualizzare una settimana del programma
/// Mostra progresso, dettagli e azioni disponibili
class WeekCard extends StatelessWidget {
  const WeekCard({
    required this.data,
    required this.onStart,
    required this.onReview,
    super.key,
  });

  final WeekData data;
  final VoidCallback onStart;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = CupertinoTheme.of(context)
        .textTheme
        .navTitleTextStyle
        .copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        );

    final TextStyle phaseStyle = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.activeBlue,
        );

    final TextStyle objectiveStyle = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .copyWith(
          fontSize: 14,
          color: CupertinoColors.secondaryLabel,
          height: 1.4,
        );

    final TextStyle detailStyle = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .copyWith(
          fontSize: 13,
          color: CupertinoColors.secondaryLabel,
        );

    // Percentuale completamento formattata
    final int percentage = (data.completionRatio * 100).round();

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: numero settimana + fase
          Row(
            children: <Widget>[
              Text(
                'SETTIMANA ${data.weekNumber}',
                style: titleStyle,
              ),
              const SizedBox(width: 8),
              // Badge stato visivo
              if (data.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'COMPLETATA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                )
              else if (data.isInProgress)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IN CORSO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Fase titolo
          Text(data.phaseTitle, style: phaseStyle),
          const SizedBox(height: 8),

          // Obiettivo della settimana (microcopy coach)
          Text(data.objective, style: objectiveStyle),
          const SizedBox(height: 12),

          // Dettagli: sessioni e durata
          Text(
            '${data.sessionsTotal} sessioni • ${data.sessionDuration} min ciascuna',
            style: detailStyle,
          ),
          const SizedBox(height: 12),

          // Progress bar + percentuale
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: data.completionRatio,
                      backgroundColor: CupertinoColors.systemGrey5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        data.isCompleted
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Completate: ${data.sessionsCompleted}/${data.sessionsTotal}',
                style: detailStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: detailStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: data.isCompleted
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottoni azione: garantiscono touch target ≥44px
          Row(
            children: <Widget>[
              // Bottone primario: Avvia (se non completata)
              if (!data.isCompleted)
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: onStart,
                    child: const Text(
                      'Avvia',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemGreen,
                    onPressed: onReview,
                    child: const Text(
                      'Rivedi Sessioni',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Bottone secondario: Rivedi esercizi
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemGrey5,
                  onPressed: onReview,
                  child: Text(
                    'Rivedi Esercizi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
