import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/habit_row.dart';
import '../profile/my_habits_screen.dart';
import 'habit_actions.dart';

/// «Mi plan de hoy»: calendario semanal, resumen del día y acciones.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  DateTime? _selected;

  Future<void> _pickDate(AppState s) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected ?? s.today,
      firstDate: s.firstDay.isBefore(s.today) ? s.firstDay : s.today.subtract(const Duration(days: 1)),
      lastDate: s.today,
      helpText: 'Elige un día',
      cancelText: 'Cancelar',
      confirmText: 'Ver plan',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.green)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selected = d);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final day = _selected ?? s.today;
    final isToday = day == s.today;
    final isFuture = day.isAfter(s.today);
    final done = s.completedOn(day);
    final total = s.plan.length;
    final pad = MediaQuery.paddingOf(context);
    final remaining = s.remainingMinutes(day);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 12, Gap.screen, pad.bottom + 20),
        children: [
          ScreenTitle(
            overline: Dates.overline(day),
            title: isToday ? 'Mi plan de hoy' : 'Mi plan del día',
            trailing: CircleIconButton(LucideIcons.calendar, semantic: 'Elegir fecha', onTap: () => _pickDate(s)),
          ),
          const SizedBox(height: 16),
          _WeekStrip(
            selected: day,
            today: s.today,
            activeOn: s.activeOn,
            onSelect: (d) => setState(() => _selected = d),
          ),
          const SizedBox(height: 16),
          ProaCard(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              ProgressRing(
                value: total == 0 ? 0 : done / total,
                size: 76,
                stroke: 8,
                child: Text('${total == 0 ? 0 : (done * 100 / total).round()}%', style: AppText.outfit(18, FontWeight.w700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$done de $total hábitos', style: AppText.outfit(20, FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    done >= total
                        ? '¡Completaste todos tus hábitos!'
                        : '${total - done} ${total - done == 1 ? 'hábito' : 'hábitos'} por completar${isToday ? ' hoy' : ''}',
                    style: AppText.inter(12.5, FontWeight.w400, color: AppColors.textSecondary),
                  ),
                  if (remaining > 0) ...[
                    const SizedBox(height: 8),
                    Pill('≈ $remaining min restantes', icon: LucideIcons.clock, fg: const Color(0xFF374151)),
                  ],
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          SectionHeader(isToday ? 'Acciones de hoy' : 'Acciones del día',
              action: 'Editar',
              onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyHabitsScreen()))),
          const SizedBox(height: 10),
          if (isFuture)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Podrás marcar estos hábitos cuando llegue el día.', style: AppText.secondary),
            ),
          IgnorePointer(
            ignoring: isFuture,
            child: Opacity(
              opacity: isFuture ? 0.55 : 1,
              child: HabitList(children: [
                for (final h in s.plan)
                  HabitRow(
                    habit: h,
                    done: s.dayOf(day, h.id).completed,
                    onToggle: () => toggleHabitFromList(context, day, h.id),
                    onOpen: () => openHabit(context, h.id, day),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          CravingBanner(onTap: () => openCravings(context)),
        ],
      ),
    );
  }
}

/// Acceso al registro de antojos (se abre desde Plan, Alimentación y Progreso).
class CravingBanner extends StatelessWidget {
  const CravingBanner({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ProaCard(
        onTap: onTap,
        color: AppColors.warmSofter,
        border: Border.all(color: const Color(0xFFFED7AA)),
        shadow: null,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          const IconBox(LucideIcons.cookie, color: AppColors.orange, bg: AppColors.warmBg, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('¿Tienes un antojo?', style: AppText.inter(14, FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Registra cómo te sientes y recibe ideas.', style: AppText.inter(12, FontWeight.w400, color: AppColors.textSecondary)),
            ]),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.orange),
        ]),
      );
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.today, required this.activeOn, required this.onSelect});
  final DateTime selected, today;
  final bool Function(DateTime) activeOn;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = Dates.weekOf(selected);
    return Row(children: [
      for (final d in days)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: _DayCell(
              date: d,
              selected: d == selected,
              isToday: d == today,
              active: !d.isAfter(today) && activeOn(d),
              onTap: () => onSelect(d),
            ),
          ),
        ),
    ]);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.selected, required this.isToday, required this.active, required this.onTap});
  final DateTime date;
  final bool selected, isToday, active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        label: Dates.chip(date),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 66,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryButtonGradient : null,
              color: selected ? null : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? Colors.transparent : (isToday ? AppColors.green : AppColors.border)),
              boxShadow: selected ? Shadows.colored() : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(Dates.weekdaysShort[date.weekday - 1],
                  style: AppText.inter(10.5, FontWeight.w500, color: selected ? AppColors.white.withValues(alpha: 0.85) : AppColors.textMuted)),
              const SizedBox(height: 3),
              Text('${date.day}', style: AppText.outfit(17, FontWeight.w700, color: selected ? AppColors.white : AppColors.text)),
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? (selected ? AppColors.white : AppColors.green) : Colors.transparent,
                ),
              ),
            ]),
          ),
        ),
      );
}
