// reminder_row.dart
// Widget per gestire preferenze promemoria giornaliero

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Widget per mostrare e modificare il promemoria
/// CupertinoSwitch + etichetta
class ReminderRow extends StatefulWidget {
  const ReminderRow({
    required this.pref,
    required this.onChanged,
    super.key,
  });

  final ReminderPref pref;
  final ValueChanged<bool> onChanged;

  @override
  State<ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<ReminderRow> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.pref.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoTheme.brightnessOf(context) == Brightness.dark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoTheme.brightnessOf(context) == Brightness.dark
              ? CupertinoColors.separator.darkColor
              : CupertinoColors.separator.color,
          width: 0.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Icona
          const Icon(
            CupertinoIcons.bell,
            size: 24,
            color: CupertinoColors.activeBlue,
          ),
          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Text(
              widget.pref.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
            ),
          ),

          // Switch
          CupertinoSwitch(
            value: _isEnabled,
            onChanged: (bool value) {
              setState(() => _isEnabled = value);
              widget.onChanged(value);
              
              // Feedback leggero
              _showFeedback(context, value);
            },
          ),
        ],
      ),
    );
  }

  /// Mostra feedback cambio stato promemoria
  void _showFeedback(BuildContext context, bool enabled) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: enabled
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              enabled ? 'Promemoria attivato' : 'Promemoria disattivato',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    // Chiudi automaticamente
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}
