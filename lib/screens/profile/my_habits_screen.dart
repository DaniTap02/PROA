import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/habits_catalog.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/popups.dart';
import '../main/habit_actions.dart';
import 'sub_screen.dart';

/// «Mis hábitos»: activar o desactivar hábitos del plan diario.
class MyHabitsScreen extends StatelessWidget {
  const MyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SubScreen(
      title: 'Mis hábitos',
      subtitle: 'Elige qué hábitos aparecen en tu plan diario.',
      children: [
        ProaCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final (i, h) in habitsCatalog.indexed) ...[
              if (i > 0) const RowDivider(),
              InkWell(
                onTap: () => openHabit(context, h.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    IconBox(h.icon, color: h.color, bg: h.softColor, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.name, style: AppText.inter(14, FontWeight.w600)),
                        Text('${h.shortGoal} · ${s.habitStreak(h.id)} ${s.habitStreak(h.id) == 1 ? 'día seguido' : 'días seguidos'}',
                            style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
                      ]),
                    ),
                    ProaSwitch(
                      value: s.activeHabits.contains(h.id),
                      onChanged: (v) async {
                        final next = Set.of(s.activeHabits);
                        v ? next.add(h.id) : next.remove(h.id);
                        if (next.isEmpty) {
                          showProaToast(context,
                              title: 'Necesitas al menos un hábito',
                              message: 'Tu plan diario no puede quedar vacío.',
                              icon: LucideIcons.info,
                              iconBg: AppColors.turquoise);
                          return;
                        }
                        try {
                          await s.setActiveHabits(next);
                        } catch (_) {
                          if (context.mounted) showErrorToast(context);
                        }
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.info, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Desactivar un hábito no borra su historial: puedes volver a activarlo cuando quieras.',
                style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted, height: 1.45)),
          ),
        ]),
      ],
    );
  }
}
