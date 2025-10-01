import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/dashboard_controller.dart';
import '../models/daily_session.dart';
import '../models/posture_path.dart';
import '../theme/theme.dart';
import 'exercise_player_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Il tuo percorso'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _DashboardContent(state: state),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.path == null ||
        state.todaySession == null ||
        state.user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Nessun percorso disponibile al momento.'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: <Widget>[
        _GreetingWidget(name: state.user!.name ?? state.user!.email),
        const SizedBox(height: 16),
        _TodaySessionCard(
          path: state.path!,
          session: state.todaySession!,
          currentWeek: state.currentWeek,
          onStart: () => _startSession(context, state.todaySession!),
        ),
        const SizedBox(height: 24),
        _StatisticsOverview(
          completedSessions: state.completedSessionsCount,
          currentStreak: state.currentStreak,
        ),
        const SizedBox(height: 24),
        _WeeklyProgressWidget(
          completedDays: state.completedDays,
          currentWeek: state.currentWeek,
        ),
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
}

class _GreetingWidget extends StatelessWidget {
  const _GreetingWidget({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String greeting = _resolveGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$greeting, $name! 👋',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.baumannPrimaryBlue,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Continua il tuo percorso posturale e prenditi cura di te.',
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _resolveGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }
}

class _TodaySessionCard extends StatelessWidget {
  const _TodaySessionCard({
    required this.path,
    required this.session,
    required this.currentWeek,
    required this.onStart,
  });

  final PosturePath path;
  final DailySession session;
  final int currentWeek;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              path.title,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Giorno ${session.dayNumber}: ${session.title}',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Icon(Icons.timer_outlined,
                    color: AppTheme.baumannAccentOrange),
                const SizedBox(width: 8),
                Text(
                  '${session.estimatedDurationInMinutes} minuti',
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Chip(
                  label: Text('Settimana $currentWeek'),
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('INIZIA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressWidget extends StatelessWidget {
  const _WeeklyProgressWidget({
    required this.completedDays,
    required this.currentWeek,
  });

  final Set<int> completedDays;
  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> labels = <String>['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    final int today = DateTime.now().weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'La Tua Settimana',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Settimana $currentWeek',
              style: textTheme.labelLarge?.copyWith(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(7, (int index) {
            final int dayNumber = index + 1;
            final bool isCompleted = completedDays.contains(dayNumber);
            final bool isToday = dayNumber == today;

            return _WeekDayCircle(
              label: labels[index],
              isCompleted: isCompleted,
              isToday: isToday,
            );
          }),
        ),
      ],
    );
  }
}

class _StatisticsOverview extends StatelessWidget {
  const _StatisticsOverview({
    required this.completedSessions,
    required this.currentStreak,
  });

  final int completedSessions;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            value: completedSessions,
            label: 'Sessioni Completate',
            iconColor: AppTheme.baumannPrimaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_outlined,
            value: currentStreak,
            label: 'Giorni di Striscia',
            iconColor: AppTheme.baumannAccentOrange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$value',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.65),
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

class _WeekDayCircle extends StatelessWidget {
  const _WeekDayCircle({
    required this.label,
    required this.isCompleted,
    required this.isToday,
  });

  final String label;
  final bool isCompleted;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = colorScheme.primary;
    final Color primary20 = primaryColor.withValues(alpha: 0.2);
    final Color primary30 = primaryColor.withValues(alpha: 0.3);
    final Color primary18 = primaryColor.withValues(alpha: 0.18);
    final Color backgroundColor = isCompleted
        ? AppTheme.baumannAccentOrange
        : isToday
            ? primary20
            : Colors.white;
    final Color borderColor = isCompleted
        ? AppTheme.baumannAccentOrange
        : isToday
            ? colorScheme.primary
            : primary30;
    final Color foregroundColor =
        isCompleted ? Colors.white : colorScheme.primary;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          if (isToday)
            BoxShadow(
              color: primary18,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foregroundColor, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
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
