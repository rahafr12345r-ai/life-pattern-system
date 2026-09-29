import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/message_record.dart';
import '../../repositories/message_repository.dart';

class DoctorMessagesScreen extends StatelessWidget {
  const DoctorMessagesScreen({required this.uid, super.key, this.repository});
  final String uid;
  final MessageRepository? repository;

  @override
  Widget build(BuildContext context) {
    final messages = repository ?? MessageRepository();
    return StreamBuilder<List<MessageRecord>>(
      stream: messages.watchInbox(uid),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <MessageRecord>[];
        return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          const Text('Life Pattern', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Patient messaging', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
          const SizedBox(height: 24),
          const Text('Messages', style: TextStyle(color: AppColors.text, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (records.isEmpty) const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Text('No patient messages yet.', style: TextStyle(color: AppColors.mutedText)))) else ...records.map((message) => _MessageTile(message: message, onRead: () => messages.markRead(message.id))),
        ]);
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.onRead});
  final MessageRecord message;
  final VoidCallback onRead;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: message.read ? null : onRead, leading: Container(width: 5, height: 48, decoration: BoxDecoration(color: message.read ? AppColors.primary : const Color(0xFFE36D28), borderRadius: BorderRadius.circular(4))), title: Text('Patient message', style: TextStyle(color: AppColors.text, fontWeight: message.read ? FontWeight.w500 : FontWeight.w700)), subtitle: Text(message.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), trailing: message.read ? null : const Icon(Icons.circle, color: AppColors.primary, size: 9)));
}
