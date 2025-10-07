// today_card.dart
// Card principale "Sessione di Oggi" con CTA primaria

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Card per la sessione di oggi
/// Focus principale della Home - azione immediata
class TodayCard extends StatelessWidget {
  const TodayCard({
    required this.session,
    required this.onStart,
    required this.onReview,
    super.key,
  });

  final TodaySession session;
  final VoidCallback onStart;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            CupertinoColors.activeBlue,
            Color(0xFF0051D5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: CupertinoColors.activeBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              if (session.isCompleted)
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: CupertinoColors.white,
                  size: 28,
                )
              else
                const Icon(
                  CupertinoIcons.play_circle,
                  color: CupertinoColors.white,
                  size: 28,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  session.isCompleted ? 'Completata oggi!' : 'Sessione di Oggi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titolo sessione
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Durata
          Row(
            children: <Widget>[
              const Icon(
                CupertinoIcons.clock,
                color: CupertinoColors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${session.durationMin} minuti',
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Warning se ha saltato sessione
          if (session.hasMissedSession && !session.isCompleted) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: CupertinoColors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sessione saltata da recuperare',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // CTA
          if (session.isCompleted)
            // Se già completata, mostra solo rivedi
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: CupertinoColors.white,
                onPressed: onReview,
                child: const Text(
                  'Rivedi Esercizi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            )
          else
            // Altrimenti mostra Avvia + Rivedi
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: CupertinoColors.white,
                    onPressed: onStart,
                    child: const Text(
                      'Avvia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: CupertinoColors.white.withValues(alpha: 0.2),
                    onPressed: onReview,
                    child: const Text(
                      'Rivedi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
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
