import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../cravings/cravings_screen.dart';
import 'habit_actions.dart';
import 'plan_screen.dart';

/// Resumen calculado para el periodo elegido (semana, mes o año).
class _Summary {
  _Summary({
    required this.overline,
    required this.activeDays,
    required this.daysInPeriod,
    required this.activeDelta,
    required this.completed,
    required this.completedDeltaPct,
    required this.bars,
    required this.pct,
    required this.evolution,
    required this.evolutionLabel,
    required this.cravings,
  });

  final String overline;
  final int activeDays, daysInPeriod, completed, pct, cravings;
  final int? activeDelta, completedDeltaPct;
  final List<BarDatum> bars;
  final List<(String, int)> evolution;
  final String evolutionLabel;
}

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

_Summary _summarize(AppState s, int period) {
  final t = s.today;
  int activeIn(DateTime a, DateTime b) {
    var n = 0;
    for (var d = a; !d.isAfter(b) && !d.isAfter(t); d = _d(d.year, d.month, d.day + 1)) {
      if (s.activeOn(d)) n++;
    }
    return n;
  }

  int doneIn(DateTime a, DateTime b) {
    var n = 0;
    for (var d = a; !d.isAfter(b) && !d.isAfter(t); d = _d(d.year, d.month, d.day + 1)) {
      n += s.completedOn(d);
    }
    return n;
  }

  int? deltaPct(int now, int before) => before == 0 ? null : ((now - before) * 100 / before).round();
  int cravingsIn(DateTime a) => s.cravings.where((c) => !c.at.isBefore(a)).length;

  switch (period) {
    case 0:
      final ws = Dates.weekStart(t);
      final prev = ws.subtract(const Duration(days: 7));
      final evo = s.weeklyEvolution(4);
      return _Summary(
        overline: 'Esta semana',
        activeDays: activeIn(ws, t),
        daysInPeriod: 7,
        activeDelta: activeIn(ws, t) - activeIn(prev, prev.add(Duration(days: t.weekday - 1))),
        completed: doneIn(ws, t),
        completedDeltaPct: deltaPct(doneIn(ws, t), doneIn(prev, prev.add(Duration(days: t.weekday - 1)))),
        bars: [
          for (final d in Dates.weekOf(t))
            BarDatum(d == t ? 'Hoy' : Dates.weekdaysAbbr[d.weekday - 1], d.isAfter(t) ? null : s.ratioOn(d), highlight: d == t),
        ],
        pct: s.pctBetween(ws, t),
        evolution: [for (var i = 0; i < evo.length; i++) ('Sem ${i + 1}', evo[i])],
        evolutionLabel: 'Últimas 4 semanas',
        cravings: cravingsIn(ws),
      );
    case 1:
      final ms = _d(t.year, t.month, 1);
      final me = _d(t.year, t.month + 1, 0);
      final prevS = _d(t.year, t.month - 1, 1);
      final prevE = _d(t.year, t.month, 0);
      final weeks = <BarDatum>[];
      var w = 1;
      for (var a = ms; !a.isAfter(me); a = _d(a.year, a.month, a.day + 7), w++) {
        final b = _d(a.year, a.month, a.day + 6).isAfter(me) ? me : _d(a.year, a.month, a.day + 6);
        weeks.add(BarDatum('S$w', a.isAfter(t) ? null : s.pctBetween(a, b) / 100, highlight: !t.isBefore(a) && !t.isAfter(b)));
      }
      return _Summary(
        overline: Dates.monthYear(t),
        activeDays: activeIn(ms, t),
        daysInPeriod: me.day,
        activeDelta: activeIn(ms, t) - activeIn(prevS, _d(prevS.year, prevS.month, t.day > prevE.day ? prevE.day : t.day)),
        completed: doneIn(ms, t),
        completedDeltaPct: deltaPct(doneIn(ms, t), doneIn(prevS, _d(prevS.year, prevS.month, t.day > prevE.day ? prevE.day : t.day))),
        bars: weeks,
        pct: s.pctBetween(ms, t),
        evolution: [
          for (var i = 3; i >= 0; i--)
            (Dates.monthsAbbr[_d(t.year, t.month - i, 1).month - 1], s.pctBetween(_d(t.year, t.month - i, 1), _d(t.year, t.month - i + 1, 0))),
        ],
        evolutionLabel: 'Últimos 4 meses',
        cravings: cravingsIn(ms),
      );
    default:
      final ys = _d(t.year, 1, 1);
      final ye = _d(t.year, 12, 31);
      return _Summary(
        overline: 'Año ${t.year}',
        activeDays: activeIn(ys, t),
        daysInPeriod: ye.difference(ys).inDays + 1,
        activeDelta: null,
        completed: doneIn(ys, t),
        completedDeltaPct: deltaPct(doneIn(ys, t), doneIn(_d(t.year - 1, 1, 1), _d(t.year - 1, t.month, t.day))),
        bars: [
          for (var m = 1; m <= 12; m++)
            BarDatum(Dates.monthsAbbr[m - 1][0].toUpperCase(), _d(t.year, m, 1).isAfter(t) ? null : s.pctBetween(_d(t.year, m, 1), _d(t.year, m + 1, 0)) / 100,
                highlight: m == t.month),
        ],
        pct: s.pctBetween(ys, t),
        evolution: [
          for (var q = 0; q < 4; q++) ('T${q + 1}', _d(t.year, q * 3 + 1, 1).isAfter(t) ? 0 : s.pctBetween(_d(t.year, q * 3 + 1, 1), _d(t.year, q * 3 + 4, 0))),
        ],
        evolutionLabel: 'Trimestres de ${t.year}',
        cravings: cravingsIn(ys),
      );
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final sum = _summarize(s, _period);
    final pad = MediaQuery.paddingOf(context);
    final lastDays = [for (var i = 0; i < 7; i++) s.today.subtract(Duration(days: i))]
        .where((d) => !d.isBefore(s.firstDay))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 12, Gap.screen, pad.bottom + 20),
        children: [
          ScreenTitle(
            overline: sum.overline,
            title: 'Mi progreso',
            trailing: CircleIconButton(LucideIcons.calendar,
                semantic: 'Ver plan por fecha', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen()))),
          ),
          const SizedBox(height: 14),
          SegmentedTabs(labels: const ['Semana', 'Mes', 'Año'], index: _period, onChanged: (i) => setState(() => _period = i)),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: Radii.rCard, boxShadow: Shadows.colored(AppColors.petrol)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      IconBox(LucideIcons.flame, color: AppColors.white, bg: AppColors.white.withValues(alpha: 0.18), size: 30, iconSize: 15, radius: 9),
                      const Spacer(),
                      if (sum.activeDelta != null && sum.activeDelta != 0)
                        Pill('${sum.activeDelta! > 0 ? '+' : ''}${sum.activeDelta}', fg: AppColors.white, bg: AppColors.white.withValues(alpha: 0.2)),
                    ]),
                    const SizedBox(height: 18),
                    Text('${sum.activeDays} ${sum.activeDays == 1 ? 'día' : 'días'}', style: AppText.outfit(24, FontWeight.w700, color: AppColors.white)),
                    Text('activos de ${sum.daysInPeriod}', style: AppText.inter(11.5, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85))),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ProaCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const IconBox(LucideIcons.check, color: AppColors.green, bg: AppColors.greenSoft, size: 30, iconSize: 15, radius: 9),
                      const Spacer(),
                      if (sum.completedDeltaPct != null)
                        Pill('${sum.completedDeltaPct! >= 0 ? '+' : ''}${sum.completedDeltaPct}%',
                            icon: sum.completedDeltaPct! >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                            fg: sum.completedDeltaPct! >= 0 ? AppColors.green : AppColors.orange,
                            bg: sum.completedDeltaPct! >= 0 ? AppColors.greenSoft : AppColors.warmBg),
                    ]),
                    const SizedBox(height: 18),
                    Text('${sum.completed}', style: AppText.outfit(24, FontWeight.w700)),
                    Text('hábitos completados', style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textSecondary)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          ProaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(_period == 0 ? 'Actividad semanal' : (_period == 1 ? 'Actividad mensual' : 'Actividad anual'), style: AppText.inter(14, FontWeight.w700))),
                Pill('${sum.pct}% cumplido', fg: AppColors.greenDark, bg: AppColors.greenSoft),
              ]),
              const SizedBox(height: 14),
              SizedBox(height: 130, child: BarChart(data: sum.bars)),
            ]),
          ),
          const SizedBox(height: 12),
          ProaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Evolución del cumplimiento', style: AppText.inter(14, FontWeight.w700)),
                    Text(sum.evolutionLabel, style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
                  ]),
                ),
                Text('${sum.evolution.last.$2}%', style: AppText.outfit(24, FontWeight.w700, color: AppColors.green)),
              ]),
              const SizedBox(height: 14),
              SizedBox(height: 110, child: LineChart(points: sum.evolution)),
            ]),
          ),
          const SizedBox(height: 22),
          SectionHeader('Registros de ansiedad',
              action: 'Registrar',
              onAction: () => openCravings(context)),
          const SizedBox(height: 4),
          Text('${sum.cravings} ${sum.cravings == 1 ? 'momento registrado' : 'momentos registrados'} en este periodo',
              style: AppText.inter(12, FontWeight.w400, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          if (s.cravings.isEmpty)
            CravingBanner(onTap: () => openCravings(context))
          else
            CravingHistory(entries: s.cravings.take(3).toList()),
          const SizedBox(height: 22),
          const SectionHeader('Historial de hábitos'),
          const SizedBox(height: 10),
          ProaCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final (i, d) in lastDays.indexed) ...[
                if (i > 0) const RowDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    SizedBox(
                      width: 92,
                      child: Text(d == s.today ? 'Hoy' : Dates.chip(d), style: AppText.inter(12.5, FontWeight.w600)),
                    ),
                    Expanded(child: ProgressBar(value: s.ratioOn(d), height: 6)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 34,
                      child: Text('${s.completedOn(d)}/${s.plan.length}',
                          textAlign: TextAlign.right, style: AppText.inter(12, FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}
