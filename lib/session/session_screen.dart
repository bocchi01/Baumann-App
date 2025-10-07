// session_screen.dart
// Stub per schermata di sessione allenamento
// Pronto per essere esteso con logica di esecuzione esercizi

import 'package:flutter/cupertino.dart';

/// Schermata di una singola sessione di allenamento
/// Stub funzionante per navigazione e flow base
class SessionScreen extends StatelessWidget {
  const SessionScreen({
    required this.weekNumber,
    required this.sessionIndex,
    required this.sessionDuration,
    super.key,
  });

  final int weekNumber;
  final int sessionIndex;
  final int sessionDuration;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Settimana $weekNumber'),
        previousPageTitle: 'Programma',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 32),

              // Titolo sessione
              Text(
                'Sessione ${sessionIndex + 1}',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navLargeTitleTextStyle
                    .copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),

              // Durata
              Text(
                '$sessionDuration minuti',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 17,
                      color: CupertinoColors.secondaryLabel,
                    ),
              ),
              const SizedBox(height: 32),

              // Descrizione placeholder (tono coach)
              Text(
                'Questa sessione ti guiderà attraverso esercizi mirati per il tuo obiettivo. Prepara uno spazio comodo e segui le indicazioni.',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: CupertinoColors.label,
                    ),
              ),

              const Spacer(),

              // CTA: Avvia sessione (stub)
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () => _completeSession(context),
                  child: const Text(
                    'Avvia Sessione',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottone secondario: Anteprima esercizi
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () => _showExercisePreview(context),
                  child: const Text(
                    'Anteprima Esercizi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Simula il completamento della sessione
  /// In produzione, qui ci sarebbe la logica di tracking e salvataggio
  void _completeSession(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Sessione Completata'),
          content: const Text(
            'Ottimo lavoro! I tuoi progressi sono stati salvati.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Chiudi dialog
                Navigator.of(context).pop(true); // Torna al programma con success
              },
              isDefaultAction: true,
              child: const Text('Continua'),
            ),
          ],
        );
      },
    );
  }

  /// Mostra un'anteprima degli esercizi (stub)
  void _showExercisePreview(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Esercizi della Sessione'),
          message: const Text(
            'Qui vedrai l\'elenco degli esercizi con descrizioni brevi.',
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }
}
