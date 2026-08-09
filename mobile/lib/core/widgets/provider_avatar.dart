import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular avatar showing a network image when available, otherwise the
/// person's initials on a navy background (mockup style).
class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 26,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              _initials,
              style: TextStyle(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.7,
              ),
            ),
    );
  }
}
