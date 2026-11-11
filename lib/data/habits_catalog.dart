import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/assets.dart';
import '../core/theme/app_colors.dart';
import '../models/habit.dart';

/// Los cinco hábitos del plan diario (Figma: «Detalle de cada hábito»).
const habitsCatalog = <Habit>[
  Habit(
    id: HabitId.water,
    name: 'Tomar agua',
    shortGoal: '8 vasos al día',
    goal: 'Meta: 8 vasos al día',
    estimate: '1 min',
    estimatedMinutes: 1,
    icon: LucideIcons.droplet,
    color: AppColors.turquoise,
    softColor: AppColors.infoBg,
    image: Img.hidratacion,
    target: 8,
    unitLabel: 'Vasos hoy',
    trackerTitle: 'Registro de hoy',
    trackerIcon: LucideIcons.droplet,
    description:
        'Mantener una buena hidratación es fundamental para el bienestar. '
        'Beber agua regularmente ayuda a regular la temperatura, mejora la '
        'concentración y reduce la sensación de hambre que a veces es sed.',
    tips: [
      'Ten una botella de agua a la vista durante el día.',
      'Toma un vaso al despertar y otro antes de cada comida.',
      'Cambia gaseosas y jugos azucarados por agua o aromáticas sin azúcar.',
    ],
  ),
  Habit(
    id: HabitId.activity,
    name: 'Actividad física',
    shortGoal: 'Caminar 30 minutos',
    goal: 'Meta: caminar 30 minutos',
    estimate: '30 min',
    estimatedMinutes: 30,
    icon: LucideIcons.activity,
    color: AppColors.green,
    softColor: AppColors.greenSoft,
    image: Img.running,
    target: 6,
    unitLabel: 'Minutos hoy',
    trackerTitle: 'Minutos de hoy',
    trackerIcon: LucideIcons.footprints,
    description:
        'Moverse a diario es uno de los hábitos más poderosos para prevenir '
        'la obesidad y la diabetes tipo 2. No necesitas un gimnasio: caminar '
        'a buen ritmo 30 minutos ya marca la diferencia.',
    tips: [
      'Divide los 30 minutos en bloques de 10 si no tienes tiempo seguido.',
      'Usa las escaleras en lugar del ascensor.',
      'Bájate una parada antes del bus y camina el resto.',
    ],
  ),
  Habit(
    id: HabitId.fruits,
    name: 'Frutas y verduras',
    shortGoal: '5 porciones al día',
    goal: 'Meta: 5 porciones al día',
    estimate: '5 min',
    estimatedMinutes: 5,
    icon: LucideIcons.carrot,
    color: AppColors.lime,
    softColor: AppColors.limeSoft,
    image: Img.frutas,
    target: 5,
    unitLabel: 'Porciones hoy',
    trackerTitle: 'Porciones de hoy',
    trackerIcon: LucideIcons.apple,
    description:
        'Incluir frutas y verduras en tu alimentación diaria aporta fibra, '
        'vitaminas y saciedad. Aprovecha lo que hay en la plaza: guayaba, '
        'papaya, mango, banano, tomate, zanahoria y ahuyama.',
    tips: [
      'Agrega una fruta al desayuno y otra a media tarde.',
      'Llena la mitad del plato del almuerzo con verduras.',
      'Prefiere la fruta entera en lugar del jugo.',
    ],
  ),
  Habit(
    id: HabitId.meals,
    name: 'Registrar alimentación',
    shortGoal: 'Anotar mis comidas',
    goal: 'Meta: anotar mis comidas',
    estimate: '2 min',
    estimatedMinutes: 2,
    icon: LucideIcons.pencilLine,
    color: AppColors.orange,
    softColor: AppColors.warmBg,
    image: Img.registro,
    target: 3,
    unitLabel: 'Comidas hoy',
    trackerTitle: 'Comidas registradas',
    trackerIcon: LucideIcons.utensils,
    slotLabels: ['Desayuno', 'Almuerzo', 'Cena'],
    description:
        'Anotar lo que comes te ayuda a reconocer patrones, horarios y '
        'antojos sin juzgarte. No se trata de contar calorías, sino de '
        'tomar conciencia de tus elecciones.',
    tips: [
      'Registra la comida justo después de comer, toma menos de un minuto.',
      'Anota también cómo te sentías: te ayudará a entender tus antojos.',
      'No te castigues si un día comiste diferente: mañana es otra oportunidad.',
    ],
  ),
  Habit(
    id: HabitId.sleep,
    name: 'Dormir bien',
    shortGoal: '7-8 horas de sueño',
    goal: 'Meta: 7-8 horas de sueño',
    estimate: '8 h',
    icon: LucideIcons.moon,
    color: AppColors.violet,
    softColor: AppColors.violetSoft,
    image: Img.dormir,
    target: 8,
    unitLabel: 'Anoche',
    trackerTitle: 'Anoche dormiste',
    trackerIcon: LucideIcons.moon,
    description:
        'El sueño es vital para la salud integral. Dormir menos de 7 horas '
        'altera las hormonas del hambre y aumenta los antojos de alimentos '
        'dulces y grasosos al día siguiente.',
    tips: [
      'Evita pantallas 30 minutos antes de acostarte.',
      'Acuéstate y levántate a la misma hora, incluso el fin de semana.',
      'Cena liviano y al menos dos horas antes de dormir.',
    ],
  ),
];

Habit habitById(HabitId id) => habitsCatalog.firstWhere((h) => h.id == id);
