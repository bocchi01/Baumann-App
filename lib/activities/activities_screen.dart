// activities_screen.dart
// Schermata principale sezione Attività (diario operativo quotidiano)
// Focus su "cosa fare oggi" + storico attività

import 'package:flutter/cupertino.dart';
import 'components/activity_item.dart';
import 'components/adherence_bar.dart';
import 'components/reminder_row.dart';
import 'fake_repository.dart';
import 'models.dart';
import '../session/session_screen.dart';

/// Schermata Attività - Diario operativo quotidiano
/// Separata dalla pianificazione strategica del Programma
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final FakeActivityRepository _repository = FakeActivityRepository();
  ActivityStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final TodayPlan todayPlan = _repository.getTodayPlan();
    final AdherenceData adherence = _repository.getAdherence();
    final ReminderPref reminder = _repository.getReminder();
    final List<ActivityEntry> allActivities = _repository.getActivities();
    
    // Applica filtro se selezionato
    final List<ActivityEntry> filteredActivities =
        _repository.filterByStatus(allActivities, _selectedFilter);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          // Navigation bar
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Attività'),
            border: null,
          ),

          // Card "Oggi" - cosa fare adesso
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _buildTodayCard(context, todayPlan),
            ),
          ),

          // Barra aderenza settimanale
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: AdherenceBar(data: adherence),
            ),
          ),

          // Filtri registro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildFilters(context),
            ),
          ),

          // Header registro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Registro Attività',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${filteredActivities.length} voci',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista attività
          if (filteredActivities.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'Nessuna attività trovata',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index >= filteredActivities.length) return null;

                  final ActivityEntry entry = filteredActivities[index];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: ActivityItem(
                      entry: entry,
                      onTap: () => _showActivityDetails(context, entry),
                      onEdit: () => _repeatActivity(context, entry),
                    ),
                  );
                },
                childCount: filteredActivities.length,
              ),
            ),

          // Promemoria
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: ReminderRow(
                pref: reminder,
                onChanged: (bool enabled) => _updateReminder(enabled),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card "Oggi" con prossima sessione da fare
  Widget _buildTodayCard(BuildContext context, TodayPlan plan) {
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
            color: CupertinoColors.activeBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          const Row(
            children: <Widget>[
              Icon(
                CupertinoIcons.today,
                color: CupertinoColors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Oggi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titolo sessione
          Text(
            plan.nextSessionTitle,
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
                '${plan.durationMin} minuti',
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Warning se ha saltato sessione
          if (plan.hasMissedSession) ...<Widget>[
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
                    CupertinoIcons.info_circle,
                    color: CupertinoColors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Hai saltato una sessione',
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
          Row(
            children: <Widget>[
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: CupertinoColors.white,
                  onPressed: () => _startToday(context),
                  child: const Text(
                    'Avvia Ora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.all(14),
                color: CupertinoColors.white.withValues(alpha: 0.2),
                onPressed: () => _scheduleLater(context),
                child: const Icon(
                  CupertinoIcons.calendar_badge_plus,
                  color: CupertinoColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Filtri per status attività
  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _buildFilterChip(
            label: 'Tutte',
            isSelected: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: ActivityStatus.done.label,
            isSelected: _selectedFilter == ActivityStatus.done,
            onTap: () => setState(() => _selectedFilter = ActivityStatus.done),
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: ActivityStatus.skipped.label,
            isSelected: _selectedFilter == ActivityStatus.skipped,
            onTap: () =>
                setState(() => _selectedFilter = ActivityStatus.skipped),
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: ActivityStatus.stopped.label,
            isSelected: _selectedFilter == ActivityStatus.stopped,
            onTap: () =>
                setState(() => _selectedFilter = ActivityStatus.stopped),
            color: CupertinoColors.systemRed,
          ),
        ],
      ),
    );
  }

  /// Singolo chip filtro
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? CupertinoColors.activeBlue)
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? CupertinoColors.white
                : CupertinoColors.label,
          ),
        ),
      ),
    );
  }

  // ========== ACTIONS ==========

  /// Avvia sessione di oggi
  void _startToday(BuildContext context) {
    Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => const SessionScreen(
          weekNumber: 2,
          sessionIndex: 1,
          sessionDuration: 12,
        ),
      ),
    ).then((bool? completed) {
      if (completed == true && mounted) {
        setState(() {
          // In produzione, qui si ricaricherebbero i dati dal backend
        });
      }
    });
  }

  /// Pianifica per dopo
  void _scheduleLater(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Quando vuoi fare la sessione?'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _showScheduleConfirmation(context, 'Tra 1 ora');
              },
              child: const Text('Tra 1 ora'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _showScheduleConfirmation(context, 'Stasera alle 18:00');
              },
              child: const Text('Stasera alle 18:00'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _showScheduleConfirmation(context, 'Domani');
              },
              child: const Text('Domani'),
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

  /// Conferma pianificazione
  void _showScheduleConfirmation(BuildContext context, String when) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Sessione Pianificata'),
          content: Text('Ti ricorderemo $when'),
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

  /// Mostra dettagli attività
  void _showActivityDetails(BuildContext context, ActivityEntry entry) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: Text(entry.title),
          message: Column(
            children: <Widget>[
              Text('${entry.formattedDate} • ${entry.formattedTime}'),
              const SizedBox(height: 8),
              Text('Durata: ${entry.durationMin} min'),
              if (entry.comfort != null) ...<Widget>[
                const SizedBox(height: 8),
                Text('Comfort: ${entry.comfort!.label}'),
              ],
              if (entry.notes != null && entry.notes!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(entry.notes!),
              ],
            ],
          ),
          actions: <Widget>[
            if (entry.status == ActivityStatus.done)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                  _repeatActivity(context, entry);
                },
                child: const Text('Ripeti Sessione'),
              ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Modifica Note'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(modalContext).pop(),
            child: const Text('Chiudi'),
          ),
        );
      },
    );
  }

  /// Ripeti attività
  void _repeatActivity(BuildContext context, ActivityEntry entry) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Ripeti Sessione'),
          content: Text('Vuoi ripetere "${entry.title}"?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startToday(context);
              },
              isDefaultAction: true,
              child: const Text('Avvia'),
            ),
          ],
        );
      },
    );
  }

  /// Aggiorna promemoria
  void _updateReminder(bool enabled) {
    // In produzione, qui si salverebbero le preferenze
    debugPrint('Promemoria ${enabled ? 'attivato' : 'disattivato'}');
  }
}
