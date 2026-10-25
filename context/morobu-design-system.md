# Design System Morobu - Gakoken

Este archivo conecta el repo con el Design System de Morobu, que está documentado en Obsidian. **Complementa** los demás documentos de `context/` y `docs/`; no los reemplaza.

- **Design System (Obsidian):** `D:/3-Projects/Software/Vault/Design System/Design System.md`
- **Nota del proyecto (Obsidian):** `D:/3-Projects/Software/Vault/Proyectos/Gakoken.md`

Al 2026-10-19.

# Pertenencia

- **Filosofía:** Herramientas Origami. La nota del proyecto en Obsidian lleva la propiedad `filosofia: "[[Herramientas Origami]]"`.
- **Herencia:** Proyecto, luego Filosofía, luego Global. Gana el nivel más específico.

# Reglas globales (Principios Morobu)

- Sello personal
- Útil
- Accesible
- Amabilidad
- Útil y bonito: estética y utilidad sin sacrificar ninguna de las dos.

# Reglas de la filosofía Herramientas Origami

| ID | Regla | Estado en este repo |
| --- | --- | --- |
| OR-01 | Sencillas: UI/UX simple | No verificable en código |
| OR-02 | Fáciles de usar desde el inicio | No verificable en código |
| OR-03 | Simples pero que puedan escalar | No verificable en código |
| OR-04 | Comparten el sistema de colores (mismos tokens y paletas, colores personalizables) | Implementado: `lib/core/theme/` y `lib/core/services/theme_service.dart` |
| OR-05 | Basadas en un animal de México (u objeto de origami) | Ver la nota del proyecto |
| OR-06 | Al iniciar, los elementos del home se doblan para formarse | En pausa: no integrar animaciones de doblez hasta nuevo aviso; solo animaciones sencillas |
| OR-07 | Al cambiar de pestaña, la página entera se dobla | En pausa: no integrar animaciones de doblez hasta nuevo aviso; solo animaciones sencillas |
| OR-08 | Animación de inicio que se dobla a la figura de origami | En pausa: no integrar animaciones de doblez hasta nuevo aviso; solo animaciones sencillas |
| OR-09 | Cada herramienta tiene un video de presentación | Fuera del código; ver Herramientas Origami en Obsidian |

# Reglas de diseño del repo

Este repo ya tiene `docs/design_rules.md`. El mismo archivo está en Ajoruto, Eloisa, Cuintle y Gakoken, y su título dice "Centavito (MIDIKKI)". Resumen:

1. **Colores:** nunca usar colores hardcoded; todo sale de `context.colors`. La única excepción son los colores que el usuario define para entidades (carteras, categorías, metas de ahorro).
2. **Tipografía:** nunca definir `TextStyle` a mano; todo sale de `context.typography`. Para ajustar un estilo se usa `.copyWith()`.
3. **Componentes:** usar `AppCard` en lugar del `Card` nativo y encapsular los gráficos complejos en widgets propios.

`design_rules.md` menciona tokens que no existen en el código actual de este repo: `bgInfoCard`, `chart1` a `chart8` y `bigStat`. Los gráficos usan `chartPalette`, que se deriva de los tokens.

# Tokens de color

Fuente de verdad en código: `lib/core/theme/color_extensions.dart` (`AppColorExtension`). Cada token tiene un nombre de código y un nombre humano.

| Nombre humano | Código | Variable CSS |
| --- | --- | --- |
| Fondo principal | bgPrimary | --color-bg-primary |
| Fondo secundario | bgSecondary | --color-bg-secondary |
| Fondo elevado | bgElevated | --color-bg-elevated |
| Overlay | overlay | --color-overlay |
| Texto principal | textPrimary | --color-text-primary |
| Texto secundario | textSecondary | --color-text-secondary |
| Texto deshabilitado | textDisabled | --color-text-disabled |
| Texto invertido | textInverse | --color-text-inverse |
| Borde sutil | borderSubtle | --color-border-subtle |
| Borde enfocado | borderFocus | --color-border-focus |
| Color primario | primary | --color-primary |
| Primario hover | primaryHover | --color-primary-hover |
| Primario activo | primaryActive | --color-primary-active |
| Superficie hover | surfaceHover | --color-surface-hover |
| Superficie activa | surfaceActive | --color-surface-active |
| Éxito | stateSuccess | --color-state-success |
| Advertencia | stateWarning | --color-state-warning |
| Error | stateError | --color-state-error |
| Información | stateInfo | --color-state-info |
| Secundario (opcional) | secondary | - |
| Secundario hover (opcional) | secondaryHover | - |
| Secundario activo (opcional) | secondaryActive | - |

**Temas integrados en este repo:** `default` (Gakoken, gato naranja: crema y naranja atigrado), `nekokag` (oscuro, gato naranja de noche), `eloisa` (colibrí: esmeralda y magenta), `asiole` (oscuro de Eloisa), `ajoruto`, `oturoja`, `manubu` (exporta "Morobu"), `ubunam` (exporta "Uborom"), `zontle`, `eltnoz`, `bioka` (la Tierra: azul océano y verde), `akoib` (oscuro de Bioka).

# Tipografía

- **Fuente:** Montserrat (`google_fonts`).
- **Uso:** `context.typography`.
- **Escala:** la misma en todas las apps de la serie y en la web.

| Nombre humano | Código | Tamaño | Peso |
| --- | --- | --- | --- |
| Título de página | pageTitle | 24 | 700 |
| Título de página móvil | mobilePageTitle | 18 | 700 |
| Título de modal | modalTitle | 20 | 700 |
| Título de modal móvil | mobileModalTitle | 18 | 700 |
| Encabezado de sección | sectionHeader | 18 | 700 |
| Encabezado de sección móvil | mobileSectionHeader | 16 | 700 |
| Título de card | cardTitle | 16 | 600 |
| Label de input | inputLabel | 14 | 500 |
| Texto | body | 14 | 400 |
| Texto pequeño | small | 12 | 400 |
| Badge | badge | 11 | 600 |

# Diferencias detectadas

- `docs/design_rules.md` viene de la copia de Ajoruto (título "Centavito (MIDIKKI)").

# Open source

**Pendiente.** Idea OR-10 de Herramientas Origami (2026-10-17): reestructurar este repo para publicarlo como open source, incluidos código, íconos, imágenes, fuentes y el lenguaje de diseño. Todavía no hay decisión; mientras tanto, evitar assets sin licencia clara y nunca subir secretos (solo archivos `.example`). Temas a resolver: `D:/3-Projects/Software/Vault/Design System/Open Source.md`.

Pendiente en este repo:
- No hay `LICENSE`.
- Montserrat se descarga con `google_fonts`. Todavía no hay íconos ni imágenes propias.
