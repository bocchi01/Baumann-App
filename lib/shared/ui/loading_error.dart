import 'package:flutter/cupertino.dart';

/// Widget riutilizzabile per mostrare stato di loading
/// Usa CupertinoActivityIndicator in stile iOS
class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = 'Caricamento…',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(
            radius: 16,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget riutilizzabile per mostrare errori con possibilità di retry
/// Mostra CupertinoAlertDialog o un messaggio inline
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showAsDialog;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.showAsDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsDialog) {
      // Mostra come dialog (da chiamare con showCupertinoDialog)
      return CupertinoAlertDialog(
        title: const Text('Errore'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            CupertinoDialogAction(
              child: const Text('Riprova'),
              onPressed: () {
                Navigator.of(context).pop();
                onRetry!();
              },
            ),
          CupertinoDialogAction(
            isDestructiveAction: onRetry == null,
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    // Mostra come widget inline
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.label,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: onRetry,
                child: const Text('Riprova'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Helper statico per mostrare un dialog di errore
  static Future<void> showErrorDialog(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => ErrorDisplay(
        message: message,
        onRetry: onRetry,
        showAsDialog: true,
      ),
    );
  }
}

/// Widget per mostrare un banner di modalità offline
/// Si posiziona in alto per informare l'utente che sta usando dati cached
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: CupertinoColors.systemYellow.withOpacity(0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.wifi_slash,
            size: 16,
            color: CupertinoColors.systemYellow.darkColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Sei offline, uso dati salvati',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemYellow.darkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
