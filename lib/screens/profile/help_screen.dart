import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';
import 'sub_screen.dart';

const _faq = [
  ('¿El test es un diagnóstico médico?',
      'No. Es una herramienta educativa que te orienta sobre tus hábitos. Si tienes dudas sobre tu salud, consulta a un profesional.'),
  ('¿Cómo se calcula mi puntaje?',
      'Cada respuesta suma puntos según qué tan saludable es el hábito. El puntaje va de 0 a 100 y también se calcula por áreas: actividad, alimentación, sueño y estrés.'),
  ('¿Cómo marco un hábito?',
      'Toca la casilla de la izquierda en Inicio o en Plan. Para ver el detalle y registrar tu avance, toca el resto de la fila.'),
  ('¿Puedo cambiar los hábitos de mi plan?',
      'Sí. Ve a Perfil › Mis hábitos o toca «Editar» en Plan.'),
  ('¿Qué pasa si un día no cumplo?',
      'Nada malo. Tu racha vuelve a empezar, pero tu progreso se conserva. Cada pequeño paso cuenta.'),
  ('¿Dónde se guardan mis datos?',
      'Solo en este dispositivo. Puedes borrarlos desde Perfil › Privacidad.'),
];

/// «Ayuda»: preguntas frecuentes (mejora del hallazgo #3 de la evaluación).
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Ayuda',
        subtitle: 'Preguntas frecuentes sobre PROA.',
        children: [
          for (final (i, q) in _faq.indexed) ...[
            ProaCard(
              onTap: () => setState(() => _open = _open == i ? null : i),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(q.$1, style: AppText.inter(14, FontWeight.w600))),
                  AnimatedRotation(
                    turns: _open == i ? 0.25 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: const Icon(LucideIcons.chevronRight, size: 17, color: AppColors.textMuted),
                  ),
                ]),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.topCenter,
                  child: _open == i
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(q.$2, style: AppText.inter(13, FontWeight.w400, color: AppColors.textSecondary, height: 1.5)),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ],
      );
}
