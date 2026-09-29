import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/checkin_record.dart';
import '../../repositories/dashboard_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.uid, required this.repository, super.key});
  final String uid;
  final DashboardRepository repository;

  @override
  Widget build(BuildContext context) => _CheckinStreamPage(uid: uid, repository: repository, title: 'History', report: false);
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({required this.uid, required this.repository, super.key});
  final String uid;
  final DashboardRepository repository;

  @override
  Widget build(BuildContext context) => _CheckinStreamPage(uid: uid, repository: repository, title: 'Reports', report: true);
}

class _CheckinStreamPage extends StatelessWidget {
  const _CheckinStreamPage({required this.uid, required this.repository, required this.title, required this.report});
  final String uid;
  final DashboardRepository repository;
  final String title;
  final bool report;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CheckinRecord>>(
        stream: repository.watchCheckins(uid),
        builder: (context, snapshot) {
          final records = snapshot.data ?? const <CheckinRecord>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(report ? 'Weekly analysis' : 'Your recent check-ins', style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(color: AppColors.text, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (records.isEmpty) const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Text('Complete your first daily check-in to see your patterns here.', style: TextStyle(color: AppColors.mutedText, height: 1.5)))) else ...[
                if (report) _ReportSummary(records: records),
                ...records.map((record) => _CheckinTile(record: record)),
              ],
            ],
          );
        },
      );
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.records});
  final List<CheckinRecord> records;
  @override
  Widget build(BuildContext context) {
    final average = records.fold<int>(0, (sum, item) => sum + item.sleepQuality) / records.length;
    return Card(elevation: 0, color: Colors.white, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Behavioral analysis', style: TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text('${records.length} check-ins recorded', style: const TextStyle(color: AppColors.mutedText)), const SizedBox(height: 4), Text('Average sleep quality: ${average.toStringAsFixed(1)} / 5', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600))])));
  }
}

class _CheckinTile extends StatelessWidget {
  const _CheckinTile({required this.record});
  final CheckinRecord record;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Container(width: 5, height: 48, decoration: BoxDecoration(color: record.mood == 'Low' ? const Color(0xFFE36D28) : AppColors.primary, borderRadius: BorderRadius.circular(4))), title: Text(record.mood, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), subtitle: Text('Sleep quality ${record.sleepQuality}/5${record.notes.isEmpty ? '' : ' • ${record.notes}'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: Text('${record.date.day}/${record.date.month}', style: const TextStyle(color: AppColors.mutedText, fontSize: 12))));
}
