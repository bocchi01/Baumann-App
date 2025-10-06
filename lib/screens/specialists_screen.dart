import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/specialist_model.dart';
import '../repositories/specialist_repository.dart';
import '../theme/theme.dart';

final Provider<ISpecialistRepository> specialistRepositoryProvider =
    Provider<ISpecialistRepository>((Ref ref) {
  return const MockSpecialistRepository();
});

final availableSpecialistsProvider =
    FutureProvider.autoDispose<List<Specialist>>((Ref ref) {
  final ISpecialistRepository repository =
      ref.watch(specialistRepositoryProvider);
  return repository.getAvailableSpecialists();
});

class SpecialistsScreen extends ConsumerWidget {
  const SpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Specialist>> specialists =
        ref.watch(availableSpecialistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli il tuo Specialista'),
      ),
      body: specialists.when(
        data: (List<Specialist> data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('Nessun professionista disponibile al momento.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: 16),
            itemBuilder: (BuildContext context, int index) {
              final Specialist specialist = data[index];
              return _SpecialistCard(specialist: specialist);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline,
                      size: 42, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    'Impossibile caricare gli specialisti in questo momento.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.invalidate(availableSpecialistsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Riprova'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({required this.specialist});

  final Specialist specialist;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Hai selezionato ${specialist.name}'),
              ),
            );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(specialist.profileImageUrl),
                backgroundColor: AppTheme.baumannSecondaryBlue,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      specialist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialist.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      specialist.bio,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: specialist.specializations
                          .map(
                            (String label) => Chip(
                              label: Text(label),
                              backgroundColor: AppTheme.baumannAccentOrange
                                  .withValues(alpha: 0.18),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.baumannAccentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
