// community_screen.dart
// Schermata principale Community con segmented control per Bacheca/Gruppi

import 'package:flutter/cupertino.dart';
import 'feed_tab.dart';
import 'groups_tab.dart';

/// Schermata Community
/// Container principale con segmented control per Bacheca/Gruppi
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    required this.onScrollNotification,
    super.key,
  });

  final bool Function(UserScrollNotification) onScrollNotification;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Community'),
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Segmented Control
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                children: const <int, Widget>{
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'Bacheca',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'Gruppi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
                onValueChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSegment = value;
                    });
                  }
                },
              ),
            ),

            // Content
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: widget.onScrollNotification,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedSegment == 0
                      ? const FeedTab(key: ValueKey<int>(0))
                      : const GroupsTab(key: ValueKey<int>(1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
