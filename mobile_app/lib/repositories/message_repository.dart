import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_record.dart';

class MessageRepository {
  MessageRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  Stream<List<MessageRecord>> watchInbox(String uid) => _firestore.collection('messages').where('recipientId', isEqualTo: uid).orderBy('createdAt', descending: true).limit(50).snapshots().map((snapshot) => snapshot.docs.map(MessageRecord.fromDocument).toList());

  Future<void> sendMessage({required String senderId, required String recipientId, required String text}) => _firestore.collection('messages').add({'senderId': senderId, 'recipientId': recipientId, 'text': text.trim(), 'read': false, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> markRead(String messageId) => _firestore.collection('messages').doc(messageId).update({'read': true, 'readAt': FieldValue.serverTimestamp()});

  Future<void> linkPatientToDoctor({required String patientId, required String doctorId}) => _firestore.collection('patient_therapist_links').doc('${patientId}_$doctorId').set({'patientId': patientId, 'doctorId': doctorId, 'status': 'active', 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
}
