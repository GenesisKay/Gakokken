---
name: documentacion-qa
description: Crea o actualiza la documentacion para el equipo de QA de cualquier proyecto de software - historias de usuario, analisis de sistema y plan de pruebas - dentro de la carpeta qa/ del repo, completa y autocontenida. Usar cuando el usuario pida documentacion de QA, historias de usuario, analisis de sistema, plan de pruebas, casos de prueba, matriz de trazabilidad o "dejar listo un proyecto para QA". Tambien despues de terminar una feature para agregar su historia y sus casos.
---

# Documentacion para QA

Skill generica. Vale para cualquier proyecto.

El equipo de QA solo tiene acceso al repo remoto. Por eso toda la documentacion de QA vive **completa** en la carpeta `qa/` en la raiz del repo: quien abra el repo en GitHub debe poder leer y ejecutar todo sin ir a otro lado.

## Reglas obligatorias

1. **Destino unico:** `<raiz del repo>/qa/`. Nunca en Obsidian ni en otra carpeta. Esta regla gana sobre cualquier regla del proyecto tipo "Obsidian primero" o "el plan de pruebas vive en el vault"; si el repo tiene una regla asi, actualizarla para que diga que QA vive en `qa/`.
2. **Autocontenida:** el contenido va escrito completo, no como referencia. Nada de enlaces ni rutas a Obsidian, al vault, a `D:/...` ni a notas fuera del repo. Si un dato de QA vive en otro lado (stack, tareas pendientes, reglas del producto), se escribe dentro de `qa/`.
3. **Cero emojis.** Ninguno: ni caras, ni manos, ni checks, ni estrellas, ni flechas o triangulos de prioridad, ni los marcadores del plugin Tasks de Obsidian. Si se migra contenido que los trae, se convierten a texto:

| Marcador | Texto |
| --- | --- |
| Check de hecho con fecha | `(hecho AAAA-MM-DD)` |
| Prioridad maxima (triangulo rojo) | `#prioridad-maxima` |
| Prioridad alta (doble flecha arriba) | `#prioridad-alta` |
| Prioridad media (flecha arriba) | `#prioridad-media` |
| Prioridad baja (flecha abajo) | `#prioridad-baja` |

4. **Markdown estandar** que GitHub muestre bien: sin frontmatter de Obsidian, sin `[[enlaces]]` de wiki, sin bloques de consulta `tasks`.
5. Nada de git add, commit ni push. El usuario hace el commit.

## Archivos

| Archivo | Contenido |
| --- | --- |
| `qa/README.md` | Que hay en la carpeta y en que orden leerlo |
| `qa/HistoriasDeUsuario.md` | Roles e historias con criterios de aceptacion |
| `qa/AnalisisDeSistema.md` | Contexto, plataformas, stack, mapa funcional, datos, estados, reglas de negocio, permisos, no funcionales, riesgos, pruebas automatizadas, pendientes del producto y puntos por confirmar |
| `qa/PlanDePruebas.md` | Solo tres cosas: Objetivo, Alcance y Pruebas (el checklist de casos, con sus bugs). Despues del checklist pueden ir "Bugs generales" y "Cambios futuros" |

El plan de pruebas **no** lleva estrategia, entornos, criterios de entrada o salida, como reportar bugs, tabla de marcadores ni trazabilidad: asi trabaja el equipo de QA del usuario y esas secciones no le aportan. No agregarlas aunque parezcan buena practica.

Plantillas en [plantillas/](plantillas/).

## 1. Leer las fuentes

En este orden, sin inventar nada que no salga de ellas:

1. `qa/` del repo, si ya existe (se actualiza, no se reescribe).
2. Notas del proyecto fuera del repo (por ejemplo Obsidian): nota central, documentacion tecnica, plan de pruebas viejo. Su contenido de QA se **trae** a `qa/`.
3. Documentacion del repo (`context/`, `docs/`, `README.md` solo si no esta marcado como desactualizado).
4. Codigo: features y pantallas, modelos y servicios, permisos del manifest, archivos de idioma, tests.

Si el codigo y la documentacion no coinciden, manda el codigo. Anotar la diferencia en "Puntos por confirmar".

## 2. Escribir

- IDs estables que nunca se renumeran: historias `HU-<MOD>-NN`, reglas `RN-NN`, riesgos `R-NN`. Lo retirado se marca "Retirada" y conserva su ID.
- Idioma del proyecto (en Morobu, espanol de Mexico).
- Lo que no se sepa: "Por confirmar" y la pregunta concreta.
- Las historias describen lo que el producto hace hoy. Lo que falta se lista en "Pendientes del producto" del analisis, escrito completo (no como enlace).
- Dentro de `qa/` cada dato se escribe en un solo archivo: reglas de negocio en el analisis, criterios en las historias, pasos y condiciones en el plan. Los demas citan el ID (`RN-04`, `HU-MOV-01`) o el nombre de la seccion en texto.
- Checklist del plan: `- [ ]` por caso, subcondiciones con `#condición`, bugs con `#bug` y `#funcional` o `#visual`. Si se migra un checklist existente, no se reordena ni se pierden casos, fechas ni bugs; solo se convierten los marcadores a texto.

## 3. Revisar antes de entregar

- [ ] Cada historia dice en que seccion del checklist estan sus pruebas, y esa seccion existe en el plan.
- [ ] El plan solo tiene Objetivo, Alcance y Pruebas (mas Bugs generales y Cambios futuros si existen).
- [ ] Cada `RN-NN` citado existe en el analisis.
- [ ] Ningun `[[`, ninguna ruta `D:/`, ninguna mencion a Obsidian o al vault dentro de `qa/`.
- [ ] Cero emojis. Revisar con un buscador de caracteres fuera de ASCII y letras acentuadas, por ejemplo:
  `LC_ALL=C.UTF-8 grep -nP "[\x{2190}-\x{2BFF}\x{1F000}-\x{1FFFF}\x{FE0F}]" qa/*.md`
- [ ] Si el contenido de QA estaba fuera del repo (por ejemplo un `PlanDePruebas-<Proyecto>.md` en Obsidian), esa nota se borra una vez migrada a `qa/`, y en la nota central o el hub del proyecto queda una linea que diga que QA vive en `qa/` del repo. Nunca dos versiones.
- [ ] El checklist sale del codigo actual, no de notas viejas: cada caso describe algo que la UI de hoy permite hacer. Casos de funciones eliminadas, textos sin usar o pantallas sin camino de navegacion no van en el plan (se anotan en "Puntos por confirmar" del analisis).

## 4. Mantenimiento

Cada proyecto con `qa/` tiene su skill de proyecto `sync-qa` (en `.claude/skills/` y `.cursor/skills/` del repo), que obliga a actualizar `qa/` con cualquier cambio de codigo. Al crear `qa/` en un proyecto nuevo, copiar esa skill desde un proyecto que ya la tenga (por ejemplo Ajoruto) y cambiar el nombre del proyecto y sus ejemplos.

Al final, decir al usuario en dos o tres lineas que se agrego y que quedo "Por confirmar".

## 5. Donde vive esta skill

La version maestra esta en el directorio central `.claude/skills/documentacion-qa/` (carpeta Software). Cada repo de la serie Herramientas Origami (Ajoruto, Zontle, Eloisa, Gakoken, Bioka) lleva una copia identica en `.claude/skills/` y `.cursor/skills/`, para que viaje con el repo. Si se cambia esta skill, se cambia la maestra y se vuelve a copiar a todos los repos; nunca editar una copia sola.
