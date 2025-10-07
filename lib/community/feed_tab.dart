// feed_tab.dart
// Tab Bacheca con sfida, quick post e feed dei post

import 'package:flutter/cupertino.dart';
import 'components/challenge_banner.dart';
import 'components/post_card.dart';
import 'fake_repository.dart';
import 'models.dart';

/// Tab Bacheca della Community
/// Mostra sfida settimanale, quick post input e feed
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final FakeCommunityRepository _repository = FakeCommunityRepository();
  late Challenge _challenge;
  late List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _challenge = _repository.getActiveChallenge();
    _posts = _repository.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        // 1. Challenge Banner
        SliverToBoxAdapter(
          child: ChallengeBanner(
            challenge: _challenge,
            onParticipate: _handleParticipateChallenge,
          ),
        ),

        // 2. Quick Post Input
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleQuickPost,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoTheme.brightnessOf(context) == Brightness.dark
                      ? CupertinoColors.systemGrey6.darkColor
                      : CupertinoColors.systemGrey6.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoTheme.brightnessOf(context) ==
                            Brightness.dark
                        ? CupertinoColors.separator.darkColor
                        : CupertinoColors.separator.color,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.chat_bubble_text,
                      size: 20,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Fai una domanda rapida o condividi un progresso...',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Intestazione feed
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Dalla Community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ),

        // 3. Feed dei Post
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Post post = _posts[index];
              return PostCard(
                post: post,
                onLike: () => _handleLikePost(post),
                onComment: () => _handleCommentPost(post),
                onReport: () => _handleReportPost(post),
              );
            },
            childCount: _posts.length,
          ),
        ),

        // Spazio finale per evitare che l'ultimo post sia coperto dalla tab bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  // ========== ACTIONS ==========

  /// Partecipa alla sfida
  void _handleParticipateChallenge() {
    setState(() {
      _challenge = _challenge.copyWith(
        isUserParticipating: true,
        participantsCount: _challenge.participantsCount + 1,
      );
    });

    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Sfida Accettata! 🎯'),
          content: const Text(
            'Fantastico! Ti invieremo promemoria quotidiani per aiutarti a completare la sfida.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
              child: const Text('Perfetto!'),
            ),
          ],
        );
      },
    );
  }

  /// Apri quick post
  void _handleQuickPost() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Cosa vuoi condividere?'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _showComingSoon('Condividi Progresso');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('🎉 '),
                  Text('Condividi un Progresso'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(modalContext).pop();
                _showComingSoon('Domanda Rapida');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('❓ '),
                  Text('Fai una Domanda Rapida'),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(modalContext).pop(),
            isDestructiveAction: true,
            child: const Text('Annulla'),
          ),
        );
      },
    );
  }

  /// Like post
  void _handleLikePost(Post post) {
    setState(() {
      final int index = _posts.indexWhere((Post p) => p.id == post.id);
      if (index != -1) {
        final Post updatedPost = post.copyWith(
          isLikedByUser: !post.isLikedByUser,
          likes: post.isLikedByUser ? post.likes - 1 : post.likes + 1,
        );
        _posts[index] = updatedPost;
      }
    });
  }

  /// Commenta post
  void _handleCommentPost(Post post) {
    _showComingSoon('Commenti');
  }

  /// Segnala post
  void _handleReportPost(Post post) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) => CupertinoActionSheet(
      title: const Text('Segnala Post'),
      message: const Text(
        'Aiutaci a mantenere la community sicura e rispettosa.',
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            _showReportConfirmation();
          },
          isDestructiveAction: true,
          child: const Text('Segnala come Inappropriato'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Blocca Autore'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(modalContext).pop(),
        child: const Text('Annulla'),
      ),
      ),
    );
  }

  /// Conferma segnalazione
  void _showReportConfirmation() {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Grazie per la segnalazione'),
          content: const Text(
            'Il nostro team revisiterà questo contenuto entro 24 ore.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
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
