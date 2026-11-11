import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
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
                  _WeekProgress(habit: h, state: s),
                  const SizedBox(height: 12),
                  _Advice(habit: h),
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

/// «Progreso semanal N/7 días»: un círculo por día (Figma › Detalle de hábito).
class _WeekProgress extends StatelessWidget {
  const _WeekProgress({required this.habit, required this.state});
  final Habit habit;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final days = Dates.weekOf(s.today);
    final done = days.where((d) => !d.isAfter(s.today) && s.dayOf(d, habit.id).completed).length;
    final c = habit.color;
    return ProaCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Progreso semanal', style: AppText.inter(13.5, FontWeight.w700))),
          Pill('$done/7 días', fg: c, bg: habit.softColor),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (final d in days)
            Expanded(
              child: Column(children: [
                Builder(builder: (_) {
                  final isToday = d == s.today;
                  final ok = !d.isAfter(s.today) && s.dayOf(d, habit.id).completed;
                  if (ok) {
                    return Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.check, size: 15, color: AppColors.white),
                    );
                  }
                  if (isToday) {
                    return SizedBox.square(
                      dimension: 30,
                      child: CustomPaint(
                        painter: _DashedCircle(c),
                        child: Center(child: Text('Hoy', style: AppText.inter(8.5, FontWeight.w700, color: c))),
                      ),
                    );
                  }
                  if (d.isAfter(s.today)) {
                    return Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 1.5)),
                    );
                  }
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Icon(LucideIcons.x, size: 13, color: Color(0xFFF87171)),
                  );
                }),
                const SizedBox(height: 5),
                Text(Dates.weekdaysShort[d.weekday - 1],
                    style: AppText.inter(10, d == s.today ? FontWeight.w700 : FontWeight.w500,
                        color: d == s.today ? c : AppColors.textMuted)),
              ]),
            ),
        ]),
      ]),
    );
  }
}

class _DashedCircle extends CustomPainter {
  _DashedCircle(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = size.width / 2 - 1;
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: size.center(Offset.zero), radius: r), a, math.pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashedCircle o) => o.color != color;
}

/// Tarjeta «CONSEJO PRÁCTICO» con el color del hábito.
class _Advice extends StatelessWidget {
  const _Advice({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: habit.softColor.withValues(alpha: 0.45),
          borderRadius: Radii.rCard,
          border: Border.all(color: habit.softColor),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Icon(LucideIcons.lightbulb, size: 16, color: habit.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CONSEJO PRÁCTICO', style: AppText.overline.copyWith(color: habit.color)),
              const SizedBox(height: 4),
              Text(habit.advice, style: AppText.inter(13.5, FontWeight.w500, height: 1.45)),
            ]),
          ),
        ]),
      );
}
