import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/checkin_repository.dart';
import '../../shared/auth_widgets.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({required this.uid, super.key, this.repository});

  final String uid;
  final CheckinRepository? repository;

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  late final CheckinRepository _repository;
  final _notesController = TextEditingController();
  String _mood = 'Good';
  int _sleepQuality = 4;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CheckinRepository();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repository.saveDailyCheckin(
        uid: widget.uid,
        mood: _mood,
        sleepQuality: _sleepQuality,
        notes: _notesController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to save your check-in. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daily check-in')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const Text('Daily check-in', style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Share how your day is going', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(height: 28),
              const Text('Mood', style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                _MoodChoice(label: 'Good', icon: Icons.sentiment_satisfied_alt, selected: _mood == 'Good', onTap: () => setState(() => _mood = 'Good')),
                const SizedBox(width: 10),
                _MoodChoice(label: 'Okay', icon: Icons.sentiment_neutral, selected: _mood == 'Okay', onTap: () => setState(() => _mood = 'Okay')),
                const SizedBox(width: 10),
                _MoodChoice(label: 'Low', icon: Icons.sentiment_dissatisfied, selected: _mood == 'Low', onTap: () => setState(() => _mood = 'Low')),
              ]),
              const SizedBox(height: 28),
              const Text('Sleep quality', style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(children: [for (var i = 1; i <= 5; i++) IconButton(onPressed: () => setState(() => _sleepQuality = i), icon: Icon(Icons.star, color: i <= _sleepQuality ? const Color(0xFFE36D28) : AppColors.border, size: 30))]),
              const SizedBox(height: 20),
              const Text('Notes', style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(controller: _notesController, minLines: 4, maxLines: 6, decoration: const InputDecoration(hintText: 'Write anything you would like to remember...')),
              if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))],
              const SizedBox(height: 24),
              PrimaryButton(label: _saving ? 'Saving...' : 'Save', onPressed: _saving ? null : _save),
            ],
          ),
        ),
      );
}

class _MoodChoice extends StatelessWidget {
  const _MoodChoice({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: selected ? AppColors.primary : AppColors.mutedText),
                const SizedBox(height: 5),
                Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}
