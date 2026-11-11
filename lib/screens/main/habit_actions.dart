import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/guide.dart';
import '../../models/habit.dart';
import '../../navigation/main_shell.dart';
import '../../state/app_state.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/popups.dart';
import '../cravings/cravings_screen.dart';
import '../guides/guide_detail_screen.dart';
import '../habits/habit_detail_screen.dart';

/// Marca o desmarca un hábito desde una lista (un solo toque).
Future<void> toggleHabitFromList(BuildContext context, DateTime date, HabitId id) async {
  try {
    await context.read<AppState>().toggleHabit(date, id);
  } catch (_) {
    if (context.mounted) showErrorToast(context);
  }
}

/// Abre [page] dentro de la sección [tab] (como en el prototipo: los detalles
/// de hábito viven en Plan; guías y antojos, en Alimentación).
void _openIn(BuildContext context, AppTab tab, Widget page) {
  final shell = MainShell.of(context);
  if (shell.tab == tab) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  } else {
    shell.openIn(tab, page);
  }
}

void openHabit(BuildContext context, HabitId id, [DateTime? date]) =>
    _openIn(context, AppTab.plan, HabitDetailScreen(id: id, date: date));

void openGuide(BuildContext context, Guide g) =>
    _openIn(context, AppTab.alimentacion, GuideDetailScreen(guide: g));

void openCravings(BuildContext context) =>
    _openIn(context, AppTab.alimentacion, const CravingsScreen());

/// Muestra «¡Hábito completado!» y, si la persona elige volver, abre el plan.
Future<void> celebrateHabit(BuildContext context, DateTime date) async {
  final s = context.read<AppState>();
  final back = await showHabitCompleted(context, done: s.completedOn(date), total: s.plan.length, streak: s.streak);
  if (back && context.mounted) {
    final shell = MainShell.of(context);
    Navigator.of(context).popUntil((r) => r.isFirst);
    shell.select(AppTab.plan);
  }
}
