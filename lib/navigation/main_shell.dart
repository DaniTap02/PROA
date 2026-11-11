import 'package:flutter/material.dart';

import '../screens/main/home_screen.dart';
import '../screens/main/nutrition_screen.dart';
import '../screens/main/plan_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/main/progress_screen.dart';
import '../widgets/bottom_nav.dart';

/// Contenedor de la app principal: barra inferior fija y un Navigator por
/// sección, para que las pantallas de detalle conserven la barra (como en el
/// prototipo de Figma).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>()!;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  AppTab _tab = AppTab.inicio;
  final _keys = {for (final t in AppTab.values) t: GlobalKey<NavigatorState>()};

  AppTab get tab => _tab;

  Widget _root(AppTab t) => switch (t) {
        AppTab.inicio => const HomeScreen(),
        AppTab.plan => const PlanScreen(),
        AppTab.alimentacion => const NutritionScreen(),
        AppTab.progreso => const ProgressScreen(),
        AppTab.perfil => const ProfileScreen(),
      };

  /// Cambia de sección. Si ya está activa, vuelve a su pantalla raíz.
  void select(AppTab t) {
    if (t == _tab) {
      _keys[t]!.currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _tab = t);
    }
  }

  /// Cambia de sección y abre [page] dentro de ella.
  Future<T?> openIn<T>(AppTab t, Widget page) {
    _keys[t]!.currentState?.popUntil((r) => r.isFirst);
    setState(() => _tab = t);
    return _keys[t]!.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final nav = _keys[_tab]!.currentState!;
          if (nav.canPop()) {
            nav.pop();
          } else if (_tab != AppTab.inicio) {
            setState(() => _tab = AppTab.inicio);
          }
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _tab.index,
            children: [
              for (final t in AppTab.values)
                HeroControllerScope.none(
                  child: Navigator(
                    key: _keys[t],
                    onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _root(t)),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: ProaBottomNav(current: _tab, onSelect: select),
        ),
      );
}
