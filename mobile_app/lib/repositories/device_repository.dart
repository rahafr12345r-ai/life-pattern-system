import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectedDevice {
  const ConnectedDevice({required this.id, required this.name, required this.type, required this.connected});
  final String id;
  final String name;
  final String type;
  final bool connected;

  factory ConnectedDevice.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ConnectedDevice(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      type: data['type'] as String? ?? 'wearable',
      connected: data['connected'] as bool? ?? false,
    );
  }
}

class DeviceRepository {
  DeviceRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _devices(String uid) =>
      _firestore.collection('users').doc(uid).collection('connected_devices');

  Stream<List<ConnectedDevice>> watchDevices(String uid) =>
      _devices(uid).snapshots().map((snapshot) => snapshot.docs.map(ConnectedDevice.fromDocument).toList());

  Future<void> setConnection({required String uid, required ConnectedDevice device, required bool connected}) {
    return _devices(uid).doc(device.id).set({
      'name': device.name,
      'type': device.type,
      'connected': connected,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
