// agenda_card.dart
// Card agenda con promemoria + banner recupero sessione

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Card agenda con promemoria e azioni
/// Mostra promemoria + banner recupero se necessario
class AgendaCard extends StatelessWidget {
  const AgendaCard({
    required this.reminder,
    required this.hasMissedSession,
    required this.onReminderToggle,
    required this.onRecoverSession,
    super.key,
  });

  final ReminderPref reminder;
  final bool hasMissedSession;
  final ValueChanged<bool> onReminderToggle;
  final VoidCallback onRecoverSession;

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
                CupertinoIcons.calendar_today,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              SizedBox(width: 8),
              Text(
                'Agenda',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Promemoria con switch
          Row(
            children: <Widget>[
              const Icon(
                CupertinoIcons.bell,
                size: 20,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: reminder.enabled,
                onChanged: onReminderToggle,
              ),
            ],
          ),

          // Banner recupero (se necessario)
          if (hasMissedSession) ...<Widget>[
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onRecoverSession,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      CupertinoColors.systemOrange,
                      Color(0xFFFF9500),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.arrow_clockwise_circle_fill,
                      color: CupertinoColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Recupera Sessione',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pianifica la sessione saltata',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
