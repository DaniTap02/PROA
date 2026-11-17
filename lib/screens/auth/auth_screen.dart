import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../services/auth.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/popups.dart';
import '../../widgets/proa_button.dart';
import '../../widgets/proa_text_field.dart';
import '../onboarding/create_profile_screen.dart';

enum AuthMode { register, login }

/// «Crea tu cuenta» / «Inicia sesión» con correo electrónico y contraseña.
/// Sigue el sistema visual de «Crear perfil».
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.mode = AuthMode.register});
  final AuthMode mode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode = widget.mode;
  late final _email = TextEditingController(text: context.read<AppState>().lastEmail ?? '');
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _showErrors = false;
  bool _busy = false;
  String? _serverError;

  bool get _register => _mode == AuthMode.register;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _emailError => Auth.emailError(_email.text);
  String? get _passwordError =>
      _register ? Auth.passwordError(_password.text) : (_password.text.isEmpty ? 'Escribe tu contraseña.' : null);
  String? get _confirmError =>
      !_register ? null : (_confirm.text != _password.text ? 'Las contraseñas no coinciden.' : null);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showErrors = true;
      _serverError = null;
    });
    if (_emailError != null || _passwordError != null || _confirmError != null) return;
    setState(() => _busy = true);
    final s = context.read<AppState>();
    final nav = Navigator.of(context);
    try {
      if (_register) {
        await s.register(_email.text, _password.text);
        // Datos de una versión anterior: ya tienen perfil y test.
        if (s.hasAccount) await s.logIn();
      } else {
        await s.signIn(_email.text, _password.text);
      }
      if (!mounted) return;
      if (s.loggedIn) {
        // La cuenta ya terminó el primer ingreso: abre la app principal.
        nav.popUntil((r) => r.isFirst);
      } else {
        nav.pushReplacement(MaterialPageRoute(builder: (_) => const CreateProfileScreen()));
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = e.message);
    } catch (_) {
      if (mounted) showErrorToast(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final e = _showErrors;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 8, Gap.screen, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AutofillGroup(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const BackCircle(),
                const SizedBox(height: 22),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(LucideIcons.leaf, color: AppColors.white, size: 24),
                ),
                const SizedBox(height: 18),
                Text(_register ? 'Crea tu cuenta' : 'Inicia sesión', style: AppText.h1),
                const SizedBox(height: 4),
                Text(
                  _register
                      ? 'Usa tu correo (por ejemplo, de Gmail) para guardar tu progreso.'
                      : 'Entra con el correo y la contraseña de tu cuenta PROA.',
                  style: AppText.secondary,
                ),
                if (_register && context.watch<AppState>().hasLegacyData) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.greenSofter, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.greenSoft)),
                    child: Row(children: [
                      const Icon(LucideIcons.sparkles, size: 16, color: AppColors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Ya tienes progreso guardado en este dispositivo. Crea tu cuenta y lo conservarás.',
                            style: AppText.inter(12.5, FontWeight.w500, color: AppColors.greenDark, height: 1.4)),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
                const FieldLabel('Correo electrónico'),
                ProaTextField(
                  controller: _email,
                  hint: 'nombre@gmail.com',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  maxLength: 80,
                  errorText: e ? _emailError : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                const FieldLabel('Contraseña'),
                ProaTextField(
                  controller: _password,
                  hint: _register ? 'Mínimo 8 caracteres, letras y números' : 'Tu contraseña',
                  icon: LucideIcons.lock,
                  obscureText: !_show,
                  maxLength: 64,
                  textInputAction: _register ? TextInputAction.next : TextInputAction.done,
                  autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                  errorText: e ? _passwordError : null,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _register ? null : (_) => _submit(),
                  trailing: GestureDetector(
                    onTap: () => setState(() => _show = !_show),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(_show ? LucideIcons.eyeOff : LucideIcons.eye, size: 18, color: AppColors.textMuted),
                    ),
                  ),
                ),
                if (_register) ...[
                  const SizedBox(height: 16),
                  const FieldLabel('Confirma tu contraseña'),
                  ProaTextField(
                    controller: _confirm,
                    hint: 'Repite la contraseña',
                    icon: LucideIcons.lock,
                    obscureText: !_show,
                    maxLength: 64,
                    textInputAction: TextInputAction.done,
                    errorText: e ? _confirmError : null,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                  ),
                ],
                if (_serverError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.warmSofter, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFED7AA))),
                    child: Row(children: [
                      const Icon(LucideIcons.info, size: 16, color: AppColors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_serverError!, style: AppText.inter(13, FontWeight.w500, color: const Color(0xFF9A3412)))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Tu cuenta y tus datos se guardan solo en este dispositivo. La contraseña se guarda cifrada.',
                        style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted, height: 1.45)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(Gap.screen, 8, Gap.screen, pad.bottom + 8),
          child: Column(children: [
            ProaButton(_register ? 'Crear cuenta' : 'Iniciar sesión', arrow: true, loading: _busy, onPressed: _submit),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _mode = _register ? AuthMode.login : AuthMode.register;
                        _showErrors = false;
                        _serverError = null;
                        _confirm.clear();
                      }),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: _register ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
                    style: AppText.inter(13, FontWeight.w400, color: AppColors.textSecondary)),
                TextSpan(
                    text: _register ? 'Inicia sesión' : 'Créala aquí',
                    style: AppText.inter(13, FontWeight.w700, color: AppColors.green)),
              ])),
            ),
          ]),
        ),
      ]),
    );
  }
}
