import 'package:cloud_firestore/cloud_firestore.dart';

class RiskAssessment {
  const RiskAssessment({required this.score, required this.level, required this.factors, required this.recommendation, required this.createdAt});
  final int score;
  final String level;
  final List<String> factors;
  final String recommendation;
  final DateTime createdAt;

  factory RiskAssessment.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return RiskAssessment(score: (data['score'] as num?)?.toInt() ?? 0, level: data['level'] as String? ?? 'low', factors: (data['factors'] as List<dynamic>? ?? const []).whereType<String>().toList(), recommendation: data['recommendation'] as String? ?? '', createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now());
  }
}
