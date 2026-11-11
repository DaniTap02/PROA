import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/emotions_catalog.dart';
import '../../models/craving.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/emotion_card.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';

/// «¿Tienes un antojo?»: elegir emoción (selección única), probar
/// recomendaciones y registrar el momento en el historial.
class CravingsScreen extends StatefulWidget {
  const CravingsScreen({super.key});

  @override
  State<CravingsScreen> createState() => _CravingsScreenState();
}

class _CravingsScreenState extends State<CravingsScreen> {
  EmotionId? _emotion;
  final Set<int> _tried = {};
  bool _saving = false;

  Future<void> _register() async {
    if (_emotion == null) return;
    setState(() => _saving = true);
    final s = context.read<AppState>();
    try {
      await s.addCraving(CravingEntry(emotion: _emotion!, at: DateTime.now(), strategies: _tried.toList()..sort()));
      if (!mounted) return;
      showProaToast(context, title: 'Momento registrado', message: '¡Bien hecho! Reconocer tus emociones es el primer paso.');
      setState(() {
        _emotion = null;
        _tried.clear();
      });
    } catch (_) {
      if (mounted) showErrorToast(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pad = MediaQuery.paddingOf(context);
    final todayCount = s.cravingsOn(s.today);
    final emotion = _emotion == null ? null : emotionById(_emotion!);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.3],
            colors: [AppColors.warmSofter, AppColors.background],
          ),
        ),
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 8, Gap.screen, pad.bottom + (emotion == null ? 20 : 90)),
            children: [
              Row(children: [
                const BackCircle(),
                const Spacer(),
                Pill('$todayCount hoy', icon: LucideIcons.clock, fg: AppColors.orange, bg: AppColors.warmBg, fontSize: 11.5),
              ]),
              const SizedBox(height: 16),
              Text('¿Tienes un antojo?', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Identifica lo que sientes. No hay respuestas malas.', style: AppText.inter(13.5, FontWeight.w400, color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              Text('¿Qué estás sintiendo ahora mismo?', style: AppText.inter(13, FontWeight.w600)),
              const SizedBox(height: 10),
              GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.08,
                children: [
                  for (final e in emotionsCatalog)
                    EmotionCard(
                      emotion: e,
                      selected: _emotion == e.id,
                      onTap: () => setState(() {
                        // Selección única (mejora del hallazgo #2 de la evaluación heurística).
                        _emotion = _emotion == e.id ? null : e.id;
                        _tried.clear();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                alignment: Alignment.topCenter,
                child: emotion == null
                    ? const SizedBox(width: double.infinity)
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: Radii.rCard,
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                            child: Row(children: [
                              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.orange),
                              const SizedBox(width: 6),
                              Text('Prueba esto antes de ceder', style: AppText.outfit(15, FontWeight.w600, color: const Color(0xFF9A3412))),
                            ]),
                          ),
                          for (final (i, st) in emotion.strategies.indexed) ...[
                            _StrategyRow(
                              icon: st.$1,
                              text: st.$2,
                              checked: _tried.contains(i),
                              onTap: () => setState(() => _tried.contains(i) ? _tried.remove(i) : _tried.add(i)),
                            ),
                            if (i < emotion.strategies.length - 1) const SizedBox(height: 8),
                          ],
                        ]),
                      ),
              ),
              const SizedBox(height: 22),
              SectionHeader('Tu historial', action: s.cravings.isEmpty ? null : '${s.cravings.length} registros', actionColor: AppColors.textSecondary),
              const SizedBox(height: 10),
              if (s.cravings.isEmpty)
                ProaCard(
                  child: Row(children: [
                    const IconBox(LucideIcons.heart, color: AppColors.orange, bg: AppColors.warmBg),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Aún no tienes momentos registrados. Cuando sientas un antojo, vuelve aquí: sin juicios.',
                          style: AppText.inter(12.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.45)),
                    ),
                  ]),
                )
              else
                CravingHistory(entries: s.cravings.take(10).toList()),
            ],
          ),
          if (emotion != null)
            Positioned(
              left: Gap.screen,
              right: Gap.screen,
              bottom: pad.bottom + 12,
              child: ProaButton('Registrar momento', kind: ProaButtonKind.accent, leading: LucideIcons.check, loading: _saving, onPressed: _register),
            ),
        ]),
      ),
    );
  }
}

class _StrategyRow extends StatelessWidget {
  const _StrategyRow({required this.icon, required this.text, required this.checked, required this.onTap});
  final IconData icon;
  final String text;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        checked: checked,
        button: true,
        child: ProaCard(
          onTap: onTap,
          radius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(children: [
            IconBox(icon, color: const Color(0xFFD97706), bg: const Color(0xFFFEF3C7), size: 34, iconSize: 16, radius: 10),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.inter(13, FontWeight.w500, height: 1.35))),
            const SizedBox(width: 8),
            RoundCheck(value: checked),
          ]),
        ),
      );
}

/// Lista del historial de antojos (también se usa en Progreso).
class CravingHistory extends StatelessWidget {
  const CravingHistory({super.key, required this.entries});
  final List<CravingEntry> entries;

  @override
  Widget build(BuildContext context) => ProaCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (final (i, c) in entries.indexed) ...[
            if (i > 0) const RowDivider(),
            Builder(builder: (_) {
              final e = emotionById(c.emotion);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: e.softColor, shape: BoxShape.circle),
                    child: Icon(e.icon, size: 16, color: e.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.label, style: AppText.inter(13.5, FontWeight.w600)),
                      Text(
                        c.strategies.isEmpty
                            ? 'Registrado'
                            : 'Probaste ${c.strategies.length} ${c.strategies.length == 1 ? 'estrategia' : 'estrategias'}',
                        style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted),
                      ),
                    ]),
                  ),
                  Text('${Dates.relative(c.at)} · ${Dates.time(c.at)}', style: AppText.caption.copyWith(color: AppColors.textMuted)),
                ]),
              );
            }),
          ],
        ]),
      );
}
