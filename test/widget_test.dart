import 'package:flutter_test/flutter_test.dart';
import 'package:proa/core/dates.dart';
import 'package:proa/data/test_catalog.dart';
import 'package:proa/models/craving.dart';
import 'package:proa/models/habit.dart';
import 'package:proa/models/risk_test.dart';
import 'package:proa/models/user_profile.dart';
import 'package:proa/screens/main/nutrition_screen.dart';
import 'package:proa/services/auth.dart';
import 'package:proa/services/local_store.dart';
import 'package:proa/services/test_scoring.dart';
import 'package:proa/state/app_state.dart';

void main() {
  group('Test de hábitos', () {
    test('tiene 8 preguntas con 4 opciones', () {
      expect(testQuestions.length, 8);
      expect(testQuestions.every((q) => q.options.length == 4), isTrue);
    });

    test('puntaje 0..100 y por áreas', () {
      const sc = TestScoring();
      final best = [for (final q in testQuestions) q.options.indexWhere((o) => o.points == 3)];
      final worst = [for (final q in testQuestions) q.options.indexWhere((o) => o.points == 0)];
      expect(sc.compute(testQuestions, best, DateTime(2026)).score, 100);
      final w = sc.compute(testQuestions, worst, DateTime(2026));
      expect(w.score, 0);
      expect(w.areaScores.keys.toSet(), TestArea.values.toSet());
      expect(sc.band(54), ResultBand.improve);
    });
  });

  group('Estado y persistencia', () {
    late MemoryStore store;
    var now = DateTime(2026, 10, 9, 10);
    AppState make() => AppState(store, clock: () => now);

    setUp(() {
      store = MemoryStore();
      now = DateTime(2026, 10, 9, 10);
    });

    test('marcar hábitos, racha y recarga desde el almacén', () async {
      final s = make();
      await s.load();
      await s.register('laura@gmail.com', 'clave1234');
      await s.saveProfile(UserProfile(
          name: 'Laura García', age: 28, sex: Sex.female, activity: ActivityLevel.moderate,
          goal: Goal.healthyRoutine, createdAt: DateTime(2026, 9, 1)));
      final yesterday = DateTime(2026, 10, 8);
      await s.toggleHabit(yesterday, HabitId.water);
      await s.toggleHabit(s.today, HabitId.water);
      await s.toggleHabit(s.today, HabitId.activity);
      expect(s.completedOn(s.today), 2);
      expect(s.streak, 2);
      expect(await s.setProgress(s.today, HabitId.fruits, 5), isTrue);
      expect(s.completedOn(s.today), 3);

      final again = make();
      await again.load();
      expect(again.profile!.firstName, 'Laura');
      expect(again.completedOn(again.today), 3);
      expect(again.streak, 2);
      expect(again.weekActiveDays, 2);
    });

    test('desmarcar resta del progreso', () async {
      final s = make();
      await s.load();
      await s.register('laura@gmail.com', 'clave1234');
      await s.toggleHabit(s.today, HabitId.sleep);
      await s.toggleHabit(s.today, HabitId.sleep);
      expect(s.completedOn(s.today), 0);
      expect(s.streak, 0);
    });

    test('favoritos e historial de antojos persisten', () async {
      final s = make();
      await s.load();
      await s.register('laura@gmail.com', 'clave1234');
      expect(await s.toggleFavorite('guide:plato'), isTrue);
      await s.addCraving(CravingEntry(emotion: EmotionId.antojo, at: now, strategies: [1]));
      final again = make();
      await again.load();
      expect(again.isFavorite('guide:plato'), isTrue);
      expect(again.cravings.single.emotion, EmotionId.antojo);
      expect(await again.toggleFavorite('guide:plato'), isFalse);
    });
  });

  group('Cuentas y registro de comidas', () {
    late MemoryStore store;
    final now = DateTime(2026, 10, 9, 10);
    AppState make() => AppState(store, clock: () => now);
    setUp(() => store = MemoryStore());

    test('registro, cierre e inicio de sesión con correo', () async {
      final s = make();
      await s.load();
      await s.register('Diego@Gmail.com', 'clave1234');
      expect(s.account, 'diego@gmail.com');
      await s.saveProfile(UserProfile(name: 'Diego', age: 22, sex: Sex.male, activity: ActivityLevel.light,
          goal: Goal.eatBetter, createdAt: now));
      await s.saveTestResult(TestResult(score: 50, areaScores: const {}, answers: const [], takenAt: now));
      await s.logIn();
      await s.toggleHabit(s.today, HabitId.water);
      await s.logOut();
      expect(s.loggedIn, isFalse);
      expect(s.profile, isNull);

      final again = make();
      await again.load();
      expect(again.loggedIn, isFalse);
      await expectLater(again.signIn('diego@gmail.com', 'otra1234'), throwsA(isA<AuthException>()));
      await expectLater(again.signIn('nadie@gmail.com', 'clave1234'), throwsA(isA<AuthException>()));
      await again.signIn(' DIEGO@gmail.com ', 'clave1234');
      expect(again.loggedIn, isTrue);
      expect(again.profile!.firstName, 'Diego');
      expect(again.completedOn(again.today), 1);
      await expectLater(again.register('diego@gmail.com', 'clave1234'), throwsA(isA<AuthException>()));
    });

    test('las comidas se marcan por casilla', () async {
      final s = make();
      await s.load();
      await s.register('a@gmail.com', 'clave1234');
      expect(await s.toggleSlot(s.today, HabitId.meals, 2), isFalse); // solo cena
      var d = s.dayOf(s.today, HabitId.meals);
      expect(d.progress, 1);
      expect(d.hasSlot(0), isFalse);
      expect(d.completed, isFalse);
      await s.toggleSlot(s.today, HabitId.meals, 0);
      expect(await s.toggleSlot(s.today, HabitId.meals, 1), isTrue);
      expect(s.dayOf(s.today, HabitId.meals).completed, isTrue);
      await s.toggleSlot(s.today, HabitId.meals, 1);
      d = s.dayOf(s.today, HabitId.meals);
      expect(d.completed, isFalse);
      expect(d.progress, 2);
    });

    test('marcar como hecho llena el registro y desmarcar lo baja', () async {
      final s = make();
      await s.load();
      await s.register('a@gmail.com', 'clave1234');
      await s.setCompleted(s.today, HabitId.water, true);
      expect(s.dayOf(s.today, HabitId.water).progress, 8);
      await s.setCompleted(s.today, HabitId.water, false);
      expect(s.dayOf(s.today, HabitId.water).progress, 7);
      expect(s.dayOf(s.today, HabitId.water).completed, isFalse);
    });

    test('los datos sin cuenta pasan a la primera cuenta', () async {
      await store.writeJson('profile', UserProfile(name: 'Diego', age: 22, sex: Sex.male,
          activity: ActivityLevel.light, goal: Goal.eatBetter, createdAt: now).toJson());
      await store.writeJson('test', TestResult(score: 50, areaScores: const {}, answers: const [], takenAt: now).toJson());
      final s = make();
      await s.load();
      expect(s.hasLegacyData, isTrue);
      await s.register('diego@gmail.com', 'clave1234');
      expect(s.hasAccount, isTrue);
      expect(s.profile!.name, 'Diego');
      expect(await store.readJson('profile'), isNull);
    });
  });

  test('búsqueda de guías ignora tildes', () {
    expect(searchGuides('hidratacion').map((g) => g.id), contains('hidratacion'));
    expect(searchGuides('arepa').isNotEmpty, isTrue);
    expect(searchGuides('zzz'), isEmpty);
  });

  test('semana empieza el lunes', () {
    expect(Dates.weekStart(DateTime(2026, 10, 9)).weekday, DateTime.monday);
  });
}
