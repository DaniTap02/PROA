import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Espaciado en múltiplos de 4 (Figma «Fondos, superficies y espaciado»).
abstract final class Gap {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  /// Margen lateral de pantalla en el diseño 390 × 844.
  static const screen = 20.0;
}

/// Radios de esquina definidos en Figma.
abstract final class Radii {
  static const checkbox = 9.0;
  static const icon = 12.0;
  static const button = 16.0;
  static const card = 20.0;
  static const header = 32.0;
  static const pill = 999.0;

  static const rCheckbox = BorderRadius.all(Radius.circular(checkbox));
  static const rIcon = BorderRadius.all(Radius.circular(icon));
  static const rButton = BorderRadius.all(Radius.circular(button));
  static const rCard = BorderRadius.all(Radius.circular(card));
  static const rHeader = BorderRadius.all(Radius.circular(header));
  static const rPill = BorderRadius.all(Radius.circular(pill));
}

/// Sombras: suave, elevada y de color.
abstract final class Shadows {
  static const soft = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 2)),
  ];
  static const elevated = [
    BoxShadow(color: Color(0x1A0F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> colored([Color c = AppColors.green]) => [
        BoxShadow(
            color: c.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6)),
      ];
}

/// Tamaño del lienzo de referencia de Figma.
abstract final class DesignFrame {
  static const width = 390.0;
  static const height = 844.0;
}
