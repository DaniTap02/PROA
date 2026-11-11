import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/risk_test.dart';

/// Las 8 preguntas del test de hábitos, con el texto, la categoría y las
/// opciones de los frames de Figma («Test de hábitos · Pregunta N de 8»).
/// Los puntos de cada opción (0-3) son parametrizables: ver test_scoring.dart.
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
    category: 'Bebidas',
    categoryIcon: LucideIcons.coffee,
    area: TestArea.alimentacion,
    text: '¿Con qué frecuencia consumes bebidas azucaradas?',
    options: [
      TestOption('Todos los días', 0),
      TestOption('Varios días/semana', 1),
      TestOption('1-2 veces/semana', 2),
      TestOption('Casi nunca', 3),
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
    category: 'Emociones',
    categoryIcon: LucideIcons.heart,
    area: TestArea.estres,
    text: '¿Con qué frecuencia comes por ansiedad o estrés?',
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
    category: 'Alimentación',
    categoryIcon: LucideIcons.utensils,
    area: TestArea.alimentacion,
    text: '¿Con qué frecuencia consumes alimentos ultraprocesados?',
    options: [
      TestOption('Todos los días', 0),
      TestOption('Varios días', 1),
      TestOption('1-2 veces/semana', 2),
      TestOption('Casi nunca', 3),
    ],
  ),
  TestQuestion(
    category: 'Hidratación',
    categoryIcon: LucideIcons.droplet,
    area: TestArea.alimentacion,
    text: '¿Cuántos vasos de agua tomas al día?',
    options: [
      TestOption('0-2 vasos', 0),
      TestOption('3-4 vasos', 1),
      TestOption('5-6 vasos', 2),
      TestOption('7 o más vasos', 3),
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
