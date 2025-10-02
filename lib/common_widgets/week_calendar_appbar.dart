import 'package:flutter/material.dart';

class WeekCalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WeekCalendarAppBar({
    super.key,
    this.onDaySelected,
    this.onAvatarTap,
    this.onNotificationTap,
    this.initialDate,
    this.weekdayWithWorkout = const <int>{},
    this.avatarInitials = 'ME',
  });

  /// Callback quando l'utente seleziona un giorno nella vista settimanale.
  final ValueChanged<DateTime>? onDaySelected;

  /// Callback per il tap sull'avatar in alto a sinistra.
  final VoidCallback? onAvatarTap;

  /// Callback per il tap sull'icona notifiche.
  final VoidCallback? onNotificationTap;

  /// Data iniziale da cui calcolare la settimana corrente.
  final DateTime? initialDate;

  /// Giorni della settimana (1 = lunedì ... 7 = domenica) con allenamenti pianificati.
  final Set<int> weekdayWithWorkout;

  /// Iniziali mostrate nell'avatar.
  final String avatarInitials;

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  State<WeekCalendarAppBar> createState() => _WeekCalendarAppBarState();
}

class _WeekCalendarAppBarState extends State<WeekCalendarAppBar> {
  late DateTime _focusDay;
  late DateTime _selectedDay;

  static const List<String> _weekdayInitials = <String>[
    'L',
    'M',
    'M',
    'G',
    'V',
    'S',
    'D'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate ?? DateTime.now();
    _focusDay = _selectedDay;
  }

  @override
  void didUpdateWidget(covariant WeekCalendarAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null &&
        widget.initialDate != oldWidget.initialDate) {
      _selectedDay = widget.initialDate!;
      _focusDay = widget.initialDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime startOfWeek =
        _focusDay.subtract(Duration(days: _focusDay.weekday - 1));
    final DateTime today = DateTime.now();

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: widget.preferredSize.height,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: widget.onAvatarTap,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      widget.avatarInitials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: theme.colorScheme.primary,
                  onPressed: widget.onNotificationTap,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Il tuo programma della settimana',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List<Widget>.generate(7, (int index) {
                final DateTime day = startOfWeek.add(Duration(days: index));
                final bool isSelected = _isSameDate(day, _selectedDay);
                final bool isToday = _isSameDate(day, today);
                final bool hasWorkout =
                    widget.weekdayWithWorkout.contains(day.weekday);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDayTapped(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _weekdayInitials[index],
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected || isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isToday
                                      ? theme.colorScheme.primary
                                          .withOpacity(0.1)
                                      : theme.colorScheme.surface),
                              border: isToday && !isSelected
                                  ? Border.all(color: theme.colorScheme.primary)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString().padLeft(2, '0'),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
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
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary,
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
        ),
      ),
    );
  }

  void _onDayTapped(DateTime day) {
    setState(() => _selectedDay = day);
    widget.onDaySelected?.call(day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
