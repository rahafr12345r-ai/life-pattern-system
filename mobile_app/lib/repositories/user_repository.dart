import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createProfile({
    required User user,
    required String role,
  }) async {
    await _users.doc(user.uid).set({
      'email': user.email ?? '',
      'role': role,
      'consentAccepted': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (user.displayName != null) 'displayName': user.displayName,
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromDocument(snapshot);
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    return UserProfile.fromDocument(snapshot);
  }

  Future<void> updateConsent({
    required String uid,
    required bool accepted,
  }) {
    return _users.doc(uid).set({
      'consentAccepted': accepted,
      'consentUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
