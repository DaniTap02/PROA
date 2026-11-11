import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/assets.dart';
import '../core/theme/app_colors.dart';
import '../models/habit.dart';

/// Los cinco hábitos del plan diario (Figma: «Detalle de cada hábito»).
/// Descripciones tomadas de Figma; el final de cada «Consejo práctico» queda
/// oculto bajo el botón fijo en el prototipo y se completó con el mismo sentido.
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
        'Mantener una buena hidratación es fundamental para el bienestar. Beber agua regularmente ayuda a regular el metabolismo, mantener la energía y controlar el apetito.',
    advice: 'Lleva una botella de agua contigo y rellénala durante el día.',
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
        'Moverse a diario es uno de los hábitos más poderosos para tu salud. No necesitas un gimnasio: caminar, bailar o subir escaleras cuenta como ejercicio.',
    advice: 'Comienza con 15 minutos al día e increméntalo poco a poco.',
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
        'Incluir frutas y verduras en tu alimentación diaria aporta vitaminas, minerales y fibra que tu cuerpo necesita para funcionar bien y mantenerse energizado.',
    advice: 'Agrega una fruta en el desayuno y una porción de verduras en el almuerzo.',
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
        'Llevar un registro de lo que comes te ayuda a conocer tus patrones alimentarios y tomar decisiones más conscientes a lo largo del día.',
    advice: 'Anota lo que comes justo después de cada comida para no olvidarlo.',
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
        'El sueño es vital para la salud integral. Dormir bien regula las hormonas del apetito, mejora la energía y apoya la recuperación muscular y mental.',
    advice: 'Establece una hora fija para acostarte y evita las pantallas antes de dormir.',
  ),
];

Habit habitById(HabitId id) => habitsCatalog.firstWhere((h) => h.id == id);
