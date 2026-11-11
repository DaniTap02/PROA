import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/test_catalog.dart';
import '../../models/risk_test.dart';
import '../../services/test_scoring.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/popups.dart';
import 'test_result_screen.dart';

(Color, Color) categoryColors(TestArea a, String category) => switch (category) {
      'Sueño' => (AppColors.violet, AppColors.violetSoft),
      'Rutina' => (const Color(0xFFB45309), const Color(0xFFFEF3C7)),
      'Estrés' => (AppColors.purple, AppColors.purpleSoft),
      _ => (AppColors.greenDark, AppColors.greenSoft),
    };

/// Test de hábitos: 8 preguntas, avanzar y retroceder, sin saltar preguntas.
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _answers = List<int>.filled(testQuestions.length, -1);
  int _i = 0;
  bool _busy = false;
  Timer? _advance;

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _select(int option) {
    if (_busy) return;
    setState(() => _answers[_i] = option);
    _advance?.cancel();
    _advance = Timer(const Duration(milliseconds: 280), _next);
  }

  Future<void> _next() async {
    if (_answers[_i] == -1) return;
    if (_i < testQuestions.length - 1) {
      setState(() => _i++);
      return;
    }
    final missing = _answers.indexOf(-1);
    if (missing != -1) {
      setState(() => _i = missing);
      return;
    }
    setState(() => _busy = true);
    final s = context.read<AppState>();
    final result = const TestScoring().compute(testQuestions, _answers, DateTime.now());
    try {
      await s.saveTestResult(result);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TestResultScreen(result: result)));
    } catch (_) {
      if (mounted) showErrorToast(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _back() {
    _advance?.cancel();
    if (_i == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _i--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = testQuestions[_i];
    final n = testQuestions.length;
    final pct = ((_i + 1) * 100 / n).round();
    final pad = MediaQuery.paddingOf(context);
    final (catFg, catBg) = categoryColors(q.area, q.category);

    return PopScope(
      canPop: _i == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 8, Gap.screen, pad.bottom + 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              BackCircle(onTap: _back),
              Expanded(
                child: Column(children: [
                  Text('Test de hábitos', style: AppText.outfit(15, FontWeight.w700)),
                  Text('Pregunta ${_i + 1} de $n', style: AppText.inter(11, FontWeight.w400, color: AppColors.textSecondary)),
                ]),
              ),
              SizedBox(
                width: 36,
                child: Text('$pct%', textAlign: TextAlign.right, style: AppText.inter(12, FontWeight.w700, color: AppColors.green)),
              ),
            ]),
            const SizedBox(height: 14),
            ProgressBar(
              value: (_i + 1) / n,
              height: 5,
              gradient: const LinearGradient(colors: [AppColors.green, AppColors.turquoise]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a), child: c),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_i),
                  padding: const EdgeInsets.only(top: 22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Pill(q.category, icon: q.categoryIcon, fg: catFg, bg: catBg),
                    const SizedBox(height: 12),
                    Text(q.text, style: AppText.outfit(24, FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 6),
                    Text('Elige la opción que mejor te describe.', style: AppText.secondary),
                    const SizedBox(height: 20),
                    for (var o = 0; o < q.options.length; o++) ...[
                      _OptionTile(
                        letter: String.fromCharCode(65 + o),
                        text: q.options[o].text,
                        selected: _answers[_i] == o,
                        onTap: () => _select(o),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ]),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.lock, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text('Responde con honestidad. Tus respuestas son privadas.',
                    style: AppText.caption.copyWith(color: AppColors.textMuted)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.letter, required this.text, required this.selected, required this.onTap});
  final String letter, text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.greenSofter : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.green : Colors.transparent, width: 1.6),
              boxShadow: Shadows.soft,
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.green : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(letter,
                    style: AppText.inter(12, FontWeight.w700, color: selected ? AppColors.white : AppColors.textSecondary)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: AppText.inter(14.5, FontWeight.w600))),
              Icon(selected ? LucideIcons.check : LucideIcons.chevronRight,
                  size: 17, color: selected ? AppColors.green : const Color(0xFFD1D5DB)),
            ]),
          ),
        ),
      );
}
