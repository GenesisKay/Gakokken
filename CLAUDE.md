# Gakoken

## Documentación

El producto (qué hace hoy, pendientes, decisiones e historial) vive en la nota `Gakoken` del vault: `D:/3-Projects/Software/Vault/Proyectos/Gakoken.md`. Este repo documenta solo lo técnico: `context/context.md` (mapa del código), `docs/architecture.md` (motor Rust y decisiones técnicas) y `docs/design_rules.md`. No dupliques; si un cambio de código cierra una tarea o toma una decisión de producto, actualiza esa nota. Regla completa: [`context/documentacion-obsidian.md`](./context/documentacion-obsidian.md).

## QA: en el repo

La documentación de QA vive completa en [`qa/`](./qa/) (historias de usuario, análisis de sistema y plan de pruebas), sin referencias a Obsidian, porque QA solo ve el repo. Todo cambio de código actualiza `qa/` en el mismo turno con la skill `sync-qa` (`.claude/skills/sync-qa/`).


## Configuración del proyecto

Datos que leen las skills `sync-docs` y `build-android`.

**Proyecto Flutter:** raíz de este repo (`D:/3-Projects/Software/Gakoken/Gakoken`). Plataformas: Android, Linux y Windows; `build-android` solo cubre Android.

**Idiomas:** en, es, fr, ja. ARB en `lib/l10n/`.

**Documentos:**

| Archivo | Rol | Idioma |
| --- | --- | --- |
| `context/context.md` | Mapa del código y reglas para agentes | Español |
| `context/run.md` | Cómo correr la app | Inglés |
| `context/documentacion-obsidian.md` | Qué va en Obsidian y qué en el repo | Español |
| `context/morobu-design-system.md` | Conexión con el Design System Morobu | Español |
| `docs/design_rules.md` | Reglas de UI y colores | Español |
| `README.md` | Presentación del proyecto | Español |
| Nota del vault `Gakoken` | Producto, etapas, tareas y decisiones | Español |

**Notas para sync-docs:** `docs/design_rules.md` viene copiado de Ajoruto y su título todavía dice Centavito. El código Rust (`rust/`, `rust_builder/`) también cuenta como código fuente al buscar archivos sin documentar.
