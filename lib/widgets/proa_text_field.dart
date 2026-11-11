import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';

/// «Campo de texto» de Figma: estado normal gris y activo con anillo verde.
class ProaTextField extends StatefulWidget {
  const ProaTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.suffix,
    this.onChanged,
    this.textInputAction,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final int? maxLength;

  @override
  State<ProaTextField> createState() => _ProaTextFieldState();
}

class _ProaTextFieldState extends State<ProaTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _focus.hasFocus || widget.controller.text.isNotEmpty;
    final error = widget.errorText != null;
    final borderColor = error
        ? AppColors.orange
        : active
            ? AppColors.green
            : AppColors.border;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focus.requestFocus,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.white : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(Radii.icon),
          border: Border.all(color: borderColor, width: active || error ? 1.5 : 1),
          boxShadow: _focus.hasFocus
              ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.12), blurRadius: 0, spreadRadius: 3)]
              : null,
        ),
        child: Row(children: [
          Icon(widget.icon, size: 17, color: active ? AppColors.green : AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              cursorColor: AppColors.green,
              style: AppText.inter(14.5, FontWeight.w500),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: widget.hint,
                hintStyle: AppText.inter(14.5, FontWeight.w400, color: AppColors.textMuted),
              ),
            ),
          ),
          if (widget.suffix != null && widget.controller.text.isNotEmpty)
            Text(widget.suffix!, style: AppText.inter(14.5, FontWeight.w500)),
        ]),
        ),
      ),
      if (error)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(widget.errorText!, style: AppText.inter(12, FontWeight.w500, color: AppColors.orange)),
        ),
    ]);
  }
}

/// Etiqueta de campo de formulario («Tu nombre», «Edad»).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.inter(12.5, FontWeight.w600, color: const Color(0xFF374151))),
      );
}
