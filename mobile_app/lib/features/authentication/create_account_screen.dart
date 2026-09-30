import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../shared/auth_widgets.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  late final UserRepository _userRepository;
  String _accountType = 'Patient';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _userRepository = UserRepository();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.createAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = credential.user;
      if (user != null) {
        await _userRepository.createProfile(user: user, role: _accountType, displayName: _nameController.text);
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      setState(() => _errorMessage = _friendlyAuthError(error));
    } catch (_) {
      setState(() => _errorMessage = 'Unable to create the account right now.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createAccountWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _userRepository.createProfile(user: user, role: _accountType, displayName: _nameController.text);
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      setState(() => _errorMessage = _friendlyAuthError(error));
    } catch (_) {
      setState(() => _errorMessage = 'Unable to continue with Google right now.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password.';
      default:
        return 'Unable to create the account right now.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LifePatternBrand(),
                    const SizedBox(height: 36),
                    const Text(
                      'Create a new account',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your account and choose a role',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (value) => value == null || value.trim().length < 3 ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
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
                        labelText: 'Password',
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _accountType,
                      decoration: const InputDecoration(labelText: 'Account type'),
                      items: const [
                        DropdownMenuItem(value: 'Patient', child: Text('Patient')),
                        DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                      ],
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _accountType = value!),
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
                      label: _isLoading ? 'Creating account...' : 'Create account',
                      onPressed: _isLoading ? null : _createAccount,
                    ),
                    const SizedBox(height: 12),
                    GoogleButton(
                      onPressed: _isLoading ? null : _createAccountWithGoogle,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Back to sign in'),
                      ),
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
