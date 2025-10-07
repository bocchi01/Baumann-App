import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../activities/activities_screen.dart';
import '../controllers/profile_controller.dart';
import '../home/home_screen.dart';
import '../models/user_model.dart';
import '../native_glass_tab_bar.dart';
import '../program/program_overview_screen.dart';
import 'community_screen.dart';
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
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = ref.watch(profileControllerProvider);
    final String initials = _resolveInitials(profileState.user);

    // Build pages con hide-on-scroll wrapper
    final List<Widget> pages = <Widget>[
      NativeTabBarScrollWrapper(
        child: HomeScreen(
          onScrollNotification: _handleUserScrollNotification,
          onOpenSettings: () => _openSettings(context),
          onShowNotifications: () => _showComingSoon(context, 'Notifiche'),
          onShowStats: () => _showComingSoon(context, 'Statistiche'),
          avatarInitials: initials,
        ),
      ),
      const ProgramOverviewScreen(),
      const ActivitiesScreen(),
      NativeTabBarScrollWrapper(
        child: CommunityScreen(
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
}
