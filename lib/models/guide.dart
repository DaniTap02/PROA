enum GuideCategory { comidas, hidratacion, antojos, porciones }

extension GuideCategoryLabel on GuideCategory {
  String get label => switch (this) {
        GuideCategory.comidas => 'Comidas',
        GuideCategory.hidratacion => 'Hidratación',
        GuideCategory.antojos => 'Antojos',
        GuideCategory.porciones => 'Porciones',
      };
}

/// Bloque de infografía de cada guía (cada guía tiene uno distinto en Figma).
sealed class GuideInfographic {
  const GuideInfographic();
}

/// Barra segmentada («Así se ve tu plato», «Tu cuerpo es 60% agua»).
class SegmentInfographic extends GuideInfographic {
  const SegmentInfographic(this.title, this.segments);
  final String title;
  final List<(String label, int percent, int colorValue)> segments;
}

/// Tarjetas pequeñas con ícono («Mide con tu mano»).
class TilesInfographic extends GuideInfographic {
  const TilesInfographic(this.title, this.tiles);
  final String title;
  final List<(String title, String subtitle, int colorValue)> tiles;
}

class Guide {
  const Guide({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.minutes,
    required this.level,
    required this.category,
    required this.image,
    required this.intro,
    required this.tips,
    this.infographic,
    this.featured = false,
  });

  final String id;
  final String title;
  final String shortTitle;
  final int minutes;
  final String level;
  final GuideCategory category;
  final String image;
  final String intro;
  final GuideInfographic? infographic;
  final List<String> tips;
  final bool featured;
}
