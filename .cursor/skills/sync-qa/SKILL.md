---
name: sync-qa
description: Mantiene la carpeta qa/ de Gakoken al dia con el codigo. Usar SIEMPRE despues de cualquier cambio de codigo en Gakoken - feature nueva, bug fix, cambio de UI o de textos, refactor que cambie comportamiento, cambio de modelo, permisos o version - y cuando el usuario pida actualizar o revisar la documentacion de QA. Todo cambio de codigo conlleva su cambio en qa/ en el mismo turno.
---

# sync-qa - Mantener qa/ de Gakoken al dia

El equipo de QA trabaja solo con el repo remoto. Lo que no este en `qa/` no existe para QA. Por eso **cualquier cambio de codigo lleva su cambio en `qa/` en el mismo turno**, antes de dar la tarea por terminada.

## Reglas

- Cero emojis en `qa/`. Ninguno: ni checks, ni flechas o triangulos de prioridad, ni caras. Fechas como `(hecho AAAA-MM-DD)`, prioridades como `#prioridad-alta`.
- Contenido completo, sin referencias a Obsidian, al vault ni a rutas `D:/`.
- Markdown estandar que GitHub muestre bien: sin frontmatter, sin `[[enlaces]]` de wiki.
- Nada de git add, commit ni push. El usuario hace el commit.
- El codigo manda: si `qa/` dice otra cosa, se corrige `qa/`.

## Archivos de qa/

| Archivo | Que contiene |
| --- | --- |
| `README.md` | Que hay en la carpeta y en que orden leerlo |
| `HistoriasDeUsuario.md` | Historias `HU-MOD-NN` con criterios de aceptacion, prioridad y la seccion del plan donde se prueban |
| `AnalisisDeSistema.md` | Stack y version, mapa funcional, datos, estados, reglas `RN-NN`, permisos, no funcionales, riesgos `R-NN`, pruebas automatizadas, pendientes del producto, puntos por confirmar |
| `PlanDePruebas.md` | Solo Objetivo, Alcance y Pruebas (checklist), mas Bugs generales y Cambios futuros |

El plan **no** lleva estrategia, entornos, criterios, instrucciones para reportar bugs, tabla de marcadores ni trazabilidad. El equipo de QA no los usa. No agregarlos.

## Que cambio en el codigo lleva a que cambio en qa/

| Cambio | Que actualizar |
| --- | --- |
| Feature nueva | Historia nueva (ID siguiente del modulo) en `HistoriasDeUsuario.md`; sus reglas en `AnalisisDeSistema.md` (Reglas de negocio, Mapa funcional, Datos, Estados si aplica); sus casos en `PlanDePruebas.md` dentro de la seccion de su modulo (o una seccion nueva). Si estaba en "Pendientes del producto", quitarla de ahi |
| Cambio de comportamiento | Ajustar criterios de la historia, la regla `RN-NN` y los casos o condiciones afectados del checklist. Si un caso ya marcado `[x]` cambia de comportamiento, desmarcarlo para que QA lo vuelva a probar |
| Bug corregido | Si el bug esta en el checklist, marcarlo `- [x] ... (hecho AAAA-MM-DD)`. Si no estaba, agregar un caso o condicion que lo cubra para regresion |
| Bug encontrado y no corregido | Agregarlo debajo del caso que falla: `- [ ] que pasa #bug #funcional` (o `#visual`) |
| Cambio de UI o de textos | Casos visuales o de idioma del modulo; si cambia como se llega a una pantalla, el Mapa funcional |
| Cambio de modelo, almacenamiento o migracion | Datos y Estados del analisis; casos de persistencia y de actualizacion desde la version anterior |
| Permiso nuevo o cambiado | Integraciones y permisos del analisis; casos de conceder y negar |
| Version, dependencia o `minSdk` | Tabla de Stack del analisis |
| Funcion eliminada | Historia a "Historias retiradas" (conserva su ID); en el plan, sacarla del Alcance y mover sus casos a una seccion "(eliminado)" en vez de borrarlos |
| Refactor sin cambio visible | Nada en `qa/`, pero revisarlo: si toco una zona de riesgo `R-NN`, decirlo al usuario para que QA haga regresion |
| Pendiente del producto decidido o descartado | "Pendientes del producto" del analisis |

## Donde mirar en Gakoken

| Cambio en el codigo | Donde mirar |
| --- | --- |
| Pestanas y navegacion | `lib/screens/main_screen.dart` |
| Explorar carpetas | `lib/features/browser/` |
| Favoritos | `lib/features/favorites/` |
| Prueba de rendimiento (Fase 1) | `lib/features/benchmark/`, `rust/src/api/bench.rs` |
| Motor: indice, busqueda, recorrido | `rust/src/` (regenerar el puente si cambia `rust/src/api/`) |
| Logos y tipos de archivo | `lib/core/files/file_kind.dart`, `lib/core/widgets/file_kind_icon.dart` |
| Permiso de almacenamiento | `lib/core/services/storage_permission_service.dart`, `android/app/src/main/AndroidManifest.xml` |
| Bottom sheets y barra de navegacion | `lib/core/widgets/gakoken_bottom_sheet.dart` |
| Idioma y temas | `lib/features/settings/`, `lib/core/theme/color_extensions.dart` |
| Textos e idiomas | `lib/l10n/app_*.arb` |

## Pasos

1. Ver que cambio (`git diff` y `git status`, solo lectura).
2. Con la tabla de arriba, decidir que archivos de `qa/` tocar.
3. Editar. IDs estables: nunca renumerar `HU`, `RN` ni `R`. No borrar casos ni bugs con fecha; no reordenar el checklist.
4. Revisar:
   - Cada historia nueva dice en que seccion del plan se prueba y esa seccion existe.
   - Cada `RN-NN` citado existe en el analisis.
   - Cero emojis: `LC_ALL=C.UTF-8 grep -nP "[\x{2190}-\x{2BFF}\x{1F000}-\x{1FFFF}\x{FE0F}]" qa/*.md` no debe regresar nada.
   - Nada de `[[`, `D:/`, Obsidian o vault en `qa/`.
5. Decir al usuario en dos o tres lineas que se cambio en `qa/`, o por que no hizo falta.
