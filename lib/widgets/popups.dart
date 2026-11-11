import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/dates.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';
import '../state/app_state.dart';
import 'common.dart';
import 'proa_button.dart';

/// Contenedor de las ventanas emergentes centradas de Figma.
class _PopupCard extends StatelessWidget {
  const _PopupCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: Shadows.elevated),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
                child: child,
              ),
            ),
          ),
        ),
      );
}

Future<T?> _showPopup<T>(BuildContext context, Widget child) => showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: const Color(0x8C0F172A),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => child,
      transitionBuilder: (_, a, _, c) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: c),
      ),
    );

/// «¡Hábito completado!». Devuelve true si eligió «Volver a mi plan».
Future<bool> showHabitCompleted(BuildContext context, {required int done, required int total, required int streak}) async {
  final r = await _showPopup<bool>(
    context,
    _PopupCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            shape: BoxShape.circle,
            boxShadow: Shadows.colored(),
          ),
          child: const Icon(LucideIcons.check, color: AppColors.white, size: 32),
        ),
        const SizedBox(height: 18),
        Text('¡Hábito completado!', style: AppText.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Cada pequeño paso cuenta. Ya llevas $done de $total hábitos hoy.',
            style: AppText.inter(13.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center),
        if (streak > 0) ...[
          const SizedBox(height: 14),
          Pill('¡Racha de $streak ${streak == 1 ? 'día' : 'días'}!', icon: LucideIcons.flame, fg: AppColors.orange, bg: AppColors.warmBg, fontSize: 12),
        ],
        const SizedBox(height: 20),
        ProaButton('Volver a mi plan', height: 50, onPressed: () => Navigator.of(context).pop(true)),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Seguir aquí', style: AppText.inter(13.5, FontWeight.w600, color: const Color(0xFF374151))),
        ),
      ]),
    ),
  );
  return r ?? false;
}

/// Confirmación para cerrar sesión. Devuelve true si eligió «Salir».
Future<bool> showLogoutConfirm(BuildContext context) async {
  final r = await _showPopup<bool>(
    context,
    _PopupCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
          child: const Icon(LucideIcons.logOut, color: AppColors.danger, size: 24),
        ),
        const SizedBox(height: 14),
        Text('¿Cerrar sesión?', style: AppText.outfit(20, FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Tu progreso queda guardado. Puedes volver cuando quieras.',
            style: AppText.inter(13, FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: ProaButton('Cancelar', kind: ProaButtonKind.dark, height: 46, onPressed: () => Navigator.of(context).pop(false))),
          const SizedBox(width: 10),
          Expanded(
            child: _DangerButton(onTap: () => Navigator.of(context).pop(true)),
          ),
        ]),
      ]),
    ),
  );
  return r ?? false;
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.danger,
        borderRadius: Radii.rButton,
        child: InkWell(
          borderRadius: Radii.rButton,
          onTap: onTap,
          child: SizedBox(height: 46, child: Center(child: Text('Salir', style: AppText.button))),
        ),
      );
}

/// Confirmación genérica con el mismo estilo (borrar datos, etc.).
Future<bool> showConfirm(BuildContext context,
    {required IconData icon, required String title, required String message, required String confirm, Color color = AppColors.danger}) async {
  final r = await _showPopup<bool>(
    context,
    _PopupCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 14),
        Text(title, style: AppText.outfit(20, FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: AppText.inter(13, FontWeight.w400, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: ProaButton('Cancelar', kind: ProaButtonKind.dark, height: 46, onPressed: () => Navigator.of(context).pop(false))),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: color,
              borderRadius: Radii.rButton,
              child: InkWell(
                borderRadius: Radii.rButton,
                onTap: () => Navigator.of(context).pop(true),
                child: SizedBox(height: 46, child: Center(child: Text(confirm, style: AppText.button.copyWith(fontSize: 15)))),
              ),
            ),
          ),
        ]),
      ]),
    ),
  );
  return r ?? false;
}

