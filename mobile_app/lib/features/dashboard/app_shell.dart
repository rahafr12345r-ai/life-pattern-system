import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/dashboard_data.dart';
import '../../models/risk_assessment.dart';
import '../../models/user_profile.dart';
import '../../repositories/dashboard_repository.dart';
import '../../repositories/user_repository.dart';
import '../alerts/alerts_screen.dart';
import '../behavioral_data/daily_checkin_screen.dart';
import '../messages/doctor_messages_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/history_reports_screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.role, required this.uid, super.key, this.dashboardRepository});
  final String role;
  final String uid;
  final DashboardRepository? dashboardRepository;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final doctor = widget.role == 'Doctor';
    final repository = widget.dashboardRepository ?? DashboardRepository();
    final pages = doctor
        ? [
            _DoctorDashboard(repository: repository, doctorId: widget.uid),
            DoctorMessagesScreen(uid: widget.uid),
            AlertsScreen(uid: widget.uid),
            ReportsScreen(uid: widget.uid, repository: repository),
            ProfileScreen(role: 'Doctor', uid: widget.uid),
          ]
        : [
            _PatientDashboard(repository: repository, uid: widget.uid),
            HistoryScreen(uid: widget.uid, repository: repository),
            AlertsScreen(uid: widget.uid),
            ReportsScreen(uid: widget.uid, repository: repository),
            ProfileScreen(role: 'Patient', uid: widget.uid),
          ];
    final labels = doctor ? const ['Patients', 'Messages', 'Alerts', 'Reports', 'Profile'] : const ['Home', 'History', 'Alerts', 'Reports', 'Profile'];
    final icons = doctor ? const [Icons.people_outline, Icons.chat_bubble_outline, Icons.notifications_none, Icons.assessment_outlined, Icons.person_outline] : const [Icons.home_outlined, Icons.show_chart, Icons.notifications_none, Icons.assessment_outlined, Icons.person_outline];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.softGreen,
        destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i], color: AppColors.primary), label: labels[i])],
      ),
    );
  }
}

class _PatientDashboard extends StatelessWidget {
  const _PatientDashboard({required this.repository, required this.uid});
  final DashboardRepository repository;
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<UserProfile?>(
        stream: UserRepository().watchProfile(uid),
        builder: (context, profileSnapshot) => StreamBuilder<BehavioralSummary>(
          stream: repository.watchPatientSummary(uid),
          builder: (context, summarySnapshot) => StreamBuilder<RiskAssessment?>(
            stream: repository.watchRiskAssessment(uid),
            builder: (context, riskSnapshot) {
              final defaults = BehavioralSummary.defaultsFor(uid);
              final summary = summarySnapshot.data ?? defaults;
              final risk = riskSnapshot.data?.score ?? summary.riskScore;
              final name = profileSnapshot.data?.displayName ?? 'User';
              final sleep = summary.sleepHours;
              final steps = summary.activitySteps;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                children: [
                  const Center(child: Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.softGreen, shape: BoxShape.circle), child: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 20)),
                    Text(_dateLabel(), style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.refresh, color: AppColors.mutedText)),
                  ]),
                  const SizedBox(height: 18),
                  Text('Hello, $name', style: const TextStyle(color: AppColors.text, fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  const Text('Here is your life pattern summary.', style: TextStyle(color: AppColors.mutedText, fontSize: 13)),
                  const SizedBox(height: 12),
                  const Wrap(spacing: 8, runSpacing: 8, children: [
                    _Badge(text: '7-Day Active Streak', background: Color(0xFFFFF3E0), foreground: Color(0xFFE65100)),
                    _Badge(text: 'Live Sync & Wearables', background: AppColors.softGreen, foreground: AppColors.primary),
                  ]),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: _MetricCard(title: 'Sleep', value: '${sleep.toStringAsFixed(1)}h', badge: sleep <= 6 ? 'Low' : 'Good', icon: Icons.bedtime_outlined, iconColor: AppColors.alertLow)),
                    const SizedBox(width: 14),
                    Expanded(child: _MetricCard(title: 'Activity', value: '$steps steps', badge: steps < 6000 ? 'Moderate' : 'Active', icon: Icons.directions_run, iconColor: const Color(0xFF43A047))),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _MetricCard(title: 'Mood', value: summary.mood, badge: 'Stable', icon: Icons.mood_outlined, iconColor: const Color(0xFFFB8C00))),
                    const SizedBox(width: 14),
                    Expanded(child: _MetricCard(title: 'Risk Level', value: risk >= 70 ? 'High' : risk >= 50 ? 'Medium' : 'Low', badge: risk >= 70 ? 'Alert' : risk >= 50 ? 'Caution' : 'Safe', icon: Icons.warning_amber_rounded, iconColor: risk >= 70 ? AppColors.alertHigh : AppColors.alertLow)),
                  ]),
                  const SizedBox(height: 14),
                  _NotesCard(onEdit: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DailyCheckinScreen(uid: uid)))),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.watch_outlined, size: 17), label: const Text('Sync Watch'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, backgroundColor: AppColors.softGreen, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.local_hospital_outlined, size: 17), label: const Text('Message Doctor'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('See full dashboard →', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700)), TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DailyCheckinScreen(uid: uid))), icon: const Icon(Icons.edit_note, size: 17), label: const Text('Log Symptoms'))]),
                  const SizedBox(height: 8),
                  SizedBox(height: 50, child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DailyCheckinScreen(uid: uid))), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Daily Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
                ],
              );
            },
          ),
        ),
      );

  String _dateLabel() {
    final now = DateTime.now();
    return '${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
}

