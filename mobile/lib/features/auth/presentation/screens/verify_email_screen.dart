import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_widgets.dart';

/// Email verification code entry (P1.2). The user types the 6-digit code sent
/// at registration; on success they return to the login screen. A resend link
/// re-issues the code behind a 60s cooldown (matching the backend).
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _codeLength = 6;
  static const int _cooldownSeconds = 60;

  final _codeCtrl = TextEditingController();
  final _focus = FocusNode();

  bool _verifying = false;
  bool _resending = false;
  String? _error;
  int _cooldown = _cooldownSeconds;
  Timer? _timer;

  String get _code => _codeCtrl.text;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else if (mounted) {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verify() async {
    if (_code.length != _codeLength || _verifying) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyEmail(widget.email, _code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified — please sign in.')),
      );
      context.go('/login');
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _codeCtrl.clear();
      });
      _focus.requestFocus();
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _resending) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).resendCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code is on its way.')),
      );
      _startCooldown();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Verify your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'We sent a code to ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              children: [
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '. Enter it below.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _pinField(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Submit',
            loading: _verifying,
            onPressed: _code.length == _codeLength ? _verify : null,
          ),
          const SizedBox(height: 18),
          _resendRow(),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              '‹ Back to Login',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinField() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The real input — invisible but interactive; drives the boxes.
          TextField(
            controller: _codeCtrl,
            focusNode: _focus,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            showCursor: false,
            enableSuggestions: false,
            autocorrect: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_codeLength),
            ],
            style: const TextStyle(color: Colors.transparent, height: 0.1),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (_) {
              setState(() {});
              if (_code.length == _codeLength) _verify();
            },
          ),
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_codeLength, _box),
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
      width: 46,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.circular(12),
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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _resendRow() {
    if (_resending) {
      return const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_cooldown > 0) {
      return Text(
        "Didn't get it? Resend in ${_cooldown}s",
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      );
    }
    return TextButton(onPressed: _resend, child: const Text('Resend code'));
  }
}
