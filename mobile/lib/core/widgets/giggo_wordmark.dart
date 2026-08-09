import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The GIGGO wordmark rendered as two-tone text — navy "GIG" + orange "GO".
/// On dark surfaces pass [onDark] so the base letters flip to white.
class GiggoWordmark extends StatelessWidget {
  const GiggoWordmark({super.key, this.fontSize = 26, this.onDark = false});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final baseColor = onDark ? AppColors.textOnDark : AppColors.primary;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          height: 1,
        ),
        children: [
          TextSpan(
            text: 'GIG',
            style: TextStyle(color: baseColor),
          ),
          const TextSpan(
            text: 'GO',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
