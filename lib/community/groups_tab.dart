// groups_tab.dart
// Tab Gruppi con lista di gruppi disponibili

import 'package:flutter/cupertino.dart';
import 'components/group_card.dart';
import 'fake_repository.dart';
import 'models.dart';

/// Tab Gruppi della Community
/// Mostra lista di gruppi con possibilità di iscriversi
class GroupsTab extends StatefulWidget {
  const GroupsTab({super.key});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  final FakeCommunityRepository _repository = FakeCommunityRepository();
  late List<Group> _groups;

  @override
  void initState() {
    super.initState();
    _groups = _repository.getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Gruppi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connettiti con persone che condividono le tue esigenze',
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista gruppi
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Group group = _groups[index];
              return GroupCard(
                group: group,
                onAction: () => _handleGroupAction(group),
              );
            },
            childCount: _groups.length,
          ),
        ),

        // Spazio finale
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  // ========== ACTIONS ==========

  /// Gestisce azione su gruppo (Entra/Visualizza)
  void _handleGroupAction(Group group) {
    if (group.isMember) {
      // Visualizza gruppo
      _showComingSoon('Visualizzazione Gruppo');
    } else {
      // Entra nel gruppo
      _showJoinGroupDialog(group);
    }
  }

  /// Dialog per entrare in un gruppo
  void _showJoinGroupDialog(Group group) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text('Entrare in "${group.name}"?'),
          content: Text(
            '${group.description}\n\n'
            'Riceverai notifiche per i nuovi post e potrai partecipare alle discussioni.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _joinGroup(group);
              },
              isDefaultAction: true,
              child: const Text('Entra'),
            ),
          ],
        );
      },
    );
  }

  /// Entra in un gruppo
  void _joinGroup(Group group) {
    setState(() {
      final int index = _groups.indexWhere((Group g) => g.id == group.id);
      if (index != -1) {
        _groups[index] = group.copyWith(
          membershipStatus: GroupMembership.member,
          memberCount: group.memberCount + 1,
        );
      }
    });

    // Feedback positivo
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✓ Sei entrato nel gruppo!',
              style: TextStyle(
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

    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  /// Mostra dialog "Presto disponibile"
  void _showComingSoon(String feature) {
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
}
