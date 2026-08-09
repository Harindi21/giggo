import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'giggo_wordmark.dart';

/// Placeholder for tabs/features that arrive in a later WBS phase.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon, this.message});

  final String title;
  final IconData icon;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GiggoWordmark(fontSize: 30),
              const SizedBox(height: 24),
              Icon(icon, size: 56, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                message ?? '$title is coming soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
