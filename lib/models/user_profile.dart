enum Sex { female, male, other }

extension SexLabel on Sex {
  String get label => switch (this) {
        Sex.female => 'Femenino',
        Sex.male => 'Masculino',
        Sex.other => 'Prefiero no decir',
      };
}

enum ActivityLevel { sedentary, light, moderate, active }

extension ActivityLevelLabel on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentario',
        ActivityLevel.light => 'Ligero',
        ActivityLevel.moderate => 'Moderado',
        ActivityLevel.active => 'Activo',
      };
  String get hint => switch (this) {
        ActivityLevel.sedentary => 'Poco o ningún ejercicio',
        ActivityLevel.light => '1-2 días/semana',
        ActivityLevel.moderate => '3-4 días/semana',
        ActivityLevel.active => '5+ días/semana',
      };
}

enum Goal { eatBetter, moveMore, healthyRoutine, sleepBetter }

extension GoalLabel on Goal {
  String get label => switch (this) {
        Goal.eatBetter => 'Mejorar mi alimentación',
        Goal.moveMore => 'Moverme más',
        Goal.healthyRoutine => 'Crear una rutina saludable',
        Goal.sleepBetter => 'Dormir y descansar mejor',
      };
  String get short => switch (this) {
        Goal.eatBetter => 'mejor alimentación',
        Goal.moveMore => 'moverme más',
        Goal.healthyRoutine => 'rutina saludable',
        Goal.sleepBetter => 'mejor descanso',
      };
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.activity,
    required this.goal,
    required this.createdAt,
    this.city = 'Colombia',
    this.photoPath,
  });

  final String name;
  final int age;
  final Sex sex;
  final ActivityLevel activity;
  final Goal goal;
  final DateTime createdAt;
  final String city;

  /// Ruta de un recurso del paquete (assets/...) usado como foto de perfil.
  final String? photoPath;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  UserProfile copyWith({
    String? name,
    int? age,
    Sex? sex,
    ActivityLevel? activity,
    Goal? goal,
    String? city,
    String? photoPath,
  }) =>
      UserProfile(
        name: name ?? this.name,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        activity: activity ?? this.activity,
        goal: goal ?? this.goal,
        createdAt: createdAt,
        city: city ?? this.city,
        photoPath: photoPath ?? this.photoPath,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'sex': sex.name,
        'activity': activity.name,
        'goal': goal.name,
        'createdAt': createdAt.toIso8601String(),
        'city': city,
        'photoPath': photoPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String,
        age: j['age'] as int,
        sex: Sex.values.byName(j['sex'] as String),
        activity: ActivityLevel.values.byName(j['activity'] as String),
        goal: Goal.values.byName(j['goal'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        city: (j['city'] as String?) ?? 'Colombia',
        photoPath: j['photoPath'] as String?,
      );
}
