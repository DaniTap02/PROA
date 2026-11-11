import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';
import '../models/craving.dart';

/// «Tarjeta de emoción»: inactiva blanca; activa con borde y fondo del color
/// de la emoción e ícono relleno.
class EmotionCard extends StatelessWidget {
  const EmotionCard({super.key, required this.emotion, required this.selected, required this.onTap});
  final Emotion emotion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = emotion.color;
    return Semantics(
      selected: selected,
      button: true,
      label: emotion.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 92,
          decoration: BoxDecoration(
            color: selected ? emotion.softColor : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? c : AppColors.border, width: selected ? 1.8 : 1),
            boxShadow: selected ? Shadows.colored(c) : Shadows.soft,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? c : emotion.softColor,
                shape: BoxShape.circle,
              ),
              child: Icon(emotion.icon, size: 19, color: selected ? AppColors.white : c),
            ),
            const SizedBox(height: 8),
            Text(emotion.label,
                style: AppText.inter(12, FontWeight.w600, color: selected ? c : AppColors.text)),
          ]),
        ),
      ),
    );
  }
}
