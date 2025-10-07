import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_widgets/glass_bottom_nav.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
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

    // Build the pages
    final Widget currentPage;
    switch (_currentIndex) {
      case 0:
        currentPage = _HomeTab(
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
        );
        break;
      case 1:
        currentPage = _ProgramTab(
          onScrollNotification: _handleUserScrollNotification,
        );
        break;
      case 2:
        currentPage = _ActivityTab(
          onScrollNotification: _handleUserScrollNotification,
        );
        break;
      case 3:
      default:
        currentPage = _CommunityTab(
          onScrollNotification: _handleUserScrollNotification,
        );
    }

    return Stack(
      children: <Widget>[
        // Content with bottom padding to avoid overlap
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: currentPage,
          ),
        ),
        // Glass bottom navigation bar
        Positioned.fill(
          child: GlassBottomBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house),
                activeIcon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                activeIcon: Icon(CupertinoIcons.book_fill),
                label: 'Programma',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.flame),
                activeIcon: Icon(CupertinoIcons.flame_fill),
                label: 'Attività',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2),
                activeIcon: Icon(CupertinoIcons.person_2_fill),
                label: 'Community',
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (int index) {
              if (_currentIndex == index) {
                return;
              }
              setState(() {
                _isTabBarVisible = true;
                _currentIndex = index;
                _tabController.index = index;
              });
            },
            reduceTransparency: false,
            enableParallax: true,
            enableEdgeGlow: true,
          ),
        ),
      ],
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
    final double topInset = MediaQuery.of(context).padding.top;
    final TextStyle navTitleStyle = CupertinoTheme.of(context)
        .textTheme
        .navTitleTextStyle
        .copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            _GlassNavigationBar(
              topInset: topInset,
              title: Text('Home', style: navTitleStyle),
              leading: _AvatarButton(
                initials: avatarInitials,
                onTap: onOpenSettings,
              ),
              trailing: <Widget>[
                _GlassIconButton(
                  icon: CupertinoIcons.bell,
                  semanticLabel: 'Notifiche',
                  onPressed: () => onShowComingSoon('Notifiche'),
                ),
                _GlassIconButton(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  semanticLabel: 'Report giornaliero',
                  onPressed: () => onShowComingSoon('Report giornaliero'),
                ),
              ],
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
    final double topInset = MediaQuery.of(context).padding.top;
    final TextStyle navTitleStyle = CupertinoTheme.of(context)
        .textTheme
        .navTitleTextStyle
        .copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            _GlassNavigationBar(
              topInset: topInset,
              title: Text('Programma', style: navTitleStyle),
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
    final double topInset = MediaQuery.of(context).padding.top;
    final TextStyle navTitleStyle = CupertinoTheme.of(context)
        .textTheme
        .navTitleTextStyle
        .copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            _GlassNavigationBar(
              topInset: topInset,
              title: Text('Attività', style: navTitleStyle),
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
    final double topInset = MediaQuery.of(context).padding.top;
    final TextStyle navTitleStyle = CupertinoTheme.of(context)
        .textTheme
        .navTitleTextStyle
        .copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        );

    return NotificationListener<UserScrollNotification>(
      onNotification: onScrollNotification,
      child: CupertinoPageScaffold(
        backgroundColor: pageBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            _GlassNavigationBar(
              topInset: topInset,
              title: Text('Community', style: navTitleStyle),
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

class _GlassNavigationBar extends StatelessWidget {
  const _GlassNavigationBar({
    required this.topInset,
    required this.title,
    this.leading,
    this.trailing = const <Widget>[],
  });

  final double topInset;
  final Widget title;
  final Widget? leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: true,
      pinned: true,
      delegate: _GlassNavigationBarDelegate(
        topInset: topInset,
        title: title,
        leading: leading,
        trailing: List<Widget>.unmodifiable(trailing),
      ),
    );
  }
}

class _GlassNavigationBarDelegate extends SliverPersistentHeaderDelegate {
  _GlassNavigationBarDelegate({
    required this.topInset,
    required this.title,
    required this.trailing,
    this.leading,
  });

  final double topInset;
  final Widget title;
  final Widget? leading;
  final List<Widget> trailing;

  static const double _barHeight = 64;
  static const double _topPadding = 12;
  static const double _bottomPadding = 18;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(26));

  @override
  double get minExtent => topInset + _topPadding + _barHeight + _bottomPadding;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final Color resolvedBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassTint,
      context,
    ).withValues(alpha: 0.86);
    final Color resolvedBorder = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBorder,
      context,
    ).withValues(alpha: 0.9);
    final Color resolvedShadow = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassShadow,
      context,
    ).withValues(alpha: 0.33);
    final Color resolvedHighlight = resolvedBackground.withValues(alpha: 0.55);
    final Color resolvedLowlight = resolvedShadow.withValues(alpha: 0.2);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        topInset + _topPadding,
        20,
        _bottomPadding,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _radius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: resolvedShadow,
              blurRadius: 36,
              offset: const Offset(0, 20),
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 28,
              sigmaY: 28,
              tileMode: TileMode.clamp,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: resolvedBackground,
                      borderRadius: _radius,
                      border: Border.all(color: resolvedBorder, width: 0.9),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: _radius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          resolvedHighlight,
                          resolvedBackground.withValues(alpha: 0.3),
                          resolvedBackground.withValues(alpha: 0.08),
                        ],
                        stops: const <double>[0, 0.5, 1],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: _radius,
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[resolvedLowlight, Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (leading != null) ...<Widget>[
                        leading!,
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DefaultTextStyle.merge(
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .navTitleTextStyle
                                .copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                            child: title,
                          ),
                        ),
                      ),
                      if (trailing.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (
                              int index = 0;
                              index < trailing.length;
                              index++
                            ) ...<Widget>[
                              if (index != 0) const SizedBox(width: 10),
                              trailing[index],
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GlassNavigationBarDelegate oldDelegate) {
    return true;
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color resolvedFill = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassTint,
      context,
    ).withValues(alpha: 0.32);
    final BorderRadius radius = const BorderRadius.all(Radius.circular(14));

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(36),
      onPressed: onPressed,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: resolvedFill,
            borderRadius: radius,
            border: Border.all(
              color: resolvedFill.withValues(alpha: 0.6),
              width: 0.7,
            ),
          ),
          child: Icon(icon, size: 18, color: AppTheme.baumannPrimaryBlue),
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
