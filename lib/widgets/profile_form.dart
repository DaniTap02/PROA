import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text.dart';
import '../models/user_profile.dart';
import 'common.dart';
import 'proa_text_field.dart';

/// Valores del formulario de perfil (crear y editar).
class ProfileDraft {
  ProfileDraft({String name = '', int? age, this.sex, this.activity, this.goal})
      : nameCtrl = TextEditingController(text: name),
        ageCtrl = TextEditingController(text: age?.toString() ?? '');

  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  Sex? sex;
  ActivityLevel? activity;
  Goal? goal;

  factory ProfileDraft.from(UserProfile p) =>
      ProfileDraft(name: p.name, age: p.age, sex: p.sex, activity: p.activity, goal: p.goal);

  int? get age => int.tryParse(ageCtrl.text.trim());

  String? get nameError {
    final n = nameCtrl.text.trim();
    if (n.isEmpty) return 'Escribe tu nombre.';
    if (n.length < 2) return 'El nombre debe tener al menos 2 letras.';
    if (!RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' ]+$").hasMatch(n)) return 'Usa solo letras y espacios.';
    return null;
  }

  /// PROA está dirigida a personas adultas (18 años o más).
  String? get ageError {
    final a = age;
    if (ageCtrl.text.trim().isEmpty) return 'Escribe tu edad.';
    if (a == null) return 'Escribe tu edad en números.';
    if (a < 18) return 'PROA está pensada para personas de 18 años o más.';
    if (a > 100) return 'Revisa tu edad.';
    return null;
  }

  String? get sexError => sex == null ? 'Elige una opción.' : null;
  String? get activityError => activity == null ? 'Elige tu nivel de actividad.' : null;
  String? get goalError => goal == null ? 'Elige tu objetivo principal.' : null;

  bool get isValid =>
      nameError == null && ageError == null && sexError == null && activityError == null && goalError == null;

  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
  }
}

/// Campos del perfil tal como en «Crear perfil» de Figma.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.draft, required this.showErrors, this.onChanged});
  final ProfileDraft draft;
  final bool showErrors;
  final VoidCallback? onChanged;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  ProfileDraft get d => widget.draft;

  void _set(VoidCallback f) {
    setState(f);
    widget.onChanged?.call();
  }

  Future<void> _pickSex() async {
    final r = await showModalBottomSheet<Sex>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.header))),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: Radii.rPill))),
          const SizedBox(height: 14),
          Text('Sexo', style: AppText.outfit(19, FontWeight.w700)),
          const SizedBox(height: 8),
          for (final s in Sex.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(s.label, style: AppText.paragraphStrong),
              trailing: d.sex == s ? const Icon(LucideIcons.check, color: AppColors.green) : null,
              onTap: () => Navigator.of(ctx).pop(s),
            ),
        ]),
      ),
    );
    if (r != null) _set(() => d.sex = r);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.showErrors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FieldLabel('Tu nombre'),
      ProaTextField(
        controller: d.nameCtrl,
        hint: 'Tu nombre',
        icon: LucideIcons.user,
        maxLength: 40,
        textInputAction: TextInputAction.next,
        errorText: e ? d.nameError : null,
        onChanged: (_) => _set(() {}),
      ),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('Edad'),
            ProaTextField(
              controller: d.ageCtrl,
              hint: 'Edad',
              icon: LucideIcons.calendar,
              suffix: ' años',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              errorText: e ? d.ageError : null,
              onChanged: (_) => _set(() {}),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('Sexo'),
            _SelectBox(
              icon: LucideIcons.user,
              text: d.sex?.label,
              hint: 'Elegir',
              error: e && d.sexError != null,
              onTap: _pickSex,
            ),
            if (e && d.sexError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(d.sexError!, style: AppText.inter(12, FontWeight.w500, color: AppColors.orange)),
              ),
          ]),
        ),
      ]),
      const SizedBox(height: 20),
      const FieldLabel('Nivel de actividad física'),
      GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: [
          for (final a in ActivityLevel.values)
            _ActivityCard(level: a, selected: d.activity == a, onTap: () => _set(() => d.activity = a)),
        ],
      ),
      if (e && d.activityError != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(d.activityError!, style: AppText.inter(12, FontWeight.w500, color: AppColors.orange)),
        ),
      const SizedBox(height: 20),
      const FieldLabel('Objetivo principal'),
      ProaCard(
        padding: EdgeInsets.zero,
        border: e && d.goalError != null ? Border.all(color: AppColors.orange) : null,
        child: Column(children: [
          for (final g in Goal.values) ...[
            if (g.index > 0) const RowDivider(),
            _GoalRow(goal: g, selected: d.goal == g, onTap: () => _set(() => d.goal = g)),
          ],
        ]),
      ),
      if (e && d.goalError != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(d.goalError!, style: AppText.inter(12, FontWeight.w500, color: AppColors.orange)),
        ),
    ]);
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.icon, required this.text, required this.hint, required this.onTap, this.error = false});
  final IconData icon;
  final String? text;
  final String hint;
  final VoidCallback onTap;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final active = text != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.white : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(Radii.icon),
          border: Border.all(color: error ? AppColors.orange : AppColors.border, width: error ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, size: 17, color: active ? AppColors.textSecondary : AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text ?? hint,
                overflow: TextOverflow.ellipsis,
                style: AppText.inter(14.5, active ? FontWeight.w500 : FontWeight.w400, color: active ? AppColors.text : AppColors.textMuted)),
          ),
          const Icon(LucideIcons.chevronDown, size: 17, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

const _activityIcons = {
  ActivityLevel.sedentary: LucideIcons.sofa,
  ActivityLevel.light: LucideIcons.bike,
  ActivityLevel.moderate: LucideIcons.activity,
  ActivityLevel.active: LucideIcons.dumbbell,
};

const goalIcons = {
  Goal.eatBetter: LucideIcons.utensils,
  Goal.moveMore: LucideIcons.footprints,
  Goal.healthyRoutine: LucideIcons.sprout,
  Goal.sleepBetter: LucideIcons.moon,
};

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.level, required this.selected, required this.onTap});
  final ActivityLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? AppColors.greenSofter : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.green : AppColors.border, width: selected ? 1.6 : 1),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconBox(_activityIcons[level]!,
                    color: selected ? AppColors.white : AppColors.textSecondary,
                    bg: selected ? AppColors.green : AppColors.surfaceMuted,
                    size: 32,
                    iconSize: 16,
                    radius: 10),
                const Spacer(),
                if (selected) const Icon(LucideIcons.check, size: 16, color: AppColors.green),
              ]),
              const Spacer(),
              Text(level.label, style: AppText.inter(14, FontWeight.w700, color: selected ? AppColors.greenDark : AppColors.text)),
              const SizedBox(height: 1),
              Text(level.hint, style: AppText.inter(11, FontWeight.w400, color: AppColors.textMuted)),
            ]),
          ),
        ),
      );
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.selected, required this.onTap});
  final Goal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Icon(goalIcons[goal], size: 18, color: selected ? AppColors.green : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(goal.label, style: AppText.inter(14, FontWeight.w600, color: selected ? AppColors.greenDark : AppColors.text))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.green : const Color(0xFFD1D5DB), width: selected ? 6 : 1.6),
              ),
            ),
          ]),
        ),
      );
}
