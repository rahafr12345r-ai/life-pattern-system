import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    required this.consentAccepted,
    required this.createdAt,
    this.displayName,
  });

  final String uid;
  final String email;
  final String role;
  final bool consentAccepted;
  final DateTime createdAt;
  final String? displayName;

  factory UserProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'Patient',
      consentAccepted: data['consentAccepted'] as bool? ?? false,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      displayName: data['displayName'] as String?,
    );
  }

  Map<String, Object?> toFirestore() => {
        'email': email,
        'role': role,
        'consentAccepted': consentAccepted,
        'createdAt': Timestamp.fromDate(createdAt),
        if (displayName != null) 'displayName': displayName,
      };
}
