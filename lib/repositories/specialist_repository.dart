import 'dart:async';

import '../models/specialist_model.dart';

abstract class ISpecialistRepository {
  Future<List<Specialist>> getAvailableSpecialists();
}

class MockSpecialistRepository implements ISpecialistRepository {
  const MockSpecialistRepository();

  static const Duration _fakeLatency = Duration(milliseconds: 650);

  @override
  Future<List<Specialist>> getAvailableSpecialists() async {
    await Future<void>.delayed(_fakeLatency);

    return const <Specialist>[
      Specialist(
        id: 'spec-001',
        name: 'Dr.ssa Martina Rossi',
        title: 'Fisioterapista, Esperta in Postura',
        profileImageUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
        bio:
            '15 anni di esperienza in riabilitazione posturale per atleti e lavoratori da ufficio.',
        specializations: <String>['Dolore Lombare', 'Cervicalgia', 'Ergonomia'],
      ),
      Specialist(
        id: 'spec-002',
        name: 'Luca Bianchi',
        title: 'Chinesiologo Clinico',
        profileImageUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e2',
        bio:
            'Aiuto le persone a ritrovare la mobilità con protocolli personalizzati e coaching continuo.',
        specializations: <String>['Rieducazione Funzionale', 'Core Stability'],
      ),
      Specialist(
        id: 'spec-003',
        name: 'Dr. Elisa Conti',
        title: 'Osteopata D.O.',
        profileImageUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e3',
        bio:
            'Approccio integrato per il benessere della colonna vertebrale e la prevenzione del dolore cronico.',
        specializations: <String>[
          'Sciatalgia',
          'Prevenzione Infortuni',
          'Benessere Vertebrale'
        ],
      ),
    ];
  }
}
