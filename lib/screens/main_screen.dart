import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../native_glass_tab_bar.dart';
import '../theme/theme.dart';
import 'activity_screen.dart';
import 'community_screen.dart';
import 'dashboard_screen.dart';
import 'my_path_screen.dart';
import 'settings_screen.dart';

typedef ScrollNotificationCallback =
    bool Function(UserScrollNotification notification);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final CupertinoTabController _tabController;
  DateTime _selectedDay = DateTime.now();
  final Set<int> _plannedWorkoutWeekdays = <int>{1, 3, 5};

  bool _isTabBarVisible = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day) {
    if (_selectedDay.year == day.year &&
        _selectedDay.month == day.month &&
        _selectedDay.day == day.day) {
      return;
    }
    setState(() {
      _selectedDay = day;
      _isTabBarVisible = true;
      _currentIndex = 0;
      _tabController.index = 0;
    });
  }

  bool _handleUserScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final ScrollDirection direction = notification.direction;
    final bool isAtTop =
        notification.metrics.pixels <=
        notification.metrics.minScrollExtent + 0.5;

    if (isAtTop && !_isTabBarVisible) {
      setState(() => _isTabBarVisible = true);
      return false;
    }

    if (direction == ScrollDirection.reverse && _isTabBarVisible) {
      setState(() => _isTabBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isTabBarVisible) {
      setState(() => _isTabBarVisible = true);
    }

    return false;
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Presto disponibile'),
          content: Text('$feature sarà presto disponibile!'),
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

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = ref.watch(profileControllerProvider);
    final String initials = _resolveInitials(profileState.user);
    final String displayName = _resolveDisplayName(profileState.user);
    final String greeting = _resolveGreeting();
    final String dateLabel = _formatSelectedDate(_selectedDay);

    // Build pages con hide-on-scroll wrapper
    final List<Widget> pages = <Widget>[
      NativeTabBarScrollWrapper(
        child: _HomeTab(
          onScrollNotification: _handleUserScrollNotification,
          selectedDay: _selectedDay,
          greeting: greeting,
          displayName: displayName,
          dateLabel: dateLabel,
          avatarInitials: initials,
          plannedWorkoutWeekdays: _plannedWorkoutWeekdays,
          onDaySelected: _onDaySelected,
          onOpenSettings: () => _openSettings(context),
          onShowComingSoon: (String feature) =>
              _showComingSoon(context, feature),
        ),
      ),
      NativeTabBarScrollWrapper(
        child: _ProgramTab(
          onScrollNotification: _handleUserScrollNotification,
        ),
      ),
      NativeTabBarScrollWrapper(
        child: _ActivityTab(
          onScrollNotification: _handleUserScrollNotification,
        ),
      ),
      NativeTabBarScrollWrapper(
        child: _CommunityTab(
          onScrollNotification: _handleUserScrollNotification,
        ),
      ),
    ];

    return NativeGlassTabScaffold(
      tabs: const <NativeTabItem>[
        NativeTabItem(title: 'Home', systemIcon: 'house'),
        NativeTabItem(title: 'Programma', systemIcon: 'book'),
        NativeTabItem(title: 'Attività', systemIcon: 'flame'),
        NativeTabItem(title: 'Community', systemIcon: 'person.2'),
      ],
      pages: pages,
      initialIndex: _currentIndex,
      onIndexChanged: (int index) {
        setState(() {
          _isTabBarVisible = true;
          _currentIndex = index;
          _tabController.index = index;
        });
      },
    );
  }

  String _resolveInitials(UserModel? user) {
    final String? displayName = user?.name ?? user?.email;
    if (displayName == null || displayName.trim().isEmpty) {
      return 'ME';
    }

    final List<String> parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'ME';
    }

    if (parts.length == 1) {
      final String fragment = parts.first;
      if (fragment.length == 1) {
        return fragment.toUpperCase();
      }
      final String firstTwo = fragment.substring(
        0,
        fragment.length >= 2 ? 2 : 1,
      );
      return firstTwo.toUpperCase();
    }

    final String first = parts.first.substring(0, 1);
    final String last = parts.last.substring(0, 1);
    return (first + last).toUpperCase();
  }

  String _resolveDisplayName(UserModel? user) {
    final String? name = user?.name;
    if (name != null && name.trim().isNotEmpty) {
      return '${name.trim()} 👋';
    }
    final String? email = user?.email;
    if (email != null && email.trim().isNotEmpty) {
      return '${email.trim()} 👋';
    }
    return 'Ciao 👋';
  }

  String _resolveGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  String _formatSelectedDate(DateTime date) {
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

    final String weekday = weekdayNames[date.weekday - 1];
    final String month = monthNames[date.month - 1];
    return '$weekday ${date.day} $month';
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.onScrollNotification,
    required this.selectedDay,
    required this.greeting,
    required this.displayName,
    required this.dateLabel,
    required this.avatarInitials,
    required this.plannedWorkoutWeekdays,
    required this.onDaySelected,
    required this.onOpenSettings,
    required this.onShowComingSoon,
  });

  final ScrollNotificationCallback onScrollNotification;
  final DateTime selectedDay;
  final String greeting;
  final String displayName;
  final String dateLabel;
  final String avatarInitials;
  final Set<int> plannedWorkoutWeekdays;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onShowComingSoon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color pageBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBackground,
      context,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Home'),
              leading: _AvatarButton(
                initials: avatarInitials,
                onTap: onOpenSettings,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.bell),
                    onPressed: () => onShowComingSoon('Notifiche'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.chart_bar_alt_fill),
                    onPressed: () => onShowComingSoon('Report giornaliero'),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      greeting,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _WeekCalendarSection(
                      selectedDay: selectedDay,
                      dateLabel: dateLabel,
                      plannedWorkoutWeekdays: plannedWorkoutWeekdays,
                      onDaySelected: onDaySelected,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverToBoxAdapter(
                child: DashboardScreen(selectedDate: selectedDay),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramTab extends StatelessWidget {
  const _ProgramTab({required this.onScrollNotification});

  final ScrollNotificationCallback onScrollNotification;

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBackground,
      context,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Programma'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              sliver: SliverToBoxAdapter(child: const MyPathScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.onScrollNotification});

  final ScrollNotificationCallback onScrollNotification;

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBackground,
      context,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Attività'),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ActivityScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab({required this.onScrollNotification});

  final ScrollNotificationCallback onScrollNotification;

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBackground,
      context,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Community'),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CommunityScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.baumannPrimaryBlue,
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WeekCalendarSection extends StatelessWidget {
  const _WeekCalendarSection({
    required this.selectedDay,
    required this.dateLabel,
    required this.plannedWorkoutWeekdays,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final String dateLabel;
  final Set<int> plannedWorkoutWeekdays;
  final ValueChanged<DateTime> onDaySelected;

  static const List<String> _weekdayInitials = <String>[
    'L',
    'M',
    'M',
    'G',
    'V',
    'S',
    'D',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final DateTime today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.baumannPrimaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                CupertinoIcons.calendar,
                size: 18,
                color: AppTheme.baumannPrimaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                dateLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.baumannPrimaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: List<Widget>.generate(7, (int index) {
            final DateTime day = startOfWeek.add(Duration(days: index));
            final bool isSelected = _isSameDate(day, selectedDay);
            final bool isToday = _isSameDate(day, today);
            final bool hasWorkout = plannedWorkoutWeekdays.contains(
              day.weekday,
            );

            return Expanded(
              child: GestureDetector(
                onTap: () => onDaySelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.baumannPrimaryBlue.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.baumannPrimaryBlue
                          : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _weekdayInitials[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected || isToday
                              ? AppTheme.baumannPrimaryBlue
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.baumannPrimaryBlue
                              : (isToday
                                    ? AppTheme.baumannPrimaryBlue.withValues(
                                        alpha: 0.12,
                                      )
                                    : theme.colorScheme.surface),
                          border: isToday && !isSelected
                              ? Border.all(color: AppTheme.baumannPrimaryBlue)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day.day.toString().padLeft(2, '0'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: hasWorkout ? 1 : 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.baumannAccentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
