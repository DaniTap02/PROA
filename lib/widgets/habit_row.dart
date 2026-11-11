import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../models/habit.dart';
import 'common.dart';
import 'controls.dart';

/// «Fila de hábito» de Figma: al tocar el check se marca/desmarca (se tacha y
/// cambia de color); al tocar el resto de la fila se abre su detalle.
class HabitRow extends StatelessWidget {
  const HabitRow({
    super.key,
    required this.habit,
    required this.done,
    required this.onToggle,
    required this.onOpen,
  });

  final Habit habit;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 14, 14),
          child: Row(children: [
            ProaCheckbox(value: done, onChanged: (_) => onToggle()),
            const SizedBox(width: 6),
            IconBox(habit.icon, color: habit.color, bg: habit.softColor, size: 38, iconSize: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  style: AppText.inter(14.5, FontWeight.w600,
                          color: done ? AppColors.textMuted : AppColors.text, height: 1.25)
                      .copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                  child: Text(habit.name),
                ),
                const SizedBox(height: 2),
                Text(habit.shortGoal, style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
              ]),
            ),
            const SizedBox(width: 8),
            done ? Pill.done() : Pill(habit.estimate, icon: LucideIcons.clock),
          ]),
        ),
      );
}

/// Tarjeta blanca con las filas de hábitos separadas por líneas finas.
class HabitList extends StatelessWidget {
  const HabitList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ProaCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const RowDivider(),
              children[i],
            ],
          ]),
        ),
      );
}
