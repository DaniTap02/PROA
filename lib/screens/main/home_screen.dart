import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/guides_catalog.dart';
import '../../models/habit.dart';
import '../../navigation/main_shell.dart';
import '../../state/app_state.dart';
import '../../widgets/avatar.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/guide_card.dart';
import '../../widgets/habit_row.dart';
import '../../widgets/popups.dart';
import '../guides/guide_detail_screen.dart';
import '../habits/habit_detail_screen.dart';
import 'habit_actions.dart';

/// Abre el panel de notificaciones y navega a la pantalla relacionada.
Future<void> openNotifications(BuildContext context) async {
  final s = context.read<AppState>();
  final shell = MainShell.of(context);
  final kind = await showNotificationsSheet(context, s);
  switch (kind) {
    case 'water':
      shell.openIn(AppTab.plan, const HabitDetailScreen(id: HabitId.water));
    case 'sleep':
      shell.openIn(AppTab.plan, const HabitDetailScreen(id: HabitId.sleep));
    case 'guide':
      shell.openIn(AppTab.alimentacion, GuideDetailScreen(guide: guideById('hidratacion')));
    case 'streak':
      shell.select(AppTab.progreso);
  }
}

String dayMessage(int done, int total) {
  if (total == 0) return 'Activa tus hábitos en tu perfil.';
  if (done == 0) return 'Empieza con un hábito pequeño.';
  if (done >= total) return '¡Completaste tu día! Excelente.';
  final left = total - done;
  return '¡Vas muy bien! Te ${left == 1 ? 'falta' : 'faltan'} $left.';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final today = s.today;
    final done = s.completedOn(today);
    final total = s.plan.length;
    final pad = MediaQuery.paddingOf(context);
    final shell = MainShell.of(context);
    final streak = s.streak;
    final tip = _tips[today.difference(DateTime(2026)).inDays.abs() % _tips.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 10, Gap.screen, pad.bottom + 20),
        children: [
          Row(children: [
            UserAvatar(profile: s.profile, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(Dates.greeting(s.now), style: AppText.inter(13, FontWeight.w400, color: AppColors.textSecondary)),
                Text(s.profile?.firstName ?? '', style: AppText.outfit(22, FontWeight.w700, height: 1.15)),
              ]),
            ),
            CircleIconButton(LucideIcons.bell,
                size: 44, semantic: 'Notificaciones', badge: s.hasUnreadNotifications, onTap: () => openNotifications(context)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Pill(streak == 1 ? '1 día seguido' : '$streak días seguidos',
                icon: LucideIcons.flame, fg: AppColors.orange, bg: AppColors.warmBg, fontSize: 11.5,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            const SizedBox(width: 8),
            Pill(Dates.chip(today),
                icon: LucideIcons.calendar, fg: const Color(0xFF374151), bg: AppColors.white, border: AppColors.border, fontSize: 11.5,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
          ]),
          const SizedBox(height: 18),
          _DayHeroCard(done: done, total: total, onPlan: () => shell.select(AppTab.plan)),
          const SizedBox(height: 22),
          SectionHeader('Hábitos de hoy', action: 'Ver todo', onAction: () => shell.select(AppTab.plan)),
          const SizedBox(height: 10),
          HabitList(children: [
            for (final h in s.plan)
              HabitRow(
                habit: h,
                done: s.dayOf(today, h.id).completed,
                onToggle: () => toggleHabitFromList(context, today, h.id),
                onOpen: () => openHabit(context, h.id),
              ),
          ]),
          const SizedBox(height: 22),
          SectionHeader('Guías para ti', action: 'Ver todas', onAction: () => shell.select(AppTab.alimentacion)),
          const SizedBox(height: 10),
          SizedBox(
            height: 194,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _homeGuides.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 218,
                child: GuideCard(
                  guide: _homeGuides[i],
                  home: true,
                  imageHeight: 124,
                  saved: s.isFavorite('guide:${_homeGuides[i].id}'),
                  onTap: () => openGuide(context, _homeGuides[i]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _WeekCard(state: s),
          const SizedBox(height: 12),
          ProaCard(
            color: AppColors.warmSofter,
            border: Border.all(color: const Color(0xFFFED7AA)),
            shadow: null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const IconBox(LucideIcons.lightbulb, color: AppColors.amber, bg: AppColors.warmBg, size: 38, iconSize: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CONSEJO DE HOY', style: AppText.overline.copyWith(color: AppColors.orange)),
                  const SizedBox(height: 4),
                  Text(tip, style: AppText.inter(13, FontWeight.w400, color: const Color(0xFF374151), height: 1.45)),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Orden de «Guías para ti» en Inicio (Figma: Plato equilibrado, Frutas y verduras…).
final _homeGuides = [for (final id in ['plato', 'frutas', 'hidratacion', 'porciones', 'proteinas', 'ultraprocesados']) guideById(id)];

const _tips = [
  'Sirve tu comida en un plato más pequeño: te ayuda a comer porciones adecuadas sin sentir que te privas.',
  'Antes de picar algo, toma un vaso de agua y espera unos minutos: a veces la sed se confunde con hambre.',
  'Caminar 10 minutos después del almuerzo ayuda a controlar el azúcar en la sangre.',
  'Cambia la gaseosa del almuerzo por agua con limón o una aromática fría sin azúcar.',
  'Prepara la fruta picada desde la noche anterior para tenerla lista en la mañana.',
  'Apaga las pantallas 30 minutos antes de dormir: descansarás mejor y tendrás menos antojos.',
  'Un paso pequeño cada día cuenta más que un cambio grande que no puedes sostener.',
];

/// Tarjeta héroe «Tu día»: degradado verde + anillo de progreso.
class _DayHeroCard extends StatelessWidget {
  const _DayHeroCard({required this.done, required this.total, required this.onPlan});
  final int done, total;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Shadows.colored(AppColors.petrol),
      ),
      child: Stack(children: [
        Positioned(
          right: -40,
          top: -50,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withValues(alpha: 0.07)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TU DÍA', style: AppText.overline.copyWith(color: AppColors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 6),
                Text('$done de $total hábitos\ncompletados', style: AppText.outfit(22, FontWeight.w700, color: AppColors.white, height: 1.18)),
                const SizedBox(height: 6),
                Text(dayMessage(done, total),
                    style: AppText.inter(12.5, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 14),
                Material(
                  color: AppColors.white,
                  borderRadius: Radii.rPill,
                  child: InkWell(
                    borderRadius: Radii.rPill,
                    onTap: onPlan,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Ver mi plan', style: AppText.outfit(13.5, FontWeight.w600, color: AppColors.greenDark)),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.arrowRight, size: 14, color: AppColors.greenDark),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 10),
            ProgressRing(
              value: ratio,
              size: 92,
              stroke: 9,
              color: AppColors.white,
              track: AppColors.white.withValues(alpha: 0.22),
              child: Text('${(ratio * 100).round()}%', style: AppText.outfit(21, FontWeight.w700, color: AppColors.white)),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// «Tu semana»: días activos y barras de cumplimiento diario (Figma › Inicio).
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final t = s.today;
    final prevStart = Dates.weekStart(t).subtract(const Duration(days: 7));
    final prevSoFar = [for (var i = 0; i < t.weekday; i++) DateTime(prevStart.year, prevStart.month, prevStart.day + i)]
        .fold(0, (a, d) => a + s.completedOn(d));
    final now = s.weekCompletedHabits;
    final delta = prevSoFar == 0 ? null : ((now - prevSoFar) * 100 / prevSoFar).round();
    return ProaCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tu semana', style: AppText.inter(14, FontWeight.w700)),
              Text('${s.weekActiveDays} de 7 días activos', style: AppText.inter(12, FontWeight.w400, color: AppColors.textMuted)),
            ]),
          ),
          if (delta != null)
            Pill('${delta >= 0 ? '+' : ''}$delta%',
                icon: delta >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                fg: delta >= 0 ? AppColors.green : AppColors.orange,
                bg: delta >= 0 ? AppColors.greenSoft : AppColors.warmBg),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: BarChart(data: [
            for (final d in Dates.weekOf(t))
              BarDatum(Dates.weekdaysShort[d.weekday - 1], d.isAfter(t) ? null : s.ratioOn(d), highlight: d == t),
          ]),
        ),
      ]),
    );
  }
}
