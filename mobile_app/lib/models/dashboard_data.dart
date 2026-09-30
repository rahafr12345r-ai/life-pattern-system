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
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 7,
      activitySteps: (data['activitySteps'] as num?)?.toInt() ?? 6000,
      mood: data['mood'] as String? ?? 'Not recorded',
      alertCount: (data['alertCount'] as num?)?.toInt() ?? 0,
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = BehavioralSummary(
    sleepHours: 7,
    activitySteps: 6000,
    mood: 'Good',
    alertCount: 0,
    riskScore: 0,
  );

  /// Safe demo/default values shown until a real check-in or health reading
  /// is available. They are replaced by Firestore values when a record exists.
  static BehavioralSummary defaultsFor(String uid) {
    const demo = <String, BehavioralSummary>{
      'qdFEFeJt5eUFqdt0PDLpKksqJeB2': BehavioralSummary(sleepHours: 7, activitySteps: 7000, mood: 'Good', alertCount: 0, riskScore: 67),
      'VSEORe4ar4g181mjflMFpea545X2': BehavioralSummary(sleepHours: 6.2, activitySteps: 5200, mood: 'Okay', alertCount: 0, riskScore: 54),
      'xM9bMPZNwUSjSebZp0aMUIHWj3h1': BehavioralSummary(sleepHours: 7.8, activitySteps: 8200, mood: 'Good', alertCount: 0, riskScore: 31),
      'pxQBwrhR7BRrQM4cVwwb2VrTIp12': BehavioralSummary(sleepHours: 5.4, activitySteps: 3100, mood: 'Low', alertCount: 1, riskScore: 78),
    };
    return demo[uid] ?? empty;
  }
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
