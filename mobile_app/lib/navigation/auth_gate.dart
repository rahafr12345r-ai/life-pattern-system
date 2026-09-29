import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/authentication/sign_in_screen.dart';
import '../features/dashboard/role_home_screen.dart';
import '../features/privacy/consent_screen.dart';
import '../repositories/user_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.userRepository});

  final UserRepository? userRepository;

  @override
  Widget build(BuildContext context) {
    final repository = userRepository ?? UserRepository();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        final user = authSnapshot.data;
        if (user == null) return const SignInScreen();

        return StreamBuilder(
          stream: repository.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }
            final profile = profileSnapshot.data;
            if (profile == null || !profile.consentAccepted) {
              return ConsentScreen(user: user, userRepository: repository);
            }
            return RoleHomeScreen(role: profile.role, uid: user.uid);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
