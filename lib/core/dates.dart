/// Utilidades de fecha en español (sin depender de intl).
abstract final class Dates {
  static const weekdaysShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const weekdaysAbbr = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const weekdays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];
  static const months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  static const monthsAbbr = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct',
    'nov', 'dic'
  ];

  static DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime today() => day(DateTime.now());

  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime parseKey(String k) => DateTime.parse(k);

  /// Lunes de la semana de [d].
  static DateTime weekStart(DateTime d) =>
      day(d).subtract(Duration(days: d.weekday - 1));

  static List<DateTime> weekOf(DateTime d) {
    final s = weekStart(d);
    return [for (var i = 0; i < 7; i++) DateTime(s.year, s.month, s.day + i)];
  }

  /// «Viernes 9 oct».
  static String chip(DateTime d) =>
      '${weekdays[d.weekday - 1]} ${d.day} ${monthsAbbr[d.month - 1]}';

  /// «VIERNES, 9 DE OCTUBRE».
  static String overline(DateTime d) =>
      '${weekdays[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]}'
          .toUpperCase();

  /// «Septiembre 2026».
  static String monthYear(DateTime d) {
    final m = months[d.month - 1];
    return '${m[0].toUpperCase()}${m.substring(1)} ${d.year}';
  }

  static String time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'a. m.' : 'p. m.'}';
  }

  static String greeting(DateTime d) => d.hour < 12
      ? 'Buenos días,'
      : d.hour < 19
          ? 'Buenas tardes,'
          : 'Buenas noches,';

  /// «Hace 5 min», «Hace 1 h», «Ayer», «3 oct».
  static String relative(DateTime at, [DateTime? now]) {
    now ??= DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (day(at) == day(now)) return 'Hace ${diff.inHours} h';
    if (day(at) == day(now).subtract(const Duration(days: 1))) return 'Ayer';
    return '${at.day} ${monthsAbbr[at.month - 1]}';
  }
}
