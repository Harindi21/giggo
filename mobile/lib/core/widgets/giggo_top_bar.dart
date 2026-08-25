import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'giggo_wordmark.dart';

/// Navy, bottom-rounded top bar carrying the GIGGO wordmark and a profile
/// avatar — the shared header used across the customer tabs (Tasks, Hub,
/// Marketplace) per the Figma. Home has its own header (it also holds search).
class GiggoTopBar extends StatelessWidget {
  const GiggoTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const GiggoWordmark(fontSize: 26, onDark: true),
            InkWell(
              onTap: () => context.go('/profile'),
              borderRadius: BorderRadius.circular(24),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
