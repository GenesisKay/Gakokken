# Gakoken - Historias de usuario

Reglas de negocio (`RN-NN`) en `AnalisisDeSistema.md`. Pasos de prueba en `PlanDePruebas.md`.

Describe lo que Gakoken hace hoy (al 2026-10-20). Gakoken es un prototipo: explora carpetas en pestañas con historial, en la memoria interna, tarjetas SD y USB, busca en todo el teléfono, ordena y filtra, muestra el espacio usado, abre y comparte archivos, guarda favoritos, muestra miniaturas y copia, mueve, renombra y borra (a una papelera) con selección múltiple. Lo que falta por construir está en la sección "Pendientes del producto" de `AnalisisDeSistema.md`.

## Roles

| Rol | Quién es |
| --- | --- |
| Usuario | Persona con un teléfono Android que quiere encontrar y manejar sus archivos rápido. Es el único rol: no hay cuentas ni red. |

## Cómo leer cada historia

- **Historia:** Como rol, quiero acción, para beneficio.
- **Criterios de aceptación:** resultado que debe cumplirse. Citan reglas `RN-NN` del análisis.
- **Pruebas:** sección del plan donde están los pasos.
- **Prioridad:** Alta, Media o Baja según el impacto si falla.

# General

## HU-GEN-01 Instalar y navegar

Como usuario, quiero instalar Gakoken y moverme entre sus pestañas, para llegar a cada parte de la app.

Criterios de aceptación:
- Gakoken se instala sin reemplazar ni afectar a otras apps de la serie, como Eloisa (RN-01).
- La barra inferior tiene cuatro pestañas: Explorar, Favoritos, Espacio y Ajustes. Cambiar de pestaña no pierde lo que había en las otras.

Prioridad: Alta. Pruebas: sección "General" de PlanDePruebas.md

# Explorar

## HU-EXP-01 Dar permiso y ver el almacenamiento

Como usuario, quiero que Gakoken me pida el acceso a mis archivos y luego me muestre mi almacenamiento, para empezar a explorar.

Criterios de aceptación:
- Sin el permiso, Explorar muestra la explicación y el botón Dar permiso, sin listado ni íconos de arriba (RN-02).
- Dar permiso lleva a los ajustes de Android; al regresar sin concederlo, sigue la explicación y la app no se cierra.
- Al regresar de los ajustes de Android con el permiso concedido, aparece el contenido de Interno sin tocar nada más.
- Con el permiso, Explorar abre en Interno (RN-11).

Prioridad: Alta. Pruebas: sección "Explorar" de PlanDePruebas.md

## HU-EXP-02 Navegar carpetas

Como usuario, quiero entrar y salir de carpetas y saber dónde estoy, para llegar a cualquier archivo.

Criterios de aceptación:
- Tocar una carpeta la abre; el título dice en qué carpeta estoy y al tocarlo veo las carpetas de arriba para saltar a cualquiera (RN-11).
- El botón atrás del sistema va a la carpeta anterior; sin historial sube una carpeta; en Interno sin historial sale de la app (RN-11).
- Carpetas primero y luego archivos, por nombre (RN-12). Los ocultos no aparecen, salvo que se activen en Ajustes (RN-13).
- Las carpetas grandes muestran sus primeras entradas al instante y siguen cargando (RN-14).
- Una carpeta vacía o sin acceso lo dice; deslizar hacia abajo recarga (RN-20).

Prioridad: Alta. Pruebas: sección "Explorar" de PlanDePruebas.md

## HU-EXP-03 Reconocer el tipo de cada archivo

Como usuario, quiero ver de un vistazo qué tipo de archivo es cada uno, para encontrar lo que busco sin leer extensiones.

Criterios de aceptación:
- Cada archivo lleva el logo de su tipo con su color fijo; las carpetas, el color del tema (RN-16).
- Los colores de los logos no cambian al cambiar de tema, salvo el de las carpetas.
- Imágenes y PDF muestran una miniatura en lugar del logo, si está activada en Ajustes (RN-25).

Prioridad: Media. Pruebas: sección "Explorar" de PlanDePruebas.md

## HU-EXP-04 Elegir la vista

Como usuario, quiero elegir cómo se ve el listado, para ver más archivos o más datos de cada uno.

Criterios de aceptación:
- El ícono de ajustes arriba a la derecha abre una hoja con Vista (Lista, Detalles, Cuadrícula y Galería, la actual marcada), Ordenar por y Mostrar solo (RN-15).
- En Galería las fotos y los videos se ven grandes, sin nombre encima; carpetas y documentos muestran logo y nombre (RN-15).
- La vista elegida aplica a todas las carpetas y se mantiene al cerrar la app (RN-15).

Prioridad: Media. Pruebas: sección "Explorar" de PlanDePruebas.md

