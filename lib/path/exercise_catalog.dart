import '../models/exercise.dart';

class MockExerciseCatalog {
  const MockExerciseCatalog();

  static const String _placeholderVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  static const Map<String, Exercise> _catalog = <String, Exercise>{
    'stretch_cat_camel': Exercise(
      id: 'stretch_cat_camel',
      name: 'Mobilizzazione Gatto-Cammello',
      description:
          'Alterna flessione ed estensione della colonna per mobilizzare la schiena.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Colonna dorsale',
    ),
    'thoracic_rotation': Exercise(
      id: 'thoracic_rotation',
      name: 'Rotazioni Toraciche',
      description:
          'Migliora la rotazione del torace con movimenti controllati.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Torace',
    ),
    'hip_circles': Exercise(
      id: 'hip_circles',
      name: 'Circle anche in stazione quadrupedica',
      description: 'Disegna cerchi con le anche per stimolare la mobilità.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Anche',
    ),
    'breathing_reset': Exercise(
      id: 'breathing_reset',
      name: 'Reset Respiratorio',
      description: 'Tecnica di respirazione profonda per rilassare la postura.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Diaframma',
    ),
    'wall_slides': Exercise(
      id: 'wall_slides',
      name: 'Wall Slides',
      description: 'Scivolate al muro per attivare la muscolatura scapolare.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Spalle',
    ),
    'glute_bridge': Exercise(
      id: 'glute_bridge',
      name: 'Ponte Glutei',
      description: 'Rinforza glutei e muscoli posteriori con il bridge.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Glutei',
    ),
    'plank_hold': Exercise(
      id: 'plank_hold',
      name: 'Plank Isometrico',
      description: 'Mantieni il plank per stabilizzare il core.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Core',
    ),
    'child_pose': Exercise(
      id: 'child_pose',
      name: 'Child Pose',
      description: 'Allunga la schiena e rilassa le spalle.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Colonna',
    ),
    'foam_roll_thoracic': Exercise(
      id: 'foam_roll_thoracic',
      name: 'Foam Roll Torace',
      description:
          'Rilascio miofasciale della colonna toracica con foam roller.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Colonna dorsale',
    ),
    'neck_mobility': Exercise(
      id: 'neck_mobility',
      name: 'Mobilità Cervicale',
      description: 'Sequenza di mobilità per le vertebre cervicali.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Collo',
    ),
    'box_breathing': Exercise(
      id: 'box_breathing',
      name: 'Box Breathing',
      description: 'Tecnica di respirazione quadrata per il rilassamento.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Sistema nervoso',
    ),
    'band_pull_apart': Exercise(
      id: 'band_pull_apart',
      name: 'Band Pull Apart',
      description: 'Apri l’elastico per attivare retrattori scapolari.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Spalle',
    ),
    'split_squat_hold': Exercise(
      id: 'split_squat_hold',
      name: 'Affondo Isometrico',
      description: 'Mantieni l’affondo per potenziare stabilità e forza.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Gambe',
    ),
    'thoracic_extension_wall': Exercise(
      id: 'thoracic_extension_wall',
      name: 'Estensioni Toraciche al Muro',
      description: 'Apri il torace con esercizi al muro.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Torace',
    ),
    'thoracic_opener': Exercise(
      id: 'thoracic_opener',
      name: 'Thoracic Opener',
      description:
          'Sequenza dinamica per aprire e mobilizzare la colonna toracica.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Torace',
    ),
    'spinal_wave': Exercise(
      id: 'spinal_wave',
      name: 'Spinal Wave',
      description:
          'Movimento fluido per mobilizzare ogni segmento della colonna.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Colonna',
    ),
    'wall_angel_hold': Exercise(
      id: 'wall_angel_hold',
      name: 'Wall Angel Hold',
      description: 'Mantieni le braccia al muro per attivare scapole e spalle.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Spalle',
    ),
    'cat_camel': Exercise(
      id: 'cat_camel',
      name: 'Cat Camel',
      description:
          'Esegui il movimento gatto-cammello per mobilizzare la colonna.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Colonna',
    ),
    'mobility_flow': Exercise(
      id: 'mobility_flow',
      name: 'Mobility Flow Completo',
      description:
          'Sequenza fluida che combina mobilità, respirazione e controllo.',
      videoUrl: _placeholderVideoUrl,
      targetArea: 'Total body',
    ),
  };

  Exercise getById(String id) {
    return _catalog[id] ??
        const Exercise(
          id: 'unknown',
          name: 'Esercizio Sconosciuto',
          description:
              'Questo esercizio non è presente nel catalogo. Riprendi dalla dashboard.',
          videoUrl: _placeholderVideoUrl,
          targetArea: 'Generale',
        );
  }
}
