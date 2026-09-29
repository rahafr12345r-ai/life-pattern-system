import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/message_record.dart';
import '../../repositories/message_repository.dart';

class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({required this.uid, super.key, this.repository});
  final String uid;
  final MessageRepository? repository;
  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  final _controller = TextEditingController();
  late final MessageRepository _repository;
  bool _sending = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MessageRepository();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reply() async {
    final doctorId = _doctorId;
    final text = _controller.text.trim();
    if (doctorId == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(senderId: widget.uid, recipientId: doctorId, text: text);
      _controller.clear();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to send message.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: StreamBuilder<List<MessageRecord>>(
          stream: _repository.watchInbox(widget.uid),
          builder: (context, snapshot) {
            final messages = snapshot.data ?? const <MessageRecord>[];
            if (messages.isNotEmpty) _doctorId = messages.first.senderId;
            return Column(children: [
              Expanded(child: messages.isEmpty ? const Center(child: Text('No messages from your doctor yet.', style: TextStyle(color: AppColors.mutedText))) : ListView.builder(reverse: true, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (context, index) => Align(alignment: messages[index].senderId == widget.uid ? Alignment.centerRight : Alignment.centerLeft, child: Card(color: messages[index].senderId == widget.uid ? AppColors.primary : Colors.white, child: Padding(padding: const EdgeInsets.all(12), child: Text(messages[index].text, style: TextStyle(color: messages[index].senderId == widget.uid ? Colors.white : AppColors.text))))))),
              SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Row(children: [Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Reply to your doctor...'))), IconButton(onPressed: _sending ? null : _reply, color: AppColors.primary, icon: const Icon(Icons.send))]))),
            ]);
          },
        ),
      );
}
