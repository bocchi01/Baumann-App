import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/posture_path.dart';
import 'path_repository.dart';

export 'path_repository.dart';

final Provider<IPathRepository> pathRepositoryProvider =
    Provider<IPathRepository>((Ref ref) {
  return FirestorePathRepository();
});

class FirestorePathRepository implements IPathRepository {
  FirestorePathRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    IPathRepository? fallbackRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance,
        _fallbackRepository = fallbackRepository ?? MockPathRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IPathRepository _fallbackRepository;

  CollectionReference<Map<String, dynamic>> get _userProgressCollection =>
      _firestore.collection('user_progress');

  @override
  Future<PosturePath> fetchCurrentUserPath() {
    return _fallbackRepository.fetchCurrentUserPath();
  }

  @override
  Future<void> markSessionAsComplete(String sessionId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await _userProgressCollection.doc(userId).set(
      <String, dynamic>{
        'completedSessions': FieldValue.arrayUnion(<String>[sessionId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<Set<String>> getCompletedSessionIds() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return <String>{};
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _userProgressCollection.doc(userId).get();

    if (!snapshot.exists) {
      return <String>{};
    }

    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return <String>{};
    }

    final dynamic rawCompleted = data['completedSessions'];
    if (rawCompleted is Iterable) {
      return rawCompleted.whereType<String>().toSet();
    }

    return <String>{};
  }
}
