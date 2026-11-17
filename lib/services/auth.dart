import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Utilidades de cuentas locales (correo + contraseña).
///
/// La contraseña nunca se guarda: se guarda un hash HMAC-SHA256 iterado con una
/// sal aleatoria por cuenta. Las cuentas viven en el dispositivo; para iniciar
/// sesión con Google o desde varios dispositivos hace falta un servicio en la
/// nube (ver docs/PENDIENTES.md).
abstract final class Auth {
  static const _iterations = 20000;

  static String newSalt() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static String hash(String password, String salt) {
    final key = utf8.encode(salt);
    var digest = Hmac(sha256, key).convert(utf8.encode(password)).bytes;
    for (var i = 1; i < _iterations; i++) {
      digest = Hmac(sha256, key).convert(digest).bytes;
    }
    return base64UrlEncode(digest);
  }

  /// Compara en tiempo constante.
  static bool matches(String password, String salt, String expected) {
    final a = hash(password, salt), b = expected;
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static String normalize(String email) => email.trim().toLowerCase();

  static final _emailRe = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');

  static String? emailError(String email) {
    final e = normalize(email);
    if (e.isEmpty) return 'Escribe tu correo electrónico.';
    if (!_emailRe.hasMatch(e)) return 'Revisa el correo, por ejemplo: nombre@gmail.com';
    return null;
  }

  static String? passwordError(String password) {
    if (password.isEmpty) return 'Escribe una contraseña.';
    if (password.length < 8) return 'Usa al menos 8 caracteres.';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) || !RegExp(r'\d').hasMatch(password)) {
      return 'Combina letras y números.';
    }
    return null;
  }
}

/// Error de inicio de sesión o registro con un mensaje para la persona.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
