import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../../data/models/register_request.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role; // 'CUSTOMER' or 'PROVIDER'
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  bool get _isProvider => widget.role == 'PROVIDER';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            RegisterRequest(
              fullName: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              password: _passwordCtrl.text,
              role: widget.role,
            ),
          );
      if (!mounted) return;
      context.go(
        '/verify-email?email=${Uri.encodeComponent(_emailCtrl.text.trim())}',
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      heroAsset: AuthAssets.heroSignup,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isProvider ? 'as a Service Provider' : 'as a Customer',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 22),

            if (_error != null) AuthErrorBanner(message: _error!),

            AuthTextField(
              controller: _nameCtrl,
              hint: 'Full name',
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _emailCtrl,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _phoneCtrl,
              hint: 'Mobile number (07XXXXXXXX)',
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordCtrl,
              hint: 'Password',
              obscure: _obscure,
              suffixIcon: _eye(_obscure, () {
                setState(() => _obscure = !_obscure);
              }),
              validator: _validatePassword,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmCtrl,
              hint: 'Confirm Password',
              obscure: _obscureConfirm,
              suffixIcon: _eye(_obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),
              validator: (v) => (v != _passwordCtrl.text)
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Sign Up',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SocialRow(),
          ],
        ),
      ),
    );
  }

  Widget _eye(bool obscured, VoidCallback onTap) => IconButton(
    icon: Icon(
      obscured ? Icons.visibility_off : Icons.visibility,
      color: AppColors.primary.withValues(alpha: 0.45),
      size: 20,
    ),
    onPressed: onTap,
  );

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your mobile number';
    final re = RegExp(r'^(?:\+94|0)7\d{8}$');
    return re.hasMatch(v.trim().replaceAll(' ', ''))
        ? null
        : 'Use a Sri Lankan mobile, e.g. 0712345678';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'At least 8 characters';
    if (v.length > 72) return 'At most 72 characters';
    return null;
  }
}
