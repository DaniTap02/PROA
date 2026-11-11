import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../models/risk_test.dart';
import '../../services/test_scoring.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';

const areaIcons = {
  TestArea.actividad: (LucideIcons.activity, AppColors.green, AppColors.greenSoft),
  TestArea.alimentacion: (LucideIcons.carrot, AppColors.lime, AppColors.limeSoft),
  TestArea.sueno: (LucideIcons.moon, AppColors.violet, AppColors.violetSoft),
  TestArea.estres: (LucideIcons.zap, AppColors.purple, AppColors.purpleSoft),
};

/// «TU RESULTADO»: puntaje circular, clasificación, áreas y recomendaciones.
class TestResultScreen extends StatefulWidget {
  const TestResultScreen({super.key, required this.result, this.readOnly = false});
  final TestResult result;

  /// true cuando se consulta desde el perfil (sin crear plan).
  final bool readOnly;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  bool _saving = false;

  Future<void> _createPlan() async {
    setState(() => _saving = true);
    try {
      await context.read<AppState>().logIn();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (_) {
      if (mounted) {
        showErrorToast(context);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const scoring = TestScoring();
    final r = widget.result;
    final band = scoring.info(r.score);
    final weakest = scoring.weakest(r).take(2).toList();
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.42],
            colors: [AppColors.infoBg, AppColors.background],
          ),
        ),
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 12, Gap.screen, 20),
              child: Column(children: [
                if (widget.readOnly) const Align(alignment: Alignment.centerLeft, child: BackCircle()),
                Text('TU RESULTADO', style: AppText.overline.copyWith(color: AppColors.turquoise)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: Shadows.colored(AppColors.turquoise)),
                  child: ProgressRing(
                    value: r.score / 100,
                    size: 128,
                    stroke: 11,
                    track: AppColors.white,
                    gradient: const SweepGradient(colors: [AppColors.turquoiseLight, AppColors.turquoise, AppColors.petrol, AppColors.turquoiseLight]),
                    child: Container(
                      width: 102,
                      height: 102,
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${r.score}', style: AppText.outfit(38, FontWeight.w800, height: 1)),
                        Text('de 100', style: AppText.caption),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(band.title, textAlign: TextAlign.center, style: AppText.outfit(26, FontWeight.w700)),
                const SizedBox(height: 6),
                Text(band.message,
                    textAlign: TextAlign.center,
                    style: AppText.inter(13.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 20),
                ProaCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tu perfil por áreas', style: AppText.inter(14, FontWeight.w700)),
                    const SizedBox(height: 12),
                    for (final a in TestArea.values)
                      if (r.areaScores[a] case final int v) ...[
                        Row(children: [
                          Expanded(child: Text(a.label, style: AppText.inter(12, FontWeight.w500, color: const Color(0xFF374151)))),
                          Text('$v%', style: AppText.inter(12, FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        ProgressBar(value: v / 100, height: 5, color: scoring.areaColor(v)),
                        const SizedBox(height: 12),
                      ],
                  ]),
                ),
                const SizedBox(height: 12),
                ProaCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const IconBox(LucideIcons.target, color: AppColors.turquoise, bg: AppColors.infoBg, size: 28, iconSize: 15, radius: 8),
                      const SizedBox(width: 10),
                      Text('Empieza por estos hábitos', style: AppText.inter(14, FontWeight.w700)),
                    ]),
                    for (final a in weakest) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        IconBox(areaIcons[a]!.$1, color: areaIcons[a]!.$2, bg: areaIcons[a]!.$3, size: 34, iconSize: 17, radius: 10),
                        const SizedBox(width: 12),
                        Expanded(child: Text(TestScoring.recommendation(a), style: AppText.inter(13, FontWeight.w400, color: const Color(0xFF374151), height: 1.4))),
                      ]),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(LucideIcons.info, size: 15, color: AppColors.turquoise),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Este test es una herramienta educativa de orientación. No es un diagnóstico y no reemplaza una valoración médica.',
                        style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.45),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          if (!widget.readOnly)
            Padding(
              padding: EdgeInsets.fromLTRB(Gap.screen, 6, Gap.screen, pad.bottom + 12),
              child: ProaButton('Crear mi plan', kind: ProaButtonKind.secondary, arrow: true, loading: _saving, onPressed: _createPlan),
            ),
        ]),
      ),
    );
  }
}
