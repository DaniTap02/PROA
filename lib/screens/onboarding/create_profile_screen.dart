import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/popups.dart';
import '../../widgets/profile_form.dart';
import '../../widgets/proa_button.dart';
import '../test/test_screen.dart';

/// «Cuéntanos sobre ti» — Paso 1 de 2 (el paso 2 es el test).
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  late final ProfileDraft _d;
  bool _showErrors = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().profile;
    _d = existing == null ? ProfileDraft() : ProfileDraft.from(existing);
  }

  @override
  void dispose() {
    _d.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    if (!_d.isValid) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _saving = true);
    final s = context.read<AppState>();
    final p = (s.profile ??
            UserProfile(
              name: '',
              age: 0,
              sex: _d.sex!,
              activity: _d.activity!,
              goal: _d.goal!,
              createdAt: DateTime.now(),
            ))
        .copyWith(name: _d.nameCtrl.text.trim(), age: _d.age, sex: _d.sex, activity: _d.activity, goal: _d.goal);
    try {
      await s.saveProfile(p);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TestScreen()));
    } catch (_) {
      if (mounted) showErrorToast(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(Gap.screen, pad.top + 8, Gap.screen, 0),
          child: Row(children: [
            const BackCircle(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Paso 1 de 2', style: AppText.inter(11, FontWeight.w600, color: AppColors.green)),
                const SizedBox(height: 6),
                const ProgressBar(value: 0.5, height: 4),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 22, Gap.screen, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cuéntanos sobre ti', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Para personalizar tu experiencia en PROA.', style: AppText.secondary),
              const SizedBox(height: 22),
              ProfileForm(draft: _d, showErrors: _showErrors, onChanged: () => setState(() {})),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(Gap.screen, 8, Gap.screen, pad.bottom + 12),
          child: ProaButton('Continuar', arrow: true, loading: _saving, onPressed: _continue),
        ),
      ]),
    );
  }
}
