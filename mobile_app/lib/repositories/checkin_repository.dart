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
    double sleepHours = 7,
    int activitySteps = 6000,
  }) async {
    final now = DateTime.now();
    final dayId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _firestore.collection('behavioral_data').doc(uid).collection('daily').doc(dayId).set({
      // Use a client timestamp for immediate local rendering and keep the
      // server timestamp separately for authoritative synchronization.
      'date': Timestamp.fromDate(now),
      'mood': mood,
      'sleepQuality': sleepQuality,
      'sleepHours': sleepHours,
      'activitySteps': activitySteps,
      'notes': notes.trim(),
      'source': 'manual_checkin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveHealthSummary({required String uid, required HealthSummary summary}) async {
    final now = DateTime.now();
    final dayId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final fields = <String, dynamic>{
      'date': Timestamp.fromDate(now),
      'source': 'health_platform',
      'updatedAt': FieldValue.serverTimestamp(),
      if (summary.steps > 0) 'activitySteps': summary.steps,
      if (summary.sleepHours > 0) 'sleepHours': summary.sleepHours,
    };
    await _firestore.collection('behavioral_data').doc(uid).collection('daily').doc(dayId).set(fields, SetOptions(merge: true));
  }
}
