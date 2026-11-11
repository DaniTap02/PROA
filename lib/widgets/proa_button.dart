import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';

/// Variantes del componente «Botones» de Figma.
enum ProaButtonKind { primary, secondary, accent, soft, text, white, dark }

class ProaButton extends StatelessWidget {
  const ProaButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.kind = ProaButtonKind.primary,
    this.arrow = false,
    this.leading,
    this.height = 54,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ProaButtonKind kind;
  final bool arrow;
  final IconData? leading;
  final double height;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (Gradient? grad, Color? bg, Color fg, BoxBorder? border, List<BoxShadow>? shadow) =
        switch (kind) {
      ProaButtonKind.primary => (AppColors.primaryButtonGradient, null, AppColors.white, null, Shadows.colored()),
      ProaButtonKind.secondary => (AppColors.secondaryButtonGradient, null, AppColors.white, null, Shadows.colored(AppColors.turquoise)),
      ProaButtonKind.accent => (AppColors.accentButtonGradient, null, AppColors.white, null, Shadows.colored(AppColors.orange)),
      ProaButtonKind.soft => (null, AppColors.greenSofter, AppColors.greenDark, Border.all(color: const Color(0xFFBBF7D0)), null),
      ProaButtonKind.text => (null, null, AppColors.green, null, null),
      ProaButtonKind.white => (null, AppColors.white, AppColors.greenDark, null, Shadows.soft),
      ProaButtonKind.dark => (null, AppColors.surfaceMuted, AppColors.text, null, null),
    };
    final style = AppText.button.copyWith(color: fg);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        else ...[
          if (leading != null) ...[Icon(leading, size: 19, color: fg), const SizedBox(width: 8)],
          Flexible(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
          if (arrow) ...[const SizedBox(width: 8), Icon(LucideIcons.arrowRight, size: 18, color: fg)],
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled || loading ? 1 : 0.5,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: grad,
            color: bg,
            border: border,
            borderRadius: Radii.rButton,
            boxShadow: enabled ? shadow : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: Radii.rButton,
              onTap: enabled ? onPressed : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
