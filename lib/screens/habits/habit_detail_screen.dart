import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/habits_catalog.dart';
import '../../models/habit.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';
import '../main/habit_actions.dart';

/// Detalle de un hábito: foto, meta, indicadores, registro, consejos y botón
/// para marcar como completado. Sirve para los cinco hábitos.
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.id, this.date});
  final HabitId id;
  final DateTime? date;

  String _trackerValue(Habit h, int p) => switch (h.id) {
        HabitId.water => '${_l(p * 0.25)} L de ${_l(h.target * 0.25)} L',
        HabitId.activity => '${p * 5} de ${h.target * 5} min',
        HabitId.fruits => '$p de ${h.target} porciones',
        HabitId.meals => '$p de ${h.target} comidas',
        HabitId.sleep => '$p h de ${h.target} h',
      };

  String _metric(Habit h, int p) => switch (h.id) {
        HabitId.activity => '${p * 5}',
        HabitId.sleep => '$p h',
        _ => '$p/${h.target}',
      };

  static String _l(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString().replaceAll('.', ',');

  Future<void> _setProgress(BuildContext context, DateTime day, Habit h, int value) async {
    HapticFeedback.selectionClick();
    try {
      final reached = await context.read<AppState>().setProgress(day, h.id, value);
      if (reached && context.mounted) await celebrateHabit(context, day);
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  Future<void> _toggle(BuildContext context, DateTime day, bool completed) async {
    try {
      await context.read<AppState>().setCompleted(day, id, !completed);
      if (!completed && context.mounted) await celebrateHabit(context, day);
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  Future<void> _bookmark(BuildContext context) async {
    try {
      final saved = await context.read<AppState>().toggleFavorite('habit:${id.name}');
      if (context.mounted) {
        showProaToast(context,
            title: saved ? 'Guardado' : 'Quitado de guardados',
            message: saved ? 'Encuéntralo en tus hábitos guardados.' : 'Ya no aparece en tus guardados.',
            icon: LucideIcons.bookmark);
      }
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final h = habitById(id);
    final day = date ?? s.today;
    final d = s.dayOf(day, id);
    final future = day.isAfter(s.today);
    final pad = MediaQuery.paddingOf(context);
    final heroH = 220.0 + pad.top * 0.4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.only(bottom: pad.bottom + 90),
            children: [
              SizedBox(
                height: heroH + 46,
                child: Stack(children: [
                  SizedBox(
                    height: heroH,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Radii.header)),
                      child: ProaImage(h.image),
                    ),
                  ),
                  Positioned(
                    left: Gap.screen,
                    right: Gap.screen,
                    bottom: 0,
                    child: ProaCard(
                      padding: const EdgeInsets.all(14),
                      shadow: Shadows.elevated,
                      child: Row(children: [
                        IconBox(h.icon, color: AppColors.white, bg: h.color, size: 46, iconSize: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(h.name, style: AppText.outfit(20, FontWeight.w700, height: 1.15)),
                            const SizedBox(height: 2),
                            Text(h.goal, style: AppText.inter(12, FontWeight.w400, color: AppColors.textSecondary)),
                          ]),
                        ),
                        d.completed ? Pill.done() : Pill.pending(),
                      ]),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.screen, 14, Gap.screen, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _Stat(value: _metric(h, d.progress), label: h.unitLabel, color: h.id == HabitId.sleep ? h.color : (h.id == HabitId.meals ? AppColors.orange : h.color)),
                    const SizedBox(width: 8),
                    _Stat(value: '${s.habitStreak(id)}', label: 'Días seguidos', color: AppColors.orange),
                    const SizedBox(width: 8),
                    _Stat(value: '${s.habitWeekPct(id)}%', label: 'Esta semana', color: AppColors.green),
                  ]),
                  const SizedBox(height: 12),
                  ProaCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(h.trackerTitle, style: AppText.inter(13.5, FontWeight.w700))),
                        Text(_trackerValue(h, d.progress),
                            style: AppText.inter(12, FontWeight.w700, color: h.id == HabitId.meals ? AppColors.orange : h.color)),
                      ]),
                      const SizedBox(height: 12),
                      _Tracker(
                        habit: h,
                        value: d.progress,
                        enabled: !future,
                        onChanged: (v) => _setProgress(context, day, h, v),
                      ),
                      const SizedBox(height: 8),
                      Text(future ? 'Podrás registrar cuando llegue el día.' : 'Toca una casilla para registrar tu avance.',
                          style: AppText.caption.copyWith(color: AppColors.textMuted)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text(h.description, style: AppText.paragraph.copyWith(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text('Consejos', style: AppText.subtitle),
                  const SizedBox(height: 10),
                  for (final (i, t) in h.tips.indexed) ...[
                    _Tip(index: i + 1, text: t),
                    const SizedBox(height: 8),
                  ],
                ]),
              ),
            ],
          ),
          Positioned(
            top: pad.top + 8,
            left: Gap.screen,
            right: Gap.screen,
            child: Row(children: [
              const BackCircle(),
              const Spacer(),
              CircleIconButton(LucideIcons.bookmark,
                  size: 36,
                  semantic: 'Guardar',
                  color: s.isFavorite('habit:${id.name}') ? AppColors.green : AppColors.text,
                  filled: s.isFavorite('habit:${id.name}'),
                  onTap: () => _bookmark(context)),
            ]),
          ),
          Positioned(
            left: Gap.screen,
            right: Gap.screen,
            bottom: pad.bottom + 12,
            child: future
                ? const SizedBox.shrink()
                : d.completed
                    ? ProaButton('Completado hoy', kind: ProaButtonKind.soft, leading: LucideIcons.check, onPressed: () => _toggle(context, day, true))
                    : ProaButton('Marcar como completado', leading: LucideIcons.check, onPressed: () => _toggle(context, day, false)),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: ProaCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          radius: BorderRadius.circular(16),
          child: Column(children: [
            Text(value, style: AppText.outfit(20, FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: AppText.caption),
          ]),
        ),
      );
}

class _Tracker extends StatelessWidget {
  const _Tracker({required this.habit, required this.value, required this.onChanged, required this.enabled});
  final Habit habit;
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final labels = habit.slotLabels;
    final isMeals = labels != null;
    final c = habit.color;
    return Row(children: [
      for (var i = 0; i < habit.target; i++)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == habit.target - 1 ? 0 : 6),
            child: Semantics(
              button: true,
              label: '${habit.trackerTitle} ${i + 1}',
              checked: i < value,
              child: GestureDetector(
                // Tocar la última casilla llena la vacía; tocar otra fija el valor.
                onTap: enabled ? () => onChanged(i + 1 == value ? i : i + 1) : null,
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: double.infinity,
                    height: isMeals ? 46 : 38,
                    decoration: BoxDecoration(
                      gradient: i < value
                          ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(c, Colors.white, 0.12)!, c])
                          : null,
                      color: i < value ? null : habit.softColor.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: i < value ? Colors.transparent : habit.softColor),
                    ),
                    child: Icon(habit.trackerIcon, size: isMeals ? 18 : 16, color: i < value ? AppColors.white : c.withValues(alpha: 0.45)),
                  ),
                  if (isMeals) ...[
                    const SizedBox(height: 6),
                    Text(labels[i], style: AppText.inter(10.5, FontWeight.w600, color: i < value ? AppColors.orange : AppColors.textMuted)),
                  ],
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(7)),
            child: Text('$index', style: AppText.inter(11.5, FontWeight.w700, color: AppColors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.inter(13, FontWeight.w400, color: const Color(0xFF374151), height: 1.45))),
        ]),
      );
}
