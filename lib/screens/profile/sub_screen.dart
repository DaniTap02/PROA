import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';

/// Estructura común de las pantallas internas del perfil.
class SubScreen extends StatelessWidget {
  const SubScreen({super.key, required this.title, this.subtitle, required this.children, this.bottom});
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 8, Gap.screen, pad.bottom + (bottom == null ? 20 : 90)),
          children: [
            const Align(alignment: Alignment.centerLeft, child: BackCircle()),
            const SizedBox(height: 16),
            Text(title, style: AppText.h1),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppText.secondary),
            ],
            const SizedBox(height: 20),
            ...children,
          ],
        ),
        if (bottom != null)
          Positioned(left: Gap.screen, right: Gap.screen, bottom: pad.bottom + 12, child: bottom!),
      ]),
    );
  }
}
