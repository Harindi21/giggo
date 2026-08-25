import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Brand asset paths (exported from the GIGGO Figma).
class AuthAssets {
  AuthAssets._();
  static const String logo = 'assets/images/giggo_logo.png';
  static const String heroLogin = 'assets/images/hero_login.png';
  static const String heroSignup = 'assets/images/hero_signup.png';
  static const String heroRoleCustomer = 'assets/images/hero_role_customer.png';
  static const String heroRoleProvider = 'assets/images/hero_role_provider.png';
  static const String google = 'assets/images/social_google.png';
  static const String linkedin = 'assets/images/social_linkedin.png';
  static const String facebook = 'assets/images/social_facebook.png';
}

/// Shared chrome for the auth screens: a navy header carrying the GIGGO logo
/// (top-left) and an optional 3D hero (top-right), with a white, large-radius
/// sheet curving up over it — matching the GIGGO auth mockups.
class AuthScaffold extends StatelessWidget {
  /// Form content rendered inside the scrollable white sheet.
  final Widget child;

  /// Optional 3D hero image shown on the right of the navy header.
  final String? heroAsset;

  /// Height of the navy header band (before the status-bar inset is added).
  final double headerHeight;

  const AuthScaffold({
    super.key,
    required this.child,
    this.heroAsset,
    this.headerHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final heroHeight = headerHeight + 40; // overlaps the white sheet's curve

    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base layer: navy header space + white rounded sheet.
          Column(
            children: [
              SizedBox(height: topInset + headerHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      36,
                      28,
                      28 + media.viewInsets.bottom,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),

          // GIGGO logo, top-left in the navy band.
          Positioned(
            left: 28,
            top: topInset + 22,
            child: Image.asset(AuthAssets.logo, height: 40),
          ),

          // 3D hero, painted last so it overlaps the white sheet's top curve.
          if (heroAsset != null)
            Positioned(
              right: 0,
              top: topInset + 6,
              child: Image.asset(
                heroAsset!,
                height: heroHeight,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}

/// Filled, light-blue auth text field (mockup `#D2E5FF`, muted navy hint).
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: width == 0
        ? BorderSide.none
        : BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.37),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.surfaceBlue,
        isDense: true,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: _border(Colors.transparent, 0),
        enabledBorder: _border(Colors.transparent, 0),
        focusedBorder: _border(AppColors.accent, 1.4),
        errorBorder: _border(AppColors.error, 1),
        focusedErrorBorder: _border(AppColors.error, 1.4),
      ),
    );
  }
}

/// Full-width orange CTA (Log in / Sign Up / Submit …), Red Hat Display bold.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.redHatDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Google / LinkedIn / Facebook row. Social sign-in is not wired yet, so every
/// icon surfaces a friendly "coming soon" message (P1.3 seam).
class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    void comingSoon() => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social sign-in is coming soon')),
    );

    Widget icon(String asset) => InkWell(
      onTap: comingSoon,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(asset, height: 44, width: 44),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon(AuthAssets.google),
        const SizedBox(width: 30),
        icon(AuthAssets.linkedin),
        const SizedBox(width: 30),
        icon(AuthAssets.facebook),
      ],
    );
  }
}

/// Inline error banner used on the auth forms.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.error, fontSize: 13),
      ),
    );
  }
}