// ------------------------------------------------------------------ toasts
OverlayEntry? _currentToast;

/// Aviso oscuro inferior de Figma («Momento registrado», «Guardado»).
void showProaToast(BuildContext context,
    {required String title, required String message, IconData icon = LucideIcons.check, Color iconBg = AppColors.green, double bottomOffset = 96}) {
  _currentToast?.remove();
  _currentToast = null;
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _Toast(
      title: title,
      message: message,
      icon: icon,
      iconBg: iconBg,
      bottom: bottomOffset + MediaQuery.paddingOf(ctx).bottom,
      onDone: () {
        if (_currentToast == entry) {
          entry.remove();
          _currentToast = null;
        }
      },
    ),
  );
  _currentToast = entry;
  overlay.insert(entry);
}

/// Aviso de error real (p. ej. si falla el guardado local).
void showErrorToast(BuildContext context, [String message = 'Inténtalo de nuevo en un momento.']) =>
    showProaToast(context, title: 'No se pudo guardar', message: message, icon: LucideIcons.x, iconBg: AppColors.orange);

class _Toast extends StatefulWidget {
  const _Toast({required this.title, required this.message, required this.icon, required this.iconBg, required this.bottom, required this.onDone});
  final String title, message;
  final IconData icon;
  final Color iconBg;
  final double bottom;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 240))..forward();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: 16,
        right: 16,
        bottom: widget.bottom,
        child: FadeTransition(
          opacity: _c,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16), boxShadow: Shadows.elevated),
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: widget.iconBg, shape: BoxShape.circle),
                    child: Icon(widget.icon, size: 16, color: AppColors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.title, style: AppText.outfit(15, FontWeight.w600, color: AppColors.white)),
                      const SizedBox(height: 2),
                      Text(widget.message, style: AppText.inter(12, FontWeight.w400, color: const Color(0xFFD1D5DB), height: 1.35)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

// --------------------------------------------------- panel de notificaciones
Future<String?> showNotificationsSheet(BuildContext context, AppState state) {
  final items = state.notifications;
  state.markNotificationsRead().catchError((_) {});
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C0F172A),
    builder: (ctx) => Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.72),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.header)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(ctx).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: Radii.rPill)),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text('Notificaciones', style: AppText.outfit(19, FontWeight.w700))),
          CircleIconButton(LucideIcons.x, size: 32, bg: AppColors.surfaceMuted, semantic: 'Cerrar', onTap: () => Navigator.of(ctx).pop()),
        ]),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text('No tienes notificaciones por ahora.', textAlign: TextAlign.center, style: AppText.secondary),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationTile(items[i], onTap: () => Navigator.of(ctx).pop(items[i].kind)),
            ),
          ),
      ]),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.n, {required this.onTap});
  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color fg, Color iconBg, Color bg) = switch (n.kind) {
      'water' => (LucideIcons.droplet, AppColors.turquoise, AppColors.white, AppColors.infoSofter),
      'guide' => (LucideIcons.bookOpen, AppColors.green, AppColors.white, AppColors.greenSofter),
      'streak' => (LucideIcons.flame, AppColors.orange, AppColors.warmBg, AppColors.white),
      _ => (LucideIcons.moon, AppColors.violet, AppColors.violetSoft, AppColors.white),
    };
    return ProaCard(
      color: bg,
      onTap: onTap,
      radius: BorderRadius.circular(16),
      border: Border.all(color: bg == AppColors.white ? AppColors.border : Colors.transparent),
      shadow: null,
      padding: const EdgeInsets.all(12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBox(icon, color: fg, bg: iconBg, size: 36, iconSize: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(n.title, style: AppText.inter(13.5, FontWeight.w700))),
              Text(Dates.relative(n.at), style: AppText.caption.copyWith(color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 2),
            Text(n.body, style: AppText.inter(12, FontWeight.w400, color: AppColors.textSecondary, height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}
