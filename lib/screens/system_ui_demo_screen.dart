// system_ui_demo_screen.dart
// Baumann Posture App - Demo dei componenti di sistema iOS nativi
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import '../system_ui.dart';
import '../theme/theme.dart';

/// Schermata demo per testare tutti i componenti SystemUI
class SystemUIDemo extends StatefulWidget {
  const SystemUIDemo({super.key});

  @override
  State<SystemUIDemo> createState() => _SystemUIDemoState();
}

class _SystemUIDemoState extends State<SystemUIDemo> {
  String _selectedDate = 'Nessuna data selezionata';
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        AppTheme.liquidGlassBackground,
        context,
      ),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('System UI Demo'),
        backgroundColor: CupertinoDynamicColor.withBrightness(
          color: Color(0x00FFFFFF),
          darkColor: Color(0x00000000),
        ),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // Share
            _SectionHeader(
              icon: CupertinoIcons.square_arrow_up,
              title: 'Share Sheet',
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Condividi Testo',
              icon: CupertinoIcons.text_bubble,
              onPressed: () async {
                await SystemUI.share(
                  text: 'Ciao da Baumann Posture App! 👋',
                  subject: 'Prova app',
                );
                await SystemUI.haptic(HapticType.success);
              },
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Condividi URL',
              icon: CupertinoIcons.link,
              onPressed: () async {
                await SystemUI.share(
                  text: 'Dai un\'occhiata a questa app!',
                  url: 'https://baumannapp.com',
                );
                await SystemUI.haptic(HapticType.success);
              },
            ),
            const SizedBox(height: 8),
            RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppTheme.baumannPrimaryBlue,
                      AppTheme.baumannPrimaryBlue.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '📸 Screenshot Demo',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Condividi Screenshot',
              icon: CupertinoIcons.photo,
              onPressed: () => _shareScreenshot(),
            ),

            const SizedBox(height: 24),

            // Action Sheets
            _SectionHeader(
              icon: CupertinoIcons.rectangle_grid_1x2,
              title: 'Action Sheet',
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Opzioni Post',
              icon: CupertinoIcons.ellipsis_circle,
              onPressed: () => _showPostActions(),
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Opzioni con Icone',
              icon: CupertinoIcons.square_list,
              onPressed: () => _showIconActions(),
            ),

            const SizedBox(height: 24),

            // Alerts
            _SectionHeader(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: 'Alert Dialog',
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Conferma Eliminazione',
              icon: CupertinoIcons.trash,
              color: CupertinoColors.destructiveRed,
              onPressed: () => _showDeleteConfirmation(),
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Info Alert',
              icon: CupertinoIcons.info_circle,
              onPressed: () => _showInfoAlert(),
            ),

            const SizedBox(height: 24),

            // Date Picker
            _SectionHeader(
              icon: CupertinoIcons.calendar,
              title: 'Date & Time Picker',
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Seleziona Data',
              icon: CupertinoIcons.calendar_badge_plus,
              onPressed: () => _showDatePicker(),
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Seleziona Orario',
              icon: CupertinoIcons.clock,
              onPressed: () => _showTimePicker(),
            ),
            const SizedBox(height: 8),
            _DemoButton(
              label: 'Seleziona Data e Ora',
              icon: CupertinoIcons.time,
              onPressed: () => _showDateTimePicker(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemFill,
                  context,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDate,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Haptics
            _SectionHeader(
              icon: CupertinoIcons.hand_raised,
              title: 'Haptic Feedback',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _HapticChip(label: 'Light', type: HapticType.light),
                _HapticChip(label: 'Medium', type: HapticType.medium),
                _HapticChip(label: 'Heavy', type: HapticType.heavy),
                _HapticChip(label: 'Selection', type: HapticType.selection),
                _HapticChip(label: 'Success', type: HapticType.success),
                _HapticChip(label: 'Warning', type: HapticType.warning),
                _HapticChip(label: 'Error', type: HapticType.error),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // MARK: - Actions

  Future<void> _shareScreenshot() async {
    await SystemUI.haptic(HapticType.light);

    final RenderRepaintBoundary boundary = _screenshotKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Condividi direttamente i bytes dell'immagine
    await SystemUI.share(
      text: 'Check out this Baumann demo!',
      imageData: pngBytes,
    );

    await SystemUI.haptic(HapticType.success);
  }

  Future<void> _showPostActions() async {
    await SystemUI.haptic(HapticType.light);
    await SystemUI.actionSheet(
      title: 'Opzioni Post',
      message: 'Cosa vuoi fare con questo post?',
      actions: const <ActionItem>[
        ActionItem('Condividi'),
        ActionItem('Copia Link'),
        ActionItem('Segnala'),
        ActionItem('Elimina', style: 'destructive'),
        ActionItem('Annulla', style: 'cancel'),
      ],
      onSelected: (index) async {
        await SystemUI.haptic(HapticType.selection);
        if (mounted) {
          _showToast('Selezionato: ${<String>[
            'Condividi',
            'Copia Link',
            'Segnala',
            'Elimina',
            'Annulla'
          ][index]}');
        }
      },
    );
  }

  Future<void> _showIconActions() async {
    await SystemUI.haptic(HapticType.light);
    await SystemUI.actionSheet(
      title: 'Azioni Rapide',
      actions: const <ActionItem>[
        ActionItem('Condividi', icon: 'square.and.arrow.up'),
        ActionItem('Preferiti', icon: 'star'),
        ActionItem('Modifica', icon: 'pencil'),
        ActionItem('Elimina', style: 'destructive', icon: 'trash'),
        ActionItem('Annulla', style: 'cancel'),
      ],
      onSelected: (index) async {
        await SystemUI.haptic(HapticType.selection);
      },
    );
  }

  Future<void> _showDeleteConfirmation() async {
    await SystemUI.haptic(HapticType.warning);
    await SystemUI.alert(
      title: 'Elimina elemento',
      message: 'Questa azione non può essere annullata.',
      actions: const <ActionItem>[
        ActionItem('Elimina', style: 'destructive'),
        ActionItem('Annulla', style: 'cancel'),
      ],
      onSelected: (index) async {
        if (index == 0) {
          await SystemUI.haptic(HapticType.success);
          if (mounted) _showToast('Elemento eliminato');
        }
      },
    );
  }

  Future<void> _showInfoAlert() async {
    await SystemUI.haptic(HapticType.light);
    await SystemUI.alert(
      title: 'Informazioni',
      message: 'Questa è una demo dei componenti di sistema iOS nativi integrati con Flutter.',
      actions: const <ActionItem>[
        ActionItem('OK'),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    await SystemUI.haptic(HapticType.light);
    final date = await SystemUI.datePicker(
      mode: 'date',
      initialDate: DateTime.now().toIso8601String(),
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = 'Data: $date');
      await SystemUI.haptic(HapticType.success);
    }
  }

  Future<void> _showTimePicker() async {
    await SystemUI.haptic(HapticType.light);
    final time = await SystemUI.datePicker(
      mode: 'time',
      initialDate: DateTime.now().toIso8601String(),
    );
    if (time != null && mounted) {
      setState(() => _selectedDate = 'Ora: $time');
      await SystemUI.haptic(HapticType.success);
    }
  }

  Future<void> _showDateTimePicker() async {
    await SystemUI.haptic(HapticType.light);
    final dateTime = await SystemUI.datePicker(
      mode: 'dateTime',
      initialDate: DateTime.now().toIso8601String(),
    );
    if (dateTime != null && mounted) {
      setState(() => _selectedDate = 'Data e Ora: $dateTime');
      await SystemUI.haptic(HapticType.success);
    }
  }

  void _showToast(String message) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(color: CupertinoColors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}

// MARK: - Widgets

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppTheme.baumannPrimaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.systemFill,
                context,
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color?.withValues(alpha: 0.3) ??
                CupertinoDynamicColor.resolve(
                  CupertinoColors.separator,
                  context,
                ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: color ?? AppTheme.baumannPrimaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color ??
                      CupertinoDynamicColor.resolve(
                        CupertinoColors.label,
                        context,
                      ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HapticChip extends StatelessWidget {
  const _HapticChip({required this.label, required this.type});

  final String label;
  final HapticType type;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => SystemUI.haptic(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.baumannPrimaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.baumannPrimaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.baumannPrimaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
