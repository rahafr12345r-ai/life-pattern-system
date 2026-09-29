import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/alert_record.dart';
import '../../repositories/alert_repository.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({required this.uid, super.key, this.repository});
  final String uid;
  final AlertRepository? repository;

  @override
  Widget build(BuildContext context) {
    final alerts = repository ?? AlertRepository();
    return StreamBuilder<List<AlertRecord>>(
      stream: alerts.watchAlerts(uid),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <AlertRecord>[];
        return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Pattern updates and follow-up reminders', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
          const SizedBox(height: 24),
          const Text('Alerts', style: TextStyle(color: AppColors.text, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (records.isEmpty) const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Text('No new alerts. We will notify you when a meaningful change is detected.', style: TextStyle(color: AppColors.mutedText, height: 1.5)))) else ...records.map((alert) => _AlertTile(alert: alert, onRead: () => alerts.markRead(alert.id))),
        ]);
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onRead});
  final AlertRecord alert;
  final VoidCallback onRead;
  @override
  Widget build(BuildContext context) {
    final color = alert.severity == 'warning' ? const Color(0xFFE36D28) : AppColors.primary;
    return Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: alert.read ? null : onRead, leading: Icon(alert.read ? Icons.notifications_none : Icons.notifications_active_outlined, color: color), title: Text(alert.title, style: TextStyle(color: AppColors.text, fontWeight: alert.read ? FontWeight.w500 : FontWeight.w700)), subtitle: Text(alert.message, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: alert.read ? null : const Icon(Icons.circle, color: AppColors.primary, size: 9)));
  }
}
