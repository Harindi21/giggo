import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_emailCtrl.text, _passwordCtrl.text);
    if (ok && mounted) context.go('/home');
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScaffold(
      heroAsset: AuthAssets.heroLogin,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null) AuthErrorBanner(message: state.error!),

            AuthTextField(
              controller: _emailCtrl,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordCtrl,
              hint: 'Password',
              obscure: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary.withValues(alpha: 0.45),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _comingSoon('Password reset'),
                child: const Text(
                  'Forgot password',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            PrimaryButton(
              label: 'Log in',
              loading: state.loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't you have an account? ",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => context.go('/role'),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const SocialRow(),
          ],
        ),
      ),
    );
  }
}
