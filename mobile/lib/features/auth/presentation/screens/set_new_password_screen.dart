import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

/// "Set New Password?" — step 3 of the reset flow (Figma). UI-only for now: with
/// no backend reset endpoint yet, Reset validates and returns to login.
class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  const SetNewPasswordScreen({super.key, required this.email});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    if (!_formKey.currentState!.validate()) return;
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated — please sign in.')),
    );
  }

  String? _validatePassword(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Enter a password';
    if (t.length < 8) return 'At least 8 characters';
    if (!RegExp(r'\d').hasMatch(t)) return 'Add at least one number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(t)) {
      return 'Add at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthCenteredScaffold(
      children: [
        const AuthTitle(
          title: 'Set New Password?',
          subtitle: 'At least 8 characters, 1 special character and a number.',
        ),
        const SizedBox(height: 30),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _passwordCtrl,
                hint: 'Password',
                obscure: _obscure,
                suffixIcon: _eye(_obscure, () {
                  setState(() => _obscure = !_obscure);
                }),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmCtrl,
                hint: 'Confirm Password',
                obscure: _obscureConfirm,
                suffixIcon: _eye(_obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }),
                validator: (v) =>
                    v != _passwordCtrl.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Reset', onPressed: _reset),
        const SizedBox(height: 20),
        BackToLogin(onTap: () => context.go('/login')),
      ],
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
}
