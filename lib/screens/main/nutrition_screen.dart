import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/guides_catalog.dart';
import '../../models/guide.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/controls.dart';
import '../../widgets/guide_card.dart';
import '../guides/guide_detail_screen.dart';
import '../../models/habit.dart';
import 'habit_actions.dart';
import 'plan_screen.dart';

String _fold(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[áà]'), 'a')
    .replaceAll(RegExp('[éè]'), 'e')
    .replaceAll(RegExp('[íì]'), 'i')
    .replaceAll(RegExp('[óò]'), 'o')
    .replaceAll(RegExp('[úùü]'), 'u');

/// Búsqueda en título, introducción y consejos (sin tildes ni mayúsculas).
List<Guide> searchGuides(String query, {GuideCategory? category, bool savedOnly = false, Set<String> saved = const {}}) {
  final q = _fold(query.trim());
  return guidesCatalog.where((g) {
    if (category != null && g.category != category) return false;
    if (savedOnly && !saved.contains('guide:${g.id}')) return false;
    if (q.isEmpty) return true;
    return _fold('${g.title} ${g.category.label} ${g.intro} ${g.tips.join(' ')}').contains(q);
  }).toList();
}

/// «Aprende a comer mejor»: buscador, filtros por categoría y guías.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _search = TextEditingController();
  GuideCategory? _cat;
  bool _savedOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Guide g) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g)));

  Future<void> _filters() async {
    final r = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.header))),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: Radii.rPill))),
          const SizedBox(height: 14),
          Text('Mostrar', style: AppText.outfit(19, FontWeight.w700)),
          const SizedBox(height: 8),
          for (final (v, label, icon) in [(false, 'Todas las guías', LucideIcons.bookOpen), (true, 'Solo guardadas', LucideIcons.bookmark)])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(icon, color: AppColors.green),
              title: Text(label, style: AppText.paragraphStrong),
              trailing: _savedOnly == v ? const Icon(LucideIcons.check, color: AppColors.green) : null,
              onTap: () => Navigator.of(ctx).pop(v),
            ),
        ]),
      ),
    );
    if (r != null) setState(() => _savedOnly = r);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pad = MediaQuery.paddingOf(context);
    final results = searchGuides(_search.text, category: _cat, savedOnly: _savedOnly, saved: s.favorites);
    final browsing = _search.text.trim().isEmpty && _cat == null && !_savedOnly;
    final featured = guidesCatalog.firstWhere((g) => g.featured);
    final grid = browsing ? guidesCatalog : results;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.only(top: pad.top + 12, bottom: pad.bottom + 20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Gap.screen),
            child: ScreenTitle(overline: 'Educación nutricional', title: 'Aprende a comer mejor'),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(LucideIcons.search, size: 17, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        cursorColor: AppColors.green,
                        style: AppText.inter(14, FontWeight.w500),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Buscar guías y consejos',
                          hintStyle: AppText.inter(14, FontWeight.w400, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    if (_search.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(_search.clear),
                        child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      ),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Filtros',
                child: Material(
                  color: _savedOnly ? AppColors.text : AppColors.fieldBg,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _filters,
                    child: SizedBox.square(
                      dimension: 46,
                      child: Icon(LucideIcons.funnel, size: 19, color: _savedOnly ? AppColors.white : AppColors.text),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
              children: [
                ProaFilterChip(label: 'Todas', selected: _cat == null, onTap: () => setState(() => _cat = null)),
                for (final c in GuideCategory.values) ...[
                  const SizedBox(width: 8),
                  ProaFilterChip(label: c.label, selected: _cat == c, onTap: () => setState(() => _cat = _cat == c ? null : c)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (browsing) ...[
                FeaturedGuideCard(guide: featured, onTap: () => _open(featured)),
                const SizedBox(height: 20),
              ],
              SectionHeader(
                browsing ? 'Todas las guías' : (_savedOnly ? 'Guías guardadas' : 'Resultados'),
                action: '${grid.length} ${grid.length == 1 ? 'guía' : 'guías'}',
              ),
              const SizedBox(height: 10),
              if (grid.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(children: [
                    const Icon(LucideIcons.searchX, size: 32, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    Text(_savedOnly ? 'Aún no has guardado guías.' : 'No encontramos guías con esa búsqueda.',
                        textAlign: TextAlign.center, style: AppText.secondary),
                  ]),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 172,
                  ),
                  itemCount: grid.length,
                  itemBuilder: (_, i) => GuideCard(
                    guide: grid[i],
                    saved: s.isFavorite('guide:${grid[i].id}'),
                    onTap: () => _open(grid[i]),
                  ),
                ),
              if (browsing) ...[
                const SizedBox(height: 24),
                const SectionHeader('Herramientas'),
                const SizedBox(height: 10),
                CravingBanner(
                  title: '¿Tienes un antojo?',
                  subtitle: 'Registra cómo te sientes y obtén apoyo',
                  icon: LucideIcons.cookie,
                  onTap: () => openCravings(context),
                ),
                const SizedBox(height: 10),
                ProaCard(
                  onTap: () => openHabit(context, HabitId.meals),
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    const IconBox(LucideIcons.pencilLine, color: AppColors.violet, bg: AppColors.violetSoft, size: 44, iconSize: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Registra lo que comes', style: AppText.inter(14, FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Identifica patrones y decide mejor', style: AppText.inter(12.5, FontWeight.w400, color: AppColors.textSecondary)),
                      ]),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 17, color: Color(0xFFD1D5DB)),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoSofter,
                    borderRadius: Radii.rCard,
                    border: Border.all(color: AppColors.infoBg),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const IconBox(LucideIcons.utensils, color: AppColors.turquoise, bg: AppColors.infoBg, size: 36, iconSize: 17),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('TIP DEL DÍA', style: AppText.overline.copyWith(color: AppColors.turquoise)),
                        const SizedBox(height: 4),
                        Text(nutritionTipOfDay(s.today), style: AppText.inter(13.5, FontWeight.w500, height: 1.45)),
                      ]),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

const _nutritionTips = [
  'Cocinar en casa te permite controlar la sal, el azúcar y el aceite de tus comidas.',
  'Cambia el jugo del almuerzo por agua con limón o una aromática sin azúcar.',
  'Arma tu plato empezando por las verduras: así la mitad queda lista.',
  'Lleva fruta picada o maní sin sal para las meriendas de la tarde.',
  'Lee las etiquetas: si el azúcar aparece entre los primeros ingredientes, consúmelo con moderación.',
];

/// Tip de alimentación que cambia cada día.
String nutritionTipOfDay(DateTime d) => _nutritionTips[d.difference(DateTime(2026)).inDays.abs() % _nutritionTips.length];
