# Gakoken - Análisis de sistema

Lo que el equipo de QA necesita saber para probar Gakoken. Historias en `HistoriasDeUsuario.md`, casos en `PlanDePruebas.md`.

# Contexto

- **Qué es:** explorador de archivos cuyo objetivo principal es la rapidez: indexar todo el almacenamiento del teléfono y buscar al instante. Forma parte de la serie Herramientas Origami (con Eloisa, Ajoruto, Zontle y otras).
- **Etapa:** prototipo, construido por fases. Cada fase se entrega como APK y se prueba en un teléfono real. Al 2026-10-20 están hechas la Fase 0 (base y motor Rust conectado), la Fase 1 (la prueba de rendimiento eligió Rust: entre 3 y 4,6 veces más rápido que Dart; la prueba ya se quitó de la app), la Fase 2 (explorar), la Fase 3 (índice y búsqueda), la Fase 4 (ordenar, filtrar y espacio usado), la Fase 5 (abrir, compartir y favoritos), las miniaturas de imágenes y PDF, la Fase 5b (pestañas con historial, memorias externas, archivos ocultos, ordenar con un toque y la pestaña Espacio) y la Fase 6 (selección múltiple, copiar, cortar, pegar, renombrar, eliminar y papelera). El 2026-10-21 se hizo la Fase 7: el índice se pone al día leyendo solo las carpetas que cambiaron, la carpeta abierta se actualiza sola cuando otra app cambia algo, miniaturas de video, caché de miniaturas y la vista Galería.
- **Plataformas:** Android (la única que se prueba hoy). Linux y Windows vienen después; sus runners existen pero no se prueban.
- **Conectividad:** ninguna. Sin red, sin cuentas, sin backend.
- **Versión actual:** paquete `gakoken`, versión `1.0.0+1`, applicationId `com.gakoken.gakoken`.

# Stack

| Área | Elección |
| --- | --- |
| UI | Flutter 3.35 / Dart 3.9, Material 3 |
| Motor | Rust (crate `gakoken_core`) conectado con `flutter_rust_bridge` 2.13. Lista carpetas, indexa, busca y calcula el espacio usado |
| Índice | En memoria dentro del motor y copia en SQLite (`index.db`, `rusqlite`) para abrir rápido la siguiente vez; recorrido en paralelo (`jwalk`); búsqueda difusa (`nucleo-matcher`) más tolerancia a errores de escritura |
| Configuración y favoritos | Hive (`hive_ce`): cajas `settings`, `themes` y `favorites` |
| Abrir archivos | Selector "Abrir con" de Android (código nativo en `MainActivity.kt` con `FileProvider`) |
| Compartir | `share_plus` 12 (menú Compartir del sistema) |
| Copiar, mover, renombrar y borrar | Motor Rust (`rust/src/ops.rs`): tareas con progreso y cancelación, una a la vez |
| Miniaturas | Imágenes decodificadas por Flutter ya reducidas; PDF con `PdfRenderer` de Android (primera página, en el caché de la app) |
| Permisos | `permission_handler` 11.4, `device_info_plus` para saber la versión de Android |
| Idiomas | ARB: es (plantilla), en, fr, ja |
| Tipografía | Montserrat (`google_fonts`) |
| Android | minSdk 24 (Android 7.0); targetSdk el de Flutter |
| APK de prueba | Release solo para arm64 (unos 26 MB), firmado con la llave de debug hasta que Gakoken tenga la suya |

# Mapa funcional

