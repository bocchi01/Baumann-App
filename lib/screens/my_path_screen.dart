import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_widgets/shimmer_widgets.dart';
import '../controllers/my_path_controller.dart';
import '../models/daily_session.dart';
import '../models/path_module.dart';
import '../models/posture_path.dart';
import '../theme/theme.dart';
import 'exercise_player_screen.dart';

class MyPathScreen extends ConsumerStatefulWidget {
  const MyPathScreen({super.key});

  @override
  ConsumerState<MyPathScreen> createState() => _MyPathScreenState();
}

class _MyPathScreenState extends ConsumerState<MyPathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPathControllerProvider.notifier).fetchPath();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MyPathState>(myPathControllerProvider,
        (MyPathState? previous, MyPathState next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
      }
    });

    final MyPathState state = ref.watch(myPathControllerProvider);
    final MyPathController controller =
        ref.read(myPathControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Mio Percorso'),
      ),
      body: SafeArea(
        child: state.isLoading && !state.hasData
            ? const _MyPathLoadingSkeleton()
            : state.path == null
                ? _EmptyPlaceholder(onRetry: controller.fetchPath)
                : _PathContent(
                    path: state.path!,
                    state: state,
                    controller: controller,
                  ),
      ),
    );
  }
}

class _MyPathLoadingSkeleton extends StatelessWidget {
  const _MyPathLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemBuilder: (BuildContext context, int index) {
        return const ShimmerBox(height: 96, borderRadius: 18);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: 6,
    );
  }
}

class _PathContent extends StatelessWidget {
  const _PathContent({
    required this.path,
    required this.state,
    required this.controller,
  });

  final PosturePath path;
  final MyPathState state;
  final MyPathController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final String? nextSessionId = controller.resolveNextSessionId();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: <Widget>[
        Text(
          path.title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.baumannPrimaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          path.description,
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        ...path.modules.map(
          (PathModule module) => _WeekExpansionTile(
            module: module,
            state: state,
            nextSessionId: nextSessionId,
          ),
        ),
      ],
    );
  }
}

class _WeekExpansionTile extends StatelessWidget {
  const _WeekExpansionTile({
    required this.module,
    required this.state,
    required this.nextSessionId,
  });

  final PathModule module;
  final MyPathState state;
  final String? nextSessionId;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<DailySession> sessions = module.sessions;
    final int completedCount = sessions
        .where((DailySession session) =>
            state.completedSessionIds.contains(session.id))
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            module.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            'Settimana ${module.weekNumber} · ${module.sessions.length} sessioni',
            style: textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$completedCount / ${sessions.length}',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.baumannPrimaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'completati',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: sessions
              .map(
                (DailySession session) => _DailySessionListItem(
                  session: session,
                  isCompleted: state.completedSessionIds.contains(session.id),
                  isNext: session.id == nextSessionId,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DailySessionListItem extends StatelessWidget {
  const _DailySessionListItem({
    required this.session,
    required this.isCompleted,
    required this.isNext,
  });

  final DailySession session;
  final bool isCompleted;
  final bool isNext;

  Color _resolveIconColor() {
    if (isCompleted) {
      return AppTheme.baumannAccentOrange;
    }
    if (isNext) {
      return AppTheme.baumannPrimaryBlue;
    }
    return Colors.grey.shade400;
  }

  IconData _resolveIconData() {
    if (isCompleted) {
      return Icons.check_circle_rounded;
    }
    if (isNext) {
      return Icons.play_circle_fill_rounded;
    }
    return Icons.lock_outline;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.baumannPrimaryBlue.withValues(alpha: 0.12),
        child: Text(
          'G${session.dayNumber}',
          style: textTheme.titleMedium?.copyWith(
            color: AppTheme.baumannPrimaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        session.title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        'Durata: ${session.estimatedDurationInMinutes} minuti',
        style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        _resolveIconData(),
        color: _resolveIconColor(),
        size: 30,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExercisePlayerScreen(session: session),
          ),
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.self_improvement, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Percorso non disponibile al momento.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}
