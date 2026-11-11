import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/guides_catalog.dart';
import '../../models/guide.dart';
import '../../navigation/main_shell.dart';
import '../../state/app_state.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';
import '../../widgets/guide_card.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';

/// Detalle de guía: portada, introducción, infografía y consejos numerados.
class GuideDetailScreen extends StatelessWidget {
  const GuideDetailScreen({super.key, required this.guide});
  final Guide guide;

  Future<void> _save(BuildContext context) async {
    try {
      final saved = await context.read<AppState>().toggleFavorite('guide:${guide.id}');
      if (context.mounted) {
        showProaToast(context,
            title: saved ? 'Guardado' : 'Quitado de guardados',
            message: saved ? 'Encuentra esta guía en Alimentación › Solo guardadas.' : 'La guía ya no está en tus guardados.',
            icon: LucideIcons.bookmark);
      }
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  void _goToPlan(BuildContext context) {
    final shell = MainShell.of(context);
    Navigator.of(context).popUntil((r) => r.isFirst);
    shell.select(AppTab.plan);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final saved = s.isFavorite('guide:${guide.id}');
    final pad = MediaQuery.paddingOf(context);
    final more = guidesCatalog.where((g) => g.id != guide.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.only(bottom: pad.bottom + 90),
            children: [
              SizedBox(
                height: 250 + pad.top * 0.5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Radii.header)),
                  child: Stack(fit: StackFit.expand, children: [
                    ProaImage(guide.image),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.3, 1],
                          colors: [Color(0x00000000), Color(0xCC111827)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: Gap.screen,
                      right: Gap.screen,
                      bottom: 18,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Pill('Guía', icon: LucideIcons.bookOpen, fg: AppColors.green, bg: AppColors.white),
                          const SizedBox(width: 6),
                          Pill('${guide.minutes} min', icon: LucideIcons.clock, fg: AppColors.text, bg: AppColors.white),
                        ]),
                        const SizedBox(height: 8),
                        Text(guide.title, style: AppText.outfit(27, FontWeight.w700, color: AppColors.white, height: 1.12)),
                      ]),
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(guide.intro, style: AppText.paragraph.copyWith(fontSize: 14)),
                  if (guide.infographic != null) ...[
                    const SizedBox(height: 16),
                    _Infographic(guide.infographic!),
                  ],
                  const SizedBox(height: 20),
                  Text('¿Qué puedes hacer?', style: AppText.subtitle),
                  const SizedBox(height: 10),
                  for (final (i, t) in guide.tips.indexed) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(7)),
                          child: Text('${i + 1}', style: AppText.inter(12, FontWeight.w700, color: AppColors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(t, style: AppText.inter(13.5, FontWeight.w400, color: const Color(0xFF374151), height: 1.45))),
                      ]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (guide.note != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.greenSofter,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.greenSoft),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(LucideIcons.messageCircle, size: 18, color: AppColors.green),
                        const SizedBox(width: 10),
                        Expanded(child: Text(guide.note!, style: AppText.inter(13.5, FontWeight.w500, height: 1.45))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text('Más guías', style: AppText.subtitle),
                  const SizedBox(height: 10),
                ]),
              ),
              SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
                  itemCount: more.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 150,
                    child: GuideCard(
                      guide: more[i],
                      saved: s.isFavorite('guide:${more[i].id}'),
                      onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: more[i]))),
                    ),
                  ),
                ),
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
                  semantic: saved ? 'Quitar de guardados' : 'Guardar',
                  color: saved ? AppColors.green : AppColors.text,
                  filled: saved,
                  onTap: () => _save(context)),
            ]),
          ),
          Positioned(
            left: Gap.screen,
            right: Gap.screen,
            bottom: pad.bottom + 12,
            child: ProaButton('Ir a mi plan diario', arrow: true, onPressed: () => _goToPlan(context)),
          ),
        ]),
      ),
    );
  }
}

class _Infographic extends StatelessWidget {
  const _Infographic(this.info);
  final GuideInfographic info;

  @override
  Widget build(BuildContext context) => ProaCard(
        child: switch (info) {
          SegmentInfographic(:final title, :final segments) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.inter(14, FontWeight.w700)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: Radii.rPill,
                child: SizedBox(
                  height: 12,
                  child: Row(children: [
                    for (final (i, seg) in segments.indexed)
                      Expanded(
                        flex: seg.$2,
                        child: Container(
                          margin: EdgeInsets.only(right: i == segments.length - 1 ? 0 : 3),
                          color: Color(seg.$3),
                        ),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 14, runSpacing: 6, children: [
                for (final seg in segments)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(seg.$3), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${seg.$1} ${seg.$2}%', style: AppText.inter(11.5, FontWeight.w500, color: AppColors.textSecondary)),
                  ]),
              ]),
            ]),
          TilesInfographic(:final title, :final tiles) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.inter(14, FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                for (final (i, t) in tiles.indexed)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == tiles.length - 1 ? 0 : 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(color: Color(t.$3).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: Icon(LucideIcons.hand, size: 15, color: Color(t.$3)),
                        ),
                        const SizedBox(height: 6),
                        Text(t.$1, textAlign: TextAlign.center, style: AppText.inter(12.5, FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(t.$2, textAlign: TextAlign.center, maxLines: 2, style: AppText.inter(9.5, FontWeight.w500, color: AppColors.textSecondary)),
                      ]),
                    ),
                  ),
              ]),
            ]),
        },
      );
}