| Módulo | Pantallas o vistas | Cómo se llega | Historias |
| --- | --- | --- | --- |
| General | Barra inferior con Explorar, Favoritos, Espacio y Ajustes | Al abrir la app | HU-GEN-01 |
| Explorar | Arriba: flechas atrás y adelante a la izquierda; al centro el título con el nombre de la carpeta actual (o de la memoria en su raíz) y una flecha hacia abajo que abre el menú de ubicación; a la derecha búsqueda y el ícono de ajustes (Vista, orden y filtro). Debajo: tira de pestañas (solo con dos o más, con + al final), chips de los tipos filtrados (solo con filtro), aviso del primer indexado, contenido de la carpeta en la vista elegida, pantalla de permiso (ahí el título dice Explorar) | Pestaña Explorar | HU-EXP-01 a 07, HU-ORD-01 |
| Memorias | Hoja con Interno, tarjetas SD y USB conectados, con espacio libre y total, y al final Raíz del sistema (solo en Explorar) | Explorar: menú del título, Memorias. Espacio: primera parte del breadcrumb | HU-EXP-06 |
| Menú de ubicación | Menú bajo el título con la ruta como árbol: arriba la memoria con su ícono y debajo cada carpeta un poco más metida que la anterior, con una flecha que baja desde su carpeta de arriba (la sangría deja de crecer a partir del séptimo nivel); la última es la actual, con carpeta abierta y marcada. Luego Memorias y Pestaña nueva | Explorar, tocar el título | HU-EXP-01, HU-EXP-06 |
| Vista, orden y filtro | Hoja con Vista (Lista, Detalles, Cuadrícula, Galería), Ordenar por (un toque ascendente, otro descendente) y Mostrar solo (tipos) | Explorar, ícono de ajustes | HU-ORD-01, HU-CON-03 |
| Buscar | Campo de búsqueda, Todo el teléfono o Solo en la carpeta actual, chips de tipo, resultados | Explorar, ícono de lupa | HU-BUS-01 y 02 |
| Espacio | Breadcrumb con la memoria, total, archivos y carpetas; Por tipo; Lo que más ocupa; ícono para abrir la carpeta en Explorar | Pestaña Espacio de la barra inferior (temporal), o Espacio usado en la hoja de una carpeta | HU-ESP-01 |
| Selección en Explorar | Barra de arriba con cuántos hay, X y Seleccionar todo; barra de abajo con Copiar, Cortar, Compartir, Renombrar, Eliminar y Más | Mantener presionado un elemento en Explorar | HU-ACC-01 a 04 |
| Pegar y progreso | Barra de abajo con lo copiado o cortado y Pegar aquí; panel de la tarea con porcentaje y Cancelar | Después de Copiar o Cortar; mientras copia o mueve | HU-ACC-02 |
| Opciones de un archivo o carpeta | Hoja inferior con miniatura o logo y nombre; Abrir, Compartir, Abrir en pestaña nueva y Espacio usado (carpetas, desde Explorar), Copiar ruta, Agregar o Quitar de favoritos, Renombrar y Eliminar | Más con un solo elemento seleccionado en Explorar; mantener presionado en Buscar, Favoritos o Espacio | HU-ARC-01 y 02, HU-FAV-01, HU-ESP-01, HU-ACC-03 y 04 |
| Papelera | Lista de lo borrado con de dónde venía y días restantes; Restaurar, Eliminar para siempre, Vaciar; Días en la papelera | Ajustes, Papelera | HU-ACC-04 |
| Favoritos | Lista de favoritos o el texto de cómo agregarlos | Pestaña Favoritos | HU-FAV-01 y 02 |
| Configuración | Idioma, Temas, Vista previa, Archivos ocultos, Papelera, Índice (hojas inferiores y pantallas de temas y papelera) | Pestaña Ajustes | HU-CON-01 a 05, HU-ACC-04 |

# Datos

| Dato | Dónde se guarda | Sobrevive a cerrar la app | Se exporta |
| --- | --- | --- | --- |
| Idioma y tema activo | Hive, caja `settings` | Sí | No |
| Temas propios | Hive, caja `themes` | Sí | JSON (portapapeles o archivo) |
| Vista del listado y orden (campo y dirección) | Hive, caja `settings` | Sí | No |
| Filtro por tipo (de cada pestaña de Explorar y de Buscar) | Solo en memoria | No: se limpia al cerrar la app | No |
| Pestañas abiertas (carpeta de cada una) y la activa | Hive, caja `settings` | Sí. El historial atrás y adelante no | No |
| Portapapeles (lo copiado o cortado) y selección | Solo en memoria | No | No |
| Papelera: lo borrado | Carpeta oculta `.gakoken-trash` en la raíz de cada memoria; de dónde venía y cuándo se borró en Hive, caja `trash` | Sí, 30 días o los que elija el usuario (Hive, `settings`, `trashDays`) | No |
| Archivos ocultos (en Explorar, en Buscar) | Hive, caja `settings` | Sí | No |
| Vista previa por tipo (Imágenes, Videos, PDF) | Hive, caja `settings` | Sí | No |
| Favoritos (ruta, si es carpeta, fecha en que se agregó) | Hive, caja `favorites` | Sí | No |
| Índice (ruta, nombre, tamaño, fecha, si es carpeta, si está oculto, cuándo se indexó) | `index.db` (SQLite) en la carpeta de soporte de la app; el recorrido completo lo reescribe todo, las puestas al día solo lo que cambió | Sí | No |
| Miniaturas de imágenes, videos y PDF (Android) | JPEG en el caché de la app (`thumbs/`); se rehacen si el archivo cambia. Si pasan de 150 MB, al abrir la app se borran las menos usadas hasta dejar 100 MB | Sí, hasta que Android limpie el caché | No |

# Estados

| Entidad | Estados | Transiciones |
| --- | --- | --- |
| Permiso de almacenamiento | Sin conceder, concedido | Dar permiso, ir a ajustes de Android y volver. Se puede quitar desde los ajustes de Android |
| Carpeta en Explorar | Cargando (círculo al centro), cargando con entradas ya visibles (barra fina arriba), lista, vacía, sin coincidencias con el filtro, sin acceso | Entrar a una carpeta, subir, tocar el breadcrumb, deslizar hacia abajo para recargar, cambiar el filtro |
| Índice | Sin índice, primer indexado (aviso en Explorar con el conteo), listo, listo y actualizándose (barra fina en Buscar, aviso en Espacio usado; solo en el recorrido completo), falló | Al abrir la app con permiso se carga y se pone al día (completo si el último recorrido completo tiene más de un día); al volver a la app; con cada cambio en la carpeta abierta; Volver a indexar en Ajustes |
| Favorito | Existe, ya no existe | Se revisa al entrar a la pestaña Favoritos, al agregar o quitar uno y al copiar, mover o borrar algo |
| Selección | Sin selección, con elementos seleccionados | Mantener presionado selecciona; tocar marca o desmarca; X, atrás o navegar la sueltan |
| Tarea de copiar o mover | En espera (otra en curso), corriendo, terminada, terminada con fallas, cancelada | Pegar aquí; Cancelar en el panel |
| Elemento borrado | En la papelera, restaurado, borrado para siempre | Eliminar, Deshacer o Restaurar, Eliminar para siempre o Vaciar, o al pasar los días elegidos (30 de fábrica) |
| Memoria externa (SD, USB) | Conectada, quitada | Se revisa al volver a la app y al abrir el selector de memorias. Quitar una SD hace que se vuelva a indexar |

