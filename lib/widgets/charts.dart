import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

class BarDatum {
  const BarDatum(this.label, this.value, {this.highlight = false});
  final String label;

  /// 0..1; null = periodo futuro (barra punteada vacía).
  final double? value;
  final bool highlight;
}

/// Gráfica de barras de «Actividad semanal».
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.data});
  final List<BarDatum> data;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
        final barH = c.maxHeight - 22;
        final gap = data.length > 8 ? 4.0 : 8.0;
        return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final (i, b) in data.indexed)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == data.length - 1 ? 0 : gap),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(
                    height: barH,
                    child: b.value == null
                        ? CustomPaint(painter: _DashedRect(), child: const SizedBox.expand())
                        : Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(end: b.value!.clamp(0, 1)),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, _) => Container(
                                height: v == 0 ? 0 : (barH * v).clamp(6, barH),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: v >= 0.6
                                        ? const [Color(0xFF22C55E), AppColors.greenDark]
                                        : (v >= 0.4 ? const [Color(0xFF4ADE80), Color(0xFF22C55E)] : const [Color(0xFFA7F3D0), Color(0xFFA7F3D0)]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                  ),
                  const SizedBox(height: 6),
                  Text(b.label,
                      maxLines: 1,
                      style: AppText.inter(10, b.highlight ? FontWeight.w700 : FontWeight.w500,
                          color: b.highlight ? AppColors.green : AppColors.textMuted)),
                ]),
              ),
            ),
        ]);
      });
}

class _DashedRect extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFBBF7D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)));
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gráfica de línea de «Evolución del cumplimiento».
class LineChart extends StatelessWidget {
  const LineChart({super.key, required this.points});
  final List<(String, int)> points;

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(child: CustomPaint(painter: _LinePainter([for (final p in points) p.$2]), child: const SizedBox.expand())),
        const SizedBox(height: 8),
        Row(children: [
          for (final (i, p) in points.indexed)
            Expanded(
              child: Column(
                crossAxisAlignment: i == 0
                    ? CrossAxisAlignment.start
                    : i == points.length - 1
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.center,
                children: [
                  Text('${p.$2}%', style: AppText.inter(11, FontWeight.w700)),
                  Text(p.$1, style: AppText.inter(9.5, FontWeight.w400, color: AppColors.textMuted)),
                ],
              ),
            ),
        ]),
      ]);
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const r = 5.0;
    final w = size.width - r * 2;
    final h = size.height - r * 2;
    Offset at(int i) => Offset(
          r + (values.length == 1 ? w / 2 : w * i / (values.length - 1)),
          r + h * (1 - values[i].clamp(0, 100) / 100),
        );
    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final area = Path.from(line)
      ..lineTo(at(values.length - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.green.withValues(alpha: 0.18), AppColors.green.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(at(i), r, Paint()..color = AppColors.white);
      canvas.drawCircle(at(i), r, Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.values != values;
}
