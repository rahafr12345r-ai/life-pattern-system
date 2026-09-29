import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_record.dart';

class AlertRepository {
  AlertRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  Stream<List<AlertRecord>> watchAlerts(String uid) => _firestore.collection('alerts').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).limit(50).snapshots().map((snapshot) => snapshot.docs.map(AlertRecord.fromDocument).toList());

  Future<void> markRead(String alertId) => _firestore.collection('alerts').doc(alertId).update({'read': true, 'readAt': FieldValue.serverTimestamp()});
}