## HU-EXP-05 Trabajar con pestañas

Como usuario, quiero tener varias carpetas abiertas en pestañas y moverme atrás y adelante en cada una, como en el Explorador de Windows, para pasar de una a otra sin perder dónde estaba.

Criterios de aceptación:
- + abre una pestaña nueva en Interno; Abrir en pestaña nueva abre la carpeta elegida (RN-26).
- Con dos o más pestañas se ve la tira; tocar una la activa y la X la cierra; siempre queda una (RN-26).
- Cada pestaña recuerda su carpeta, su filtro y su historial; las flechas atrás y adelante, arriba a la izquierda, recorren el historial (RN-27).
- Al cerrar y abrir la app vuelven las mismas pestañas (RN-26).

Prioridad: Media. Pruebas: sección "Pestañas" de PlanDePruebas.md

## HU-EXP-06 Usar tarjetas SD y USB

Como usuario, quiero ver y navegar mi tarjeta SD y un USB conectado, para manejar también esos archivos.

Criterios de aceptación:
- En Explorar, Memorias en el menú del título (en Espacio, la primera parte del breadcrumb) muestra Interno, la SD y el USB con su nombre y espacio libre (RN-28).
- Elegir una memoria abre su raíz; no se puede subir más arriba (RN-11).
- La SD sale en Buscar y se indexa; el USB no (RN-21, RN-23).
- Quitar una memoria no cierra la app (RN-28).
- Al final de Memorias, en Explorar, está Raíz del sistema para ver las carpetas de Android desde `/` (RN-28).

Prioridad: Media. Pruebas: sección "Memorias" de PlanDePruebas.md

## HU-EXP-07 Ver al momento lo que cambia otra app

Como usuario, quiero que la carpeta abierta muestre lo que otra app acaba de crear o borrar, para no tener que recargar a mano.

Criterios de aceptación:
- Si otra app crea, borra o renombra algo en la carpeta abierta, la lista se pone al día sola en menos de un segundo, sin vaciarse ni saltar de posición (RN-36).
- Lo nuevo aparece también en Buscar sin Volver a indexar (RN-21, RN-36).
- Al volver a Gakoken desde otra app, la carpeta abierta ya está al día (RN-36).

Prioridad: Media. Pruebas: sección "Explorar" de PlanDePruebas.md

# Archivos

## HU-ARC-01 Abrir un archivo

Como usuario, quiero abrir cualquier archivo con la app que lo soporte, para verlo o usarlo.

Criterios de aceptación:
- Tocar un archivo, o Abrir en su hoja, muestra siempre el selector "Abrir con" para elegir la app (RN-17).
- Si ninguna app puede, aparece "Ninguna app puede abrir este archivo." y la app no se cierra (RN-17).
- Un APK abre el instalador de Android (RN-17).

Prioridad: Alta. Pruebas: sección "Archivos" de PlanDePruebas.md

## HU-ARC-02 Compartir un archivo

Como usuario, quiero compartir un archivo con otra app, para mandarlo o guardarlo en otro lado.

Criterios de aceptación:
- Mantener presionado un archivo y tocar Compartir abre el menú Compartir del sistema con ese archivo (RN-18).
- Las carpetas no tienen Compartir (RN-18).
- Copiar ruta, en la misma hoja, pone la ruta completa del archivo o carpeta en el portapapeles del teléfono para pegarla en otra app (RN-18).

Prioridad: Alta. Pruebas: sección "Archivos" de PlanDePruebas.md

# Favoritos

## HU-FAV-01 Marcar y quitar favoritos

Como usuario, quiero marcar archivos y carpetas como favoritos, para tenerlos a la mano.

Criterios de aceptación:
- Mantener presionado un elemento y tocar Agregar a favoritos lo agrega; si ya está, la opción dice Quitar de favoritos (RN-18).
- Un elemento no se puede agregar dos veces.
- Los favoritos se mantienen al cerrar y abrir la app.

Prioridad: Alta. Pruebas: sección "Favoritos" de PlanDePruebas.md

## HU-FAV-02 Usar los favoritos

Como usuario, quiero abrir mis favoritos desde su pestaña y saber si alguno ya no existe, para llegar rápido y no confundirme.

Criterios de aceptación:
- Sin favoritos, la pestaña explica cómo agregarlos.
- La lista va del más reciente al más viejo y muestra dónde está cada uno (RN-19).
- Tocar una carpeta la abre en Explorar; tocar un archivo lo abre (RN-19).
- Si uno ya no existe, se marca "Ya no existe" y solo se puede quitar (RN-19).

Prioridad: Media. Pruebas: sección "Favoritos" de PlanDePruebas.md

# Acciones

## HU-ACC-01 Seleccionar varios

Como usuario, quiero seleccionar varios archivos y carpetas, para hacer algo con todos a la vez.

