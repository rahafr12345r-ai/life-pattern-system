import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/checkin_record.dart';
import '../../repositories/dashboard_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.uid, required this.repository, super.key});
  final String uid;
  final DashboardRepository repository;
  @override
  Widget build(BuildContext context) => _DataPage(uid: uid, repository: repository, reports: false);
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({required this.uid, required this.repository, super.key});
  final String uid;
  final DashboardRepository repository;
  @override
  Widget build(BuildContext context) => _DataPage(uid: uid, repository: repository, reports: true);
}

class _DataPage extends StatelessWidget {
  const _DataPage({required this.uid, required this.repository, required this.reports});
  final String uid;
  final DashboardRepository repository;
  final bool reports;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CheckinRecord>>(
        stream: repository.watchCheckins(uid),
        builder: (context, snapshot) {
          final records = snapshot.data ?? const <CheckinRecord>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
            children: [
              Text(reports ? 'Reports' : 'History', style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _ChartCard(title: 'Sleep (hours)', color: AppColors.primary, values: records.isEmpty ? const [7.0, 6.5, 7.2, 7.8, 6.8, 7.4, 7.0] : records.take(7).map((record) => record.sleepQuality.toDouble() + 2).toList()),
              const SizedBox(height: 28),
              _ChartCard(title: 'Activity (steps)', color: const Color(0xFF0288D1), values: records.isEmpty ? const [5, 7, 4, 8, 6, 7, 6] : records.take(7).map((record) => (record.sleepQuality + 2).toDouble()).toList()),
              if (reports) ...[
                const SizedBox(height: 28),
                _AnalysisCard(records: records),
              ],
              if (records.isNotEmpty) ...[
                const SizedBox(height: 28),
                const Text('Recent check-ins', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ...records.map((record) => _CheckinRow(record: record)),
              ],
            ],
          );
        },
      );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.color, required this.values});
  final String title;
  final Color color;
  final List<double> values;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)), child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 15), SizedBox(height: 145, child: CustomPaint(painter: _BarPainter(values: values, color: color))), const SizedBox(height: 4), const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('Mon'), Text('Tue'), Text('Wed'), Text('Thu'), Text('Fri'), Text('Sat'), Text('Sun')])])));
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.values, required this.color});
  final List<double> values;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = AppColors.border..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), grid);
    }
    final paint = Paint()..color = color;
    final width = size.width / (values.length * 2 - 1);
    for (var i = 0; i < values.length; i++) {
      final height = (values[i] / 10).clamp(.1, 1.0) * (size.height - 10);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(i * width * 2, size.height - height, width, height), const Radius.circular(4)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => oldDelegate.values != values;
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.records});
  final List<CheckinRecord> records;
  @override
  Widget build(BuildContext context) {
    final average = records.isEmpty ? 4.0 : records.fold<int>(0, (sum, item) => sum + item.sleepQuality) / records.length;
    return Card(elevation: 0, color: AppColors.softGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Behavioral Analysis', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('${records.length} check-ins recorded', style: const TextStyle(color: AppColors.mutedText, fontSize: 13)), const SizedBox(height: 4), Text('Average sleep quality: ${average.toStringAsFixed(1)} / 5', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Keep recording daily patterns to improve the quality of your trend.', style: TextStyle(color: AppColors.mutedText, fontSize: 12))])));
  }
}

class _CheckinRow extends StatelessWidget {
  const _CheckinRow({required this.record});
  final CheckinRecord record;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)), child: ListTile(leading: Container(width: 5, height: 44, decoration: BoxDecoration(color: record.mood == 'Low' ? AppColors.alertHigh : AppColors.primary, borderRadius: BorderRadius.circular(4))), title: Text(record.mood, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)), subtitle: Text('Sleep quality ${record.sleepQuality}/5${record.notes.isEmpty ? '' : ' • ${record.notes}'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: Text('${record.date.day}/${record.date.month}', style: const TextStyle(color: AppColors.mutedText, fontSize: 12))));
}
