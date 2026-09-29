import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionRequest {
  const ConnectionRequest({required this.id, required this.patientId, required this.doctorId, required this.status, required this.createdAt});
  final String id;
  final String patientId;
  final String doctorId;
  final String status;
  final DateTime createdAt;

  factory ConnectionRequest.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return ConnectionRequest(id: doc.id, patientId: data['patientId'] as String? ?? '', doctorId: data['doctorId'] as String? ?? '', status: data['status'] as String? ?? 'pending', createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now());
  }
}
