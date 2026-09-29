import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinRecord {
  const CheckinRecord({required this.id, required this.mood, required this.sleepQuality, required this.notes, required this.date});

  final String id;
  final String mood;
  final int sleepQuality;
  final String notes;
  final DateTime date;

  factory CheckinRecord.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['date'];
    return CheckinRecord(
      id: doc.id,
      mood: data['mood'] as String? ?? 'Not recorded',
      sleepQuality: (data['sleepQuality'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String? ?? '',
      date: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }
}
