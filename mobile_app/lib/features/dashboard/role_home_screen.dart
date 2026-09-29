import 'package:flutter/material.dart';

import 'app_shell.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({required this.role, required this.uid, super.key});

  final String role;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return AppShell(role: role, uid: uid);
  }
}
