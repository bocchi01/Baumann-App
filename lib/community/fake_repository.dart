// fake_repository.dart
// Repository con dati fittizi per la Community
// Fornisce dati realistici per testing e sviluppo

import 'models.dart';

/// Repository fake per dati Community
class FakeCommunityRepository {
  /// Restituisce la sfida settimanale attiva
  Challenge getActiveChallenge() {
    return Challenge(
      id: 'challenge_1',
      title: 'Sfida della Settimana: 7 Giorni Perfetti',
      description:
          'Completa tutte le sessioni pianificate per 7 giorni consecutivi!',
      isUserParticipating: false,
      participantsCount: 142,
      endDate: DateTime.now().add(const Duration(days: 4)),
    );
  }

  /// Restituisce lista di post per la bacheca
  List<Post> getPosts() {
    final DateTime now = DateTime.now();

    return <Post>[
      Post(
        id: 'post_1',
        authorName: 'Marco R.',
        authorInitials: 'MR',
        content:
            'Completata la mia 10ª sessione! Il dolore alla schiena è praticamente sparito. Grazie al team Baumann! 🎉',
        type: PostType.progress,
        likes: 24,
        comments: 8,
        timestamp: now.subtract(const Duration(hours: 2)),
        isLikedByUser: true,
      ),
      Post(
        id: 'post_2',
        authorName: 'Giulia M.',
        authorInitials: 'GM',
        content:
            'Chi ha consigli per mantenere la postura corretta durante le videochiamate infinite? 😅',
        type: PostType.quickQuestion,
        likes: 12,
        comments: 15,
        timestamp: now.subtract(const Duration(hours: 5)),
        isLikedByUser: false,
      ),
      Post(
        id: 'post_3',
        authorName: 'Luca B.',
        authorInitials: 'LB',
        content:
            'Prima settimana completata! Non pensavo che 12 minuti al giorno potessero fare così tanta differenza.',
        type: PostType.progress,
        likes: 31,
        comments: 6,
        timestamp: now.subtract(const Duration(hours: 8)),
        isLikedByUser: false,
      ),
      Post(
        id: 'post_4',
        authorName: 'Sofia T.',
        authorInitials: 'ST',
        content:
            'Qualcuno ha sperimentato l\'esercizio della "plank modificata"? Come vi siete trovati?',
        type: PostType.quickQuestion,
        likes: 8,
        comments: 11,
        timestamp: now.subtract(const Duration(hours: 12)),
        isLikedByUser: false,
      ),
      Post(
        id: 'post_5',
        authorName: 'Andrea P.',
        authorInitials: 'AP',
        content:
            '30 giorni di aderenza al 100%! Mi sento una persona nuova. Il segreto? Sessioni mattutine appena sveglio. ☀️',
        type: PostType.progress,
        likes: 45,
        comments: 12,
        timestamp: now.subtract(const Duration(days: 1)),
        isLikedByUser: true,
      ),
      Post(
        id: 'post_6',
        authorName: 'Francesca D.',
        authorInitials: 'FD',
        content:
            'Piccolo traguardo: oggi sono riuscita a stare seduta per 2 ore senza dolore! Grazie community per il supporto 💪',
        type: PostType.progress,
        likes: 38,
        comments: 9,
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        isLikedByUser: false,
      ),
    ];
  }

  /// Restituisce lista di gruppi
  List<Group> getGroups() {
    return <Group>[
      const Group(
        id: 'group_1',
        name: 'Lavoro da Casa',
        description:
            'Per chi lavora da remoto e vuole mantenere una postura corretta durante le ore al computer.',
        memberCount: 243,
        membershipStatus: GroupMembership.member,
        iconEmoji: '💻',
      ),
      const Group(
        id: 'group_2',
        name: 'Neomamme e Neopapà',
        description:
            'Supporto e consigli per gestire la postura mentre ci si prende cura dei piccoli.',
        memberCount: 178,
        membershipStatus: GroupMembership.notMember,
        iconEmoji: '👶',
      ),
      const Group(
        id: 'group_3',
        name: 'Runner e Ciclisti',
        description:
            'Esercizi specifici per prevenire infortuni e migliorare le performance sportive.',
        memberCount: 312,
        membershipStatus: GroupMembership.member,
        iconEmoji: '🏃',
      ),
      const Group(
        id: 'group_4',
        name: 'Over 50',
        description:
            'Programmi personalizzati e supporto per mantenere mobilità e benessere.',
        memberCount: 156,
        membershipStatus: GroupMembership.notMember,
        iconEmoji: '🌟',
      ),
      const Group(
        id: 'group_5',
        name: 'Studenti e Universitari',
        description:
            'Consigli per studiare ore senza compromettere la salute della schiena.',
        memberCount: 189,
        membershipStatus: GroupMembership.notMember,
        iconEmoji: '📚',
      ),
      const Group(
        id: 'group_6',
        name: 'Dolore Cronico',
        description:
            'Supporto tra pari per chi affronta dolori posturali di lunga durata. Moderato da esperti.',
        memberCount: 127,
        membershipStatus: GroupMembership.notMember,
        iconEmoji: '🤝',
      ),
    ];
  }
}
