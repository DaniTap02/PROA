import 'package:flutter/widgets.dart';

/// Áreas que agrupa el test («Tu perfil por áreas» en la pantalla de resultado).
enum TestArea { actividad, alimentacion, sueno, estres }

extension TestAreaLabel on TestArea {
  String get label => switch (this) {
        TestArea.actividad => 'Actividad física',
        TestArea.alimentacion => 'Alimentación',
        TestArea.sueno => 'Sueño y descanso',
        TestArea.estres => 'Manejo del estrés',
      };
}

class TestOption {
  const TestOption(this.text, this.points);
  final String text;

  /// Puntos de la opción (0 = menos saludable … 3 = más saludable).
  final int points;
}

class TestQuestion {
  const TestQuestion({
    required this.category,
    required this.categoryIcon,
    required this.area,
    required this.text,
    required this.options,
  });

  /// Etiqueta de la categoría visible («Actividad física», «Sueño»...).
  final String category;
  final IconData categoryIcon;
  final TestArea area;
  final String text;
  final List<TestOption> options;
}

/// Resultado calculado y persistido.
class TestResult {
  const TestResult({
    required this.score,
    required this.areaScores,
    required this.answers,
    required this.takenAt,
  });

  /// Puntaje 0-100.
  final int score;
  final Map<TestArea, int> areaScores;
  final List<int> answers;
  final DateTime takenAt;

  Map<String, dynamic> toJson() => {
        'score': score,
        'areas': {for (final e in areaScores.entries) e.key.name: e.value},
        'answers': answers,
        'takenAt': takenAt.toIso8601String(),
      };

  factory TestResult.fromJson(Map<String, dynamic> j) => TestResult(
        score: j['score'] as int,
        areaScores: {
          for (final e in (j['areas'] as Map<String, dynamic>).entries)
            TestArea.values.byName(e.key): e.value as int,
        },
        answers: (j['answers'] as List).cast<int>(),
        takenAt: DateTime.parse(j['takenAt'] as String),
      );
}