class _DoctorDashboard extends StatefulWidget {
  const _DoctorDashboard({required this.repository, required this.doctorId});
  final DashboardRepository repository;
  final String doctorId;
  @override
  State<_DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<_DoctorDashboard> {
  String _filter = 'All';
  String? _selected;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<PatientSummary>>(
        stream: widget.repository.watchPatients(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <PatientSummary>[];
          final patients = all.where((patient) => _filter == 'All' || (_filter == 'High Risk' && patient.uid == 'pxQBwrhR7BRrQM4cVwwb2VrTIp12')).toList();
          final selected = patients.where((patient) => patient.uid == _selected).firstOrNull ?? patients.firstOrNull;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Specialist Portal', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)), SizedBox(height: 3), Text('Dr. Abdullah Abdulaziz Alnuaim', style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800))]), Row(children: [const _Badge(text: 'Live Sync', background: AppColors.softGreen, foreground: AppColors.primary), IconButton(onPressed: () {}, icon: const Icon(Icons.logout, color: AppColors.mutedText))])]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Patients (${all.length})', style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800)), Wrap(spacing: 4, children: [for (final filter in ['All', 'High Risk']) ChoiceChip(label: Text(filter, style: const TextStyle(fontSize: 11)), selected: _filter == filter, selectedColor: filter == 'High Risk' ? AppColors.alertHigh : AppColors.primary, labelStyle: TextStyle(color: _filter == filter ? Colors.white : AppColors.text), onSelected: (_) => setState(() => _filter = filter))])]),
              const SizedBox(height: 12),
              if (patients.isEmpty) const Text('No patients found in this category.', style: TextStyle(color: AppColors.mutedText)) else ...patients.map((patient) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _PatientCard(patient: patient, selected: selected?.uid == patient.uid, onTap: () => setState(() => _selected = patient.uid)))),
              if (selected != null) ...[
                const SizedBox(height: 12),
                _SelectedPatientCard(patient: selected),
                const SizedBox(height: 20),
                Text('Patient Trend (${selected.name})', style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const _TrendCard(),
                const SizedBox(height: 20),
                const Text('Clinical Intervention Notes', style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Send guidance or record notes directly to patient dashboard', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                const SizedBox(height: 10),
                TextField(minLines: 3, maxLines: 4, decoration: const InputDecoration(hintText: 'Type remote guidance or clinical intervention note...')),
                const SizedBox(height: 8),
                Align(alignment: AlignmentDirectional.centerEnd, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.send, size: 16), label: const Text('Save & Send'))),
              ],
            ],
          );
        },
      );
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.selected, required this.onTap});
  final PatientSummary patient;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: selected ? AppColors.softGreen : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: selected ? AppColors.primary : AppColors.border)), child: ListTile(onTap: onTap, leading: CircleAvatar(backgroundColor: AppColors.softGreen, child: Text(patient.name.isEmpty ? 'P' : patient.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))), title: Text(patient.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)), subtitle: Text(patient.email, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText)));
}

