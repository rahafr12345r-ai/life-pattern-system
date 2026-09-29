import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRecord {
  const MessageRecord({required this.id, required this.senderId, required this.recipientId, required this.text, required this.read, required this.createdAt});
  final String id;
  final String senderId;
  final String recipientId;
  final String text;
  final bool read;
  final DateTime createdAt;

  factory MessageRecord.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return MessageRecord(id: doc.id, senderId: data['senderId'] as String? ?? '', recipientId: data['recipientId'] as String? ?? '', text: data['text'] as String? ?? '', read: data['read'] as bool? ?? false, createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now());
  }
}
