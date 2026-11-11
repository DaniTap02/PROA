import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';

/// Tarjeta blanca con esquinas de 20 px y sombra suave.
class ProaCard extends StatelessWidget {
  const ProaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppColors.white,
    this.radius = Radii.rCard,
    this.border,
    this.shadow = Shadows.soft,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final BorderRadius radius;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// Caja de ícono de hábito/emoción (radio 12).
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, required this.color, required this.bg, this.size = 40, this.iconSize = 20, this.radius = Radii.icon});

  final IconData icon;
  final Color color;
  final Color bg;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
        child: Icon(icon, size: iconSize, color: color),
      );
}

/// Píldora (radio total) con ícono opcional: «Hecho», «2 min», «6 días seguidos».
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.icon, this.fg = AppColors.textSecondary, this.bg = AppColors.surfaceMuted, this.border, this.fontSize = 11, this.padding});

  final String text;
  final IconData? icon;
  final Color fg;
  final Color bg;
  final Color? border;
  final double fontSize;
  final EdgeInsets? padding;

  factory Pill.done() => const Pill('Hecho', icon: LucideIcons.check, fg: AppColors.green, bg: AppColors.greenSoft);
  factory Pill.pending() => const Pill('Pendiente', fg: AppColors.orange, bg: AppColors.warmBg);

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: Radii.rPill,
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: fontSize + 1, color: fg), const SizedBox(width: 4)],
          Text(text, style: AppText.inter(fontSize, FontWeight.w600, color: fg)),
        ]),
      );
}

/// Botón circular blanco (volver, guardar, calendario, notificaciones).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton(this.icon, {super.key, required this.onTap, this.size = 40, this.color = AppColors.text, this.bg = AppColors.white, this.badge = false, this.semantic, this.filled = false});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color bg;
  final bool badge;
  final String? semantic;
  final bool filled;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantic,
        child: Material(
          color: bg,
          shape: const CircleBorder(),
          elevation: 0,
          shadowColor: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: bg == AppColors.white ? Shadows.soft : null),
              child: Stack(alignment: Alignment.center, children: [
                Icon(icon, size: size * 0.48, color: color, fill: filled ? 1 : 0),
                if (badge)
                  Positioned(
                    top: size * 0.24,
                    right: size * 0.26,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 1.5),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

/// Botón de volver de las pantallas internas.
class BackCircle extends StatelessWidget {
  const BackCircle({super.key, this.onTap, this.size = 36});
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) => CircleIconButton(
        LucideIcons.chevronLeft,
        size: size,
        semantic: 'Volver',
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
      );
}

/// Encabezado de sección «Hábitos de hoy ··· Ver todo».
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.actionColor = AppColors.green});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Color actionColor;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: AppText.outfit(17, FontWeight.w600))),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(action!, style: AppText.inter(13, FontWeight.w600, color: actionColor)),
            ),
          ),
      ]);
}

/// Antetítulo + título de pantalla («EDUCACIÓN NUTRICIONAL / Aprende a comer mejor»).
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, this.overline, required this.title, this.trailing, this.overlineColor = AppColors.green});
  final String? overline;
  final String title;
  final Widget? trailing;
  final Color overlineColor;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (overline != null) ...[
              Text(overline!.toUpperCase(), style: AppText.overline.copyWith(color: overlineColor)),
              const SizedBox(height: 4),
            ],
            Text(title, style: AppText.h1),
          ]),
        ),
        ?trailing,
      ]);
}

/// Separador fino entre filas de una tarjeta.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.indent = 16});
  final double indent;
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: AppColors.border.withValues(alpha: 0.7), indent: indent, endIndent: indent);
}

/// Imagen del banco con recorte y degradado opcional.
class ProaImage extends StatelessWidget {
  const ProaImage(this.path, {super.key, this.fit = BoxFit.cover, this.alignment = Alignment.center});
  final String path;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Image.asset(
        path,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.greenSoft,
          alignment: Alignment.center,
          child: const Icon(LucideIcons.image, color: AppColors.green),
        ),
      );
}
