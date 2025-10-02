import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../common_widgets/week_calendar_appbar.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../theme/theme.dart';
import 'activity_screen.dart';
import 'community_screen.dart';
import 'dashboard_screen.dart';
import 'my_path_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDay = DateTime.now();

  late final List<Widget> _screens = <Widget>[
    const DashboardScreen(),
    const MyPathScreen(),
    const ActivityScreen(),
    const CommunityScreen(),
  ];

  // TODO: collegare questi dati con il piano reale dell'utente quando sarà disponibile.
  final Set<int> _plannedWorkoutWeekdays = <int>{1, 3, 5};

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _onDaySelected(DateTime day) {
    setState(() => _selectedDay = day);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature sarà presto disponibile!'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = ref.watch(profileControllerProvider);
    final String initials = _resolveInitials(profileState.user);

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WeekCalendarAppBar(
        initialDate: _selectedDay,
        onDaySelected: _onDaySelected,
        onAvatarTap: _openSettings,
        onNotificationTap: () => _showComingSoon('Notifiche'),
        avatarInitials: initials,
        weekdayWithWorkout: _plannedWorkoutWeekdays,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: GNav(
                gap: 10,
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
                backgroundColor: Colors.transparent,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                activeColor: AppTheme.baumannPrimaryBlue,
                tabBackgroundColor:
                    AppTheme.baumannPrimaryBlue.withValues(alpha: 0.12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                tabs: const <GButton>[
                  GButton(
                    icon: Icons.home_rounded,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.route_outlined,
                    text: 'Il mio percorso',
                  ),
                  GButton(
                    icon: Icons.bolt_outlined,
                    text: 'Attività',
                  ),
                  GButton(
                    icon: Icons.groups_outlined,
                    text: 'Community',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      final String firstTwo =
          fragment.substring(0, fragment.length >= 2 ? 2 : 1);
      return firstTwo.toUpperCase();
    }

    final String first = parts.first.substring(0, 1);
    final String last = parts.last.substring(0, 1);
    return (first + last).toUpperCase();
  }
}
