import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

/// "Password Reset" — step 2 of the reset flow (Figma): a 4-digit code. UI-only
/// for now; Submit advances to setting the new password.
class ResetCodeScreen extends StatefulWidget {
  final String email;
  const ResetCodeScreen({super.key, required this.email});

  @override
  State<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends State<ResetCodeScreen> {
  static const int _len = 4;
  final _codeCtrl = TextEditingController();
  final _focus = FocusNode();

  String get _code => _codeCtrl.text;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.length != _len) return;
    context.go('/set-new-password?email=${Uri.encodeComponent(widget.email)}');
  }

  @override
  Widget build(BuildContext context) {
    final to = widget.email.isEmpty ? 'your email' : widget.email;
    return AuthCenteredScaffold(
      children: [
        AuthTitle(
          title: 'Password Reset',
          subtitle: 'We sent a code to $to. Enter it.',
        ),
        const SizedBox(height: 30),
        _pinField(),
        const SizedBox(height: 30),
        PrimaryButton(
          label: 'Submit',
          onPressed: _code.length == _len ? _submit : null,
        ),
        const SizedBox(height: 20),
        BackToLogin(onTap: () => context.go('/login')),
      ],
    );
  }

  Widget _pinField() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _codeCtrl,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              showCursor: false,
              enableSuggestions: false,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_len),
              ],
              style: const TextStyle(color: Colors.transparent, height: 0.1),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _len; i++) ...[
                  _box(i),
                  if (i != _len - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(int i) {
    final filled = i < _code.length;
    final active = i == _code.length && _focus.hasFocus;
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? AppColors.accent
              : (filled ? AppColors.primary : Colors.transparent),
          width: active || filled ? 2 : 1,
        ),
      ),
      child: Text(
        filled ? _code[i] : '',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
