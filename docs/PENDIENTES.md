# Pendientes, supuestos y diferencias con Figma

## Cómo se revisó Figma

El prototipo público (`Alta-Fidelidad`, flujo «PROA – Prototipo») se recorrió en un
navegador automatizado, igual que lo haría un usuario: flechas para el primer ingreso y
clics en la barra inferior, filas de hábito y tarjetas de guía para el resto. Se
capturaron, entre otros, estos frames:

| Pantalla | node-id |
|---|---|
| Bienvenida | 30-7 |
| Inicio | 31-171 |
| Plan | 31-421 |
| Alimentación | 32-179 |
| Antojos y ansiedad | 33-3 |
| Progreso | 33-171 |
| Perfil | 33-376 |
| Hábitos: agua / actividad / frutas / registro / sueño | 40-3 · 40-190 · 40-376 · 40-559 · 40-734 |
| Guías: plato / porciones / frutas / proteínas / hidratación / ultraprocesados | 45-3 · 45-131 · 45-282 · 45-418 · 45-530 · 45-654 |

La vista de diseño (capas y página «Elementos de diseño») no se pudo abrir de forma
automatizada, así que los valores exactos de los estilos se tomaron de las capturas.

## Ya alineado con Figma

- Las **8 preguntas** del test, con su categoría, ícono y color.
- Las **6 guías**: textos, consejos, infografías y nota final.
- **Descripción y «Consejo práctico»** de los 5 hábitos y la tarjeta «Progreso semanal».
- Inicio: «Guías para ti» con etiqueta, «Tu semana» y «Consejo de hoy».
- Progreso: tarjeta «Hoy» y acceso naranja a «Registros de ansiedad».
- Alimentación: buscador, chips y filtro grises, y la sección «Herramientas».
- Plan: acceso «¿Sientes ansiedad o un antojo?».
- Perfil: 3 filas de información y «Cerrar sesión» centrado.
- Fotos: recortadas de los frames del prototipo (hasta 4× más resolución que antes).

## Texto oculto en el prototipo (completado con el mismo sentido)

En Figma, el final de algunos textos queda tapado por el botón fijo y no se puede leer:
- Final de los 5 «Consejo práctico» (`lib/data/habits_catalog.dart`).
- Final de las notas verdes de las 6 guías (`lib/data/guides_catalog.dart`).
- Contenido de «Tip del día» de Alimentación (`nutritionTipOfDay`).
- Objetivos «Moverme más» y «Dormir y descansar mejor» del perfil (solo se ve el
  primero en Figma).

## Puntaje del test

El proyecto no documenta una metodología validada. La lógica está **parametrizada** en
`lib/services/test_scoring.dart` (0-3 puntos por opción; bandas orientativas ≥75, 40-74,
<40). **No son umbrales clínicos** y deben validarse con un profesional de la salud.

## Diferencias visuales que quedan

1. **Fotos**: vienen de capturas del prototipo, no de las exportaciones originales. En la
   bienvenida, la parte inferior se difuminó para ocultar el texto que traía la captura
   (queda bajo el degradado verde). Para fotos perfectas, exportar desde Figma con los
   mismos nombres de `assets/images/`. «Porciones» y «Proteínas» siguen viniendo del PDF.
2. **Avatar**: por defecto se muestran las iniciales. La «Foto ilustrativa» depende del
   sexo del perfil (mujer: avatar de Figma; hombre: recorte del corredor del onboarding;
   «Prefiero no decir»: solo iniciales).
3. **Ventana «Guardado»**: en el prototipo no se pudo activar; se usa el aviso oscuro
   del mismo estilo que «Momento registrado».
4. **Horas de sueño**: el registro es por horas enteras (Figma muestra «6.5 h»).
5. **Ayuda (FAQ)**: Figma tiene la opción en el perfil, pero no la pantalla; se creó
   siguiendo la mejora #3 de la evaluación heurística.

## Cuentas (correo y contraseña)

- Registro e inicio de sesión con correo electrónico (por ejemplo, de Gmail) y
  contraseña. La contraseña se guarda como hash HMAC-SHA256 iterado con sal.
- Los datos de cada cuenta se guardan por separado en el dispositivo; al cerrar sesión se
  conservan y vuelven al iniciar sesión con la misma cuenta.
- Los datos de versiones anteriores (sin cuenta) pasan a la primera cuenta que se cree.
- **Pendiente**: «Continuar con Google» y el inicio de sesión desde otro dispositivo
  necesitan un servicio en la nube (Firebase Authentication) con un proyecto propio y la
  huella SHA-1 de la app. Tampoco hay recuperación de contraseña por correo.

## Funcionalidad pendiente

- **Notificaciones push del sistema**: los recordatorios se guardan y alimentan el panel
  de notificaciones de la app, pero no hay avisos del sistema operativo.
- **Foto propia** desde cámara o galería.
- Se probó en un Samsung A54 (Android) y en web a 390 × 844; no en iPhone.
