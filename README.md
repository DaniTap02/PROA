# PROA — Prevención y Reeducación en Obesidad y Alimentación

App móvil en Flutter que ayuda a adultos de 18 a 50 años a prevenir la obesidad y la
diabetes tipo 2 con un test de hábitos, un plan diario de 5 hábitos, guías nutricionales
con comida colombiana y el registro de antojos y ansiedad.

> Herramienta educativa. No es un diagnóstico ni reemplaza una valoración médica.

Referencia visual: archivo de alta fidelidad y prototipo de Figma (*Alta-Fidelidad*) y
el documento *Segundo avance del proyecto UI/UX* (Equipo 3, Universidad de Ibagué).

## Ejecutar

```bash
flutter pub get
flutter run            # dispositivo/emulador Android o iOS
flutter run -d chrome  # navegador (en pantallas anchas se muestra en un lienzo de 390 × 844)
flutter test           # pruebas de lógica y persistencia
```

Requisitos: Flutter 3.47+ / Dart 3.13+.

## Arquitectura

```
lib/
├── main.dart, app.dart          Arranque, tema y decisión primer ingreso / app principal
├── core/                        Tema (colores, tipografía, radios, sombras, espaciado), fechas, imágenes
├── models/                      Perfil, hábito, test, guía, emoción/antojo
├── data/                        Catálogos: 5 hábitos, 8 preguntas, 6 guías, 5 emociones
├── services/                    LocalStore (persistencia) y TestScoring (puntaje parametrizado)
├── state/app_state.dart         Estado global (Provider): hábitos, rachas, progreso, favoritos, historial
├── navigation/main_shell.dart   Barra inferior fija + un Navigator por sección
├── widgets/                     Componentes reutilizables del sistema de diseño
└── screens/                     onboarding · test · main · habits · guides · cravings · profile
```

- **Estado:** `provider` + `ChangeNotifier`. Cada escritura se guarda antes de notificar;
  si falla, la interfaz muestra un aviso (no se simulan éxitos).
- **Persistencia:** `LocalStore` (interfaz) con implementación `SharedPrefsStore`. Para
  conectar un backend basta con otra implementación de `LocalStore`.
- **Dependencias:** `provider`, `shared_preferences`, `google_fonts` (Outfit e Inter),
  `lucide_icons_flutter` (la iconografía de Figma es Lucide, trazo 2 px).

## Pantallas (36 de Figma + complementarias)

| Grupo | Pantallas |
|---|---|
| Primer ingreso (5) | Bienvenida, Onboarding 1-3, Crear perfil |
| Test (9) | 8 preguntas + Resultado |
| Principales (6) | Inicio, Plan diario, Alimentación, Antojos y ansiedad, Progreso, Perfil |
| Hábitos (5) | Tomar agua, Actividad física, Frutas y verduras, Registrar alimentación, Dormir bien |
| Guías (6) | Plato equilibrado, Porciones, Frutas y verduras, Proteínas saludables, Hidratación, Alimentos ultraprocesados |
| Emergentes (5) | ¡Hábito completado!, Momento registrado, Guardado, Notificaciones, Cerrar sesión |
| Complementarias | Editar perfil, Mis hábitos, Recordatorios, Privacidad, Ayuda (FAQ) |

Pendientes y diferencias con Figma: ver [`docs/PENDIENTES.md`](docs/PENDIENTES.md).
