import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../behavioral_data/daily_checkin_screen.dart';
import '../alerts/alerts_screen.dart';
import '../messages/doctor_messages_screen.dart';
import '../messages/patient_conversation_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/history_reports_screens.dart';
import '../../models/dashboard_data.dart';
import '../../models/risk_assessment.dart';
import '../../repositories/dashboard_repository.dart';

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
        ? [_DoctorPatientsPage(repository: repository, doctorId: widget.uid), DoctorMessagesScreen(uid: widget.uid), AlertsScreen(uid: widget.uid), ReportsScreen(uid: widget.uid, repository: repository), ProfileScreen(role: 'Doctor', uid: widget.uid)]
        : [_PatientHomePage(repository: repository, uid: widget.uid), HistoryScreen(uid: widget.uid, repository: repository), AlertsScreen(uid: widget.uid), ReportsScreen(uid: widget.uid, repository: repository), ProfileScreen(role: 'Patient', uid: widget.uid)];
    final labels = doctor ? const ['Patients', 'Messages', 'Alerts', 'Reports', 'Profile'] : const ['Home', 'History', 'Alerts', 'Reports', 'Profile'];
    final icons = doctor ? const [Icons.people_outline, Icons.chat_bubble_outline, Icons.notifications_none, Icons.assessment_outlined, Icons.person_outline] : const [Icons.home_outlined, Icons.show_chart, Icons.notifications_none, Icons.assessment_outlined, Icons.person_outline];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)), if (subtitle != null) Text(subtitle!, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))]), IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: AppColors.primary))]);
}

class _PatientHomePage extends StatelessWidget {
  const _PatientHomePage({required this.repository, required this.uid});
  final DashboardRepository repository;
  final String uid;
  @override
  Widget build(BuildContext context) => StreamBuilder<BehavioralSummary>(stream: repository.watchPatientSummary(uid), builder: (context, snapshot) {
    final summary = snapshot.data ?? BehavioralSummary.empty;
    return StreamBuilder<RiskAssessment?>(stream: repository.watchRiskAssessment(uid), builder: (context, riskSnapshot) {
    final assessment = riskSnapshot.data;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
        const _Header(title: 'Home', subtitle: 'Your daily pattern summary'),
        const SizedBox(height: 22),
        const Text('Hello, Rahaf', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _ScoreCard(score: assessment?.score ?? summary.riskScore, level: assessment?.level),
        const SizedBox(height: 16),
        Row(children: [_MetricCard(label: 'Sleep', value: summary.sleepHours == 0 ? '--' : '${summary.sleepHours.toStringAsFixed(1)} h', icon: Icons.nightlight_round, color: const Color(0xFF3C987B)), const SizedBox(width: 12), _MetricCard(label: 'Activity', value: summary.activitySteps == 0 ? '--' : '${summary.activitySteps} steps', icon: Icons.directions_walk, color: const Color(0xFF2D91C7))]),
        const SizedBox(height: 12),
        Row(children: [_MetricCard(label: 'Mood', value: summary.mood, icon: Icons.sentiment_satisfied_alt, color: const Color(0xFFE36D28)), const SizedBox(width: 12), _MetricCard(label: 'Alerts', value: '${summary.alertCount}', icon: Icons.notifications, color: const Color(0xFFD84E50))]),
        const SizedBox(height: 24),
        const Text('Last 7 days', style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const _ChartCard(),
        const SizedBox(height: 16),
        SizedBox(height: 50, child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DailyCheckinScreen(uid: uid))), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Add daily check-in'))),
      ]);
    });
  });
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, this.level});
  final int score;
  final String? level;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Behavioral change score', style: TextStyle(color: AppColors.mutedText, fontSize: 12)), const SizedBox(height: 5), Text(score == 0 ? '--' : '$score', style: const TextStyle(color: Color(0xFFE36D28), fontSize: 31, fontWeight: FontWeight.w800)), Text(score == 0 ? 'No daily assessment yet' : 'Risk level: ${level ?? 'pending'}', style: const TextStyle(color: AppColors.mutedText, fontSize: 12))])));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(child: Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 20), const SizedBox(height: 8), Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700))]))));
}

class _ChartCard extends StatelessWidget {
  const _ChartCard();
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: const SizedBox(height: 150, child: Padding(padding: EdgeInsets.fromLTRB(12, 16, 12, 8), child: CustomPaint(painter: _BarsPainter()))));
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final primary = Paint()..color = AppColors.primary;
    final accent = Paint()..color = const Color(0xFF8BC8B1);
    const values = [0.52, 0.68, 0.42, 0.78, 0.56, 0.72, 0.48];
    final gap = size.width / (values.length * 2 + 1);
    for (var i = 0; i < values.length; i++) {
      final x = gap + i * gap * 2;
      final height = (size.height - 24) * values[i];
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - height - 14, gap * .72, height), const Radius.circular(4)), i.isEven ? primary : accent);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DoctorPatientsPage extends StatelessWidget {
  const _DoctorPatientsPage({required this.repository, required this.doctorId});
  final DashboardRepository repository;
  final String doctorId;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<PatientSummary>>(stream: repository.watchPatients(), builder: (context, snapshot) {
    final patients = snapshot.data ?? const <PatientSummary>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const _Header(title: 'Patients', subtitle: 'Connected patient overview'),
        const SizedBox(height: 22),
        if (patients.isEmpty)
          const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Text('No connected patients yet.', style: TextStyle(color: AppColors.mutedText))))
        else
          ...patients.map((patient) => _PatientRow(
                name: patient.name,
                status: patient.status,
                color: AppColors.primary,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => PatientConversationScreen(doctorId: doctorId, patientId: patient.uid, patientName: patient.name),
                )),
              )),
      ],
    );
  });
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.name, required this.status, required this.color, this.onTap});
  final String name;
  final String status;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(onTap: onTap, leading: Container(width: 5, height: 48, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))), title: Text(name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), subtitle: Text(status, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText)));
}
