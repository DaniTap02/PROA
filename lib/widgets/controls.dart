import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';

/// Checkbox de Figma (22 px, radio 7, verde al marcar).
class ProaCheckbox extends StatelessWidget {
  const ProaCheckbox({super.key, required this.value, required this.onChanged, this.size = 24, this.color = AppColors.green});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        checked: value,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: value ? color : AppColors.white,
                borderRadius: BorderRadius.circular(size * 0.3),
                border: Border.all(color: value ? color : const Color(0xFFD1D5DB), width: 1.6),
              ),
              child: value ? Icon(LucideIcons.check, size: size * 0.66, color: AppColors.white) : null,
            ),
          ),
        ),
      );
}

/// Casilla circular de recomendaciones («Prueba esto antes de ceder»).
class RoundCheck extends StatelessWidget {
  const RoundCheck({super.key, required this.value, this.color = AppColors.amber, this.size = 22});
  final bool value;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: value ? color : const Color(0xFFD1D5DB), width: 1.6),
        ),
        child: value ? Icon(LucideIcons.check, size: size * 0.62, color: AppColors.white) : null,
      );
}

/// Interruptor de Figma (verde activo, gris inactivo).
class ProaSwitch extends StatelessWidget {
  const ProaSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
        toggled: value,
        child: GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? AppColors.green : const Color(0xFFE5E7EB),
              borderRadius: Radii.rPill,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: Shadows.soft),
              ),
            ),
          ),
        ),
      );
}

/// Chip de filtro (activo: fondo oscuro con check).
class ProaFilterChip extends StatelessWidget {
  const ProaFilterChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.text : AppColors.white,
              borderRadius: Radii.rPill,
              border: Border.all(color: selected ? AppColors.text : AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (selected) ...[const Icon(LucideIcons.check, size: 13, color: AppColors.white), const SizedBox(width: 5)],
              Text(label,
                  style: AppText.inter(12.5, FontWeight.w600,
                      color: selected ? AppColors.white : const Color(0xFF374151))),
            ]),
          ),
        ),
      );
}

/// Anillo de progreso circular.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 84,
    this.stroke = 8,
    this.color = AppColors.green,
    this.track = const Color(0xFFE5EDE8),
    this.gradient,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Gradient? gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(v, stroke, color, track, gradient),
            child: Center(child: child),
          ),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.stroke, this.color, this.track, this.gradient);
  final double v, stroke;
  final Color color, track;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(r, 0, math.pi * 2, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..color = track);
    if (v <= 0) return;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      p.shader = gradient!.createShader(rect);
    } else {
      p.color = color;
    }
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color || o.track != track;
}

/// Barra de progreso lineal redondeada.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 6, this.color = AppColors.green, this.track = const Color(0xFFE5EDE8), this.gradient});
  final double value;
  final double height;
  final Color color;
  final Color track;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: Radii.rPill,
        child: SizedBox(
          height: height,
          child: Stack(children: [
            Positioned.fill(child: ColoredBox(color: track)),
            TweenAnimationBuilder<double>(
              tween: Tween(end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 400),
              builder: (_, v, _) => FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(color: gradient == null ? color : null, gradient: gradient, borderRadius: Radii.rPill),
                ),
              ),
            ),
          ]),
        ),
      );
}

/// Selector segmentado («Semana · Mes · Año»).
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels, required this.index, required this.onChanged});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFE8EFEB), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: i == index ? Shadows.soft : null,
                  ),
                  child: Text(labels[i],
                      style: AppText.inter(13, i == index ? FontWeight.w600 : FontWeight.w500,
                          color: i == index ? AppColors.text : AppColors.textSecondary)),
                ),
              ),
            ),
        ]),
      );
}
