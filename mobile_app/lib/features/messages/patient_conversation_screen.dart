import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/message_record.dart';
import '../../repositories/message_repository.dart';

class PatientConversationScreen extends StatefulWidget {
  const PatientConversationScreen({required this.doctorId, required this.patientId, required this.patientName, super.key, this.repository});
  final String doctorId;
  final String patientId;
  final String patientName;
  final MessageRepository? repository;

  @override
  State<PatientConversationScreen> createState() => _PatientConversationScreenState();
}

class _PatientConversationScreenState extends State<PatientConversationScreen> {
  final _controller = TextEditingController();
  late final MessageRepository _repository;
  bool _sending = false;

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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(senderId: widget.doctorId, recipientId: widget.patientId, text: text);
      _controller.clear();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to send message.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.patientName)),
        body: Column(children: [
          Expanded(child: StreamBuilder<List<MessageRecord>>(stream: _repository.watchInbox(widget.patientId), builder: (context, snapshot) {
            final messages = (snapshot.data ?? const <MessageRecord>[]).where((message) => message.senderId == widget.doctorId || message.recipientId == widget.doctorId).toList();
            if (messages.isEmpty) return const Center(child: Text('No messages yet.', style: TextStyle(color: AppColors.mutedText)));
            return ListView.builder(reverse: true, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (context, index) => Align(alignment: messages[index].senderId == widget.doctorId ? Alignment.centerRight : Alignment.centerLeft, child: Card(color: messages[index].senderId == widget.doctorId ? AppColors.primary : Colors.white, child: Padding(padding: const EdgeInsets.all(12), child: Text(messages[index].text, style: TextStyle(color: messages[index].senderId == widget.doctorId ? Colors.white : AppColors.text))))));
          })),
          SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Row(children: [Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 3, decoration: const InputDecoration(hintText: 'Write a message...'))), const SizedBox(width: 8), IconButton(onPressed: _sending ? null : _send, color: AppColors.primary, icon: const Icon(Icons.send))]))),
        ]),
      );
}
