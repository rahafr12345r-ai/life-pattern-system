import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/connection_request.dart';

class ConnectionRepository {
  ConnectionRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('patient_therapist_links');

  Stream<List<ConnectionRequest>> watchForUser({required String uid, required bool doctor}) => _requests.where(doctor ? 'doctorId' : 'patientId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map(ConnectionRequest.fromDocument).toList());

  Future<void> requestConnection({required String patientId, required String doctorId}) => _requests.doc('${patientId}_$doctorId').set({'patientId': patientId, 'doctorId': doctorId, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

  Future<void> updateStatus({required String requestId, required String status}) => _requests.doc(requestId).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
}
