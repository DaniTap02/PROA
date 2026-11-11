import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/dates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/popups.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/help_screen.dart';
import '../profile/my_habits_screen.dart';
import '../profile/privacy_screen.dart';
import '../profile/reminders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  Future<void> _logout(BuildContext context) async {
    if (!await showLogoutConfirm(context)) return;
    if (!context.mounted) return;
    try {
      ProaApp.navigatorKey.currentState?.popUntil((r) => r.isFirst);
      await context.read<AppState>().logOut();
    } catch (_) {
      if (context.mounted) showErrorToast(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.profile;
    if (p == null) return const SizedBox.shrink();
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ListView(
          padding: EdgeInsets.only(bottom: pad.bottom + 20),
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(Radii.header)),
              ),
              child: Stack(children: [
                Positioned(
                  right: -60,
                  top: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withValues(alpha: 0.07)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 10, Gap.screen, 22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Mi perfil', style: AppText.outfit(18, FontWeight.w600, color: AppColors.white))),
                      CircleIconButton(LucideIcons.slidersHorizontal,
                          size: 38,
                          semantic: 'Editar perfil',
                          color: AppColors.white,
                          bg: AppColors.white.withValues(alpha: 0.18),
                          onTap: () => _push(context, const EditProfileScreen())),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      UserAvatar(profile: p, size: 74, border: AppColors.white.withValues(alpha: 0.9)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: AppText.outfit(24, FontWeight.w700, color: AppColors.white, height: 1.1)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(LucideIcons.mapPin, size: 12, color: AppColors.white.withValues(alpha: 0.85)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text('${p.age} años · ${p.city}',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.inter(12, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85))),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Pill('Objetivo: ${p.goal.short}',
                              icon: LucideIcons.target, fg: AppColors.white, bg: AppColors.white.withValues(alpha: 0.18), fontSize: 10.5),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      _HeaderStat('${s.weekActiveDays}', 'Días activos'),
                      const SizedBox(width: 8),
                      _HeaderStat('${s.completedOn(s.today)}/${s.plan.length}', 'Hoy'),
                      const SizedBox(width: 8),
                      _HeaderStat('${s.weekPct}%', 'Semana'),
                    ]),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 16, Gap.screen, 0),
              child: Column(children: [
                ProaCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Información del perfil', style: AppText.inter(14, FontWeight.w700)),
                    const SizedBox(height: 10),
                    _InfoRow(LucideIcons.activity, 'Nivel de actividad', p.activity.label),
                    _InfoRow(LucideIcons.target, 'Objetivo', p.goal.label),
                    _InfoRow(LucideIcons.calendar, 'Miembro desde', Dates.monthYear(p.createdAt)),
                  ]),
                ),
                const SizedBox(height: 12),
                ProaCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    _MenuRow(LucideIcons.pencil, 'Editar perfil', 'Actualiza tu información', AppColors.textSecondary, AppColors.surfaceMuted,
                        () => _push(context, const EditProfileScreen())),
                    const RowDivider(),
                    _MenuRow(LucideIcons.leaf, 'Mis hábitos', 'Ver y gestionar hábitos', AppColors.green, AppColors.greenSoft,
                        () => _push(context, const MyHabitsScreen())),
                    const RowDivider(),
                    _MenuRow(LucideIcons.bell, 'Recordatorios', 'Configura tus notificaciones', AppColors.amber, AppColors.warmBg,
                        () => _push(context, const RemindersScreen())),
                    const RowDivider(),
                    _MenuRow(LucideIcons.lock, 'Privacidad', 'Gestión de datos', AppColors.violet, AppColors.violetSoft,
                        () => _push(context, const PrivacyScreen())),
                    const RowDivider(),
                    _MenuRow(LucideIcons.circleQuestionMark, 'Ayuda', 'Preguntas frecuentes', AppColors.turquoise, AppColors.infoBg,
                        () => _push(context, const HelpScreen())),
                  ]),
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.dangerSoft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _logout(context),
                    child: SizedBox(
                      height: 52,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(LucideIcons.logOut, size: 18, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Text('Cerrar sesión', style: AppText.inter(14.5, FontWeight.w600, color: AppColors.danger)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('PROA · Herramienta educativa. No reemplaza consulta médica.',
                    textAlign: TextAlign.center, style: AppText.caption.copyWith(color: AppColors.textMuted)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Text(value, style: AppText.outfit(20, FontWeight.w700, color: AppColors.white)),
            Text(label, style: AppText.inter(10.5, FontWeight.w400, color: AppColors.white.withValues(alpha: 0.85))),
          ]),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: AppText.inter(12.5, FontWeight.w400, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppText.inter(12.5, FontWeight.w700, color: AppColors.text)),
          ),
        ]),
      );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.title, this.subtitle, this.color, this.bg, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color, bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: Radii.rCard,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            IconBox(icon, color: color, bg: bg, size: 38, iconSize: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.inter(14, FontWeight.w600, color: AppColors.text)),
                Text(subtitle, style: AppText.inter(11.5, FontWeight.w400, color: AppColors.textMuted)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, size: 17, color: Color(0xFFD1D5DB)),
          ]),
        ),
      );
}
