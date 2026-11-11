import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipográfica de PROA (Tabla 3 del segundo avance).
/// Outfit: títulos, cifras y botones. Inter: párrafos, etiquetas y menús.
abstract final class AppText {
  static TextStyle outfit(double size, FontWeight w,
          {Color color = AppColors.text, double? height, double? spacing}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: w,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  static TextStyle inter(double size, FontWeight w,
          {Color color = AppColors.text, double? height, double? spacing}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: w,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  /// Display · Outfit ExtraBold 54 — nombre de la marca en la bienvenida.
  static TextStyle get display =>
      outfit(54, FontWeight.w800, color: AppColors.white, height: 1.0, spacing: 1);

  /// Título 1 · Outfit Bold 28 — título principal de cada pantalla.
  static TextStyle get h1 => outfit(28, FontWeight.w700, height: 1.2);

  /// Título 2 · Outfit Bold 22 — títulos de tarjetas destacadas.
  static TextStyle get h2 => outfit(22, FontWeight.w700, height: 1.2);

  /// Subtítulo · Outfit SemiBold 18 — encabezados de sección.
  static TextStyle get subtitle => outfit(18, FontWeight.w600, height: 1.3);

  /// Botón · Outfit SemiBold 17.
  static TextStyle get button =>
      outfit(17, FontWeight.w600, color: AppColors.white, height: 1.2);

  /// Párrafo · Inter Regular 15 (interlineado 160 %).
  static TextStyle get paragraph =>
      inter(15, FontWeight.w400, color: const Color(0xFF374151), height: 1.6);

  /// Párrafo destacado · Inter SemiBold 15 — nombres de hábitos y opciones.
  static TextStyle get paragraphStrong => inter(15, FontWeight.w600, height: 1.3);

  /// Texto secundario · Inter Regular 13 — descripciones cortas.
  static TextStyle get secondary =>
      inter(13, FontWeight.w400, color: AppColors.textSecondary, height: 1.45);

  /// Etiqueta · Inter SemiBold 12 — chips, píldoras y etiquetas.
  static TextStyle get label => inter(12, FontWeight.w600, height: 1.3);

  /// Antetítulo · Inter Bold 11, mayúsculas — textos sobre los títulos.
  static TextStyle get overline =>
      inter(11, FontWeight.w700, color: AppColors.green, spacing: 1.1, height: 1.2);

  /// Caption · Inter Medium 10 — barra de navegación y notas.
  static TextStyle get caption =>
      inter(10, FontWeight.w500, color: AppColors.textSecondary, height: 1.3);
}
