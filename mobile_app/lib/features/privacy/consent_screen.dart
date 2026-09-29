import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/user_repository.dart';
import '../../shared/auth_widgets.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({required this.user, super.key, this.userRepository});

  final User user;
  final UserRepository? userRepository;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  late final UserRepository _repository;
  bool _accepted = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.userRepository ?? UserRepository();
  }

  Future<void> _continue() async {
    if (!_accepted) {
      setState(() => _error = 'Please review and accept the privacy consent.');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _repository.updateConsent(uid: widget.user.uid, accepted: true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to save consent. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LifePatternBrand(),
                  const SizedBox(height: 36),
                  const Text(
                    'Privacy and consent',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Life Pattern uses lifestyle data such as sleep and activity to build a personal baseline and identify unusual changes.',
                    style: TextStyle(color: AppColors.mutedText, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your information is private and is shared with a therapist only when you allow it. This system provides early behavioral insights; it is not a medical diagnosis.',
                    style: TextStyle(color: AppColors.mutedText, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    value: _accepted,
                    onChanged: _isSaving ? null : (value) => setState(() => _accepted = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text('I understand and agree to the privacy consent.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: _isSaving ? 'Saving...' : 'Continue',
                    onPressed: _isSaving ? null : _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
