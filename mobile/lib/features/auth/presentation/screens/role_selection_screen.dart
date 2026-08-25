import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

/// "How do you want to use Giggo as?" — the customer/provider role picker,
/// rendered as a full navy screen with the two 3D characters (mockup).
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selected; // 'CUSTOMER' or 'PROVIDER'

  void _continue() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick how you want to use Giggo')),
      );
      return;
    }
    context.go('/register?role=$_selected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            final w = c.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Person with phone — top-right, overlapping the corner.
                Positioned(
                  top: h * 0.04,
                  right: -w * 0.05,
                  child: Image.asset(
                    AuthAssets.heroRoleCustomer,
                    height: h * 0.26,
                    fit: BoxFit.contain,
                  ),
                ),
                // Person with laptop — anchored bottom-left, large.
                Positioned(
                  bottom: h * 0.05,
                  left: -w * 0.04,
                  child: Image.asset(
                    AuthAssets.heroRoleProvider,
                    height: h * 0.40,
                    fit: BoxFit.contain,
                  ),
                ),

                // Foreground content.
                Padding(
                  padding: EdgeInsets.fromLTRB(28, h * 0.02, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(AuthAssets.logo, height: 42),
                      SizedBox(height: h * 0.16),
                      const Text(
                        'How do you want to\nuse Giggo as?',
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 26,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      _RoleButton(
                        label: 'Customer',
                        selected: _selected == 'CUSTOMER',
                        onTap: () => setState(() => _selected = 'CUSTOMER'),
                      ),
                      const SizedBox(height: 16),
                      _RoleButton(
                        label: 'Service Provider',
                        selected: _selected == 'PROVIDER',
                        onTap: () => setState(() => _selected = 'PROVIDER'),
                      ),
                    ],
                  ),
                ),

                // Continue — bottom-right.
                Positioned(
                  right: 24,
                  bottom: h * 0.03,
                  child: GestureDetector(
                    onTap: _continue,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: _selected == null
                                ? AppColors.accent.withValues(alpha: 0.6)
                                : AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: _selected == null
                              ? AppColors.accent.withValues(alpha: 0.6)
                              : AppColors.accent,
                        ),
                      ],
                    ),
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

class _RoleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: selected ? 1 : 0.85),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
