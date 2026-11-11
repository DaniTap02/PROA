import 'package:flutter/material.dart';

/// Paleta oficial de PROA (Segundo avance UI/UX, Tabla 2 y estilos de Figma).
/// No agregar colores fuera de esta paleta salvo tintes derivados (opacidades)
/// documentados aquí mismo.
abstract final class AppColors {
  // Primarios
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF15803D);
  static const petrol = Color(0xFF0F766E);

  // Secundarios
  static const turquoise = Color(0xFF0891B2);
  static const turquoiseLight = Color(0xFF22D3EE);
  static const infoBg = Color(0xFFCFFAFE);

  // Acentos
  static const orange = Color(0xFFEA580C);
  static const amber = Color(0xFFF59E0B);
  static const warmBg = Color(0xFFFFEDD5);

  // Neutros
  static const text = Color(0xFF111827);
  static const background = Color(0xFFF4FAF6);
  static const white = Color(0xFFFFFFFF);

  // Tintes derivados de la paleta (grises con leve tinte verde, ver Tabla 2).
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5EDE8);
  static const surfaceMuted = Color(0xFFF1F5F3);
  static const greenSoft = Color(0xFFDCFCE7);
  static const greenSofter = Color(0xFFF0FDF4);
  static const warmSofter = Color(0xFFFFF7ED);
  static const infoSofter = Color(0xFFECFEFF);

  // Colores por hábito / emoción (iconografía de Figma: cada hábito y
  // emoción tiene su ícono y color).
  static const violet = Color(0xFF6366F1);
  static const violetSoft = Color(0xFFE0E7FF);
  static const purple = Color(0xFF8B5CF6);
  static const purpleSoft = Color(0xFFEDE9FE);
  static const lime = Color(0xFF65A30D);
  static const limeSoft = Color(0xFFECFCCB);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFDBEAFE);

  // Destructivo (botón «Salir» del diálogo de cerrar sesión en Figma).
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);

  // Degradados definidos en Figma
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, petrol],
  );
  static const primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF22C55E), greenDark],
  );
  static const secondaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [turquoiseLight, petrol],
  );
  static const accentButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFB923C), orange],
  );
  static const welcomeOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.35, 0.7, 1.0],
    colors: [
      Color(0x00052E16),
      Color(0x33052E16),
      Color(0xD9064E2B),
      Color(0xFF053B22),
    ],
  );
}
