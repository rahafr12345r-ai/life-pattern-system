import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/health_data_service.dart';

class CheckinRepository {
  CheckinRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  Future<void> saveDailyCheckin({
    required String uid,
    required String mood,
    required int sleepQuality,
    required String notes,
  }) async {
    final now = DateTime.now();
    final dayId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _firestore.collection('behavioral_data').doc(uid).collection('daily').doc(dayId).set({
      'date': FieldValue.serverTimestamp(),
      'mood': mood,
      'sleepQuality': sleepQuality,
      'notes': notes.trim(),
      'source': 'manual_checkin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveHealthSummary({required String uid, required HealthSummary summary}) async {
    final now = DateTime.now();
    final dayId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _firestore.collection('behavioral_data').doc(uid).collection('daily').doc(dayId).set({
      'date': FieldValue.serverTimestamp(),
      'activitySteps': summary.steps,
      'sleepHours': summary.sleepHours,
      'source': 'health_platform',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
