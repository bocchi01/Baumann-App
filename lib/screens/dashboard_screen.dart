import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_widgets/shimmer_widgets.dart';
import '../controllers/dashboard_controller.dart';
import '../models/daily_session.dart';
import '../models/path_module.dart';
import '../models/posture_path.dart';
import '../theme/theme.dart';
import 'exercise_player_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DashboardState>(dashboardControllerProvider,
        (DashboardState? prev, DashboardState next) {
      if (!mounted) return;
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        ref.read(dashboardControllerProvider.notifier).clearError();
      }
    });

    final DashboardState state = ref.watch(dashboardControllerProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: state.isLoading
              ? const _DashboardLoadingSkeleton()
              : _DashboardContent(
                  state: state,
                  selectedDate: widget.selectedDate,
                ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.state,
    required this.selectedDate,
  });

  final DashboardState state;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    if (state.path == null || state.user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Nessun percorso disponibile al momento.'),
        ),
      );
    }

    final DailySession? session =
        _resolveSessionForDate(state.path!, selectedDate);
    if (session == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Nessuna sessione pianificata per questo giorno.'),
        ),
      );
    }

    final String userName = (state.user!.name?.trim().isNotEmpty ?? false)
        ? state.user!.name!
        : state.user!.email;
    final String fallbackEmail = state.user!.email.trim().isNotEmpty
        ? state.user!.email.trim()
        : 'Utente';
    final String avatarInitial =
        (userName.trim().isNotEmpty ? userName.trim()[0] : fallbackEmail[0])
            .toUpperCase();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: <Widget>[
        _OverviewHeader(
          name: userName,
          email: state.user!.email,
          avatarInitial: avatarInitial,
        ),
        const SizedBox(height: 24),
        _TodaysWorkoutCard(
          path: state.path!,
          session: session,
          onStart: () => _startSession(context, session),
        ),
        const SizedBox(height: 28),
        _WeekOverviewCard(
          completedSessions: state.completedSessionsCount,
          currentStreak: state.currentStreak,
          totalWeeks: state.path!.durationInWeeks,
          currentWeek:
              _determineWeekForSession(state.path!, session) ?? state.currentWeek,
        ),
        const SizedBox(height: 28),
        const _PremiumContentHighlight(),
        const SizedBox(height: 24),
        const _TipOfTheDayCard(),
      ],
    );
  }

  static void _startSession(BuildContext context, DailySession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercisePlayerScreen(session: session),
      ),
    );
  }

  static DailySession? _resolveSessionForDate(
    PosturePath path,
    DateTime selectedDate,
  ) {
    final List<DailySession> sessions = path.modules
        .expand<DailySession>((PathModule module) => module.sessions)
        .toList(growable: false);
    sessions.sort(
      (DailySession a, DailySession b) => a.dayNumber.compareTo(b.dayNumber),
    );

    if (sessions.isEmpty) {
      return null;
    }

    final int targetDay = selectedDate.weekday;
    for (final DailySession session in sessions) {
      if (session.dayNumber == targetDay) {
        return session;
      }
    }

    for (final DailySession session in sessions) {
      if (session.dayNumber > targetDay) {
        return session;
      }
    }

    return sessions.last;
  }

  static int? _determineWeekForSession(
    PosturePath path,
    DailySession session,
  ) {
    for (final PathModule module in path.modules) {
      final bool containsSession = module.sessions
          .any((DailySession candidate) => candidate.id == session.id);
      if (containsSession) {
        return module.weekNumber;
      }
    }
    return null;
  }
}

