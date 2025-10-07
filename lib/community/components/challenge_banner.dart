// challenge_banner.dart
// Banner per la sfida settimanale nella bacheca

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Banner per la sfida settimanale
/// Mostra titolo, descrizione e CTA per partecipare
class ChallengeBanner extends StatelessWidget {
  const ChallengeBanner({
    required this.challenge,
    required this.onParticipate,
    super.key,
  });

  final Challenge challenge;
  final VoidCallback onParticipate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFF6B35),
            Color(0xFFFF8C42),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header con icona
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🏆',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Sfida della Settimana',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      'Finisce tra ${challenge.daysRemaining} giorni',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titolo
          Text(
            challenge.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Descrizione
          Text(
            challenge.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Footer con partecipanti e CTA
          Row(
            children: <Widget>[
              // Partecipanti
              Expanded(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.person_2,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${challenge.participantsCount} partecipanti',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // CTA
              if (!challenge.isUserParticipating)
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: onParticipate,
                  child: const Text(
                    'Partecipa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        CupertinoIcons.check_mark,
                        color: CupertinoColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Partecipi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
