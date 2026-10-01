import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/dashboard_data.dart';
import '../../models/user_profile.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../messages/patient_messages_screen.dart';
import 'connected_devices_screen.dart';
import 'connect_therapist_screen.dart';
import 'connection_requests_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.role, required this.uid, super.key});
  final String role;
  final String uid;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => StreamBuilder<UserProfile?>(
        stream: UserRepository().watchProfile(widget.uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = profile?.displayName ?? 'Life Pattern user';
          final email = profile?.email ?? '';
          final summary = BehavioralSummary.defaultsFor(widget.uid);
          return ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [CircleAvatar(radius: 25, backgroundColor: AppColors.softGreen, child: Text(name.isEmpty ? 'L' : name[0], style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w800)), Text(email, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))])]),
              Row(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: AppColors.mutedText)), IconButton(onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout, color: AppColors.mutedText))]),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [for (final item in ['Overview', 'Trends', 'Notes']) _TabItem(label: item, selected: _tab == ['Overview', 'Trends', 'Notes'].indexOf(item), onTap: () => setState(() => _tab = ['Overview', 'Trends', 'Notes'].indexOf(item)))]),
            const SizedBox(height: 20),
            if (_tab == 0) ...[
              const Text('Risk Level', style: TextStyle(color: AppColors.mutedText, fontSize: 14)),
              const SizedBox(height: 6),
              const _RiskBadge(),
              const SizedBox(height: 22),
              const _ProfileTrendChart(title: 'Trend (This Week)'),
              const SizedBox(height: 22),
              const Text('Notes', style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('No recent notes', style: TextStyle(color: AppColors.mutedText, fontSize: 13)),
            ] else if (_tab == 1) ...[
              const _ProfileTrendChart(title: 'Multi-Day Stability Index'),
              const SizedBox(height: 16),
              Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)), child: const Padding(padding: EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Baseline Status: Calibrated', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 13)), SizedBox(height: 4), Text('Weekly deviation: stable sleep and activity pattern', style: TextStyle(color: AppColors.mutedText, fontSize: 12))]))),
            ] else ...[
              const Text('Clinical Guidance & Notes', style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)), child: const Padding(padding: EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('No direct clinical notes yet.', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Notes and recommendations from your specialist will appear here.', style: TextStyle(color: AppColors.mutedText, fontSize: 12))]))),
            ],
            const SizedBox(height: 24),
            _ActionTile(icon: Icons.bluetooth, label: 'Wearables & Sensors', subtitle: 'Manage connected health devices', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectedDevicesScreen(uid: widget.uid)))),
            if (widget.role == 'Patient') _ActionTile(icon: Icons.chat_bubble_outline, label: 'Messages', subtitle: 'Contact your specialist', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PatientMessagesScreen(uid: widget.uid)))),
            if (widget.role == 'Patient') _ActionTile(icon: Icons.link, label: 'Connect therapist', subtitle: 'Share your pattern with a specialist', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectTherapistScreen(patientId: widget.uid)))),
            if (widget.role == 'Doctor') _ActionTile(icon: Icons.person_add_alt_1, label: 'Connection requests', subtitle: 'Review patient requests', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ConnectionRequestsScreen(doctorId: widget.uid)))),
            const SizedBox(height: 10),
            _ActionTile(icon: Icons.logout, label: 'Sign out', subtitle: 'Return to the login screen', color: AppColors.error, onTap: () => AuthService().signOut()),
            const SizedBox(height: 20),
            Text('Sleep baseline: ${summary.sleepHours}h  •  Activity baseline: ${summary.activitySteps} steps', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)),
          ]);
        },
      );
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)), child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.w800))));
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: AppColors.alertLowBackground, borderRadius: BorderRadius.circular(12)), child: const Text('Low', style: TextStyle(color: AppColors.alertLow, fontSize: 13, fontWeight: FontWeight.w800)));
}

class _ProfileTrendChart extends StatelessWidget {
  const _ProfileTrendChart({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 12), SizedBox(height: 130, child: CustomPaint(painter: _LinePainter()))])));
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { final p = Paint()..color = AppColors.primary..strokeWidth = 3..style = PaintingStyle.stroke; final path = Path()..moveTo(0, size.height * .7)..lineTo(size.width * .16, size.height * .55)..lineTo(size.width * .32, size.height * .62)..lineTo(size.width * .48, size.height * .33)..lineTo(size.width * .65, size.height * .45)..lineTo(size.width * .8, size.height * .22)..lineTo(size.width, size.height * .3); canvas.drawPath(path, p); }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.onTap, this.color = AppColors.primary});
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)), child: ListTile(onTap: onTap, leading: Icon(icon, color: color), title: Text(label, style: TextStyle(color: color == AppColors.error ? color : AppColors.text, fontWeight: FontWeight.w700)), subtitle: Text(subtitle, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText)));
}
