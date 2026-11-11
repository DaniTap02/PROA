import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';
import 'navigation/main_shell.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'state/app_state.dart';

class ProaApp extends StatelessWidget {
  const ProaApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PROA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        builder: (context, child) => _DeviceFrame(child: child!),
        home: const _RootGate(),
      );
}

/// Decide entre el primer ingreso y la app principal.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: s.loggedIn && s.hasAccount ? const MainShell() : const WelcomeScreen(),
    );
  }
}

/// En pantallas anchas (web/escritorio) muestra la app dentro del lienzo de
/// referencia de Figma (390 × 844) para comparar fielmente. En móviles ocupa
/// toda la pantalla y respeta las áreas seguras.
class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < 600) return child;
    final h = size.height < DesignFrame.height + 32 ? size.height - 32 : DesignFrame.height;
    return ColoredBox(
      color: const Color(0xFFE3ECE6),
      child: Center(
        child: Container(
          width: DesignFrame.width,
          height: h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(44),
            boxShadow: Shadows.elevated,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(DesignFrame.width, h),
              padding: const EdgeInsets.only(top: 47, bottom: 34),
              viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
