// group_card.dart
// Widget per un singolo gruppo nella lista gruppi

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Card per un singolo gruppo
/// Mostra nome, descrizione, membri e CTA (Entra/Visualizza)
class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.onAction,
    super.key,
  });

  final Group group;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Icona gruppo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  CupertinoColors.activeBlue.withValues(alpha: 0.8),
                  CupertinoColors.activeBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              group.iconEmoji ?? '👥',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),

          // Info gruppo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Nome + badge membro
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (group.isMember) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Membro',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Descrizione
                Text(
                  group.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Membri + CTA
                Row(
                  children: <Widget>[
                    // Numero membri
                    const Icon(
                      CupertinoIcons.person_2,
                      size: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount} membri',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const Spacer(),

                    // CTA
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: group.isMember
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: onAction,
                      child: Text(
                        group.isMember ? 'Visualizza' : 'Entra',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: group.isMember
                              ? CupertinoColors.label
                              : CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
