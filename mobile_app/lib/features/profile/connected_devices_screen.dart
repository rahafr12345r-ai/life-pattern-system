import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/checkin_repository.dart';
import '../../repositories/device_repository.dart';
import '../../services/health_data_service.dart';

class ConnectedDevicesScreen extends StatelessWidget {
  const ConnectedDevicesScreen({required this.uid, super.key, this.repository});
  final String uid;
  final DeviceRepository? repository;

  static const available = [
    ConnectedDevice(id: 'garmin', name: 'Garmin Band 8', type: 'wearable', connected: false),
    ConnectedDevice(id: 'fitbit', name: 'Fitbit', type: 'wearable', connected: false),
    ConnectedDevice(id: 'apple_watch', name: 'Apple Watch', type: 'health platform', connected: false),
    ConnectedDevice(id: 'health_connect', name: 'Health Connect', type: 'health platform', connected: false),
  ];

  @override
  Widget build(BuildContext context) {
    final deviceRepository = repository ?? DeviceRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Connected devices')),
      body: StreamBuilder<List<ConnectedDevice>>(
        stream: deviceRepository.watchDevices(uid),
        builder: (context, snapshot) {
          final saved = <String, ConnectedDevice>{};
          for (final device in snapshot.data ?? const <ConnectedDevice>[]) {
            saved[device.id] = device;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const Text('Connected devices', style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Choose which devices can contribute lifestyle data.', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(height: 22),
              ...available.map((device) {
                final current = saved[device.id] ?? device;
                return _DeviceTile(
                  device: current,
                  onChanged: (connected) async {
                    try {
                      if (connected && (current.id == 'health_connect' || current.id == 'apple_watch')) {
                        final granted = await HealthDataService().requestReadPermission();
                        if (!granted) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Health data permission was not granted.')));
                          return;
                        }
                        final summary = await HealthDataService().readRecentSummary();
                        await CheckinRepository().saveHealthSummary(uid: uid, summary: summary);
                      }
                      await deviceRepository.setConnection(uid: uid, device: current, connected: connected);
                    } catch (_) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to update this device.')));
                    }
                  },
                );
              }),
              const SizedBox(height: 18),
              const Text('Device permissions are controlled by the operating system. Life Pattern only reads the categories you approve.', style: TextStyle(color: AppColors.mutedText, fontSize: 12, height: 1.5)),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onChanged});
  final ConnectedDevice device;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Icon(device.type == 'wearable' ? Icons.watch_outlined : Icons.health_and_safety_outlined, color: device.connected ? AppColors.primary : AppColors.mutedText), title: Text(device.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), subtitle: Text(device.connected ? 'Connected' : 'Not connected', style: TextStyle(color: device.connected ? AppColors.primary : AppColors.mutedText, fontSize: 12)), trailing: TextButton(onPressed: () => onChanged(!device.connected), child: Text(device.connected ? 'Disconnect' : 'Connect'))));
}
