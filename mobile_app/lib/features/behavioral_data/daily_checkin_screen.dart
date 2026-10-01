import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/checkin_repository.dart';
import '../../services/health_data_service.dart';

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
  final _sleepController = TextEditingController(text: '7.0');
  final _stepsController = TextEditingController(text: '6500');
  String _mood = 'Good';
  int _quality = 4;
  bool _saving = false;
  bool _syncing = false;
  String? _error;

  @override
  void initState() { super.initState(); _repository = widget.repository ?? CheckinRepository(); }
  @override
  void dispose() { _notesController.dispose(); _sleepController.dispose(); _stepsController.dispose(); super.dispose(); }

  Future<void> _syncWatch() async {
    setState(() { _syncing = true; _error = null; });
    try {
      final granted = await HealthDataService().requestReadPermission();
      if (!granted) throw StateError('Health data permission was not granted.');
      final summary = await HealthDataService().readRecentSummary();
      if (summary.steps > 0) _stepsController.text = '${summary.steps}';
      if (summary.sleepHours > 0) _sleepController.text = summary.sleepHours.toStringAsFixed(1);
      if (summary.steps > 0 || summary.sleepHours > 0) {
        _quality = 5;
        _notesController.text = 'Synced via smartwatch / Google Health';
      }
    } catch (error) { if (mounted) setState(() => _error = error.toString().replaceFirst('Bad state: ', '')); }
    finally { if (mounted) setState(() => _syncing = false); }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      final analysisMood = switch (_mood) { 'Ok-so' => 'Okay', 'Bad' || 'Very bad' => 'Low', _ => 'Good' };
      await _repository.saveDailyCheckin(uid: widget.uid, mood: analysisMood, sleepQuality: _quality, notes: _notesController.text, sleepHours: double.tryParse(_sleepController.text) ?? 7, activitySteps: int.tryParse(_stepsController.text) ?? 6000);
      if (mounted) Navigator.of(context).pop();
    } catch (_) { if (mounted) setState(() => _error = 'Unable to save your check-in. Please try again.'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Daily Check-in')),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 30), children: [
          const Center(child: Text('Daily Behavioral Check-in', style: TextStyle(color: AppColors.text, fontSize: 19, fontWeight: FontWeight.w800))),
          const SizedBox(height: 3),
          const Center(child: Text('تسجيل بيانات النوم والنشاط اليومي', style: TextStyle(color: AppColors.mutedText, fontSize: 12))),
          const SizedBox(height: 14),
          Center(child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.softGreen, shape: BoxShape.circle), child: const Icon(Icons.spa_outlined, color: AppColors.primary))),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: _syncing ? null : _syncWatch, icon: const Icon(Icons.watch_outlined, size: 17), label: Text(_syncing ? 'Syncing...' : 'Sync From Smartwatch / سحب من الساعة الذكية'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, backgroundColor: AppColors.softGreen, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 18),
          _FieldTitle(title: 'Sleep Duration (Hours) / مدة النوم', warning: (double.tryParse(_sleepController.text) ?? 7) <= 4 ? '⚠️ Severe Deficit / نقص حاد' : null),
          TextField(controller: _sleepController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'e.g. 3.0 or 7.5')),
          const SizedBox(height: 7),
          _QuickChips(values: const [('3.0', '3h ⚠️'), ('5.0', '5h'), ('7.0', '7h'), ('8.5', '8.5h')], current: _sleepController.text, onSelect: (value) => setState(() => _sleepController.text = value)),
          const SizedBox(height: 16),
          const _FieldTitle(title: 'Steps Walked / عدد الخطوات اليومية'),
          TextField(controller: _stepsController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 1500 or 7000')),
          const SizedBox(height: 7),
          _QuickChips(values: const [('1500', '1.5k'), ('4000', '4k'), ('7000', '7k'), ('10000', '10k')], current: _stepsController.text, onSelect: (value) => setState(() => _stepsController.text = value)),
          const SizedBox(height: 18),
          const Center(child: Text('How are you feeling today? / ما هو مزاجك اليوم؟', style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _MoodItem(emoji: '😊', label: 'Good', color: const Color(0xFF4CAF50), selected: _mood == 'Good', onTap: () => setState(() => _mood = 'Good')),
            _MoodItem(emoji: '😐', label: 'Ok-so', color: const Color(0xFFFFB300), selected: _mood == 'Ok-so', onTap: () => setState(() => _mood = 'Ok-so')),
            _MoodItem(emoji: '🙁', label: 'Bad', color: const Color(0xFFFF7043), selected: _mood == 'Bad', onTap: () => setState(() => _mood = 'Bad')),
            _MoodItem(emoji: '😡', label: 'Very bad', color: const Color(0xFFE53935), selected: _mood == 'Very bad', onTap: () => setState(() => _mood = 'Very bad')),
          ]),
          const SizedBox(height: 18),
          const Center(child: Text('Sleep Quality / جودة النوم', style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (var i = 1; i <= 5; i++) IconButton(onPressed: () => setState(() => _quality = i), icon: Icon(Icons.star, color: i <= _quality ? const Color(0xFF8B6B3D) : const Color(0xFFE0E0E0), size: 27))]),
          const SizedBox(height: 12),
          const _FieldTitle(title: 'Notes & Routine / ملاحظات النشاط والروتين'),
          TextField(controller: _notesController, minLines: 3, maxLines: 5, decoration: const InputDecoration(hintText: 'Write anything about your day...')),
          if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12))],
          const SizedBox(height: 22),
          SizedBox(height: 48, child: FilledButton(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(_saving ? 'Saving...' : 'Save & Analyze / حفظ وتحليل النمط', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)))),
        ]),
      );
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle({required this.title, this.warning});
  final String title;
  final String? warning;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700)), if (warning != null) Text(warning!, style: const TextStyle(color: AppColors.alertHigh, fontSize: 11, fontWeight: FontWeight.w800))]);
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({required this.values, required this.current, required this.onSelect});
  final List<(String, String)> values;
  final String current;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 6, children: [for (final item in values) ChoiceChip(label: Text(item.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), selected: current == item.$1, selectedColor: AppColors.primary, labelStyle: TextStyle(color: current == item.$1 ? Colors.white : AppColors.text), onSelected: (_) => onSelect(item.$1))]);
}

class _MoodItem extends StatelessWidget {
  const _MoodItem({required this.emoji, required this.label, required this.color, required this.selected, required this.onTap});
  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(width: 64, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: selected ? color.withValues(alpha: .13) : Colors.transparent, border: Border.all(color: selected ? color : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 25)), const SizedBox(height: 3), Text(label, style: TextStyle(color: selected ? color : AppColors.mutedText, fontSize: 10, fontWeight: FontWeight.w800))])));
}
