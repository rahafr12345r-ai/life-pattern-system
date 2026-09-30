import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../shared/auth_widgets.dart';
import 'create_account_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await _runAuth(() {
      return _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    });
  }

  Future<void> _runAuth(Future<Object?> Function() action) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      setState(() => _errorMessage = _friendlyAuthError(error));
    } catch (_) {
      setState(() => _errorMessage = 'Unable to sign in right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Unable to sign in right now. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LifePatternBrand(),
                    const SizedBox(height: 48),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to review your daily patterns',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: _isLoading ? 'Signing in...' : 'Sign in',
                      onPressed: _isLoading ? null : _signIn,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const CreateAccountScreen(),
                                  ),
                                ),
                        child: const Text('Create a new account'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3DD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        '✓  Test access: rahaf.adil@lifepattern.com / Life1234',
                        style: TextStyle(color: Color(0xFFE36D28), fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'This score describes behavioral changes only; it is not a medical diagnosis or treatment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedText, fontSize: 13, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
