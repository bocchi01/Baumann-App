// post_card.dart
// Widget per un singolo post nella bacheca

import 'package:flutter/cupertino.dart';
import '../models.dart';

/// Card per un singolo post
/// Mostra autore, contenuto, badge tipo, azioni (like, commenta, segnala)
class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onReport,
    super.key,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onReport;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: Avatar + Nome + Tempo + Badge
          Row(
            children: <Widget>[
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAvatarColor(post.authorInitials),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  post.authorInitials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nome e tempo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge tipo post
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBadgeColor(post.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _getBadgeEmoji(post.type),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.type.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Contenuto
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 15,
              color: CupertinoColors.label,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Azioni
          Row(
            children: <Widget>[
              // Like
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: onLike,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        post.isLikedByUser
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 18,
                        color: post.isLikedByUser
                            ? CupertinoColors.systemRed
                            : CupertinoColors.secondaryLabel,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: post.isLikedByUser
                              ? CupertinoColors.systemRed
                              : CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Commenta
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: onComment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        CupertinoIcons.chat_bubble,
                        size: 18,
                        color: CupertinoColors.secondaryLabel,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.comments}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Segnala
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: onReport,
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  size: 18,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Colore avatar basato su iniziali
  Color _getAvatarColor(String initials) {
    final int hash = initials.codeUnitAt(0);
    final List<Color> colors = <Color>[
      CupertinoColors.systemBlue,
      CupertinoColors.systemGreen,
      CupertinoColors.systemOrange,
      CupertinoColors.systemPurple,
      CupertinoColors.systemPink,
      CupertinoColors.systemTeal,
    ];
    return colors[hash % colors.length];
  }

  /// Colore badge basato su tipo post
  Color _getBadgeColor(PostType type) {
    switch (type) {
      case PostType.progress:
        return CupertinoColors.systemGreen;
      case PostType.quickQuestion:
        return CupertinoColors.systemBlue;
    }
  }

  /// Emoji badge basato su tipo post
  String _getBadgeEmoji(PostType type) {
    switch (type) {
      case PostType.progress:
        return '🎉';
      case PostType.quickQuestion:
        return '❓';
    }
  }
}
