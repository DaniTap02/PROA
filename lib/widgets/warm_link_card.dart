import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';

/// Tarjeta de acceso con acento naranja (antojos y ansiedad en Figma).
class WarmLinkCard extends StatelessWidget {
  const WarmLinkCard({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: title,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.warmSofter, AppColors.warmBg]),
              borderRadius: Radii.rCard,
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(gradient: AppColors.accentButtonGradient, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppText.inter(14, FontWeight.w700, color: const Color(0xFF9A3412))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.inter(12.5, FontWeight.w400, color: const Color(0xFFC2410C))),
                ]),
              ),
              const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.orange),
            ]),
          ),
        ),
      );
}
