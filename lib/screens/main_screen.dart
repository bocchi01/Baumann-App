import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const Duration _tabBarAnimationDuration = Duration(milliseconds: 220);
  static const Curve _tabBarAnimationCurve = Curves.easeOutQuad;

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

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: _HidableCupertinoTabBar(
        isVisible: _isTabBarVisible,
        duration: _tabBarAnimationDuration,
        curve: _tabBarAnimationCurve,
        activeColor: AppTheme.baumannPrimaryBlue,
        inactiveColor: CupertinoColors.inactiveGray,
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
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
            activeIcon: Icon(CupertinoIcons.group_solid),
            label: 'Community',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        if (_currentIndex != index) {
          return const SizedBox.shrink();
        }

        switch (index) {
          case 0:
            return _HomeTab(
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
          case 1:
            return _ProgramTab(
              onScrollNotification: _handleUserScrollNotification,
            );
          case 2:
            return _ActivityTab(
              onScrollNotification: _handleUserScrollNotification,
            );
          case 3:
          default:
            return _CommunityTab(
              onScrollNotification: _handleUserScrollNotification,
            );
        }
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

class _HidableCupertinoTabBar extends CupertinoTabBar {
  _HidableCupertinoTabBar({
    required this.isVisible,
    required this.duration,
    required this.curve,
    required super.items,
    super.currentIndex,
    super.onTap,
    Color? activeColor,
    Color? inactiveColor,
  }) : _effectiveActiveColor = activeColor ?? CupertinoColors.activeBlue,
       _effectiveInactiveColor = inactiveColor ?? CupertinoColors.inactiveGray,
       super(
         activeColor: activeColor ?? CupertinoColors.activeBlue,
         inactiveColor: inactiveColor ?? CupertinoColors.inactiveGray,
         backgroundColor: Colors.transparent,
         border: Border.all(color: Colors.transparent, width: 0),
         height: kBottomNavigationBarHeight,
         iconSize: 28,
       );

  final bool isVisible;
  final Duration duration;
  final Curve curve;
  final Color _effectiveActiveColor;
  final Color _effectiveInactiveColor;

  static const double _horizontalPadding = 18;
  static const double _verticalPadding = 12;
  static const double _floatingGap = 32;
  static const double _itemSpacing = 8;
  static const double _itemHorizontalPadding = 12;
  static const double _itemVerticalPadding = 10;
  static const double _blurSigma = 24;
  static const Duration _itemAnimationDuration = Duration(milliseconds: 260);
  static const Curve _itemAnimationCurve = Curves.easeOutCubic;
  static const BorderRadius _barRadius = BorderRadius.all(Radius.circular(26));
  static const BorderRadius _itemRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final EdgeInsets targetPadding = isVisible
        ? EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: _floatingGap,
          )
        : EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: 0,
          );

    final Color resolvedBackground = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassTint,
      context,
    ).withValues(alpha: 0.68);
    final Color resolvedBorderColor = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassBorder,
      context,
    );
    final Color resolvedShadow = CupertinoDynamicColor.resolve(
      AppTheme.liquidGlassShadow,
      context,
    );
    final Color resolvedHighlight = resolvedBackground.withValues(alpha: 0.42);
    final Color resolvedLowlight = resolvedShadow.withValues(alpha: 0.18);
    final Color resolvedActiveColor = CupertinoDynamicColor.resolve(
      _effectiveActiveColor,
      context,
    );
    final Color resolvedInactiveColor = CupertinoDynamicColor.resolve(
      _effectiveInactiveColor,
      context,
    );

    return AnimatedPadding(
      duration: duration,
      curve: curve,
      padding: targetPadding,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _verticalPadding),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: AnimatedOpacity(
                opacity: isVisible ? 1 : 0,
                duration: duration,
                curve: curve,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: _barRadius,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: resolvedShadow.withValues(alpha: 0.24),
                        blurRadius: 40,
                        offset: const Offset(0, 22),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: _barRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurSigma,
                        sigmaY: _blurSigma,
                        tileMode: TileMode.clamp,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: resolvedBackground,
                                borderRadius: _barRadius,
                                border: Border.all(
                                  color: resolvedBorderColor,
                                  width: 0.7,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: _barRadius,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    resolvedHighlight,
                                    resolvedBackground.withValues(alpha: 0.18),
                                    resolvedBackground.withValues(alpha: 0.04),
                                  ],
                                  stops: const <double>[0, 0.55, 1],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: _barRadius,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: <Color>[
                                    resolvedLowlight,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: _FloatingTabRow(
                              items: items,
                              currentIndex: currentIndex,
                              iconSize: iconSize,
                              activeColor: resolvedActiveColor,
                              inactiveColor: resolvedInactiveColor,
                              itemSpacing: _itemSpacing,
                              itemHorizontalPadding: _itemHorizontalPadding,
                              itemVerticalPadding: _itemVerticalPadding,
                              itemRadius: _itemRadius,
                              duration: _itemAnimationDuration,
                              curve: _itemAnimationCurve,
                              onPressed: onTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    isVisible
        ? kBottomNavigationBarHeight + (_verticalPadding * 2) + _floatingGap
        : 0,
  );
}

class _FloatingTabRow extends StatelessWidget {
  const _FloatingTabRow({
    required this.items,
    required this.currentIndex,
    required this.iconSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.itemSpacing,
    required this.itemHorizontalPadding,
    required this.itemVerticalPadding,
    required this.itemRadius,
    required this.duration,
    required this.curve,
    required this.onPressed,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;
  final double itemSpacing;
  final double itemHorizontalPadding;
  final double itemVerticalPadding;
  final BorderRadius itemRadius;
  final Duration duration;
  final Curve curve;
  final ValueChanged<int>? onPressed;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    for (int index = 0; index < items.length; index++) {
      children.add(
        Expanded(
          child: _FloatingTabItem(
            index: index,
            item: items[index],
            isActive: index == currentIndex,
            iconSize: iconSize,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            horizontalPadding: itemHorizontalPadding,
            verticalPadding: itemVerticalPadding,
            borderRadius: itemRadius,
            duration: duration,
            curve: curve,
            onPressed: onPressed,
          ),
        ),
      );

      if (index != items.length - 1) {
        children.add(SizedBox(width: itemSpacing));
      }
    }

    return Row(children: children);
  }
}

class _FloatingTabItem extends StatelessWidget {
  const _FloatingTabItem({
    required this.index,
    required this.item,
    required this.isActive,
    required this.iconSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.duration,
    required this.curve,
    required this.onPressed,
  });

  final int index;
  final BottomNavigationBarItem item;
  final bool isActive;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;
  final double horizontalPadding;
  final double verticalPadding;
  final BorderRadius borderRadius;
  final Duration duration;
  final Curve curve;
  final ValueChanged<int>? onPressed;

  @override
  Widget build(BuildContext context) {
    final String label = item.label ?? '';
    final TextStyle baseLabelStyle = CupertinoTheme.of(
      context,
    ).textTheme.tabLabelTextStyle;
    final TextStyle resolvedLabelStyle = baseLabelStyle.copyWith(
      fontSize: 11,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
      letterSpacing: -0.1,
      color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.85),
    );

    final Widget icon = IconTheme(
      data: IconThemeData(
        color: isActive ? activeColor : inactiveColor,
        size: iconSize,
      ),
      child: isActive ? item.activeIcon : item.icon,
    );

    return Semantics(
      selected: isActive,
      button: true,
      label: label.isEmpty ? null : label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed == null ? null : () => onPressed!(index),
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              if (label.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: curve,
                  style: resolvedLabelStyle,
                  child: Text(label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
