import 'package:flutter/foundation.dart';

import '../core/dates.dart';
import '../data/habits_catalog.dart';
import '../models/craving.dart';
import '../models/habit.dart';
import '../models/risk_test.dart';
import '../models/user_profile.dart';
import '../services/local_store.dart';

/// Recordatorio configurable desde Perfil › Recordatorios.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool enabled;
  final int hour;
  final int minute;

  Reminder copyWith({bool? enabled, int? hour, int? minute}) => Reminder(
        id: id,
        title: title,
        subtitle: subtitle,
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  Map<String, dynamic> toJson() => {'e': enabled, 'h': hour, 'm': minute};
}

const _defaultReminders = [
  Reminder(id: 'water', title: 'Tomar agua', subtitle: 'Cada 2 horas desde', enabled: true, hour: 8, minute: 0),
  Reminder(id: 'activity', title: 'Actividad física', subtitle: 'Todos los días a las', enabled: true, hour: 18, minute: 0),
  Reminder(id: 'meals', title: 'Registrar comidas', subtitle: 'Después de cada comida, desde', enabled: false, hour: 13, minute: 0),
  Reminder(id: 'sleep', title: 'Prepárate para dormir', subtitle: 'Todas las noches a las', enabled: true, hour: 21, minute: 30),
  Reminder(id: 'streak', title: 'Racha y logros', subtitle: 'Resumen diario a las', enabled: true, hour: 20, minute: 0),
];

/// Notificación generada a partir de los datos reales del usuario.
class AppNotification {
  const AppNotification(this.kind, this.title, this.body, this.at);
  final String kind; // water | guide | streak | sleep | habit
  final String title;
  final String body;
  final DateTime at;
}

