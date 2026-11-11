import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

enum AppTab { inicio, plan, alimentacion, progreso, perfil }

const _items = [
  (AppTab.inicio, 'Inicio', LucideIcons.house),
  (AppTab.plan, 'Plan', LucideIcons.calendarCheck),
  (AppTab.alimentacion, 'Alimentación', LucideIcons.mapPin),
  (AppTab.progreso, 'Progreso', LucideIcons.chartColumn),
  (AppTab.perfil, 'Perfil', LucideIcons.user),
];

/// Barra inferior fija con las cinco secciones (activo en verde).
class ProaBottomNav extends StatelessWidget {
  const ProaBottomNav({super.key, required this.current, required this.onSelect});
  final AppTab? current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(top: 8, bottom: bottom > 0 ? bottom : 10),
      child: Row(children: [
        for (final (tab, label, icon) in _items)
          Expanded(
            child: Semantics(
              selected: tab == current,
              button: true,
              label: label,
              child: InkResponse(
                onTap: () => onSelect(tab),
                radius: 32,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon,
                        size: 22,
                        color: tab == current ? AppColors.green : AppColors.textMuted,
                        fill: tab == current ? 1 : 0),
                    const SizedBox(height: 4),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: AppText.inter(10, tab == current ? FontWeight.w700 : FontWeight.w500,
                            color: tab == current ? AppColors.green : AppColors.textMuted)),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
