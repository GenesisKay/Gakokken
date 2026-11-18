---
name: sync-docs
description: Empata la documentación del proyecto con el código real. Usar después de cualquier cambio de código, refactor, feature nueva o bug fix, antes de dar el trabajo por terminado, o cuando el usuario pida sincronizar, actualizar o revisar la documentación. Detecta lo incorrecto, lo que falta y lo obsoleto, y lo corrige en el mismo turno.
---

# sync-docs: documentación igual al código

Skill genérica. Es la misma en todos los proyectos; lo propio de cada uno vive en su `CLAUDE.md`. Sin emojis.

**Regla:** el código es la fuente de verdad. La documentación se corrige, nunca el código para que coincida con la documentación.

## Configuración

En la sección "Configuración del proyecto" del `CLAUDE.md` del repo:

- **Documentos:** tabla con cada documento, su rol y su idioma. No inventar documentos que no estén ahí; si falta uno, proponerlo al usuario.
- **Notas para sync-docs** (opcional): datos propios del proyecto (documentos desactualizados a propósito, funciones eliminadas, convenciones de nombres). Respetarlas.

## Cuándo aplica

- Cambió cómo funciona, se ve o se construye la app: features, bugs, UI, temas, motor, almacenamiento, build, idiomas, permisos.
- Se cerró o cambió una decisión de producto o arquitectura.

Se omite solo si el cambio no altera nada documentado (typo en un comentario, formato). Si hay duda, se sincroniza.

## Flujo

1. **Alcance.** Si hay cambios recientes: `git status --short` y `git diff --stat` (y `git diff HEAD~1 --stat` si ya hubo commit); revisar solo lo tocado. Si el usuario pide revisión completa, recorrer todos los documentos de la tabla.
2. **Verificaciones mecánicas** (siempre):
   - Cada ruta de código citada en los `.md` existe.
   - Archivos de código nuevos en `lib/` (sin contar generados como `*.g.dart` o `app_localizations*.dart`) aparecen donde la documentación lista la estructura.
   - Carpetas de features en `lib/` coinciden con las que describen los documentos.
   - Idiomas (`lib/l10n/*.arb`), versión y dependencias del `pubspec.yaml` coinciden con lo que dicen los documentos.
   - Cada `export '...'` de los archivos barrel apunta a un archivo que existe.
3. **Verificaciones de comportamiento** (lo tocado): acciones reales de menús y pantallas, métodos públicos de servicios y sus reglas, campos de modelos guardados (y si importar y exportar los cubren), claves de idioma nuevas presentes en todos los `.arb`, reglas de diseño, decisiones tomadas y abiertas.
   - **Tutorial guiado** (si el proyecto tiene `lib/core/tutorial/`, apps de Herramientas Origami, regla OR-14): si el cambio agrega, quita o mueve una función visible o un elemento envuelto con `KeyedSubtree(key: <App>TourKeys.x)`, su paso en `lib/core/tutorial/<app>_tours.dart` y sus textos en todos los `.arb` se ajustan en el mismo turno. Una función nueva sin su paso es **Falta**; un paso que explica algo que ya no existe es **Incorrecto**. `origami_tour.dart` es copia de `Origami-Base/codigo/flutter/tutorial/`: no se edita en el repo sin cambiar también la copia maestra (skill personal `origami-tutorial`).
4. **Clasificar:**
   - **Incorrecto:** el documento contradice al código.
   - **Falta:** comportamiento o archivo nuevo sin documentar.
   - **Obsoleto:** el documento menciona algo que ya no existe.
5. **Aplicar.** Cambios mínimos, respetando el estilo y el idioma de cada documento. Si un documento tiene una línea `Last updated` o `Última actualización`, actualizarla con un resumen breve. Si el usuario pidió solo reporte, no editar. Si un documento describe algo deseable que no existe, reportarlo como pendiente. No tocar archivos generados.

Pregunta guía: ¿qué haría mal un agente futuro si la documentación se queda así?

## No duplicar

Cada dato vive en un solo documento; los demás enlazan. Producto y tareas van en la nota del vault cuando el proyecto la tiene (`E:/Vault/Software/Proyectos/<Proyecto>.md`; reglas de ubicación en la skill personal `documentar`); lo técnico, en el repo. La carpeta `qa/` no es de esta skill: la mantiene `sync-qa`.

## Reporte

```
## Sync de documentación - <fecha>
Alcance: <archivos o áreas>

### Incorrecto
- context/context.md:42 - dice X, el código hace Y.

### Falta
- lib/core/... - no aparece en la estructura.

### Obsoleto
- context/context.md:N - menciona Z, ya no existe.

### Cambios aplicados
- <archivo>: <qué cambió>   (o "Ninguno, solo reporte")
```

## Qué no hacer

- No editar código para que coincida con la documentación.
- No hacer git add, commit ni push.
