import 'package:flutter/widgets.dart';

enum HabitId { water, activity, fruits, meals, sleep }

/// Definición estática de un hábito del plan (contenido de Figma).
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.shortGoal,
    required this.goal,
    required this.estimate,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.image,
    required this.target,
    required this.unitLabel,
    required this.trackerTitle,
    required this.trackerIcon,
    required this.description,
    required this.tips,
    this.slotLabels,
    this.estimatedMinutes = 0,
  });

  final HabitId id;
  final String name;

  /// Texto bajo el nombre en las filas («8 vasos al día»).
  final String shortGoal;

  /// Meta mostrada en el detalle («Meta: 8 vasos al día»).
  final String goal;

  /// Píldora de tiempo estimado en la fila pendiente («1 min», «8 h»).
  final String estimate;
  final IconData icon;
  final Color color;
  final Color softColor;
  final String image;

  /// Número de casillas del registro diario.
  final int target;

  /// Etiqueta de la primera métrica («Vasos hoy», «Minutos hoy»...).
  final String unitLabel;

  /// Título del bloque de registro («Registro de hoy», «Minutos de hoy»...).
  final String trackerTitle;
  final IconData trackerIcon;
  final String description;
  final List<String> tips;

  /// Etiquetas opcionales por casilla (p. ej. Desayuno / Almuerzo / Cena).
  final List<String>? slotLabels;

  /// Minutos estimados para el cálculo «≈ N min restantes» del plan.
  final int estimatedMinutes;
}

/// Estado de un hábito en un día concreto.
class HabitDay {
  const HabitDay({this.progress = 0, this.completed = false});

  final int progress;
  final bool completed;

  HabitDay copyWith({int? progress, bool? completed}) => HabitDay(
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {'p': progress, 'c': completed};
  factory HabitDay.fromJson(Map<String, dynamic> j) =>
      HabitDay(progress: j['p'] as int? ?? 0, completed: j['c'] as bool? ?? false);
}
