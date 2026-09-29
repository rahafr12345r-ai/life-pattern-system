import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dashboard_data.dart';
import '../models/checkin_record.dart';
import '../models/risk_assessment.dart';

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  Stream<BehavioralSummary> watchPatientSummary(String uid) {
    return _firestore
        .collection('behavioral_data')
        .doc(uid)
        .collection('daily')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return BehavioralSummary.empty;
      return BehavioralSummary.fromDocument(snapshot.docs.first);
    });
  }

  Stream<List<PatientSummary>> watchPatients() {
    return _firestore.collection('users').where('role', isEqualTo: 'Patient').snapshots().map(
          (snapshot) => snapshot.docs.map(PatientSummary.fromDocument).toList(),
        );
  }

  Stream<List<CheckinRecord>> watchCheckins(String uid) {
    return _firestore
        .collection('behavioral_data')
        .doc(uid)
        .collection('daily')
        .orderBy('date', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CheckinRecord.fromDocument).toList());
  }

  Stream<RiskAssessment?> watchRiskAssessment(String uid) {
    return _firestore
        .collection('risk_assessments')
        .doc(uid)
        .collection('daily')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : RiskAssessment.fromDocument(snapshot.docs.first));
  }
}
