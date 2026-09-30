import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../messages/patient_messages_screen.dart';
import 'connected_devices_screen.dart';
import 'connect_therapist_screen.dart';
import 'connection_requests_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.role, required this.uid, super.key});
  final String role;
  final String uid;

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<UserProfile?>(
        stream: UserRepository().watchProfile(uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = profile?.displayName ?? 'Life Pattern user';
          final email = profile?.email ?? '';
          final initial = name.trim().isEmpty ? 'L' : name.trim()[0].toUpperCase();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(role, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Text(initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
                  title: Text(name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                  subtitle: Text(email, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 14),
              _ProfileAction(icon: Icons.devices_other, label: 'Connected devices', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectedDevicesScreen(uid: uid)))),
              if (role == 'Patient') _ProfileAction(icon: Icons.chat_bubble_outline, label: 'Messages', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PatientMessagesScreen(uid: uid)))),
              if (role == 'Patient') _ProfileAction(icon: Icons.link, label: 'Connect therapist', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectTherapistScreen(patientId: uid)))),
              if (role == 'Doctor') _ProfileAction(icon: Icons.person_add_alt_1, label: 'Connection requests', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectionRequestsScreen(doctorId: uid)))),
              const _ProfileAction(icon: Icons.edit_outlined, label: 'Edit profile'),
              const _ProfileAction(icon: Icons.language, label: 'Language'),
              const _ProfileAction(icon: Icons.lock_outline, label: 'Privacy'),
              const SizedBox(height: 18),
              _ProfileAction(icon: Icons.logout_rounded, label: 'Sign out', color: AppColors.error, onTap: () => _logout(context)),
            ],
          );
        },
      );
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.label, this.onTap, this.color = AppColors.primary});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, child: ListTile(leading: Icon(icon, color: color), title: Text(label, style: TextStyle(color: color == AppColors.error ? AppColors.error : AppColors.text, fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText), onTap: onTap));
}
