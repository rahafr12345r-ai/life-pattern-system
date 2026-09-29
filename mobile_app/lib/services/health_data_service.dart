import 'package:health/health.dart';

class HealthSummary {
  const HealthSummary({required this.steps, required this.sleepHours});
  final int steps;
  final double sleepHours;
}

class HealthDataService {
  HealthDataService({Health? health}) : _health = health ?? Health();

  final Health _health;
  static const _types = [HealthDataType.STEPS, HealthDataType.SLEEP_ASLEEP];

  Future<bool> requestReadPermission() async {
    await _health.configure();
    return _health.requestAuthorization(
      _types,
      permissions: [HealthDataAccess.READ, HealthDataAccess.READ],
    );
  }

  Future<HealthSummary> readRecentSummary() async {
    await _health.configure();
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 1));
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: start,
      endTime: end,
    );

    var steps = 0.0;
    var sleepHours = 0.0;
    for (final point in points) {
      final value = point.value;
      if (value is! NumericHealthValue) continue;
      if (point.type == HealthDataType.STEPS) {
        steps += value.numericValue.toDouble();
      } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
        sleepHours += point.dateTo.difference(point.dateFrom).inMinutes / 60;
      }
    }
    return HealthSummary(steps: steps.round(), sleepHours: sleepHours);
  }
}
