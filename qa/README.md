# Gakoken - Documentación de QA

Gakoken es un explorador de archivos para Android (después Linux y Windows) cuyo objetivo principal es la rapidez: indexar todo el almacenamiento y buscar al instante. Está en etapa de prototipo. Esta carpeta tiene todo lo que el equipo de QA necesita para probarlo.

## Orden de lectura

| Archivo | Para qué |
| --- | --- |
| [AnalisisDeSistema.md](AnalisisDeSistema.md) | Entender el sistema: stack, pantallas, datos, estados, reglas de negocio (`RN-NN`), permisos, riesgos (`R-NN`), pendientes del producto y puntos por confirmar |
| [HistoriasDeUsuario.md](HistoriasDeUsuario.md) | Qué puede hacer el usuario hoy (`HU-MOD-NN`), con criterios de aceptación y prioridad |
| [PlanDePruebas.md](PlanDePruebas.md) | Objetivo, alcance y el checklist de casos |

## Cómo trabajar

1. Instalar el APK de la fase en curso en un teléfono Android real.
2. Ejecutar el checklist de `PlanDePruebas.md`. Marcar `- [x]` lo que pasa.
3. Reportar cada bug debajo del caso que falla, con `#bug` y `#funcional` o `#visual`.

## Convenciones

- IDs estables: historias `HU-MOD-NN`, reglas `RN-NN`, riesgos `R-NN`. No se renumeran.
- Marcadores en texto: `#condición`, `#bug`, `#funcional`, `#visual`, `#prioridad-...`, `(hecho AAAA-MM-DD)`.
- Sin emojis.
