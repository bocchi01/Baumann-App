import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../theme/theme.dart';
import 'dashboard_screen.dart';
import 'my_path_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = <Widget>[
    const DashboardScreen(),
    const MyPathScreen(),
    const ProfileScreen(),
  ];

  static const List<_MainShellTabConfig> _tabConfig = <_MainShellTabConfig>[
    _MainShellTabConfig(
      title: 'Dashboard',
      subtitle: 'Monitora i tuoi progressi quotidiani.',
      heroIcon: Icons.dashboard_customize_rounded,
      primaryActionIcon: Icons.notifications_outlined,
      accentColor: AppTheme.baumannAccentOrange,
    ),
    _MainShellTabConfig(
      title: 'Percorso',
      subtitle: 'Segui il programma creato per te.',
      heroIcon: Icons.alt_route_rounded,
      primaryActionIcon: Icons.flag_outlined,
      accentColor: AppTheme.baumannPrimaryBlue,
    ),
    _MainShellTabConfig(
      title: 'Profilo',
      subtitle: 'Gestisci impostazioni e preferenze.',
      heroIcon: Icons.person_pin_circle_rounded,
      primaryActionIcon: Icons.settings_outlined,
      accentColor: AppTheme.baumannSecondaryBlue,
    ),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _MainShellTabConfig activeConfig = _tabConfig[_selectedIndex];
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _MainShellAppBar(config: activeConfig),
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
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    text: 'Il Mio Percorso',
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Profilo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MainShellAppBar({required this.config});

  final _MainShellTabConfig config;

  @override
  Size get preferredSize => const Size.fromHeight(112);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: <Widget>[
                _SoftIconBadge(
                  icon: config.heroIcon,
                  backgroundColor: config.accentColor.withValues(alpha: 0.12),
                  iconColor: config.accentColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        config.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.64),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SoftIconButton(
                  icon: Icons.search,
                  semanticLabel: 'Cerca',
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                _SoftIconButton(
                  icon: config.primaryActionIcon,
                  semanticLabel: 'Azioni rapide',
                  badge:
                      config.primaryActionIcon == Icons.notifications_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  const _SoftIconBadge({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.badge = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Material(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  size: 22,
                ),
              ),
            ),
          ),
          if (badge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppTheme.baumannAccentOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MainShellTabConfig {
  const _MainShellTabConfig({
    required this.title,
    required this.subtitle,
    required this.heroIcon,
    required this.primaryActionIcon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData heroIcon;
  final IconData primaryActionIcon;
  final Color accentColor;
}
