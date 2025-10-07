// program_overview_screen.dart
// Schermata principale della sezione Programma
// Overview del percorso personalizzato con timeline settimanale

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'fake_repository.dart';
import 'models.dart';
import 'week_card.dart';
import '../session/session_screen.dart';
import '../shared/widgets/glass_surface.dart';

/// Schermata overview del programma personalizzato
/// Mostra progressi, KPI e timeline delle settimane
class ProgramOverviewScreen extends StatefulWidget {
  const ProgramOverviewScreen({super.key});

  @override
  State<ProgramOverviewScreen> createState() => _ProgramOverviewScreenState();
}

class _ProgramOverviewScreenState extends State<ProgramOverviewScreen> {
  final FakeProgramRepository _repository = FakeProgramRepository();

  @override
  Widget build(BuildContext context) {
    final ProgramData program = _repository.getProgram();
    final List<WeekData> weeks = _repository.getWeeks();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          // Navigation bar con large title
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Programma'),
            border: null,
          ),

          // Header del percorso
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: _buildProgramHeader(context, program),
            ),
          ),

          // Timeline delle settimane
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index >= weeks.length) return null;

                final WeekData week = weeks[index];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: WeekCard(
                    data: week,
                    onStart: () => _startSession(context, week),
                    onReview: () => _reviewExercises(context, week),
                  ),
                );
              },
              childCount: weeks.length,
            ),
          ),

          // Footer con link progressi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: _buildFooter(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Header con info programma, KPI e CTA principali
  Widget _buildProgramHeader(BuildContext context, ProgramData program) {
    final TextStyle titleStyle = CupertinoTheme.of(context)
        .textTheme
        .navLargeTitleTextStyle
        .copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        );

    final TextStyle subtitleStyle = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .copyWith(
          fontSize: 16,
          color: CupertinoColors.secondaryLabel,
          height: 1.4,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Titolo percorso
        Text('Il tuo percorso', style: subtitleStyle),
        const SizedBox(height: 8),
        Text(program.title, style: titleStyle),
        const SizedBox(height: 8),
        Text(program.subtitle, style: subtitleStyle),
        const SizedBox(height: 24),

        // KPI Cards
        _buildKPISection(context, program),
        const SizedBox(height: 24),

        // CTA principali
        _buildMainCTAs(context),
      ],
    );
  }

  /// Sezione KPI con metriche chiave
  Widget _buildKPISection(BuildContext context, ProgramData program) {
    final int weekPercentage = (program.completionRatio * 100).round();
    final int adherencePercentage = (program.adherenceRatio * 100).round();

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Progressi settimane
          _buildKPIRow(
            'Completate',
            '${program.completedWeeks}/${program.totalWeeks} settimane',
          ),
          const SizedBox(height: 8),
          // Progress bar settimane
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: program.completionRatio,
                backgroundColor: CupertinoColors.systemGrey5,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$weekPercentage%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Aderenza sessioni
          _buildKPIRow(
            'Sessioni completate',
            '${program.completedSessions}/${program.totalSessions}',
          ),
          const SizedBox(height: 4),
          Text(
            'Aderenza: $adherencePercentage%',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 16),

          // Tempo medio
          _buildKPIRow(
            'Tempo medio',
            '~${program.avgSessionMinutes} min/sessione',
          ),
        ],
      ),
    );
  }

  /// Singola riga di KPI
  Widget _buildKPIRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// CTA principali: Avvia prossima + Rivedi esercizi
  Widget _buildMainCTAs(BuildContext context) {
    final WeekData? nextWeek = _repository.getNextSession();

    return Column(
      children: <Widget>[
        // Avvia prossima sessione
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: nextWeek != null
                ? () => _startSession(context, nextWeek)
                : null,
            child: Text(
              nextWeek != null
                  ? 'Avvia Prossima Sessione'
                  : 'Programma Completato',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Rivedi esercizi
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: CupertinoColors.systemGrey5,
            onPressed: () => _showExerciseLibrary(context),
            child: Text(
              'Rivedi Esercizi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Footer con link a progressi dettagliati
  Widget _buildFooter(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showProgressDetails(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Vedi progressi dettagliati',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          Icon(CupertinoIcons.chevron_right, size: 16),
        ],
      ),
    );
  }

  // ========== NAVIGATION ACTIONS ==========

  /// Avvia una sessione specifica
  Future<void> _startSession(BuildContext context, WeekData week) async {
    // Determina quale sessione avviare (la prima non completata)
    final int nextSessionIndex = week.sessionsCompleted;

    final bool? completed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => SessionScreen(
          weekNumber: week.weekNumber,
          sessionIndex: nextSessionIndex,
          sessionDuration: week.sessionDuration,
        ),
      ),
    );

    // Verifica mounted prima di usare context dopo async
    if (!mounted) return;

    // Se la sessione è stata completata, aggiorna UI
    if (completed == true) {
      setState(() {
        // In un'app reale, qui si aggiornerebbero i dati dal backend
        // Per ora il refresh dello stato è gestito dal FakeRepository
      });

      // Feedback positivo - safe perché siamo dopo il check mounted
      if (mounted) {
        // ignore: use_build_context_synchronously
        _showCompletionFeedback(context);
      }
    }
  }

  /// Rivedi esercizi di una settimana
  void _reviewExercises(BuildContext context, WeekData week) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: Text('Settimana ${week.weekNumber} - Esercizi'),
          message: Text(week.objective),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                // In produzione, naviga a schermata esercizi
              },
              child: const Text('Vedi Video Dimostrativi'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                // In produzione, apri PDF o guida
              },
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

  /// Mostra libreria completa esercizi (stub)
  void _showExerciseLibrary(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Libreria Esercizi'),
          content: const Text(
            'Qui troverai tutti gli esercizi del programma con video e descrizioni dettagliate.',
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

  /// Mostra progressi dettagliati (stub)
  void _showProgressDetails(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Progressi Dettagliati'),
          content: const Text(
            'Questa schermata mostrerà grafici e statistiche complete del tuo percorso.',
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

  /// Feedback di completamento sessione
  void _showCompletionFeedback(BuildContext context) {
    // Usa uno snackbar-like con dismissible
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
              '✓ Sessione completata!',
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

    // Chiudi automaticamente dopo 2 secondi
    // Cattura navigator prima del delay per evitare warning
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        navigator.pop();
      }
    });
  }
}
