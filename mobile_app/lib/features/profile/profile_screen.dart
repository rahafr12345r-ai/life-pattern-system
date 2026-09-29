import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../messages/patient_messages_screen.dart';
import 'connected_devices_screen.dart';
import 'connect_therapist_screen.dart';
import 'connection_requests_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.role, required this.uid, super.key});
  final String role;
  final String uid;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
        const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(role, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
        const SizedBox(height: 24),
        Card(elevation: 0, color: Colors.white, child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: const Text('R', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))), title: const Text('Rahaf Adil', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), subtitle: const Text('rahaf.adil@lifepattern.com', style: TextStyle(color: AppColors.mutedText, fontSize: 12)))),
        const SizedBox(height: 14),
        _ProfileAction(icon: Icons.devices_other, label: 'Connected devices', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectedDevicesScreen(uid: uid)))),
        if (role == 'Patient') _ProfileAction(icon: Icons.chat_bubble_outline, label: 'Messages', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PatientMessagesScreen(uid: uid)))),
        if (role == 'Patient') _ProfileAction(icon: Icons.link, label: 'Connect therapist', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectTherapistScreen(patientId: uid)))),
        if (role == 'Doctor') _ProfileAction(icon: Icons.person_add_alt_1, label: 'Connection requests', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectionRequestsScreen(doctorId: uid)))),
        const _ProfileAction(icon: Icons.edit_outlined, label: 'Edit profile'),
        const _ProfileAction(icon: Icons.language, label: 'Language'),
        const _ProfileAction(icon: Icons.lock_outline, label: 'Privacy'),
      ]);
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(label, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText), onTap: onTap));
}
