import '../core/assets.dart';
import '../models/guide.dart';

const _green = 0xFF16A34A, _amber = 0xFFF59E0B, _orange = 0xFFEA580C;
const _turq = 0xFF0891B2, _gray = 0xFFCBD5E1;

/// Seis guías nutricionales, en el orden y con los textos de Figma
/// («Todas las guías» y pantallas de detalle).
const guidesCatalog = <Guide>[
  Guide(
    id: 'plato',
    title: 'El plato equilibrado',
    shortTitle: 'Plato equilibrado',
    minutes: 4,
    level: 'Básico',
    category: GuideCategory.comidas,
    image: Img.plato,
    featured: true,
    intro: 'Imagina tu plato dividido en cuatro partes. La mitad debe ser '
        'verduras y frutas de colores variados, un cuarto carbohidratos '
        'saludables y un cuarto proteínas.',
    infographic: SegmentInfographic('Así se ve tu plato', [
      ('Verduras y frutas', 50, _green),
      ('Carbohidratos', 25, _amber),
      ('Proteínas', 25, _orange),
    ]),
    tips: [
      'Llena la mitad de tu plato con verduras y frutas de diferentes colores',
      'Incluye carbohidratos: arroz integral, papa, yuca o arepa de maíz',
      'Agrega proteína en cada comida: huevo, pollo, pescado o frijoles',
      'Usa aceite vegetal con moderación para cocinar',
    ],
    note: 'No necesitas dietas estrictas. El equilibrio en las proporciones hace la diferencia.',
  ),
  Guide(
    id: 'porciones',
    title: 'Porciones adecuadas',
    shortTitle: 'Porciones',
    minutes: 3,
    level: 'Básico',
    category: GuideCategory.porciones,
    image: Img.porciones,
    intro: 'Tu mano es la mejor guía para medir porciones sin básculas ni '
        'complicaciones. Es una herramienta que siempre tienes contigo.',
    infographic: TilesInfographic('Mide con tu mano', [
      ('Puño', 'Carbohidratos', _amber),
      ('Palma', 'Proteínas', _orange),
      ('Pulgar', 'Grasas', _amber),
      ('2 manos', 'Verduras', _green),
    ]),
    tips: [
      'Carbohidratos: el tamaño de tu puño cerrado',
      'Proteínas: el tamaño de tu palma de mano',
      'Grasas saludables: el tamaño de tu pulgar',
      'Verduras y ensaladas: tanto como quepan en tus dos manos juntas',
    ],
    note: 'Come despacio. La saciedad llega al cerebro 20 minutos después de empezar a comer.',
  ),
  Guide(
    id: 'frutas',
    title: 'Frutas y verduras',
    shortTitle: 'Frutas y verduras',
    minutes: 3,
    level: 'Básico',
    homeTag: 'Nutrición',
    category: GuideCategory.comidas,
    image: Img.frutas,
    intro: 'Consumir 5 porciones al día de frutas y verduras variadas aporta '
        'vitaminas, fibra y minerales que protegen tu salud.',
    infographic: SegmentInfographic('Meta diaria: 5 porciones de colores', [
      ('Rojo', 20, 0xFFEF4444),
      ('Naranja', 20, _orange),
      ('Amarillo', 20, 0xFFEAB308),
      ('Verde', 20, 0xFF22C55E),
      ('Morado', 20, 0xFF8B5CF6),
    ]),
    tips: [
      'Varía los colores: cada color representa diferentes nutrientes',
      'Incluye fruta en el desayuno y verdura en el almuerzo y la cena',
      'Prefiere frutas enteras sobre jugos (conservan la fibra)',
      'Las verduras congeladas sin sal también son nutritivas',
    ],
    note: 'No hay fruta o verdura «mala». La variedad y la frecuencia son lo que cuenta.',
  ),
  Guide(
    id: 'proteinas',
    title: 'Proteínas saludables',
    shortTitle: 'Proteínas',
    minutes: 4,
    level: 'Básico',
    category: GuideCategory.comidas,
    image: Img.proteinas,
    intro: 'Las proteínas son esenciales para construir y reparar tejidos. No '
        'solo se encuentran en la carne: hay muchas fuentes vegetales.',
    tips: [
      'Legumbres (frijoles, lentejas, garbanzos) son económicas y muy nutritivas',
      'El huevo es una fuente completa de proteína y muy versátil',
      'Prefiere carnes blancas (pollo, pescado) sobre carnes rojas',
      'Los lácteos bajos en grasa también aportan proteína de calidad',
    ],
    note: 'Una dieta variada y equilibrada cubre tus necesidades de proteína.',
  ),
  Guide(
    id: 'hidratacion',
    title: 'Hidratación',
    shortTitle: 'Hidratación',
    minutes: 2,
    level: 'Básico',
    category: GuideCategory.hidratacion,
    image: Img.hidratacion,
    intro: 'El cuerpo humano es 60% agua. Estar bien hidratado mejora la '
        'concentración, el metabolismo y los niveles de energía.',
    infographic: SegmentInfographic('Tu cuerpo es 60% agua', [
      ('Agua', 60, _turq),
      ('Otros componentes', 40, _gray),
    ]),
    tips: [
      'Toma al menos 8 vasos de agua al día (aproximadamente 2 litros)',
      'Bebe agua antes, durante y después del ejercicio',
      'Incluye frutas y verduras con alto contenido de agua',
      'Reduce el consumo de bebidas azucaradas y con cafeína',
    ],
    note: 'Si tu orina es amarillo oscuro, necesitas tomar más agua.',
  ),
  Guide(
    id: 'ultraprocesados',
    title: 'Alimentos ultraprocesados',
    shortTitle: 'Ultraprocesados',
    minutes: 5,
    level: 'Intermedio',
    category: GuideCategory.antojos,
    image: Img.ultraprocesados,
    intro: 'Los alimentos ultraprocesados tienen muchos ingredientes '
        'industriales, azúcar, sal y grasas añadidas. Consumirlos con '
        'frecuencia afecta la salud a largo plazo.',
    tips: [
      'Lee las etiquetas: más de 5 ingredientes suele indicar ultraprocesado',
      'Limita snacks empacados, gaseosas, embutidos y comidas rápidas',
      'Cocinar en casa te da control total sobre los ingredientes',
      'Si los consumes, hazlo con moderación y consciencia',
    ],
    note: 'No se trata de eliminarlos para siempre, sino de consumirlos con menos frecuencia.',
  ),
];

Guide guideById(String id) => guidesCatalog.firstWhere((g) => g.id == id);
