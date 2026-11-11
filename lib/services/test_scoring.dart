import 'package:flutter/painting.dart';

import '../core/theme/app_colors.dart';
import '../models/risk_test.dart';

/// Reglas de puntuación del test — PARAMETRIZADAS.
///
/// El documento del proyecto no define una metodología validada ni umbrales
/// clínicos. Por eso:
///  * Cada opción vale de 0 a 3 puntos (ver test_catalog.dart).
///  * Puntaje total = suma / máximo posible × 100.
///  * Puntaje por área = mismo cálculo con las preguntas del área.
///  * Las bandas de clasificación de [ScoringConfig] son orientativas, NO un
///    diagnóstico, y deben validarse con un profesional de la salud.
class ScoringConfig {
  const ScoringConfig({this.goodFrom = 75, this.improveFrom = 40});

  /// Desde este puntaje: «Buenos hábitos».
  final int goodFrom;

  /// Desde este puntaje (y menor que [goodFrom]): «Hábitos por mejorar».
  /// Por debajo: «Hábitos que necesitan atención».
  final int improveFrom;
}

enum ResultBand { good, improve, attention }

class BandInfo {
  const BandInfo(this.title, this.message, this.color);
  final String title;
  final String message;
  final Color color;
}

class TestScoring {
  const TestScoring([this.config = const ScoringConfig()]);
  final ScoringConfig config;

  TestResult compute(List<TestQuestion> qs, List<int> answers, DateTime at) {
    assert(answers.length == qs.length && !answers.contains(-1));
    var total = 0, max = 0;
    final sum = <TestArea, int>{}, maxBy = <TestArea, int>{};
    for (var i = 0; i < qs.length; i++) {
      final q = qs[i];
      final best = q.options.map((o) => o.points).reduce((a, b) => a > b ? a : b);
      final pts = q.options[answers[i]].points;
      total += pts;
      max += best;
      sum[q.area] = (sum[q.area] ?? 0) + pts;
      maxBy[q.area] = (maxBy[q.area] ?? 0) + best;
    }
    return TestResult(
      score: (total * 100 / max).round(),
      areaScores: {
        for (final a in TestArea.values)
          if (maxBy[a] != null) a: (sum[a]! * 100 / maxBy[a]!).round(),
      },
      answers: List.of(answers),
      takenAt: at,
    );
  }

  ResultBand band(int score) => score >= config.goodFrom
      ? ResultBand.good
      : score >= config.improveFrom
          ? ResultBand.improve
          : ResultBand.attention;

  BandInfo info(int score) => switch (band(score)) {
        ResultBand.good => const BandInfo(
            'Buenos hábitos',
            'Tienes una base sólida. Sigue sumando pequeños pasos para mantenerla.',
            AppColors.green),
        ResultBand.improve => const BandInfo(
            'Hábitos por mejorar',
            'Tienes una base, pero hay oportunidades para fortalecer tus rutinas diarias.',
            AppColors.turquoise),
        ResultBand.attention => const BandInfo(
            'Hábitos que necesitan atención',
            'Hay varias rutinas que puedes cambiar. Empieza por una sola, a tu ritmo.',
            AppColors.orange),
      };

  /// Color de la barra por área (naranja/ámbar = requiere atención).
  Color areaColor(int pct) => pct >= config.goodFrom
      ? AppColors.green
      : pct >= 50
          ? AppColors.amber
          : AppColors.orange;

  /// Áreas ordenadas de menor a mayor puntaje.
  List<TestArea> weakest(TestResult r) =>
      (r.areaScores.entries.toList()..sort((a, b) => a.value.compareTo(b.value)))
          .map((e) => e.key)
          .toList();

  static String recommendation(TestArea a) => switch (a) {
        TestArea.actividad =>
          'Aumenta tu actividad física a al menos 30 minutos diarios.',
        TestArea.alimentacion =>
          'Incluye frutas y verduras en al menos 5 porciones al día.',
        TestArea.sueno => 'Procura dormir entre 7 y 8 horas cada noche.',
        TestArea.estres =>
          'Registra tus antojos para reconocer cuándo comes por emoción.',
      };
}
