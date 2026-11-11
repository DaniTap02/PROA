import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../models/craving.dart';

/// Emociones de «¿Tienes un antojo?» (componente «Tarjeta de emoción»).
/// Las recomendaciones de «Antojo» son las de la captura de Figma; las de las
/// demás emociones siguen el mismo tono y quedan pendientes de validar.
const emotionsCatalog = <Emotion>[
  Emotion(
    id: EmotionId.ansiedad,
    label: 'Ansiedad',
    icon: LucideIcons.frown,
    color: AppColors.blue,
    softColor: AppColors.blueSoft,
    strategies: [
      (LucideIcons.wind, 'Respira profundo: 4 segundos inhala, 4 exhala'),
      (LucideIcons.droplet, 'Toma un vaso de agua despacio'),
      (LucideIcons.footprints, 'Sal a caminar 5 minutos'),
      (LucideIcons.pencilLine, 'Escribe qué te preocupa en este momento'),
    ],
  ),
  Emotion(
    id: EmotionId.estres,
    label: 'Estrés',
    icon: LucideIcons.zap,
    color: AppColors.purple,
    softColor: AppColors.purpleSoft,
    strategies: [
      (LucideIcons.wind, 'Haz 5 respiraciones lentas antes de comer'),
      (LucideIcons.activity, 'Estira el cuerpo durante 2 minutos'),
      (LucideIcons.music, 'Escucha una canción que te relaje'),
      (LucideIcons.heart, 'Habla con alguien de confianza'),
    ],
  ),
  Emotion(
    id: EmotionId.hambre,
    label: 'Hambre',
    icon: LucideIcons.utensils,
    color: AppColors.green,
    softColor: AppColors.greenSoft,
    strategies: [
      (LucideIcons.apple, 'Elige una fruta o un puñado de maní'),
      (LucideIcons.clock, 'Revisa cuánto falta para tu próxima comida'),
      (LucideIcons.droplet, 'Acompaña con un vaso de agua'),
      (LucideIcons.utensils, 'Sirve una porción en un plato, no del paquete'),
    ],
  ),
  Emotion(
    id: EmotionId.aburrimiento,
    label: 'Aburrimiento',
    icon: LucideIcons.meh,
    color: AppColors.turquoise,
    softColor: AppColors.infoBg,
    strategies: [
      (LucideIcons.target, 'Distráete con una actividad corta'),
      (LucideIcons.footprints, 'Da una vuelta a la manzana'),
      (LucideIcons.bookOpen, 'Lee una guía de PROA de 2 minutos'),
      (LucideIcons.droplet, 'Prepárate una aromática sin azúcar'),
    ],
  ),
  Emotion(
    id: EmotionId.antojo,
    label: 'Antojo',
    icon: LucideIcons.cookie,
    color: AppColors.orange,
    softColor: AppColors.warmBg,
    strategies: [
      (LucideIcons.clock, 'Espera 15 minutos antes de ceder al antojo'),
      (LucideIcons.droplet, 'Toma un vaso de agua primero'),
      (LucideIcons.target, 'Distráete con una actividad corta'),
      (LucideIcons.apple, 'Si persiste, elige una porción pequeña o una fruta'),
    ],
  ),
];

Emotion emotionById(EmotionId id) => emotionsCatalog.firstWhere((e) => e.id == id);
