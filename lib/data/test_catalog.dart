import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/risk_test.dart';

/// Las 8 preguntas del test de hábitos.
///
/// Preguntas 1, 3, 5 y 8: texto exacto de las capturas de Figma.
/// Preguntas 2, 4, 6 y 7: no aparecen en el documento del segundo avance;
/// se redactaron siguiendo el mismo formato y quedan PENDIENTES DE VALIDAR
/// contra los frames de Figma (ver docs/PENDIENTES.md).
const testQuestions = <TestQuestion>[
  TestQuestion(
    category: 'Actividad física',
    categoryIcon: LucideIcons.activity,
    area: TestArea.actividad,
    text: '¿Con qué frecuencia realizas actividad física?',
    options: [
      TestOption('Nunca', 0),
      TestOption('1-2 días/semana', 1),
      TestOption('3-4 días/semana', 2),
      TestOption('Todos los días', 3),
    ],
  ),
  TestQuestion(
    category: 'Actividad física',
    categoryIcon: LucideIcons.activity,
    area: TestArea.actividad,
    text: '¿Cuántas horas al día pasas sentado?',
    options: [
      TestOption('Más de 10 horas', 0),
      TestOption('7-10 horas', 1),
      TestOption('4-6 horas', 2),
      TestOption('Menos de 4 horas', 3),
    ],
  ),
  TestQuestion(
    category: 'Alimentación',
    categoryIcon: LucideIcons.leaf,
    area: TestArea.alimentacion,
    text: '¿Cuántos días a la semana consumes frutas y verduras?',
    options: [
      TestOption('0-1 días', 0),
      TestOption('2-3 días', 1),
      TestOption('4-5 días', 2),
      TestOption('Todos los días', 3),
    ],
  ),
  TestQuestion(
    category: 'Alimentación',
    categoryIcon: LucideIcons.leaf,
    area: TestArea.alimentacion,
    text: '¿Con qué frecuencia tomas gaseosas o jugos azucarados?',
    options: [
      TestOption('Todos los días', 0),
      TestOption('Varios días', 1),
      TestOption('Raramente', 2),
      TestOption('Nunca', 3),
    ],
  ),
  TestQuestion(
    category: 'Sueño',
    categoryIcon: LucideIcons.moon,
    area: TestArea.sueno,
    text: '¿Cuántas horas duermes normalmente?',
    options: [
      TestOption('Menos de 5 horas', 0),
      TestOption('5-6 horas', 1),
      TestOption('7-8 horas', 3),
      TestOption('Más de 8 horas', 2),
    ],
  ),
  TestQuestion(
    category: 'Estrés',
    categoryIcon: LucideIcons.zap,
    area: TestArea.estres,
    text: '¿Con qué frecuencia comes por ansiedad o estrés?',
    options: [
      TestOption('Casi siempre', 0),
      TestOption('A menudo', 1),
      TestOption('A veces', 2),
      TestOption('Casi nunca', 3),
    ],
  ),
  TestQuestion(
    category: 'Estrés',
    categoryIcon: LucideIcons.zap,
    area: TestArea.estres,
    text: '¿Cómo describirías tu nivel de estrés en la última semana?',
    options: [
      TestOption('Muy alto', 0),
      TestOption('Alto', 1),
      TestOption('Moderado', 2),
      TestOption('Bajo', 3),
    ],
  ),
  TestQuestion(
    category: 'Rutina',
    categoryIcon: LucideIcons.clock,
    area: TestArea.alimentacion,
    text: '¿Con qué frecuencia saltas el desayuno?',
    options: [
      TestOption('Todos los días', 0),
      TestOption('Varios días', 1),
      TestOption('Raramente', 2),
      TestOption('Nunca lo salto', 3),
    ],
  ),
];
