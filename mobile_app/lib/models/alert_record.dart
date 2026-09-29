import 'package:cloud_firestore/cloud_firestore.dart';

class AlertRecord {
  const AlertRecord({required this.id, required this.title, required this.message, required this.severity, required this.read, required this.createdAt});
  final String id;
  final String title;
  final String message;
  final String severity;
  final bool read;
  final DateTime createdAt;

  factory AlertRecord.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return AlertRecord(id: doc.id, title: data['title'] as String? ?? 'Pattern update', message: data['message'] as String? ?? '', severity: data['severity'] as String? ?? 'info', read: data['read'] as bool? ?? false, createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now());
  }
}
