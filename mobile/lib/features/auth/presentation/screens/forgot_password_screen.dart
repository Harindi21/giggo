import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_widgets.dart';

/// "Forgot Password?" — step 1 of the reset flow (Figma). UI-only for now: the
/// backend has no password-reset endpoint yet, so Submit advances the flow.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    context.go('/reset-code?email=${Uri.encodeComponent(email)}');
  }

  @override
  Widget build(BuildContext context) {
    return AuthCenteredScaffold(
      children: [
        const AuthTitle(
          title: 'Forgot Password?',
          subtitle: "No worries. We'll send you instructions to reset.",
        ),
        const SizedBox(height: 30),
        Form(
          key: _formKey,
          child: AuthTextField(
            controller: _emailCtrl,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Enter your email';
              final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              return re.hasMatch(t) ? null : 'Enter a valid email';
            },
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(label: 'Submit', onPressed: _submit),
        const SizedBox(height: 20),
        BackToLogin(onTap: () => context.go('/login')),
      ],
    );
  }
}