Criterios de aceptación:
- Mantener presionado un elemento lo selecciona; luego tocar marca o desmarca (RN-29).
- Arriba se ve cuántos hay, Información, la estrella de favoritos, Seleccionar todo y la X para soltar; atrás también suelta (RN-29).
- Información muestra tipo, tamaño, contenido, fecha y ubicación de uno, o el total de varios (RN-29).
- La estrella agrega todos los seleccionados a favoritos de una vez, o los quita si ya lo eran (RN-29).
- Abajo están Copiar, Cortar, Compartir, Renombrar, Eliminar y Más; Renombrar y Más solo con uno, Compartir solo con archivos.

Prioridad: Alta. Pruebas: sección "Selección y acciones" de PlanDePruebas.md

## HU-ACC-02 Copiar y mover

Como usuario, quiero copiar o mover archivos y carpetas a otra carpeta, incluso de otra pestaña o memoria, sin que la app se trabe, para organizar mis archivos.

Criterios de aceptación:
- Copiar o Cortar y luego Pegar aquí en la carpeta de destino (RN-30).
- Si hay nombres repetidos, se pregunta una vez qué hacer (RN-31).
- Se ve el progreso y se puede cancelar sin dejar archivos a medias (RN-32).
- Al terminar, la carpeta, el espacio usado y la búsqueda ya lo reflejan (RN-32).

Prioridad: Alta. Pruebas: sección "Selección y acciones" de PlanDePruebas.md

## HU-ACC-03 Renombrar

Como usuario, quiero cambiar el nombre de un archivo o carpeta, para ordenarlos a mi manera.

Criterios de aceptación:
- El diálogo trae el nombre listo para escribir encima sin perder la extensión (RN-33).
- Un nombre que ya existe o no es válido no se acepta y se avisa (RN-33).
- Si era favorito, sigue en Favoritos con el nombre nuevo (RN-33).

Prioridad: Media. Pruebas: sección "Selección y acciones" de PlanDePruebas.md

## HU-ACC-04 Eliminar sin miedo

Como usuario, quiero que lo que borro vaya a una papelera, para recuperarlo si me equivoco.

Criterios de aceptación:
- Eliminar manda a la papelera y el aviso ofrece Deshacer y Ver papelera, que abre la Papelera (RN-34).
- En Ajustes, Papelera, se ve lo borrado con de dónde venía y los días que le quedan; se restaura o se borra para siempre (RN-35).
- Pasados 30 días se borra solo; puedo elegir otro número de días (RN-35).

Prioridad: Alta. Pruebas: sección "Papelera" de PlanDePruebas.md

# Ordenar y filtrar

## HU-ORD-01 Ordenar y filtrar una carpeta

Como usuario, quiero ordenar una carpeta y ver solo ciertos tipos de archivo, para encontrar rápido lo más nuevo, lo más pesado o solo mis PDF.

Criterios de aceptación:
- En la hoja de ajustes (Vista, orden y filtro), un toque a Nombre, Fecha, Tamaño o Tipo ordena de menor a mayor y otro toque de mayor a menor; una flecha lo indica; las carpetas siempre van primero (RN-12).
- Los encabezados de Detalles funcionan igual (RN-12).
- El orden se usa en todas las carpetas y se mantiene al cerrar la app (RN-12).
- Mostrar solo deja ver solo los tipos marcados, con las carpetas siempre visibles; arriba de la lista se ve un chip por tipo filtrado con X para quitarlo (RN-22).

Prioridad: Media. Pruebas: sección "Ordenar y filtrar" de PlanDePruebas.md

# Buscar

## HU-BUS-01 Buscar en todo el teléfono

Como usuario, quiero buscar un archivo por su nombre en todo el teléfono, aunque me equivoque al escribir, para encontrarlo sin saber dónde está.

Criterios de aceptación:
- La primera vez Gakoken indexa la memoria interna y la SD y lo avisa en Explorar con el conteo; las siguientes veces la búsqueda funciona al instante (RN-21).
- Los resultados salen mientras se escribe, con dónde está cada uno (RN-23).
- Un error de escritura (por ejemplo "wahtsapp") igual encuentra el archivo (RN-23).
- Los archivos ocultos no salen, salvo que se active Incluir en Buscar (RN-13).
- Tocar un archivo lo abre; tocar una carpeta la abre en Explorar (RN-23).

Prioridad: Alta. Pruebas: sección "Buscar" de PlanDePruebas.md

## HU-BUS-02 Limitar la búsqueda

Como usuario, quiero buscar solo en la carpeta donde estoy o solo un tipo de archivo, para tener menos resultados.

Criterios de aceptación:
- Fuera de la raíz de Interno o la SD aparece Solo en la carpeta actual, que incluye sus subcarpetas (RN-23).
- Los chips de tipo dejan solo los archivos de esos tipos (RN-23).

