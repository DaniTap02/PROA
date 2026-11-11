import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';
import '../models/guide.dart';
import 'common.dart';

/// Tarjeta de guía de la cuadrícula «Todas las guías».
class GuideCard extends StatelessWidget {
  const GuideCard({super.key, required this.guide, required this.onTap, this.saved = false, this.imageHeight = 112, this.home = false});
  final Guide guide;
  final VoidCallback onTap;
  final bool saved;
  final double imageHeight;

  /// Variante de «Guías para ti» en Inicio: etiqueta sobre la foto, título
  /// completo y «N min de lectura».
  final bool home;

  @override
  Widget build(BuildContext context) => ProaCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        radius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(fit: StackFit.expand, children: [
                ProaImage(guide.image),
                if (home)
                  Positioned(top: 8, left: 8, child: Pill(guide.tag, fg: AppColors.text, bg: AppColors.white, fontSize: 10.5)),
                if (saved)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.bookmark, size: 13, color: AppColors.green, fill: 1),
                    ),
                  ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(home ? guide.title : guide.shortTitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.inter(home ? 13.5 : 13, FontWeight.w700)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(LucideIcons.clock, size: 11, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(home ? '${guide.minutes} min de lectura' : '${guide.minutes} min',
                    style: AppText.caption.copyWith(color: AppColors.textMuted)),
              ]),
            ]),
          ),
        ]),
      );
}

/// Tarjeta grande con foto y texto encima («Destacado»).
class FeaturedGuideCard extends StatelessWidget {
  const FeaturedGuideCard({super.key, required this.guide, required this.onTap, this.height = 160, this.badge = 'Destacado'});
  final Guide guide;
  final VoidCallback onTap;
  final double height;
  final String? badge;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(borderRadius: Radii.rCard, boxShadow: Shadows.soft),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            ProaImage(guide.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Color(0x00000000), Color(0xB3052E16)],
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: 12,
                left: 12,
                child: Pill(badge!, icon: LucideIcons.flame, fg: AppColors.green, bg: AppColors.white),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(guide.title, style: AppText.outfit(21, FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(LucideIcons.clock, size: 12, color: AppColors.white.withValues(alpha: 0.85)),
                  const SizedBox(width: 5),
                  Text('${guide.minutes} min de lectura · ${guide.level}',
                      style: AppText.inter(11.5, FontWeight.w500, color: AppColors.white.withValues(alpha: 0.85))),
                ]),
              ]),
            ),
          ]),
        ),
      );
}
