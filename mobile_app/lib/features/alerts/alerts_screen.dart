import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/alert_record.dart';
import '../../repositories/alert_repository.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({required this.uid, super.key, this.repository});
  final String uid;
  final AlertRepository? repository;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository ?? AlertRepository();
    return StreamBuilder<List<AlertRecord>>(
      stream: repository.watchAlerts(widget.uid),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <AlertRecord>[];
        final timeline = records.isEmpty ? _demoAlerts : records;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: [
            const Text('Alerts & Notifications', style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            _FeaturedRiskCard(showDetails: _showDetails, onDetails: () => setState(() => _showDetails = !_showDetails)),
            const SizedBox(height: 24),
            for (var index = 0; index < timeline.length; index++) ...[
              _AlertTimelineCard(
                alert: timeline[index],
                demo: records.isEmpty,
                onRead: records.isEmpty ? null : () => repository.markRead(timeline[index].id),
              ),
              if (index != timeline.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  static final _demoAlerts = <AlertRecord>[
    AlertRecord(id: 'demo-high', title: 'High Risk Detected', message: 'A significant behavioral change was detected.', severity: 'high', read: false, createdAt: DateTime(2025, 5, 7)),
    AlertRecord(id: 'demo-medium', title: 'Change Detected', message: 'Some daily pattern values changed.', severity: 'warning', read: true, createdAt: DateTime(2025, 5, 5)),
    AlertRecord(id: 'demo-low', title: 'All Good', message: 'Your recent pattern is stable.', severity: 'low', read: true, createdAt: DateTime(2025, 5, 1)),
  ];
}

class _FeaturedRiskCard extends StatelessWidget {
  const _FeaturedRiskCard({required this.showDetails, required this.onDetails});
  final bool showDetails;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFFFCDD2))),
        color: AppColors.alertHighBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Container(width: 54, height: 54, decoration: const BoxDecoration(color: Color(0xFFFFCDD2), shape: BoxShape.circle), child: const Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 32)),
              const SizedBox(height: 12),
              const Text('Attention', style: TextStyle(color: AppColors.text, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('We noticed a significant change\nin your daily patterns.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.text, fontSize: 14, height: 1.45)),
              const SizedBox(height: 8),
              const Text('Please take care and consider\nreaching out for support.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText, fontSize: 13, height: 1.4)),
              const SizedBox(height: 18),
              SizedBox(width: 220, height: 46, child: FilledButton(onPressed: onDetails, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w800)))),
              if (showDetails) ...[
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFFFCDD2)),
                const SizedBox(height: 10),
                const Align(alignment: AlignmentDirectional.centerStart, child: Row(children: [Icon(Icons.psychology, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Synced to Specialist: Dr. Abdullah Alnuaim', style: TextStyle(color: AppColors.text, fontSize: 12))])),
                const SizedBox(height: 6),
                const Align(alignment: AlignmentDirectional.centerStart, child: Row(children: [Icon(Icons.phone, color: Color(0xFFE53935), size: 18), SizedBox(width: 8), Text('Mental Health Support Hotline: 920033360', style: TextStyle(color: AppColors.alertHigh, fontSize: 12, fontWeight: FontWeight.w800))])),
              ],
            ],
          ),
        ),
      );
}

class _AlertTimelineCard extends StatelessWidget {
  const _AlertTimelineCard({required this.alert, required this.demo, this.onRead});
  final AlertRecord alert;
  final bool demo;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    final high = alert.severity.toLowerCase() == 'high';
    final medium = alert.severity.toLowerCase() == 'warning' || alert.severity.toLowerCase() == 'medium';
    final background = high ? AppColors.alertHighBackground : medium ? AppColors.alertMediumBackground : AppColors.alertLowBackground;
    final color = high ? AppColors.alertHigh : medium ? AppColors.alertMedium : AppColors.alertLow;
    final icon = high ? Icons.warning_rounded : medium ? Icons.warning_amber_rounded : Icons.check_circle;
    final date = '${alert.createdAt.day} ${_month(alert.createdAt.month)}, ${alert.createdAt.year}';
    return Card(
      elevation: 0,
      color: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onRead,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(alert.title, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(demo ? date : alert.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))]))]),
        ),
      ),
    );
  }

  String _month(int month) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
}