class _SelectedPatientCard extends StatelessWidget {
  const _SelectedPatientCard({required this.patient});
  final PatientSummary patient;
  @override
  Widget build(BuildContext context) {
    final summary = BehavioralSummary.defaultsFor(patient.uid);
    final high = summary.riskScore >= 70;
    return Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.primary.withValues(alpha: .4), width: 1.5)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Selected Patient Analysis', style: TextStyle(color: AppColors.mutedText, fontSize: 11, fontWeight: FontWeight.w700)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: high ? AppColors.alertHighBackground : AppColors.alertLowBackground, borderRadius: BorderRadius.circular(6)), child: Text(high ? 'High Risk' : 'Stable', style: TextStyle(color: high ? AppColors.alertHigh : AppColors.alertLow, fontSize: 12, fontWeight: FontWeight.w800)))]), const SizedBox(height: 5), Text(patient.name, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 14), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ _MiniMetric(label: 'Avg Sleep', value: '${summary.sleepHours}h', icon: Icons.bedtime_outlined), _MiniMetric(label: 'Avg Steps', value: '${summary.activitySteps}', icon: Icons.directions_walk), _MiniMetric(label: 'Mood', value: summary.mood, icon: Icons.mood_outlined)])])));
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(height: 4), Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 10))]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.badge, required this.icon, required this.iconColor});
  final String title;
  final String value;
  final String badge;
  final IconData icon;
  final Color iconColor;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)), child: SizedBox(height: 125, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600))]), Text(value, style: const TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w800)), _Badge(text: badge, background: AppColors.softGreen, foreground: AppColors.alertLow)]))));
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.background, required this.foreground});
  final String text;
  final Color background;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w800)));
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.onEdit});
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.softGreen, shape: BoxShape.circle), child: const Icon(Icons.edit_note, color: AppColors.primary)),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notes', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w800)), Text('No action needed', style: TextStyle(color: AppColors.mutedText, fontSize: 12))]),
            ]),
            TextButton(onPressed: onEdit, child: const Text('Edit')),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)), child: const SizedBox(height: 150, child: Padding(padding: EdgeInsets.all(16), child: CustomPaint(painter: _TrendPainter()))));
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sleep = Paint()..color = AppColors.primary..strokeWidth = 3..style = PaintingStyle.stroke;
    final activity = Paint()..color = const Color(0xFF0288D1)..strokeWidth = 3..style = PaintingStyle.stroke;
    final path1 = Path()..moveTo(0, size.height * .60)..lineTo(size.width * .15, size.height * .48)..lineTo(size.width * .3, size.height * .63)..lineTo(size.width * .45, size.height * .35)..lineTo(size.width * .6, size.height * .42)..lineTo(size.width * .75, size.height * .25)..lineTo(size.width, size.height * .3);
    final path2 = Path()..moveTo(0, size.height * .8)..lineTo(size.width * .15, size.height * .7)..lineTo(size.width * .3, size.height * .73)..lineTo(size.width * .45, size.height * .58)..lineTo(size.width * .6, size.height * .62)..lineTo(size.width * .75, size.height * .4)..lineTo(size.width, size.height * .5);
    canvas.drawPath(path1, sleep); canvas.drawPath(path2, activity);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
