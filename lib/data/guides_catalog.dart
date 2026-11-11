import '../core/assets.dart';
import '../models/guide.dart';

const _green = 0xFF16A34A, _amber = 0xFFF59E0B, _orange = 0xFFEA580C;
const _turq = 0xFF0891B2, _gray = 0xFFCBD5E1;

/// Seis guías nutricionales.
/// Guías 1-4: textos tomados de las capturas de Figma.
/// Guías 5-6: el documento solo muestra la foto «Proteínas» en el banco de
/// imágenes; su contenido queda PENDIENTE DE VALIDAR contra Figma.
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
      'Llena la mitad de tu plato con verduras y frutas: ensalada, tomate, '
          'ahuyama o habichuela.',
      'Usa un cuarto para arroz, papa, yuca, plátano o arepa, sin repetir '
          'varias en la misma comida.',
      'Completa con un cuarto de proteína: pollo, huevo, pescado, carne magra '
          'o frijoles.',
      'Acompaña con agua en lugar de gaseosa o jugo azucarado.',
    ],
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
      'Sirve el arroz, la papa o la yuca del tamaño de tu puño cerrado.',
      'La porción de pollo, carne o pescado cabe en la palma de tu mano.',
      'Aceite, mantequilla o aguacate: más o menos el tamaño de tu pulgar.',
      'Las verduras pueden ocupar lo que cabe en tus dos manos abiertas.',
    ],
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
      'Toma al menos 8 vasos de agua al día (aproximadamente 2 litros).',
      'Lleva una botella contigo y rellénala durante el día.',
      'Si te aburre el agua sola, agrégale limón, hierbabuena o pepino.',
      'A veces la sed se confunde con hambre: toma agua antes de picar.',
    ],
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
      'Lee las etiquetas: más de 5 ingredientes suele indicar ultraprocesado.',
      'Limita snacks empacados, gaseosas, embutidos y comidas rápidas.',
      'Fíjate en los sellos de advertencia «Exceso en azúcares», «sodio» o '
          '«grasas saturadas».',
      'Cambia el paquete de mecato por fruta, maní sin sal o una arepa con '
          'queso.',
    ],
  ),
  Guide(
    id: 'proteinas',
    title: 'Proteínas en tu día',
    shortTitle: 'Proteínas',
    minutes: 4,
    level: 'Básico',
    category: GuideCategory.comidas,
    image: Img.proteinas,
    intro: 'Las proteínas te dan saciedad y ayudan a mantener tus músculos. '
        'No tienen que ser costosas: los frijoles, las lentejas y el huevo '
        'son opciones económicas y muy colombianas.',
    infographic: TilesInfographic('Buenas fuentes', [
      ('Huevo', 'Desayuno', _amber),
      ('Frijoles', 'Almuerzo', _orange),
      ('Pescado', 'Cena', _turq),
      ('Pollo', 'Cualquier hora', _green),
    ]),
    tips: [
      'Incluye una porción de proteína en cada comida principal.',
      'Combina arroz con frijoles o lentejas: juntos son una proteína completa.',
      'Prefiere preparaciones a la plancha, sudadas o al horno en vez de fritas.',
    ],
  ),
  Guide(
    id: 'snacks',
    title: 'Meriendas para tus antojos',
    shortTitle: 'Meriendas',
    minutes: 3,
    level: 'Básico',
    category: GuideCategory.antojos,
    image: Img.frutas,
    intro: 'Tener a mano meriendas sencillas evita llegar con demasiada hambre '
        'a la siguiente comida y te ayuda a manejar los antojos sin culpa.',
    tips: [
      'Fruta picada con un poco de limón: mango, papaya, piña o guayaba.',
      'Un puñado de maní o almendras sin sal.',
      'Yogur natural sin azúcar con avena.',
      'Zanahoria o pepino en bastones con un poco de sal y limón.',
    ],
  ),
];

Guide guideById(String id) => guidesCatalog.firstWhere((g) => g.id == id);
