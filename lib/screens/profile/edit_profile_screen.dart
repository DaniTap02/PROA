import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/app_state.dart';
import '../../widgets/avatar.dart';
import '../../widgets/popups.dart';
import '../../widgets/profile_form.dart';
import '../../widgets/proa_button.dart';
import '../../widgets/proa_text_field.dart';
import 'sub_screen.dart';

/// Edición del perfil: foto, datos personales, actividad y objetivo.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileDraft _d;
  late final TextEditingController _city;
  late String _photo;
  bool _showErrors = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile!;
    _d = ProfileDraft.from(p);
    _city = TextEditingController(text: p.city);
    _photo = p.photoPath ?? UserAvatar.noPhoto;
  }

  @override
  void dispose() {
    _d.dispose();
    _city.dispose();
    super.dispose();
  }

  String? get _cityError => _city.text.trim().length < 2 ? 'Escribe tu ciudad o país.' : null;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_d.isValid || _cityError != null) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _saving = true);
    final s = context.read<AppState>();
    try {
      await s.saveProfile(s.profile!.copyWith(
        name: _d.nameCtrl.text.trim(),
        age: _d.age,
        sex: _d.sex,
        activity: _d.activity,
        goal: _d.goal,
        city: _city.text.trim(),
        photoPath: _photo,
      ));
      if (!mounted) return;
      showProaToast(context, title: 'Perfil actualizado', message: 'Guardamos tus cambios.');
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showErrorToast(context);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().profile!;
    final preview = p.copyWith(name: _d.nameCtrl.text.isEmpty ? p.name : _d.nameCtrl.text, photoPath: _photo);
    return SubScreen(
      title: 'Editar perfil',
      subtitle: 'Actualiza tu información cuando quieras.',
      bottom: ProaButton('Guardar cambios', leading: LucideIcons.check, loading: _saving, onPressed: _save),
      children: [
        Center(
          child: Column(children: [
            UserAvatar(profile: preview, size: 92, border: AppColors.white),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              _PhotoChoice(label: 'Iniciales', selected: _photo == UserAvatar.noPhoto, onTap: () => setState(() => _photo = UserAvatar.noPhoto)),
              _PhotoChoice(label: 'Foto ilustrativa', selected: _photo == Img.avatar, onTap: () => setState(() => _photo = Img.avatar)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        ProfileForm(draft: _d, showErrors: _showErrors, onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        const FieldLabel('Ciudad o país'),
        ProaTextField(
          controller: _city,
          hint: 'Ciudad o país',
          icon: LucideIcons.mapPin,
          maxLength: 40,
          errorText: _showErrors ? _cityError : null,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenSoft : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.green : AppColors.border),
          ),
          child: Text(label, style: AppText.inter(12, FontWeight.w600, color: selected ? AppColors.greenDark : AppColors.textSecondary)),
        ),
      );
}