class _DashboardLoadingSkeleton extends StatelessWidget {
  const _DashboardLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: const <Widget>[
        ShimmerBox(height: 120, borderRadius: 26),
        SizedBox(height: 24),
        ShimmerBox(height: 240, borderRadius: 30),
        SizedBox(height: 24),
        ShimmerBox(height: 160, borderRadius: 24),
        SizedBox(height: 24),
        ShimmerBox(height: 200, borderRadius: 24),
        SizedBox(height: 24),
        ShimmerBox(height: 140, borderRadius: 20),
      ],
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.name,
    required this.email,
    required this.avatarInitial,
  });

  final String name;
  final String email;
  final String avatarInitial;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String greeting = _resolveGreeting();
    final String todayLabel = _resolveTodayLabel();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _AvatarBadge(initial: avatarInitial),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$name 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_outlined,
                      color: theme.colorScheme.primary.withValues(alpha: 0.85),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      todayLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          _SoftActionChip(
            icon: Icons.auto_graph_rounded,
            label: 'Report',
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Report giornaliero presto disponibile'),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }

  String _resolveGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  String _resolveTodayLabel() {
    const List<String> weekdayNames = <String>[
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    const List<String> monthNames = <String>[
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    final DateTime now = DateTime.now();
    final String weekday = weekdayNames[now.weekday - 1];
    final String month = monthNames[now.month - 1];
    return '$weekday ${now.day} $month';
  }
}

class _TodaysWorkoutCard extends StatelessWidget {
  const _TodaysWorkoutCard({
    required this.path,
    required this.session,
    required this.onStart,
  });

  final PosturePath path;
  final DailySession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppTheme.baumannPrimaryBlue.withValues(alpha: 0.95),
            AppTheme.baumannSecondaryBlue.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.baumannPrimaryBlue.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Sessione di oggi',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                _PlayIconBadge(onTap: onStart),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              session.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Percorso: ${path.title}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: <Widget>[
                _SessionMetaChip(
                  icon: Icons.timer_outlined,
                  label: '${session.estimatedDurationInMinutes} minuti',
                ),
                _SessionMetaChip(
                  icon: Icons.calendar_view_day_outlined,
                  label: 'Giorno ${session.dayNumber}',
                ),
                _SessionMetaChip(
                  icon: Icons.sports_gymnastics_outlined,
                  label: '${session.exercises.length} esercizi',
                ),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.baumannPrimaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: onStart,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.play_arrow_rounded, size: 28),
                    SizedBox(width: 8),
                    Text('Inizia allenamento'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekOverviewCard extends StatelessWidget {
  const _WeekOverviewCard({
    required this.completedSessions,
    required this.currentStreak,
    required this.totalWeeks,
    required this.currentWeek,
  });

  final int completedSessions;
  final int currentStreak;
  final int totalWeeks;
  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<_OverviewMetric> metrics = <_OverviewMetric>[
      _OverviewMetric(
        icon: Icons.check_circle_outline,
        label: 'Sessioni completate',
        value: '$completedSessions',
        highlightColor: AppTheme.baumannPrimaryBlue,
      ),
      _OverviewMetric(
        icon: Icons.local_fire_department_outlined,
        label: 'Striscia attuale',
        value: '${currentStreak}g',
        highlightColor: AppTheme.baumannAccentOrange,
      ),
      _OverviewMetric(
        icon: Icons.track_changes_outlined,
        label: 'Progresso percorso',
        value: '$currentWeek / $totalWeeks',
        highlightColor: AppTheme.baumannSecondaryBlue,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Panoramica rapida',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: metrics
                .map((_) => Expanded(child: _WeeklyMetricTile(metric: _)))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppTheme.baumannPrimaryBlue.withValues(alpha: 0.95),
            AppTheme.baumannSecondaryBlue.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SoftActionChip extends StatelessWidget {
  const _SoftActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionMetaChip extends StatelessWidget {
  const _SessionMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlayIconBadge extends StatelessWidget {
  const _PlayIconBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _OverviewMetric {
  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.highlightColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color highlightColor;
}

class _WeeklyMetricTile extends StatelessWidget {
  const _WeeklyMetricTile({required this.metric});

  final _OverviewMetric metric;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: metric.highlightColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: metric.highlightColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: metric.highlightColor.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                metric.icon,
                color: metric.highlightColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              metric.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: metric.highlightColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              metric.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumContentHighlight extends StatelessWidget {
  const _PremiumContentHighlight();

  static const List<_MasterclassPreview> _mockMasterclasses =
      <_MasterclassPreview>[
    _MasterclassPreview(
      title: 'Mobilità e Core Stability',
      imageUrl:
          'https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=900&q=80',
    ),
    _MasterclassPreview(
      title: 'Stretching Post-Lavoro',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=900&q=80',
    ),
    _MasterclassPreview(
      title: 'Rilassamento e Respirazione',
      imageUrl:
          'https://images.unsplash.com/photo-1517832207067-4db24a2ae47c?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Masterclass in Evidenza',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _mockMasterclasses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (BuildContext context, int index) {
              final _MasterclassPreview masterclass = _mockMasterclasses[index];
              return SizedBox(
                width: 220,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Presto disponibile: ${masterclass.title}',
                          ),
                        ),
                      );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            masterclass.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      AppTheme.baumannPrimaryBlue
                                          .withValues(alpha: 0.65),
                                      AppTheme.baumannSecondaryBlue
                                          .withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white70,
                                  size: 54,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Text(
                            masterclass.title,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MasterclassPreview {
  const _MasterclassPreview({
    required this.title,
    required this.imageUrl,
  });

  final String title;
  final String imageUrl;
}

class _TipOfTheDayCard extends StatelessWidget {
  const _TipOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppTheme.baumannAccentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Consiglio del Giorno',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imposta un promemoria ogni ora per alzarti, respirare profondamente e fare due minuti di mobilità della colonna. Piccoli gesti, grande impatto!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
