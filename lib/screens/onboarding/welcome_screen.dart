import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';
import 'onboarding_screen.dart';

/// Bienvenida: foto a sangre, degradado verde, marca y «Comenzar».
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _login(BuildContext context) async {
    final s = context.read<AppState>();
    if (!s.hasAccount) {
      showProaToast(context,
          title: 'Aún no tienes cuenta aquí',
          message: 'No encontramos un perfil guardado en este dispositivo. Toca «Comenzar».',
          icon: LucideIcons.info,
          iconBg: AppColors.turquoise,
          bottomOffset: 40);
      return;
    }
    try {
      await s.logIn();
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF053B22),
        body: Stack(fit: StackFit.expand, children: [
          const ProaImage(Img.cooking, alignment: Alignment(0.2, -0.4)),
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.welcomeOverlay)),
          Padding(
            padding: EdgeInsets.fromLTRB(24, pad.top + 16, 24, pad.bottom + 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
                ),
                child: const Icon(LucideIcons.leaf, color: AppColors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text('PROA', style: AppText.display),
              const SizedBox(height: 8),
              Text('PREVENCIÓN Y REEDUCACIÓN EN OBESIDAD Y\nALIMENTACIÓN',
                  style: AppText.inter(9.5, FontWeight.w600, color: AppColors.white.withValues(alpha: 0.75), spacing: 1.2, height: 1.5)),
              const SizedBox(height: 22),
              Text('Pequeños hábitos.\nGrandes cambios.', style: AppText.outfit(30, FontWeight.w700, color: AppColors.white, height: 1.15)),
              const SizedBox(height: 10),
              Text('Un test de 3 minutos y un plan diario que cabe en tu rutina.',
                  style: AppText.inter(14, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85), height: 1.5)),
              const SizedBox(height: 28),
              ProaButton('Comenzar',
                  kind: ProaButtonKind.white,
                  arrow: true,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()))),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => _login(context),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '¿Ya tienes cuenta? ', style: AppText.inter(13, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85))),
                        TextSpan(text: 'Inicia sesión', style: AppText.inter(13, FontWeight.w700, color: AppColors.white)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('Herramienta educativa · No reemplaza consulta médica',
                    style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.6))),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
