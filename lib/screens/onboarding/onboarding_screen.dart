import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';
import '../../widgets/proa_button.dart';
import 'create_profile_screen.dart';

class _Page {
  const _Page(this.image, this.step, this.icon, this.color, this.title, this.body, this.button, this.kind);
  final String image, step, title, body, button;
  final IconData icon;
  final Color color;
  final ProaButtonKind kind;
}

const _pages = [
  _Page(Img.bowl, 'Paso 1 de 3 · Diagnóstico', LucideIcons.search, AppColors.green, 'Conoce tus hábitos',
      'Identifica cómo están tus hábitos actuales con un test sencillo y visual.', 'Continuar', ProaButtonKind.primary),
  _Page(Img.cooking, 'Paso 2 de 3 · Rutina', LucideIcons.sprout, AppColors.turquoise, 'Crea una rutina saludable',
      'Organiza pequeñas acciones que puedas mantener en tu día a día sin esfuerzo extremo.', 'Continuar', ProaButtonKind.secondary),
  _Page(Img.running, 'Paso 3 de 3 · Progreso', LucideIcons.trendingUp, AppColors.orange, 'Avanza a tu ritmo',
      'Registra tus avances y construye constancia un día a la vez.', 'Empezar mi perfil', ProaButtonKind.accent),
];

/// Onboarding de tres pasos (con botón o deslizando la foto).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _i = 0;

  void _toProfile() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CreateProfileScreen()));

  void _next() {
    if (_i == _pages.length - 1) {
      _toProfile();
    } else {
      _ctrl.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_i];
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) => _OnboardingPage(page: _pages[i], photoHeight: h * 0.54),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, pad.bottom + 8),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _i ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _i ? p.color : const Color(0xFFD1D5DB),
                      borderRadius: Radii.rPill,
                    ),
                  ),
              ]),
              const SizedBox(height: 20),
              ProaButton(p.button, kind: p.kind, arrow: true, onPressed: _next),
              SizedBox(
                height: 44,
                child: _i < _pages.length - 1
                    ? TextButton(
                        onPressed: _toProfile,
                        child: Text('Omitir', style: AppText.inter(13.5, FontWeight.w500, color: AppColors.textMuted)),
                      )
                    : null,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.photoHeight});
  final _Page page;
  final double photoHeight;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: photoHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Radii.header)),
            child: Stack(fit: StackFit.expand, children: [
              ProaImage(page.image),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: Radii.rPill, boxShadow: Shadows.soft),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: page.color, shape: BoxShape.circle),
                      child: Icon(page.icon, size: 12, color: AppColors.white),
                    ),
                    const SizedBox(width: 7),
                    Text(page.step, style: AppText.inter(11.5, FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 28, Gap.screen, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(page.title, style: AppText.h1),
            const SizedBox(height: 10),
            Text(page.body, style: AppText.inter(14.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.5)),
          ]),
        ),
      ]);
}
