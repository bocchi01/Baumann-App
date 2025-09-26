import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _handleStartNow(BuildContext context) {
    debugPrint('Avvio flusso di acquisto Premium...');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passa a Premium'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Sblocca il Tuo Pieno Potenziale',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.baumannPrimaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Accedi a contenuti esclusivi, masterclass dedicate e un supporto prioritario pensato per il tuo benessere posturale.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 28),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppTheme.baumannAccentOrange.withValues(alpha: 0.4),
                    width: 1.6,
                  ),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.workspace_premium,
                              color: AppTheme.baumannAccentOrange, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Premium',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _BenefitRow(
                        icon: Icons.check_circle_outline,
                        label: 'Accesso a tutte le Masterclass',
                      ),
                      const _BenefitRow(
                        icon: Icons.check_circle_outline,
                        label: 'Consulenze 1-a-1 con i nostri esperti',
                      ),
                      const _BenefitRow(
                        icon: Icons.check_circle_outline,
                        label: 'Supporto prioritario e personalizzato',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '29,99€ / mese',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.baumannPrimaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.baumannAccentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          onPressed: () => _handleStartNow(context),
                          child: const Text('INIZIA ORA'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppTheme.baumannAccentOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
