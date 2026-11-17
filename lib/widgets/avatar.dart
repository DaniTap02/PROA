import 'package:flutter/material.dart';

import '../core/assets.dart';
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

  /// Foto ilustrativa acorde al sexo del perfil.
  static const illustrative = 'illustrative';

  /// Foto ilustrativa para [sex]; null si no aplica («Prefiero no decir»).
  static String? illustrativeFor(Sex sex) => switch (sex) {
        Sex.female => Img.avatar,
        Sex.male => Img.avatarMale,
        Sex.other => null,
      };

  /// Resuelve la ruta a mostrar. Las versiones anteriores guardaban
  /// directamente la foto de mujer; se trata como «foto ilustrativa».
  static String? resolve(UserProfile? p) {
    final path = p?.photoPath;
    if (p == null || path == null || path == noPhoto) return null;
    if (path == illustrative || path == Img.avatar || path == Img.avatarMale) return illustrativeFor(p.sex);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final path = resolve(profile);
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
        child: path == null
            ? fallback
            : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}
