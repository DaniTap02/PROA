import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/popups.dart';
import 'sub_screen.dart';

/// «Privacidad»: dónde se guardan los datos y opción real de borrarlos.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Future<void> _delete(BuildContext context) async {
    final ok = await showConfirm(context,
        icon: LucideIcons.trash2,
        title: '¿Borrar todos tus datos?',
        message: 'Se eliminarán tu perfil, el test, tus hábitos, guardados e historial de este dispositivo. No se puede deshacer.',
        confirm: 'Borrar');
    if (!ok || !context.mounted) return;
    try {
      ProaApp.navigatorKey.currentState?.popUntil((r) => r.isFirst);
      await context.read<AppState>().deleteAllData();
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final days = s.totalActiveDays;
    return SubScreen(
      title: 'Privacidad',
      subtitle: 'Tus datos son tuyos.',
      children: [
        ProaCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Point(LucideIcons.smartphone, 'Se guardan solo en este dispositivo',
                'PROA no envía tu perfil, tus respuestas del test ni tus registros a ningún servidor.'),
            const SizedBox(height: 14),
            const _Point(LucideIcons.shield, 'Sin diagnósticos',
                'El test es una herramienta educativa de orientación; no reemplaza una valoración médica.'),
            const SizedBox(height: 14),
            _Point(LucideIcons.database, 'Lo que hay guardado',
                'Perfil, resultado del test, $days ${days == 1 ? 'día' : 'días'} con hábitos, ${s.cravings.length} registros de antojos y ${s.favorites.length} elementos guardados.'),
          ]),
        ),
        const SizedBox(height: 12),
        ProaCard(
          onTap: () => _delete(context),
          child: Row(children: [
            const IconBox(LucideIcons.trash2, color: AppColors.danger, bg: AppColors.dangerSoft, size: 38, iconSize: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Borrar todos mis datos', style: AppText.inter(14, FontWeight.w600, color: AppColors.danger)),
                Text('Elimina la información de este dispositivo', style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.title, this.body);
  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBox(icon, color: AppColors.violet, bg: AppColors.violetSoft, size: 34, iconSize: 16, radius: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.inter(13.5, FontWeight.w700)),
            const SizedBox(height: 2),
            Text(body, style: AppText.inter(12.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.45)),
          ]),
        ),
      ]);
}
