import 'package:cloud_firestore/cloud_firestore.dart';

class BehavioralSummary {
  const BehavioralSummary({
    required this.sleepHours,
    required this.activitySteps,
    required this.mood,
    required this.alertCount,
    required this.riskScore,
  });

  final double sleepHours;
  final int activitySteps;
  final String mood;
  final int alertCount;
  final int riskScore;

  factory BehavioralSummary.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return BehavioralSummary(
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 0,
      activitySteps: (data['activitySteps'] as num?)?.toInt() ?? 0,
      mood: data['mood'] as String? ?? 'Not recorded',
      alertCount: (data['alertCount'] as num?)?.toInt() ?? 0,
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = BehavioralSummary(
    sleepHours: 0,
    activitySteps: 0,
    mood: 'Not recorded',
    alertCount: 0,
    riskScore: 0,
  );
}

class PatientSummary {
  const PatientSummary({required this.uid, required this.name, required this.email, required this.status, this.studentId});

  final String uid;
  final String name;
  final String email;
  final String status;
  final String? studentId;

  factory PatientSummary.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return PatientSummary(
      uid: doc.id,
      name: data['displayName'] as String? ?? data['email'] as String? ?? 'Unnamed patient',
      email: data['email'] as String? ?? '',
      status: data['patientStatus'] as String? ?? 'Connected',
      studentId: data['studentId'] as String?,
    );
  }
}
