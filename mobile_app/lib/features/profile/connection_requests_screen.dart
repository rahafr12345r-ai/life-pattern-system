import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/connection_request.dart';
import '../../repositories/connection_repository.dart';

class ConnectionRequestsScreen extends StatelessWidget {
  const ConnectionRequestsScreen({required this.doctorId, super.key, this.repository});

  final String doctorId;
  final ConnectionRepository? repository;

  @override
  Widget build(BuildContext context) {
    final links = repository ?? ConnectionRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Connection requests')),
      body: StreamBuilder<List<ConnectionRequest>>(
        stream: links.watchForUser(uid: doctorId, doctor: true),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? const <ConnectionRequest>[];
          if (requests.isEmpty) {
            return const Center(child: Text('No connection requests.', style: TextStyle(color: AppColors.mutedText)));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: requests.map((request) {
              final actions = request.status == 'pending'
                  ? Wrap(children: [
                      IconButton(onPressed: () => links.updateStatus(requestId: request.id, status: 'rejected'), icon: const Icon(Icons.close, color: AppColors.error)),
                      IconButton(onPressed: () => links.updateStatus(requestId: request.id, status: 'accepted'), icon: const Icon(Icons.check, color: AppColors.primary)),
                    ])
                  : Text(request.status);
              return Card(elevation: 0, color: Colors.white, child: ListTile(title: Text('Patient ${request.patientId}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), subtitle: Text(request.status, style: const TextStyle(color: AppColors.mutedText)), trailing: actions));
            }).toList(),
          );
        },
      ),
    );
  }
}
