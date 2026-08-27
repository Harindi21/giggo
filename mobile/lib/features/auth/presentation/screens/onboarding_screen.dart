import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

/// Onboarding intro (Figma): "Get Things Done. Earn With Your Skills." on navy
/// with the 3D worker, then Continue on to login.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            return Stack(
              children: [
                // 3D worker anchored to the bottom.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    AuthAssets.heroSignup,
                    height: h * 0.40,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(28, h * 0.04, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(AuthAssets.logo, height: 52),
                      SizedBox(height: h * 0.11),
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textOnDark,
                          ),
                          children: [
                            TextSpan(text: 'Get Things '),
                            TextSpan(
                              text: 'Done',
                              style: TextStyle(color: AppColors.accent),
                            ),
                            TextSpan(text: '.\n'),
                            TextSpan(
                              text: 'Earn',
                              style: TextStyle(color: AppColors.accent),
                            ),
                            TextSpan(text: ' With Your Skills.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Giggo connects people who need help with trusted '
                        'local pros. Book in minutes or start getting jobs today.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 34),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Continue ›',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