/// Estado global de PROA. Toda escritura se persiste en [LocalStore] antes de
/// notificar: si el guardado falla, la excepción llega a la interfaz.
class AppState extends ChangeNotifier {
  AppState(this._store, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final LocalStore _store;
  final DateTime Function() _clock;

  bool loaded = false;
  bool loggedIn = false;
  UserProfile? profile;
  TestResult? testResult;

  /// fecha (yyyy-mm-dd) → hábito → estado del día.
  final Map<String, Map<HabitId, HabitDay>> _days = {};
  final Set<String> favorites = {};
  final List<CravingEntry> cravings = [];
  Set<HabitId> activeHabits = HabitId.values.toSet();
  List<Reminder> reminders = List.of(_defaultReminders);
  bool remindersMaster = true;
  DateTime? notificationsReadAt;
  bool shareAnonymousData = false;
  bool lockWithDevice = false;

  DateTime get now => _clock();
  DateTime get today => Dates.day(now);

  // ---------------------------------------------------------------- carga
  Future<void> load() async {
    final s = await _store.readJson('session');
    loggedIn = s?['loggedIn'] as bool? ?? false;
    final readAt = s?['notifReadAt'] as String?;
    notificationsReadAt = readAt == null ? null : DateTime.parse(readAt);

    final p = await _store.readJson('profile');
    profile = p == null ? null : UserProfile.fromJson(p);
    final t = await _store.readJson('test');
    testResult = t == null ? null : TestResult.fromJson(t);

    final d = await _store.readJson('days');
    _days.clear();
    d?.forEach((date, habits) {
      _days[date] = {
        for (final e in (habits as Map<String, dynamic>).entries)
          HabitId.values.byName(e.key): HabitDay.fromJson(e.value as Map<String, dynamic>),
      };
    });

    final f = await _store.readJson('favorites');
    favorites
      ..clear()
      ..addAll(((f?['ids'] as List?) ?? const []).cast<String>());

    final c = await _store.readJson('cravings');
    cravings
      ..clear()
      ..addAll(((c?['items'] as List?) ?? const [])
          .map((e) => CravingEntry.fromJson(e as Map<String, dynamic>)));

    final h = await _store.readJson('habits');
    if (h != null) {
      activeHabits = ((h['active'] as List).cast<String>())
          .map(HabitId.values.byName)
          .toSet();
    }

    final r = await _store.readJson('reminders');
    if (r != null) {
      remindersMaster = r['master'] as bool? ?? true;
      final items = (r['items'] as Map<String, dynamic>?) ?? {};
      reminders = [
        for (final def in _defaultReminders)
          if (items[def.id] case final Map<String, dynamic> j)
            def.copyWith(enabled: j['e'] as bool, hour: j['h'] as int, minute: j['m'] as int)
          else
            def,
      ];
    }

    final pv = await _store.readJson('privacy');
    shareAnonymousData = pv?['share'] as bool? ?? false;
    lockWithDevice = pv?['lock'] as bool? ?? false;

    loaded = true;
    notifyListeners();
  }

  // -------------------------------------------------------------- sesión
  bool get hasAccount => profile != null && testResult != null;

  Future<void> _saveSession() => _store.writeJson('session', {
        'loggedIn': loggedIn,
        'notifReadAt': notificationsReadAt?.toIso8601String(),
      });

  Future<void> saveProfile(UserProfile p) async {
    await _store.writeJson('profile', p.toJson());
    profile = p;
    notifyListeners();
  }

  Future<void> saveTestResult(TestResult r) async {
    await _store.writeJson('test', r.toJson());
    testResult = r;
    notifyListeners();
  }

  Future<void> logIn() async {
    loggedIn = true;
    await _saveSession();
    notifyListeners();
  }

  /// Cierra sesión conservando el progreso («Tu progreso queda guardado»).
  Future<void> logOut() async {
    loggedIn = false;
    await _saveSession();
    notifyListeners();
  }

  // ------------------------------------------------------------- hábitos
  List<Habit> get plan =>
      habitsCatalog.where((h) => activeHabits.contains(h.id)).toList();

  HabitDay dayOf(DateTime date, HabitId id) =>
      _days[Dates.key(date)]?[id] ?? const HabitDay();

  Future<void> _saveDays() => _store.writeJson('days', {
        for (final e in _days.entries)
          e.key: {for (final h in e.value.entries) h.key.name: h.value.toJson()},
      });

  Future<void> _setDay(DateTime date, HabitId id, HabitDay value) async {
    final k = Dates.key(date);
    final previous = _days[k]?[id];
    (_days[k] ??= {})[id] = value;
    try {
      await _saveDays();
    } catch (_) {
      if (previous == null) {
        _days[k]!.remove(id);
      } else {
        _days[k]![id] = previous;
      }
      rethrow;
    }
    notifyListeners();
  }

  /// Marca o desmarca un hábito. Devuelve el nuevo estado `completed`.
  Future<bool> toggleHabit(DateTime date, HabitId id) async {
    final d = dayOf(date, id);
    await _setDay(date, id, d.copyWith(completed: !d.completed));
    return !d.completed;
  }

  Future<void> setCompleted(DateTime date, HabitId id, bool value) =>
      _setDay(date, id, dayOf(date, id).copyWith(completed: value));

  /// Actualiza el registro (vasos, minutos, porciones, comidas, horas).
  /// Devuelve true si con este cambio el hábito quedó completo.
  Future<bool> setProgress(DateTime date, HabitId id, int value) async {
    final h = habitById(id);
    final d = dayOf(date, id);
    final v = value.clamp(0, h.target);
    final reached = v >= h.target && !d.completed;
    await _setDay(date, id, d.copyWith(progress: v, completed: reached ? true : d.completed));
    return reached;
  }

  int completedOn(DateTime date) =>
      plan.where((h) => dayOf(date, h.id).completed).length;

  double ratioOn(DateTime date) =>
      plan.isEmpty ? 0 : completedOn(date) / plan.length;

  bool activeOn(DateTime date) => completedOn(date) > 0;

  /// Minutos estimados de los hábitos pendientes del día.
  int remainingMinutes(DateTime date) => plan
      .where((h) => !dayOf(date, h.id).completed)
      .fold(0, (a, h) => a + h.estimatedMinutes);

  /// Días seguidos con al menos un hábito cumplido (cuenta hoy si ya hay
  /// actividad; si no, termina ayer).
  int get streak {
    var d = activeOn(today) ? today : today.subtract(const Duration(days: 1));
    var n = 0;
    while (activeOn(d)) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  int habitStreak(HabitId id) {
    var d = dayOf(today, id).completed ? today : today.subtract(const Duration(days: 1));
    var n = 0;
    while (dayOf(d, id).completed) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  /// Días de la semana actual transcurridos (hasta hoy incluido).
  List<DateTime> get weekSoFar =>
      Dates.weekOf(today).where((d) => !d.isAfter(today)).toList();

  int get weekActiveDays => weekSoFar.where(activeOn).length;

  int get weekCompletedHabits =>
      weekSoFar.fold(0, (a, d) => a + completedOn(d));

  int get lastWeekCompletedHabits {
    final s = Dates.weekStart(today).subtract(const Duration(days: 7));
    return [for (var i = 0; i < 7; i++) DateTime(s.year, s.month, s.day + i)]
        .fold(0, (a, d) => a + completedOn(d));
  }

  /// % de cumplimiento entre [from] y [to] (incluidos, sin pasar de hoy).
  int pctBetween(DateTime from, DateTime to) {
    var done = 0, total = 0;
    for (var d = from; !d.isAfter(to) && !d.isAfter(today); d = DateTime(d.year, d.month, d.day + 1)) {
      done += completedOn(d);
      total += plan.length;
    }
    return total == 0 ? 0 : (done * 100 / total).round();
  }

  int get weekPct => pctBetween(Dates.weekStart(today), today);

  int habitWeekPct(HabitId id) {
    final days = weekSoFar;
    return (days.where((d) => dayOf(d, id).completed).length * 100 / days.length).round();
  }

  /// Cumplimiento semanal de las últimas [n] semanas (la última es la actual).
  List<int> weeklyEvolution([int n = 4]) {
    final start = Dates.weekStart(today);
    return [
      for (var i = n - 1; i >= 0; i--)
        pctBetween(start.subtract(Duration(days: 7 * i)),
            start.subtract(Duration(days: 7 * i - 6))),
    ];
  }

  /// Primera fecha con actividad o con perfil creado.
  DateTime get firstDay {
    final dates = _days.keys.map(Dates.parseKey).toList()..sort();
    final created = profile == null ? today : Dates.day(profile!.createdAt);
    return dates.isEmpty || created.isBefore(dates.first) ? created : dates.first;
  }

  int get totalActiveDays => _days.keys
      .map(Dates.parseKey)
      .where(activeOn)
      .length;

  int get totalCompletedHabits =>
      _days.values.fold(0, (a, m) => a + m.values.where((d) => d.completed).length);

  Future<void> setActiveHabits(Set<HabitId> ids) async {
    if (ids.isEmpty) throw ArgumentError('El plan necesita al menos un hábito');
    await _store.writeJson('habits', {'active': ids.map((e) => e.name).toList()});
    activeHabits = ids;
    notifyListeners();
  }

  // ----------------------------------------------------------- favoritos
  bool isFavorite(String id) => favorites.contains(id);

  /// Alterna un favorito; devuelve true si quedó guardado.
  Future<bool> toggleFavorite(String id) async {
    final next = Set.of(favorites);
    final saved = !next.contains(id);
    saved ? next.add(id) : next.remove(id);
    await _store.writeJson('favorites', {'ids': next.toList()});
    favorites
      ..clear()
      ..addAll(next);
    notifyListeners();
    return saved;
  }

  // ------------------------------------------------------------- antojos
  Future<void> addCraving(CravingEntry e) async {
    final next = [e, ...cravings];
    await _store.writeJson('cravings', {'items': next.map((x) => x.toJson()).toList()});
    cravings.insert(0, e);
    notifyListeners();
  }

  int cravingsOn(DateTime d) => cravings.where((c) => Dates.day(c.at) == Dates.day(d)).length;

  int get weekCravings =>
      cravings.where((c) => !c.at.isBefore(Dates.weekStart(today))).length;

  // ------------------------------------------------------- recordatorios
  Future<void> _saveReminders() => _store.writeJson('reminders', {
        'master': remindersMaster,
        'items': {for (final r in reminders) r.id: r.toJson()},
      });

  Future<void> updateReminder(Reminder r) async {
    final prev = reminders;
    reminders = [for (final x in reminders) x.id == r.id ? r : x];
    try {
      await _saveReminders();
    } catch (_) {
      reminders = prev;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setRemindersMaster(bool v) async {
    remindersMaster = v;
    await _saveReminders();
    notifyListeners();
  }

  Future<void> setPrivacy({bool? share, bool? lock}) async {
    final s = share ?? shareAnonymousData, l = lock ?? lockWithDevice;
    await _store.writeJson('privacy', {'share': s, 'lock': l});
    shareAnonymousData = s;
    lockWithDevice = l;
    notifyListeners();
  }

  /// Borra todos los datos guardados en este dispositivo.
  Future<void> deleteAllData() async {
    await _store.clear();
    profile = null;
    testResult = null;
    loggedIn = false;
    _days.clear();
    favorites.clear();
    cravings.clear();
    activeHabits = HabitId.values.toSet();
    reminders = List.of(_defaultReminders);
    remindersMaster = true;
    notificationsReadAt = null;
    shareAnonymousData = false;
    lockWithDevice = false;
    notifyListeners();
  }

  // ------------------------------------------------------- notificaciones
  bool _reminderOn(String id) =>
      remindersMaster && reminders.firstWhere((r) => r.id == id).enabled;

  DateTime _at(int h, int m) => DateTime(today.year, today.month, today.day, h, m);

  /// Notificaciones derivadas del estado real (no hay servidor de push).
  List<AppNotification> get notifications {
    final out = <AppNotification>[];
    final n = now;
    if (activeHabits.contains(HabitId.water) && _reminderOn('water')) {
      final w = habitById(HabitId.water);
      final r = reminders.firstWhere((r) => r.id == 'water');
      final p = dayOf(today, HabitId.water).progress;
      final start = _at(r.hour, r.minute);
      if (n.isAfter(start) && p < w.target) {
        final slots = n.difference(start).inMinutes ~/ 120;
        out.add(AppNotification('water', 'Hora de tomar agua',
            'Llevas $p de ${w.target} vasos. ${p >= w.target / 2 ? '¡Vas muy bien!' : 'Un vaso más suma.'}',
            start.add(Duration(minutes: slots * 120))));
      }
    }
    final s = streak;
    if (s >= 2 && _reminderOn('streak')) {
      out.add(AppNotification('streak', '¡$s días seguidos!',
          'Estás construyendo constancia. Mira tu progreso.', n.hour >= 8 ? _at(8, 0) : n));
    }
    if (activeHabits.contains(HabitId.sleep) && _reminderOn('sleep')) {
      final r = reminders.firstWhere((r) => r.id == 'sleep');
      final at = _at(r.hour, r.minute);
      final when = n.isAfter(at) ? at : at.subtract(const Duration(days: 1));
      out.add(AppNotification('sleep', 'Prepárate para dormir',
          'Evita pantallas 30 minutos antes de acostarte.', when));
    }
    if (profile != null) {
      out.add(AppNotification('guide', 'Nueva guía: Hidratación',
          'Aprende cuánta agua necesitas al día.', profile!.createdAt));
    }
    out.sort((a, b) => b.at.compareTo(a.at));
    return out;
  }

  bool get hasUnreadNotifications {
    final list = notifications;
    if (list.isEmpty) return false;
    return notificationsReadAt == null || list.first.at.isAfter(notificationsReadAt!);
  }

  Future<void> markNotificationsRead() async {
    notificationsReadAt = now;
    await _saveSession();
    notifyListeners();
  }
}