# Reglas de negocio

| ID | Regla | Dónde vive en el código |
| --- | --- | --- |
| RN-01 | Gakoken usa el applicationId `com.gakoken.gakoken`, distinto al de las otras apps de la serie: se instala junto a ellas sin reemplazarlas. | `android/app/build.gradle.kts` |
| RN-02 | Gakoken necesita acceso a todo el almacenamiento. En Android 11 o más pide "Acceso a todos los archivos" (lleva a los ajustes del sistema); en Android 10 o menos, el permiso de almacenamiento clásico. Sin permiso no se puede explorar ni indexar. | `lib/core/services/storage_permission_service.dart`, `AndroidManifest.xml` |
| RN-03 | (Retirada el 2026-10-20: era el orden de la prueba de rendimiento, que se quitó de la app.) | - |
| RN-04 | Desde Android 11 ninguna app puede leer `Android/data` ni `Android/obb`. No es un bug: Explorar dice que no se puede abrir y el índice no las incluye. | Sistema Android |
| RN-05 | (Retirada el 2026-10-20: tabla de resultados de la prueba de rendimiento.) | - |
| RN-06 | (Retirada el 2026-10-20: progreso de la prueba de rendimiento.) | - |
| RN-07 | Idiomas: Español (es_MX), English (en_US), Français y 日本語. La primera vez se usa el del teléfono si es uno de ellos; si no, inglés. | `lib/core/services/locale_service.dart` |
| RN-08 | Temas integrados: Gakoken (default, claro, basado en gatos naranjas), Nekokag (su par oscuro), Eloisa y los de la serie (Asiole, Ajoruto, Oturoja, Manubu, Ubunam, Zontle, Eltnoz, Bioka, Akoib). Los integrados no se editan ni se borran; los propios sí. | `lib/core/theme/color_extensions.dart`, `lib/features/settings/` |
| RN-09 | Idioma y tema activo se guardan y se mantienen al cerrar y abrir la app. | `lib/core/storage/hive_bootstrap.dart` |
| RN-10 | Importar un tema acepta JSON pegado o un archivo JSON. Si el JSON no es válido, muestra un error y no crea el tema. | `lib/features/settings/presentation/pages/themes_screen.dart` |
| RN-11 | Explorar, recién instalada la app, empieza en Raíz del sistema (`/`); en Linux y Windows, en la carpeta personal. Cada memoria (Interno = `/storage/emulated/0`, SD, USB) es su propia raíz: dentro de ella no se puede subir más arriba. Para volver a `/` está Raíz del sistema en el selector de memorias (RN-28). En Explorar la ruta no se muestra completa: el título es la carpeta actual (o la memoria en su raíz) y al tocarlo se abre un menú con la ruta como árbol, de la memoria a la carpeta actual (marcada); tocar una va ahí; luego Memorias (abre el selector de memorias) y Pestaña nueva. Espacio sigue con su breadcrumb. En Explorar, el botón atrás del sistema va a la carpeta anterior del historial de la pestaña; sin historial sube una carpeta; en la raíz sin historial, sale de la app. En Espacio, atrás sube dentro de la pestaña. En Favoritos y Ajustes, atrás sale de la app. | `lib/features/browser/presentation/controllers/browser_controller.dart`, `lib/screens/main_screen.dart` |
| RN-12 | Orden del listado: las carpetas siempre van primero. Se ordena por Nombre (sin distinguir mayúsculas), Fecha, Tamaño o Tipo, ascendente o descendente; si empatan, por nombre. En carpetas, Tamaño es lo que pesan con sus subcarpetas según el índice. Un toque a un criterio (en la hoja de filtro o en un encabezado de Detalles) ordena de menor a mayor (A-Z, más viejo, más chico); otro toque al mismo, de mayor a menor. Una flecha marca el criterio y la dirección. Es uno solo para todas las carpetas y pestañas y se mantiene al cerrar la app. | `browser_controller.dart`, `lib/features/browser/presentation/widgets/sort_filter_sheet.dart` |
| RN-13 | Los nombres que empiezan con punto (`.thumbnails`, `.nomedia`) son ocultos. Por defecto no se muestran en Explorar, no cuentan en los elementos de una carpeta y no salen en Buscar (tampoco lo que está dentro de una carpeta oculta). Ajustes, Archivos ocultos, tiene dos interruptores separados: Mostrar en Explorar e Incluir en Buscar. Siempre cuentan en Espacio, porque ocupan lugar. | `rust/src/api/engine.rs`, `rust/src/index.rs` |
| RN-14 | El contenido llega por partes: las primeras entradas aparecen en cuanto se leen y una barra fina arriba indica que sigue cargando. Cuántos elementos tiene cada carpeta llega un momento después. | `rust/src/api/engine.rs` (`list_dir`) |
| RN-15 | Vistas: Lista (miniatura o logo, nombre y debajo tamaño o elementos y fecha), Detalles (columnas Nombre, Tamaño y Modificado; en carpetas, Tamaño es lo que pesan si el índice ya lo sabe y si no, cuántos elementos tienen), Cuadrícula (miniatura o logo grande y nombre en máximo 2 líneas) y Galería (celdas cuadradas: la miniatura ocupa toda la celda y no lleva nombre; lo que no tiene miniatura, como carpetas y documentos, muestra su logo y su nombre; seleccionado se ve con borde, tinte y una palomita arriba a la derecha). Se elige con el ícono de vista. Es una sola para todas las carpetas y se mantiene al cerrar la app. Lista compacta se quitó el 2026-10-21: quien la tenía elegida ve Lista. | `lib/features/browser/presentation/widgets/entry_views.dart` |
| RN-16 | Logo por tipo de archivo: cuadrado redondeado con color fijo (no cambia con el tema) y etiqueta blanca: PDF rojo "PDF", Word azul "W", Excel verde "X", PowerPoint naranja "P", Texto gris "T", Código índigo "</>", Imagen rosa "I", Video morado "V", Audio turquesa "A", Comprimido café "Z", APK verde olivo "APK", Libro mostaza "E"; desconocido gris con la primera letra de la extensión, o "?" si no tiene. Las carpetas usan el color del tema con el dibujo de una carpeta. | `lib/core/files/file_kind.dart`, `lib/core/widgets/file_kind_icon.dart` |
| RN-17 | Tocar un archivo muestra siempre el selector "Abrir con" de Android para elegir la app. Si ninguna puede: "Ninguna app puede abrir este archivo."; si ya no existe: "Ya no existe". Un APK abre el instalador de Android, que la primera vez pide permitir que Gakoken instale apps. | `android/app/src/main/kotlin/com/gakoken/gakoken/MainActivity.kt`, `lib/core/services/file_actions_service.dart` |
| RN-18 | Hoja de opciones de un elemento (en Explorar: Más con uno solo seleccionado; en Buscar, Favoritos y Espacio: mantener presionado), con su miniatura o logo y su nombre. Archivos: Abrir, Compartir, Copiar ruta, Agregar (o Quitar) de favoritos, Renombrar y Eliminar. Carpetas: Abrir en pestaña nueva y Espacio usado (los dos desde Explorar), Copiar ruta, Agregar (o Quitar) de favoritos, Renombrar y Eliminar; las carpetas no se comparten. Copiar ruta pone la ruta completa (por ejemplo `/storage/emulated/0/Download/factura.pdf`) en el portapapeles del sistema, no en el de Gakoken, y avisa "Ruta copiada". Un favorito que ya no existe solo tiene Copiar ruta y Quitar de favoritos. | `lib/core/widgets/file_actions.dart` |
| RN-19 | Favoritos: del más reciente al más viejo. Cada uno muestra la carpeta donde está (`Interno / Download`). Tocar una carpeta la abre en Explorar; tocar un archivo lo abre. Si ya no existe: logo atenuado, "Ya no existe" en rojo, tocarlo solo avisa y su hoja solo ofrece Quitar de favoritos. Se revisa al entrar a la pestaña. | `lib/features/favorites/`, `lib/core/services/favorites_service.dart` |
| RN-20 | Una carpeta que no se puede leer (por ejemplo `Android/data`) muestra "No se puede abrir esta carpeta."; una vacía, "Esta carpeta está vacía."; una sin archivos del tipo filtrado, "Ningún archivo de este tipo en esta carpeta.". Deslizar hacia abajo sobre el listado lo vuelve a leer. | `lib/features/browser/presentation/pages/browser_screen.dart` |
| RN-21 | Índice: cubre Interno y las tarjetas SD; los USB no se indexan (se conectan y se desconectan). Con el permiso concedido, al abrir la app se carga el índice guardado (Buscar y Espacio usado funcionan de inmediato) y se pone al día en segundo plano: solo se leen las carpetas cuya fecha de modificación cambió (crear, borrar, mover o renombrar algo cambia la fecha de su carpeta). Si el último recorrido completo tiene más de un día, se recorre todo, para alcanzar lo que cambia sin tocar su carpeta (un archivo que otra app reescribe en su lugar). También se pone al día al volver a la app (si pasaron más de 30 segundos desde la última revisión) y con cada cambio en la carpeta abierta (RN-36). Mientras no exista ningún índice, Explorar muestra "Indexando tu teléfono: N archivos y carpetas". Ajustes, Índice, muestra cuántos archivos tiene, "Al día desde" la fecha de la última puesta al día, "La última revisión tardó" (en ms o s, desde que se abrió la app) y el botón Volver a indexar, que recorre todo (desactivado mientras indexa). Poner o quitar una SD vuelve a indexar. | `lib/core/services/index_service.dart`, `rust/src/api/engine.rs`, `rust/src/index.rs` |
| RN-22 | Filtro por tipo en Explorar (de cada pestaña): los chips de Mostrar solo dejan ver solo esos tipos; las carpetas siempre se ven para poder navegar. Con un filtro activo, arriba de la lista se ve un chip por tipo con X para quitarlo (el ícono de ajustes ya no lleva número). Quitar filtro en la hoja los desmarca todos. El filtro no se guarda al cerrar la app. | `browser_controller.dart`, `sort_filter_sheet.dart` |
| RN-23 | Buscar: por nombre en todo el teléfono, sobre el índice, mientras se escribe. Orden: primero los que empiezan con lo escrito, luego los que lo contienen, luego coincidencias con letras salteadas y al final los que tienen errores de escritura (1 error con 4 a 7 letras escritas, 2 errores con 8 o más; con 3 letras o menos no tolera errores). Muestra hasta 300 resultados. Busca en Interno y SD, no en USB. Fuera de la raíz de una memoria indexada aparece la opción Solo en la carpeta actual (incluye sus subcarpetas); en un USB no aparece. Los ocultos salen solo si está activado Incluir en Buscar. Los chips de tipo filtran los resultados y quitan las carpetas. Cada resultado muestra dónde está. Tocar una carpeta la abre en Explorar y cierra Buscar. | `lib/features/search/`, `rust/src/index.rs` |
| RN-24 | Espacio (pestaña de la barra inferior, por ahora): total de la carpeta con sus subcarpetas, cuántos archivos y carpetas tiene, desglose Por tipo (nombre, logo, tamaño, porcentaje y cantidad de archivos; tocar un tipo abre la lista de todos sus archivos dentro de la carpeta y sus subcarpetas, ocultos incluidos, con tamaño y dónde está cada uno; muestra los 500 más grandes y lo dice si hay más; arriba tiene buscar por nombre dentro de la lista, ordenar (Nombre, Modificado, Tamaño; al abrir, del más pesado al más ligero) y vista (Lista, Detalles, Cuadrícula, Galería; empieza en la de Explorar), que no cambian Explorar ni se guardan; tocar uno lo abre y mantener presionado abre su hoja de opciones) y Lo que más ocupa (hasta 50 hijos directos, del más pesado al más ligero). Abre en Interno; el breadcrumb lleva a carpetas de arriba y su primera parte cambia de memoria. Tocar una carpeta de la lista entra a ella dentro de la pestaña; tocar un archivo lo abre. El ícono de carpeta arriba abre esa carpeta en Explorar. Espacio usado en la hoja de una carpeta de Explorar cambia a esta pestaña en esa carpeta. Interno y SD se calculan sobre el índice (sin índice muestra el progreso; mientras se actualiza lo avisa); un USB se recorre en el momento ("Calculando…"). | `lib/features/storage_usage/`, `rust/src/index.rs` |
| RN-26 | Pestañas en Explorar, como el Explorador de Windows: Pestaña nueva (en el menú del título, o el + al final de la tira) abre una pestaña nueva en Raíz del sistema; Abrir en pestaña nueva (hoja de una carpeta) la abre en esa carpeta. Con dos o más pestañas aparece la tira arriba: cada pestaña dice su carpeta (o la memoria en su raíz), tocarla la activa y su X la cierra; siempre queda una. Cada pestaña tiene su carpeta, su filtro y su historial; vista, orden y ocultos son los mismos para todas. Las pestañas y la activa vuelven al abrir la app. | `lib/features/browser/presentation/controllers/explorer_controller.dart`, `widgets/explorer_tab_strip.dart` |
| RN-27 | Historial por pestaña: las flechas atrás y adelante, arriba a la izquierda (no se ven mientras hay selección), van a la carpeta anterior y a la siguiente; se desactivan cuando no hay. Entrar a una carpeta nueva borra el adelante. El historial no se guarda al cerrar la app. | `browser_controller.dart` |
| RN-28 | Memorias: en Explorar, Memorias en el menú del título (en Espacio, la primera parte del breadcrumb) abre la hoja Memorias con Interno, cada tarjeta SD y cada USB conectado (con el nombre que da Android), su espacio libre y total y una barra de uso. Los USB dicen "No se incluye en Buscar". Al final, solo en Explorar, está Raíz del sistema (`/`, las carpetas de Android) con la nota "Carpetas de Android; casi todo es de solo lectura": no se indexa, no sale en Buscar ni en Espacio, y Android no deja a las apps leer el contenido de `/`, `/storage` ni `/storage/emulated`: ahí Gakoken muestra las carpetas conocidas de Android que existen (por ejemplo `apex`, `data`, `dev`, `proc`, `sdcard`, `storage`, `system`, `vendor`); las demás carpetas que Android no deja leer se ven como sin acceso. Si desde ahí se entra a Interno, la SD o un USB (también por el enlace `sdcard`), el título y su menú pasan a esa memoria. Elegir una abre su raíz. Si una pestaña guardada estaba en una memoria que ya no está, abre Interno. | `lib/core/services/storage_volumes_service.dart`, `lib/core/widgets/volume_picker_sheet.dart`, `MainActivity.kt` |
| RN-29 | Selección en Explorar: mantener presionado un elemento lo selecciona (palomita en lugar del logo y fondo de color); con la selección activa, tocar marca o desmarca. Arriba se ve cuántos hay, la X para soltar y Información, la estrella de favoritos y Seleccionar todo (lo visible con el filtro). Información abre una hoja: con uno, su miniatura o logo y nombre arriba, y Tipo (con la extensión), Tamaño (en carpetas, solo si el índice ya lo sabe), Contenido (carpetas: cuántos elementos), Modificado y Ubicación (ruta completa de la carpeta, se puede seleccionar para copiar); con varios, "N seleccionados", Tamaño total, Contenido (archivos y carpetas) y Ubicación. La estrella agrega todo lo seleccionado a favoritos y avisa "N se agregaron a favoritos"; si todo ya era favorito, se ve llena y los quita ("N se quitaron de favoritos"). En los dos casos se suelta la selección. Atrás del sistema, navegar a otra carpeta o cambiar de carpeta sueltan la selección. | `browser_controller.dart`, `entry_views.dart`, `browser_screen.dart` |
| RN-30 | Copiar y Cortar ponen lo seleccionado en el portapapeles de Gakoken (no el del sistema) y aparece la barra "N elementos copiados (o cortados)" con Cancelar y Pegar aquí, en cualquier carpeta y pestaña. Pegar lo cortado lo mueve y vacía el portapapeles; lo copiado se puede pegar varias veces. Pegar en la misma carpeta al copiar crea `nombre (1)`. Una carpeta no se puede pegar dentro de sí misma (falla solo esa). Mover en la misma memoria es instantáneo; entre memorias se copia y luego se borra el original. | `lib/core/services/file_ops_service.dart`, `rust/src/ops.rs` |
| RN-31 | Nombres repetidos: si en el destino ya hay elementos con el mismo nombre, antes de empezar se pregunta una vez para todos: Mantener ambos (`nombre (1)`), Reemplazar, Omitir o Cancelar. Cancelar no copia nada y, si era cortado, lo deja en el portapapeles. | `lib/core/widgets/file_dialogs.dart`, `rust/src/ops.rs` |
| RN-32 | Mientras copia o mueve, abajo se ve "Copiando 2 de 5" (o Moviendo), el porcentaje por bytes, una barra, el nombre actual y los bytes. Cancelar detiene la tarea: lo ya terminado se queda, el archivo a medias se borra y el original de lo que se estaba moviendo queda intacto. Al terminar avisa "Listo: N elementos", "Cancelado..." o los nombres que no se pudieron pasar. Las tareas van una tras otra. La carpeta abierta, Favoritos, Espacio y el índice se ponen al día solos. | `file_ops_service.dart`, `file_ops_bars.dart`, `rust/src/ops.rs` |
| RN-33 | Renombrar: el diálogo trae el nombre con la parte antes de la extensión seleccionada. No acepta nombres vacíos, con `/` o `\`, ni uno que ya exista en la carpeta (avisa). Los favoritos del elemento (y de lo que tenga dentro) siguen funcionando con el nombre nuevo. | `rust/src/ops.rs`, `file_actions.dart`, `favorites_service.dart` |
| RN-34 | Eliminar manda a la papelera sin preguntar y muestra "Se movió a la papelera" con Ver papelera y Deshacer durante unos segundos; Deshacer lo regresa a su lugar y Ver papelera abre la pantalla Papelera. Nunca borra para siempre al primer paso. | `lib/core/services/trash_service.dart`, `file_actions.dart` |
| RN-35 | Papelera (Ajustes, Papelera): lo borrado de las memorias conectadas, del más reciente al más viejo, con de dónde venía y cuántos días le quedan. Se guarda 30 días (de fábrica) y luego se borra solo al abrir la app. Ajustes, Días en la papelera (muestra el número actual) deja escribir otro número de 1 a 999; con texto vacío, 0 o más de 999 no deja guardar. Al guardar un número menor, lo que ya lleve más días se borra para siempre en ese momento (el diálogo lo avisa). Los días restantes de cada elemento se cuentan con el número actual. Tocar uno: Restaurar (a su carpeta; si ahí ya hay algo con ese nombre queda `nombre (1)`) o Eliminar para siempre (con confirmación). Vaciar borra todo con confirmación. La carpeta `.gakoken-trash` no se ve en Explorar (ni con los ocultos) ni sale en Buscar, pero sí ocupa lugar en Espacio. | `trash_service.dart`, `lib/features/trash/`, `rust/src/api/engine.rs`, `rust/src/index.rs` |
| RN-25 | Vista previa: en Ajustes se elige por tipo (Imágenes, Videos, PDF) si se ve una miniatura en lugar del logo; los tres vienen activados. Aplica en Explorar, Buscar, Favoritos, Espacio usado y la hoja de opciones. Mientras carga, o si no se puede leer, se ve el logo. Imágenes: jpg, jpeg, png, gif, webp, bmp, heic, heif e ico (svg y raw siempre usan el logo). Videos: un cuadro del video, con un botón de reproducir al centro, en todas las vistas y pantallas. PDF: la primera página. En Android la miniatura la hace el sistema y se guarda en el caché: la segunda vez sale al instante. | `lib/core/services/preview_settings_service.dart`, `lib/core/services/thumbnail_service.dart`, `lib/core/widgets/file_thumbnail.dart`, `MainActivity.kt` |
| RN-36 | La carpeta abierta en la pestaña activa se vigila: si otra app crea, borra, mueve o escribe algo ahí, la lista se pone al día sola en menos de un segundo, sin vaciarse ni perder la posición; lo seleccionado sigue seleccionado salvo lo que ya no existe. Esos cambios también llegan al índice (Buscar y Espacio). Al volver a la app, la carpeta abierta se vuelve a leer igual. Si la carpeta abierta desaparece, se muestra "No se puede abrir esta carpeta.". | `lib/core/services/folder_watch_service.dart`, `explorer_controller.dart`, `browser_controller.dart`, `MainActivity.kt` |

# Integraciones y permisos

| Integración o permiso | Para qué | Qué pasa si falla o se niega |
| --- | --- | --- |
| Acceso a todos los archivos (`MANAGE_EXTERNAL_STORAGE`, Android 11 o más) | Explorar e indexar todo el almacenamiento | Se queda la pantalla Dar permiso; no hay listado ni índice |
| Almacenamiento (`READ_EXTERNAL_STORAGE`, Android 10 o menos) | Lo mismo en teléfonos viejos | Igual que arriba |
| Selector de archivos del sistema | Importar un tema desde archivo y exportarlo a archivo | Cancelar no importa ni crea archivo |
| Portapapeles | Copiar el JSON de un tema | Sin efecto visible si falla |
| Selector "Abrir con" (intent `ACTION_VIEW` por `FileProvider`) | Abrir cualquier archivo | Aviso "Ninguna app puede abrir este archivo." o "No se pudo abrir el archivo." |
| Menú Compartir del sistema | Compartir un archivo | Cancelar el menú no hace nada |
| Memorias de Android (`StorageManager`, `StatFs`) | Saber qué SD y USB hay, su nombre y su espacio | Si Android no las reporta, solo se ve Interno |
| Instalar apps (`REQUEST_INSTALL_PACKAGES`) | Abrir un APK con el instalador | Android pide activarlo para Gakoken; si se niega, no instala |
| `PdfRenderer` de Android | Miniatura de un PDF | Si el PDF está dañado o protegido, se ve el logo |

# Requerimientos no funcionales

| Tipo | Requerimiento |
| --- | --- |
| Rendimiento (metas del prototipo) | Primeras entradas de una carpeta de 10 000 archivos en menos de 100 ms; búsqueda sobre 200 000 archivos en menos de 50 ms; espacio usado con índice listo en menos de 100 ms. En la Fase 1, con 7 347 archivos, Rust indexó todo en unos 0,5 s y buscó en menos de 2 ms |
| Fluidez | La interfaz no se congela durante el indexado, la búsqueda ni al desplazarse con miniaturas |
| Privacidad | Todo ocurre en el teléfono; nada sale a la red |
| Idiomas | es, en, fr, ja |
| Pantalla | App de borde a borde: nada queda tapado por la barra de estado ni por la barra de navegación (botones o gestos) |

# Riesgos para pruebas

| ID | Riesgo | Por qué | Cómo probarlo |
| --- | --- | --- | --- |
| R-01 | (Retirado el 2026-10-20: la prueba de rendimiento se quitó.) | - | - |
| R-02 | El permiso se comporta distinto según la versión de Android | Android 10 o menos y Android 11 o más usan permisos distintos | Probar en al menos un Android 11 o más y, si hay, uno con Android 10 o menos |
| R-03 | (Retirado el 2026-10-20: la prueba de rendimiento se quitó.) | - | - |
| R-04 | (Retirado el 2026-10-20: la prueba de rendimiento se quitó.) | - | - |
| R-05 | Carpetas muy grandes se sienten lentas | El listado y las miniaturas se cargan por carpeta | Abrir `DCIM/Camera` o `WhatsApp/Media` con miles de archivos en cada vista, con y sin vista previa, y desplazarse rápido |
| R-06 | Abrir o compartir falla con nombres raros | Rutas con espacios, acentos, emojis o varios puntos | Abrir y compartir archivos así en Download |
| R-07 | El botón atrás sale de la app en vez de subir, o sube estando en otra pestaña | Atrás depende de la pestaña activa | Entrar a varias carpetas, cambiar de pestaña y probar atrás en cada una |
| R-08 | El indexado se cierra o tarda mucho con almacenamientos grandes | El recorrido completo pasa por todo el teléfono (en la primera apertura y una vez al día) | Teléfono con más de 100 000 archivos: abrir la app, usar Explorar y Buscar mientras indexa |
| R-09 | Resultados o espacio usado viejos | La puesta al día solo lee carpetas cuya fecha cambió; un archivo que otra app reescribe en su lugar no cambia la fecha de su carpeta y se alcanza en el recorrido diario | Crear, borrar y renombrar archivos con otra app (en una carpeta que no esté abierta en Gakoken), volver a Gakoken y buscarlos sin Volver a indexar |
| R-17 | La carpeta abierta no se pone al día sola | El aviso de cambios depende de Android y puede no llegar en algunas memorias (SD, USB) o fabricantes | Con una carpeta abierta en Gakoken, tomar una foto o descargar un archivo en esa carpeta (pantalla dividida o volviendo a la app), en Interno, en la SD y en un USB |
| R-19 | La hoja de Información no muestra el tamaño de una carpeta | El tamaño de las carpetas sale del índice; sin índice (o en un USB) no se sabe sin recorrerla | Información de una carpeta en Interno con el índice listo, en un USB y en una instalación nueva mientras indexa |
| R-18 | La Galería se siente lenta o consume mucha memoria la primera vez | Cada miniatura nueva se hace en el momento; las siguientes salen del caché | Abrir `DCIM/Camera` con miles de fotos y videos en Galería, desplazarse rápido, salir y volver |
| R-10 | Miniaturas de PDF dañados, protegidos o enormes | Android tiene que abrir el PDF para dibujarlo | PDF con contraseña, PDF dañado y uno de cientos de páginas |
| R-11 | Una SD o un USB no se puede leer, o se confunde SD con USB | Cada fabricante monta las memorias distinto; Android no dice en público si una es USB | Probar con una SD y con un USB por OTG: que aparezcan con su nombre, se naveguen, la SD salga en Buscar y el USB no |
| R-12 | Quitar una memoria con pestañas o Espacio abiertos en ella | La carpeta deja de existir de golpe | Abrir una pestaña en el USB, quitarlo y volver a la app; no debe cerrarse |
| R-13 | Muchas pestañas o un historial largo | Cada pestaña guarda su estado | Abrir 10 pestañas, navegar en cada una, cerrar y abrir la app |
| R-20 | En Raíz del sistema algo truena o se queda cargando | Son carpetas de Android que cambian por fabricante; muchas no se pueden leer ni escribir | Elegir Raíz del sistema, entrar a `system`, `storage`, `data` y `proc`; intentar crear una carpeta, renombrar y eliminar ahí: debe avisar que no se pudo, sin cerrarse |
| R-14 | Copias grandes o entre memorias fallan o dejan basura | Entre memorias se copia byte por byte; cancelar a la mitad debe limpiar | Copiar una carpeta de varios GB de Interno a la SD y cancelar a la mitad; revisar que no quede el archivo a medias |
| R-15 | No se puede escribir en la SD o el USB | Cada fabricante da permisos distintos a las memorias externas | Copiar, renombrar y eliminar en la SD y en un USB |
| R-16 | Deshacer o restaurar después de mover la carpeta de origen | El lugar original puede ya no existir | Borrar un archivo, borrar su carpeta y restaurar el archivo: se recrea la carpeta |

# Pruebas automatizadas existentes

| Archivo | Cubre |
| --- | --- |
| `test/theme_test.dart` | Gakoken es el tema por defecto, Nekokag existe y es más oscuro, Eloisa sigue disponible |
| `test/file_kind_test.dart` | Clasificación de archivos por extensión para los logos |
| `test/browser_test.dart` | Orden con un toque y otro (nombre, tamaño, fecha, tipo; carpetas primero), filtro por tipo, conteo de elementos, historial atrás y adelante, botón atrás del sistema, cada memoria como raíz (y la raíz del sistema detrás de ellas), ocultos que recargan, recarga sin vaciar la lista (y la selección sin lo que ya no existe), carpeta sin acceso, abrir y cerrar pestañas, cambios de otra app que recargan solo la carpeta abierta, camino de regreso en Espacio, formato de tamaños |
| `test/favorites_test.dart` | Agregar, orden, sin repetidos, quitar, rutas largas, que siguen al mover o renombrar y que se mantienen al cerrar |
| `rust/src/ops.rs` (pruebas al final) | Nombres `(1)`, copiar carpetas, nombres repetidos (mantener ambos, reemplazar, omitir), pegar en la misma carpeta, carpeta dentro de sí misma, cancelar sin dejar nada a medias, mover, renombrar, papelera y restaurar |
| `rust/src/index.rs` (pruebas al final) | Distancia con errores de escritura, orden y tolerancia de la búsqueda, ocultos fuera y solo cuando se piden, recorrido en el momento (USB), buscar dentro de una carpeta, espacio usado (subcarpetas, ocultos, por extensión, hijos por tamaño), guardar y cargar el índice, poner al día solo lo que cambió, encontrar cambios leyendo solo las carpetas con otra fecha, guardar solo lo que cambió, papelera fuera de Buscar, extensiones (`cargo test` dentro de `rust/`) |

# Pendientes del producto

Lo que aún no existe y no se prueba. Escrito completo para que QA no espere verlo.

- **Vista Columnas:** solo para escritorio.
- **Puesta al día del índice con la app cerrada:** hoy se hace al abrir o volver a la app; no hay trabajo en segundo plano con la app cerrada.
- **Versiones de Linux y Windows (Fase 8 y Etapa 2).**
- **Identidad:** animal, logo, ícono de la app y splash.
- **Publicación:** imágenes de Play Store, llave de firma propia, pruebas cerradas y producción.

# Puntos por confirmar

- ¿El filtro por tipo de Explorar debe guardarse al cerrar la app, como el orden?
