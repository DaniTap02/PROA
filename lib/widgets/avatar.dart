import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../models/user_profile.dart';

/// Foto de perfil; si la persona eligió no usar foto, muestra sus iniciales.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, this.size = 44, this.border});
  final UserProfile? profile;
  final double size;
  final Color? border;

  static const noPhoto = 'none';

  @override
  Widget build(BuildContext context) {
    final path = profile?.photoPath;
    final initials = (profile?.name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final fallback = Container(
      color: AppColors.greenSoft,
      alignment: Alignment.center,
      child: Text(initials, style: AppText.outfit(size * 0.38, FontWeight.w700, color: AppColors.greenDark)),
    );
    return Container(
      width: size,
      height: size,
      padding: border == null ? null : EdgeInsets.all(size * 0.04),
      decoration: BoxDecoration(shape: BoxShape.circle, color: border),
      child: ClipOval(
        child: path == null || path == noPhoto
            ? fallback
            : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}