Prioridad: Media. Pruebas: sección "Buscar" de PlanDePruebas.md

# Espacio usado

## HU-ESP-01 Ver qué ocupa espacio

Como usuario, quiero ver cuánto ocupa una carpeta, por tipo y por lo que contiene, para saber qué borrar.

Criterios de aceptación:
- Está en la pestaña Espacio de la barra inferior y abre en Interno; también se llega desde la hoja de una carpeta (RN-24).
- Muestra el total con subcarpetas y cuántos archivos y carpetas hay (RN-24).
- Por tipo muestra cada tipo con su logo, tamaño, porcentaje y cantidad de archivos; tocar uno lista todos los archivos de ese tipo, del más pesado al más ligero, y ahí puedo buscar, ordenar y cambiar la vista (RN-24).
- Lo que más ocupa lista los hijos del más pesado al más ligero; tocar una carpeta entra a ella y atrás regresa (RN-24).
- Funciona también en la SD y en un USB (RN-24).
- Abre al instante con el índice listo; sin índice muestra el progreso (RN-24).

Prioridad: Media. Pruebas: sección "Espacio usado" de PlanDePruebas.md

# Configuración

## HU-CON-01 Idioma

Como usuario, quiero usar la app en español, inglés, francés o japonés, para entenderla en mi idioma.

Criterios de aceptación:
- La primera vez usa el idioma del teléfono si es uno de los cuatro; si no, inglés (RN-07).
- El idioma elegido se mantiene al cerrar y abrir la app (RN-09).

Prioridad: Baja. Pruebas: sección "Configuración" de PlanDePruebas.md

## HU-CON-02 Temas

Como usuario, quiero elegir, crear, importar y exportar temas, para que la app se vea como me gusta.

Criterios de aceptación:
- El tema por defecto es Gakoken (claro, naranja) y su par oscuro es Nekokag (RN-08).
- Los temas integrados se aplican y exportan, pero no se editan ni se borran (RN-08).
- Los temas propios se crean, editan, aplican, exportan y borran.
- Importar acepta un JSON pegado o un archivo; un JSON inválido muestra un error y no crea nada (RN-10).
- El tema elegido se mantiene al cerrar y abrir la app (RN-09).

Prioridad: Baja. Pruebas: sección "Configuración" de PlanDePruebas.md

## HU-CON-03 Vista previa

Como usuario, quiero elegir qué tipos muestran miniatura y cuáles el logo de color, para ver mis fotos, videos y PDF o una lista más limpia.

Criterios de aceptación:
- Ajustes, Vista previa, tiene un interruptor para Imágenes, otro para Videos y otro para PDF, los tres activados al instalar (RN-25).
- Apagar uno cambia las miniaturas por el logo en todas las pantallas, sin reiniciar (RN-25).
- La elección se mantiene al cerrar la app.

Prioridad: Baja. Pruebas: sección "Configuración" de PlanDePruebas.md

## HU-CON-04 Índice

Como usuario, quiero ver el estado del índice y volver a indexar, para que la búsqueda incluya lo más reciente.

Criterios de aceptación:
- Ajustes, Índice, muestra cuántos archivos tiene, desde cuándo está al día y cuánto tardó la última revisión, o el progreso si está indexando (RN-21).
- Al abrir la app, lo creado o borrado con otras apps aparece en Buscar sin Volver a indexar (RN-21).
- Volver a indexar recorre todo; el botón se desactiva mientras tanto (RN-21).

Prioridad: Baja. Pruebas: sección "Configuración" de PlanDePruebas.md

## HU-CON-05 Archivos ocultos

Como usuario, quiero decidir si veo los archivos ocultos en Explorar y, por separado, si salen al buscar, para encontrarlos solo cuando los necesito.

Criterios de aceptación:
- Ajustes, Archivos ocultos, tiene Mostrar en Explorar e Incluir en Buscar, los dos apagados al instalar (RN-13).
- Activar Mostrar en Explorar los muestra en la carpeta abierta sin reiniciar (RN-13).
- Activar Incluir en Buscar los hace salir en los resultados (RN-13, RN-23).
- La fila de Ajustes dice dónde están visibles.

Prioridad: Baja. Pruebas: sección "Configuración" de PlanDePruebas.md

# Historias retiradas

| ID | Motivo | Fecha |
| --- | --- | --- |
| HU-REN-01 | Dar acceso a todos los archivos desde la prueba de rendimiento. La prueba se quitó al cerrar la Fase 1; el permiso ahora se pide en Explorar (HU-EXP-01) | 2026-10-20 |
| HU-REN-02 | Medir la velocidad del motor (Rust contra Dart). La Fase 1 eligió Rust y la prueba se quitó de la app | 2026-10-20 |
