import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Contrato de almacenamiento. La app no depende de SharedPreferences
/// directamente: para integrar un backend en el futuro basta con otra
/// implementación de [LocalStore] (p. ej. una API REST).
abstract interface class LocalStore {
  Future<Map<String, dynamic>?> readJson(String key);
  Future<void> writeJson(String key, Object value);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPrefsStore implements LocalStore {
  SharedPrefsStore._(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'proa.';

  static Future<SharedPrefsStore> create() async =>
      SharedPrefsStore._(await SharedPreferences.getInstance());

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> writeJson(String key, Object value) async {
    final ok = await _prefs.setString('$_prefix$key', jsonEncode(value));
    if (!ok) throw StateError('No se pudo guardar "$key"');
  }

  @override
  Future<void> remove(String key) => _prefs.remove('$_prefix$key');

  @override
  Future<void> clear() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await _prefs.remove(k);
    }
  }
}

/// Almacén en memoria para pruebas.
class MemoryStore implements LocalStore {
  final Map<String, String> _data = {};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async =>
      _data[key] == null ? null : jsonDecode(_data[key]!) as Map<String, dynamic>;

  @override
  Future<void> writeJson(String key, Object value) async =>
      _data[key] = jsonEncode(value);

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}
