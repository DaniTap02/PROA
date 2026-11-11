import 'package:flutter/widgets.dart';

enum EmotionId { ansiedad, estres, hambre, aburrimiento, antojo }

class Emotion {
  const Emotion({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.strategies,
  });

  final EmotionId id;
  final String label;
  final IconData icon;
  final Color color;
  final Color softColor;

  /// Recomendaciones «Prueba esto antes de ceder» (ícono + texto).
  final List<(IconData icon, String text)> strategies;
}

/// Momento registrado en el historial de antojos y ansiedad.
class CravingEntry {
  const CravingEntry({
    required this.emotion,
    required this.at,
    required this.strategies,
  });

  final EmotionId emotion;
  final DateTime at;

  /// Índices de las recomendaciones que la persona marcó.
  final List<int> strategies;

  Map<String, dynamic> toJson() => {
        'e': emotion.name,
        'at': at.toIso8601String(),
        's': strategies,
      };

  factory CravingEntry.fromJson(Map<String, dynamic> j) => CravingEntry(
        emotion: EmotionId.values.byName(j['e'] as String),
        at: DateTime.parse(j['at'] as String).toLocal(),
        strategies: (j['s'] as List).cast<int>(),
      );
}
