// models.dart
// Modelli dati per la sezione Community
// Immutabili e fortemente tipizzati

/// Tipo di post nella bacheca
enum PostType {
  progress('Progresso'),
  quickQuestion('Domanda Rapida');

  const PostType(this.label);
  final String label;
}

/// Stato di appartenenza a un gruppo
enum GroupMembership {
  member('Membro'),
  notMember('Non Membro');

  const GroupMembership(this.label);
  final String label;
}

/// Post nella bacheca community
class Post {
  final String id;
  final String authorName;
  final String authorInitials;
  final String content;
  final PostType type;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isLikedByUser;

  const Post({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    required this.type,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLikedByUser = false,
  });

  /// Tempo trascorso dalla pubblicazione (es. "2h fa")
  String get timeAgo {
    final Duration diff = DateTime.now().difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}g fa';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h fa';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m fa';
    } else {
      return 'Ora';
    }
  }

  /// Copia con modifiche
  Post copyWith({
    bool? isLikedByUser,
    int? likes,
    int? comments,
  }) {
    return Post(
      id: id,
      authorName: authorName,
      authorInitials: authorInitials,
      content: content,
      type: type,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }
}

/// Gruppo community
class Group {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final GroupMembership membershipStatus;
  final String? iconEmoji;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.membershipStatus,
    this.iconEmoji,
  });

  /// È membro?
  bool get isMember => membershipStatus == GroupMembership.member;

  /// Copia con modifiche
  Group copyWith({
    GroupMembership? membershipStatus,
    int? memberCount,
  }) {
    return Group(
      id: id,
      name: name,
      description: description,
      memberCount: memberCount ?? this.memberCount,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      iconEmoji: iconEmoji,
    );
  }
}

/// Sfida settimanale
class Challenge {
  final String id;
  final String title;
  final String description;
  final bool isUserParticipating;
  final int participantsCount;
  final DateTime endDate;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.isUserParticipating,
    required this.participantsCount,
    required this.endDate,
  });

  /// Giorni rimanenti
  int get daysRemaining {
    final Duration diff = endDate.difference(DateTime.now());
    return diff.inDays;
  }

  /// Copia con modifiche
  Challenge copyWith({
    bool? isUserParticipating,
    int? participantsCount,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      isUserParticipating: isUserParticipating ?? this.isUserParticipating,
      participantsCount: participantsCount ?? this.participantsCount,
      endDate: endDate,
    );
  }
}
