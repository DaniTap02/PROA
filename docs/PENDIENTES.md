# Pendientes, supuestos y diferencias con Figma

## Acceso a las referencias

- **Figma no se pudo inspeccionar**: el archivo pide iniciar sesión. Todo se construyó a
  partir de las capturas del PDF *Segundo avance* (≈180 px de ancho por pantalla), del
  banco de imágenes, componentes, iconografía y estilos documentados ahí.
- Repositorio `androidmaycry/lab01/EditProfile`: no se consultó; la edición de perfil
  sigue el formulario de «Crear perfil» de Figma.

## Contenido que no aparece en el documento (redactado, PENDIENTE DE VALIDAR)

| Elemento | Archivo |
|---|---|
| Preguntas 2, 4, 6 y 7 del test (sí son exactas la 1, 3, 5 y 8) | `lib/data/test_catalog.dart` |
| Guías 5 y 6 (*Proteínas en tu día*, *Meriendas para tus antojos*) y los consejos 2-4 de las guías 1-4 | `lib/data/guides_catalog.dart` |
| Consejos de cada hábito y textos completos de descripción | `lib/data/habits_catalog.dart` |
| Recomendaciones de Ansiedad, Estrés, Hambre y Aburrimiento (la de Antojo es de Figma) | `lib/data/emotions_catalog.dart` |
| Objetivos *Moverme más* y *Dormir y descansar mejor* | `lib/models/user_profile.dart` |
| Pantallas Editar perfil, Mis hábitos, Recordatorios, Privacidad y Ayuda (no están entre las 36) | `lib/screens/profile/` |

## Puntaje del test

El proyecto no documenta una metodología validada. La lógica está **parametrizada** en
`lib/services/test_scoring.dart`:
- Cada opción vale 0-3 puntos; puntaje = suma / máximo × 100 (también por área).
- Bandas orientativas: ≥75 «Buenos hábitos», 40-74 «Hábitos por mejorar», <40
  «Hábitos que necesitan atención». **No son umbrales clínicos**; deben validarse con un
  profesional de la salud. El resultado muestra el aviso educativo.

## Diferencias visuales conocidas

1. **Fotos en baja resolución**: se recortaron del PDF (≈170-210 px de ancho) y se ven
   borrosas a pantalla completa. Reemplazar los archivos de `assets/images/` por las
   exportaciones de Figma (mismos nombres).
2. **Avatar**: por defecto se muestran las iniciales; la foto ilustrativa de Figma se elige
   en Editar perfil (evita mostrar la cara de otra persona como si fuera la del usuario).
3. **Edad**: el sufijo «años» queda alineado a la derecha del campo (en Figma va junto al
   número).
4. **Inicio**: se agregaron «Guías para ti» y «Consejo del día» según la jerarquía visual
   del documento; el resumen semanal vive en Progreso (mejora #5 de la evaluación).
5. **Antojos**: selección única de emoción (mejora #2 de la evaluación heurística).
6. **Accesos a «¿Tienes un antojo?»** desde Plan, Alimentación y Progreso (tarjeta naranja).
7. La barra de estado «9:41» de Figma es la del sistema en el dispositivo real.

## Funcionalidad pendiente

- **Notificaciones push del sistema**: los recordatorios se guardan y alimentan el panel de
  notificaciones dentro de la app, pero no hay avisos del sistema operativo (requiere
  `flutter_local_notifications` y permisos).
- **Cuentas en servidor**: no hay backend; los datos viven en el dispositivo
  (`SharedPreferences`). «Iniciar sesión» reabre el perfil guardado localmente.
- **Foto propia** desde cámara o galería (requiere `image_picker`).
- No se probó en un dispositivo Android/iOS físico (el SDK Android de este equipo tiene las
  licencias sin aceptar). Se verificó en web a 390 × 844.
