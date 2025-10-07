// home_screen.dart
// Schermata Home - Cruscotto motivazionale focalizzato sull'azione
// Mostra sessione oggi, check-in, week strip, progressi e agenda

import 'package:flutter/cupertino.dart';
import 'components/today_card.dart';
import 'components/daily_checkin_card.dart';
import 'components/week_strip.dart';
import 'components/progress_kpis.dart';
import 'components/agenda_card.dart';
import 'fake_repository.dart';
import 'models.dart';
import '../session/session_screen.dart';

/// Schermata Home - Focus sull'azione immediata
/// Cruscotto quotidiano con motivazione e tracking
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onScrollNotification,
    required this.onOpenSettings,
    required this.onShowNotifications,
    required this.onShowStats,
    required this.avatarInitials,
    super.key,
  });

  final bool Function(UserScrollNotification) onScrollNotification;
  final VoidCallback onOpenSettings;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowStats;
  final String avatarInitials;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FakeHomeRepository _repository = FakeHomeRepository();

  @override
  Widget build(BuildContext context) {
    // Carica dati dal repository
    final TodaySession todaySession = _repository.getTodaySession();
    final List<WeekDayStatus> weekDays = _repository.getWeekStatus();
    final ProgressStats stats = _repository.getProgressStats();
    final ReminderPref reminder = _repository.getReminder();
    final DailyCheckin checkin = _repository.getDailyCheckin();

    return NotificationListener<UserScrollNotification>(
      onNotification: widget.onScrollNotification,
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            // Navigation bar con avatar e azioni
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Home'),
              leading: _AvatarButton(
                initials: widget.avatarInitials,
                onTap: widget.onOpenSettings,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onShowNotifications,
                    child: const Icon(CupertinoIcons.bell),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onShowStats,
                    child: const Icon(CupertinoIcons.chart_bar_alt_fill),
                  ),
                ],
              ),
              border: null,
            ),

            // 1. Sessione di Oggi (azione primaria)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: TodayCard(
                session: todaySession,
                onStart: () => _startSession(context, todaySession),
                onReview: () => _reviewExercises(context),
              ),
            ),
          ),

          // 2. Check-in Quotidiano
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DailyCheckinCard(
                checkin: checkin,
                onCheckin: (DailyFeelingValue feeling) =>
                    _handleCheckin(feeling),
              ),
            ),
          ),

          // 3. Week Strip (striscia settimanale)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: WeekStrip(
                days: weekDays,
                onDayTap: (WeekDayStatus day) => _showDayDetails(context, day),
              ),
            ),
          ),

          // 4. KPI Progressi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: ProgressKpis(stats: stats),
            ),
          ),

          // 5. Agenda (promemoria + recupero)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: AgendaCard(
                reminder: reminder,
                hasMissedSession: todaySession.hasMissedSession,
                onReminderToggle: (bool enabled) =>
                    _toggleReminder(enabled),
                onRecoverSession: () => _recoverSession(context),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ========== ACTIONS ==========

  /// Avvia sessione di oggi
  Future<void> _startSession(
    BuildContext context,
    TodaySession session,
  ) async {
    final bool? completed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => const SessionScreen(
          weekNumber: 2,
          sessionIndex: 1,
          sessionDuration: 12,
        ),
      ),
    );

    if (!mounted) return;

    if (completed == true) {
      setState(() {
        // In produzione, qui si aggiornerebbero i dati dal backend
      });

      // Feedback positivo
      _showCompletionFeedback();
    }
  }

  /// Rivedi esercizi
  void _reviewExercises(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Esercizi del Programma'),
          message: const Text(
            'Rivedi gli esercizi della tua sessione',
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Vedi Video Dimostrativi'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Scarica Guida PDF'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(modalContext).pop(),
            isDestructiveAction: true,
            child: const Text('Chiudi'),
          ),
        );
      },
    );
  }

  /// Gestisce check-in quotidiano
  void _handleCheckin(DailyFeelingValue feeling) {
    // In produzione, salva il feeling nel backend
    debugPrint('Check-in: ${feeling.label}');
    
    setState(() {
      // Aggiorna UI
    });
  }

  /// Mostra dettagli di un giorno
  void _showDayDetails(BuildContext context, WeekDayStatus day) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text('${day.dayName} ${day.dayNumber}'),
          content: Text(
            'Status: ${day.status.label}\n\n'
            '${_getDayMessage(day.status)}',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Messaggio per status giorno
  String _getDayMessage(WeekDayStatusValue status) {
    switch (status) {
      case WeekDayStatusValue.done:
        return 'Sessione completata con successo! 🎉';
      case WeekDayStatusValue.skipped:
        return 'Sessione saltata. Puoi recuperarla.';
      case WeekDayStatusValue.planned:
        return 'Sessione pianificata.';
      case WeekDayStatusValue.recover:
        return 'Giorno di recupero programmato.';
    }
  }

  /// Toggle promemoria
  void _toggleReminder(bool enabled) {
    // In produzione, salva le preferenze
    debugPrint('Promemoria ${enabled ? 'attivato' : 'disattivato'}');
    
    setState(() {
      // Aggiorna UI
    });

    // Feedback leggero
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: enabled
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              enabled ? 'Promemoria attivato' : 'Promemoria disattivato',
              style: const TextStyle(
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

    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  /// Recupera sessione saltata
  void _recoverSession(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Recupera Sessione Saltata'),
          message: const Text('Quando vuoi recuperare la sessione?'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _startSession(context, _repository.getTodaySession());
              },
              child: const Text('Ora'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _scheduleRecovery(context, 'Stasera');
              },
              child: const Text('Stasera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _scheduleRecovery(context, 'Domani');
              },
              child: const Text('Domani'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _scheduleRecovery(context, 'Questo weekend');
              },
              child: const Text('Questo Weekend'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(modalContext).pop(),
            isDestructiveAction: true,
            child: const Text('Annulla'),
          ),
        );
      },
    );
  }

  /// Pianifica recupero
  void _scheduleRecovery(BuildContext context, String when) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Sessione Pianificata'),
          content: Text('Ti ricorderemo di recuperare la sessione $when'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Feedback completamento sessione
  void _showCompletionFeedback() {
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
              '🎉 Sessione completata!\nOttimo lavoro!',
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

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}

/// Widget avatar per navigation bar
class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.initials,
    required this.onTap,
  });

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: CupertinoColors.activeBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
