import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/connection_repository.dart';
import '../../shared/auth_widgets.dart';

class ConnectTherapistScreen extends StatefulWidget {
  const ConnectTherapistScreen({required this.patientId, super.key, this.repository});
  final String patientId;
  final ConnectionRepository? repository;
  @override
  State<ConnectTherapistScreen> createState() => _ConnectTherapistScreenState();
}

class _ConnectTherapistScreenState extends State<ConnectTherapistScreen> {
  final _doctorController = TextEditingController();
  late final ConnectionRepository _repository;
  bool _saving = false;
  String? _message;
  @override
  void initState() { super.initState(); _repository = widget.repository ?? ConnectionRepository(); }
  @override
  void dispose() { _doctorController.dispose(); super.dispose(); }
  Future<void> _request() async {
    final doctorId = _doctorController.text.trim();
    if (doctorId.isEmpty) { setState(() => _message = 'Enter the doctor ID provided by your therapist.'); return; }
    setState(() { _saving = true; _message = null; });
    try { await _repository.requestConnection(patientId: widget.patientId, doctorId: doctorId); if (mounted) setState(() => _message = 'Connection request sent.'); } catch (_) { if (mounted) setState(() => _message = 'Unable to send the request.'); } finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Connect therapist')), body: ListView(padding: const EdgeInsets.all(24), children: [const Text('Connect therapist', style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Ask your therapist for their Life Pattern doctor ID, then send a connection request.', style: TextStyle(color: AppColors.mutedText, height: 1.5)), const SizedBox(height: 24), TextField(controller: _doctorController, decoration: const InputDecoration(labelText: 'Doctor ID')), const SizedBox(height: 20), if (_message != null) Padding(padding: const EdgeInsets.only(bottom: 14), child: Text(_message!, style: const TextStyle(color: AppColors.primary))), PrimaryButton(label: _saving ? 'Sending...' : 'Send request', onPressed: _saving ? null : _request)]));
}
