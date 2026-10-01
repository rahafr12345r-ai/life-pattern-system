import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../shared/auth_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  final _users = UserRepository();
  bool _signup = false;
  bool _specialist = false;
  bool _visible = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); _authService = widget.authService ?? AuthService(); }
  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final role = _specialist ? 'Doctor' : 'Patient';
      if (_signup) {
        final credential = await _authService.createAccount(email: _emailController.text, password: _passwordController.text);
        final user = credential.user;
        if (user != null) await _users.createProfile(user: user, role: role, displayName: _nameController.text);
      } else {
        await _authService.signInWithEmail(email: _emailController.text, password: _passwordController.text);
      }
    } on FirebaseAuthException catch (error) { if (mounted) setState(() => _error = _friendly(error)); }
    catch (_) { if (mounted) setState(() => _error = 'Unable to continue right now. Please try again.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  String _friendly(FirebaseAuthException error) => switch (error.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'The email or password is incorrect.',
        'email-already-in-use' => 'An account already exists for this email.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        _ => 'Unable to continue right now. Please try again.',
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
            children: [
              const LifePatternBrand(showLanguage: false),
              const SizedBox(height: 28),
              Center(child: Text(_signup ? 'Create your account' : 'Sign in to your account', style: const TextStyle(color: AppColors.mutedText, fontSize: 14))),
              const SizedBox(height: 20),
              if (_error != null) ...[
                _ErrorBanner(message: _error!),
                const SizedBox(height: 14),
              ],
              Row(children: [
                Expanded(child: _RoleTab(icon: Icons.person_outline, label: 'Patient', selected: !_specialist, onTap: () => setState(() => _specialist = false))),
                const SizedBox(width: 6),
                Expanded(child: _RoleTab(icon: Icons.local_hospital_outlined, label: 'Specialist', selected: _specialist, onTap: () => setState(() => _specialist = true))),
              ]),
              const SizedBox(height: 18),
              Form(key: _formKey, child: Column(children: [
                if (_signup) ...[
                  _label('Full Name / الاسم الكامل'),
                  TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'e.g. Sarah or خالد'), validator: (value) => value == null || value.trim().length < 3 ? 'Enter your full name' : null),
                  const SizedBox(height: 14),
                ],
                _label('Username or Email / اسم المستخدم أو البريد'),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'e.g. your email'), validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null),
                const SizedBox(height: 14),
                _label('Password / كلمة المرور'),
                TextFormField(controller: _passwordController, obscureText: !_visible, decoration: InputDecoration(hintText: 'Enter your password', suffixIcon: IconButton(onPressed: () => setState(() => _visible = !_visible), icon: Icon(_visible ? Icons.visibility : Icons.visibility_off))), validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: _loading ? null : _submit, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_signup ? 'Create Account' : 'Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
              ])),
              if (!_signup) ...[const SizedBox(height: 14), Center(child: TextButton(onPressed: () {}, child: const Text('Forgot password?')))],
              const SizedBox(height: 8),
              Center(child: Wrap(alignment: WrapAlignment.center, children: [Text(_signup ? 'Already have an account? ' : "Don't have an account? ", style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), GestureDetector(onTap: () => setState(() { _signup = !_signup; _error = null; }), child: Text(_signup ? 'Sign in' : 'Sign up', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)))])),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );

  Widget _label(String text) => Align(alignment: AlignmentDirectional.centerStart, child: Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(text, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600))));
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: selected ? AppColors.primary : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 17, color: selected ? Colors.white : AppColors.mutedText), const SizedBox(width: 6), Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.mutedText, fontSize: 13, fontWeight: FontWeight.w800))])));
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.alertHighBackground, border: Border.all(color: const Color(0xFFFFCDD2)), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.error_outline, color: AppColors.alertHigh, size: 20), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(color: AppColors.alertHigh, fontSize: 12, fontWeight: FontWeight.w600)))]));
}
