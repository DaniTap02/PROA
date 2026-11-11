import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/popups.dart';
import 'sub_screen.dart';

const _icons = {
  'water': (LucideIcons.droplet, AppColors.turquoise, AppColors.infoBg),
  'activity': (LucideIcons.activity, AppColors.green, AppColors.greenSoft),
  'meals': (LucideIcons.pencilLine, AppColors.orange, AppColors.warmBg),
  'sleep': (LucideIcons.moon, AppColors.violet, AppColors.violetSoft),
  'streak': (LucideIcons.flame, AppColors.orange, AppColors.warmBg),
};

String _fmt(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

/// «Recordatorios»: interruptores y horas configurables (persisten).
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SubScreen(
      title: 'Recordatorios',
      subtitle: 'Configura cuándo quieres que PROA te recuerde tus hábitos.',
      children: [
        ProaCard(
          child: Row(children: [
            const IconBox(LucideIcons.bell, color: AppColors.amber, bg: AppColors.warmBg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Recordatorios activos', style: AppText.inter(14, FontWeight.w600)),
                Text(s.remindersMaster ? 'Activados' : 'Pausados', style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
              ]),
            ),
            ProaSwitch(value: s.remindersMaster, onChanged: (v) => _run(context, () => s.setRemindersMaster(v))),
          ]),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: s.remindersMaster ? 1 : 0.5,
          child: IgnorePointer(
            ignoring: !s.remindersMaster,
            child: ProaCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final (i, r) in s.reminders.indexed) ...[
                  if (i > 0) const RowDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      IconBox(_icons[r.id]!.$1, color: _icons[r.id]!.$2, bg: _icons[r.id]!.$3, size: 38, iconSize: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.title, style: AppText.inter(14, FontWeight.w600)),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: r.hour, minute: r.minute),
                                helpText: r.title,
                                cancelText: 'Cancelar',
                                confirmText: 'Guardar',
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.green)),
                                  child: child!,
                                ),
                              );
                              if (t != null && context.mounted) {
                                await _run(context, () => s.updateReminder(r.copyWith(hour: t.hour, minute: t.minute)));
                              }
                            },
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(
                                child: Text('${r.subtitle} ', style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
                              ),
                              Text(_fmt(r.hour, r.minute), style: AppText.inter(11.5, FontWeight.w700, color: AppColors.green)),
                              const SizedBox(width: 2),
                              const Icon(LucideIcons.pencil, size: 11, color: AppColors.green),
                            ]),
                          ),
                        ]),
                      ),
                      ProaSwitch(value: r.enabled, onChanged: (v) => _run(context, () => s.updateReminder(r.copyWith(enabled: v)))),
                    ]),
                  ),
                ],
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.info, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Tus recordatorios aparecen en el panel de notificaciones de Inicio según la hora configurada.',
              style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted, height: 1.45),
            ),
          ),
        ]),
      ],
    );
  }
}
