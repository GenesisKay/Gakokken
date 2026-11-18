# Gakoken - Plan de pruebas

# Plan

## Objetivo
Asegurar que cada APK del prototipo se instala y funciona en un teléfono Android real: que se puede explorar el almacenamiento, buscar, ordenar, filtrar, ver el espacio usado, abrir, compartir, guardar favoritos y ver miniaturas, y que todo se siente rápido.

## Alcance
Dentro:
- Todo lo de `HistoriasDeUsuario.md`: instalación y pestañas, permiso de almacenamiento, explorar carpetas, vistas, logos y miniaturas, ordenar, agrupar por fecha y filtrar, índice y búsqueda, espacio usado (con la barra de todo el espacio), abrir, compartir, favoritos (buscar y organizar), selección (también deslizando, en Explorar, Favoritos, Papelera y la lista de un tipo, con vibración), ruedita de carga, copiar, mover, renombrar, crear carpetas y papelera (buscar, organizar y acciones en grupo), idioma, temas, vista previa, índice y vibración en Ajustes.

Fuera:
- Linux y Windows (todavía no se prueban).
- Lo listado en la sección "Pendientes del producto" de `AnalisisDeSistema.md`.

# Pruebas

## General
- [ ] Al abrir la app, el splash tiene fondo naranja (#E65C00) con el logo blanco al centro, en Android 12 o mayor y en anteriores; ya no sale en blanco (cambiado 2026-11-13) #visual
- [ ] Gakoken se instala con Eloisa (u otra app de la serie) ya instalada, y las dos siguen funcionando
- [ ] La barra inferior muestra Explorar, Favoritos, Espacio y Ajustes
	- [ ] Toda la barra tiene un solo color de fondo; la pestaña activa se nota por su ícono relleno en el color principal, sin pastilla de color detrás del ícono (cambiado el 2026-11-10) #visual
- [ ] Cambiar de pestaña y regresar conserva lo que había #condición
- [ ] Nada queda tapado por la barra de estado ni por la barra de navegación #condición
	- [ ] Navegación con 3 botones
	- [ ] Navegación con gestos
- [ ] Ruedita de carga: al entrar a DCIM/Camera en Galería por primera vez, mientras salen las miniaturas aparece una ruedita chica en la barra de arriba, a la izquierda de los íconos, y se va al terminar
	- [ ] No mueve el título ni los íconos al aparecer o irse #condición
	- [ ] Al volver a una carpeta con miniaturas ya hechas no aparece (o no parpadea) #condición
	- [ ] Deslizar hacia abajo para recargar una carpeta con contenido la muestra mientras lee; ya no hay barra fina debajo del título #condición
	- [ ] Al volver a la app después de un rato, mientras el índice se pone al día se ve en Explorar, Favoritos, Espacio y Ajustes #condición
	- [ ] En Espacio ya no sale el texto "Actualizando el índice; los números pueden cambiar." #condición
	- [ ] Con la selección activa también se ve en la barra de arriba #condición

## Explorar
- [ ] Instalación nueva: Explorar muestra la explicación del permiso y Dar permiso, sin listado
	- [ ] Conceder el permiso y regresar muestra el contenido de Interno #condición
	- [ ] Sin permiso, la pestaña Espacio muestra la misma explicación y Dar permiso, sin cifras en cero; al concederlo desde ahí, Espacio y Explorar muestran su contenido #condición
	- [ ] Día 0: Favoritos y Papelera vacíos muestran su aviso de lista vacía, sin fallar #condición
	- [ ] Regresar sin concederlo deja la explicación y la app no se cierra #condición
- [ ] Con permiso, el título deja de decir Explorar y muestra la carpeta actual con una flecha hacia abajo; no hay fila de ruta debajo
	- [ ] Con un nombre corto (por ejemplo DCIM) el título queda al centro de la pantalla, aunque a la derecha estén Nueva carpeta, la lupa y ajustes (corregido el 2026-10-30); con una sola pestaña también está el + y en un teléfono angosto puede correrse un poco a la izquierda #condición
- [ ] Instalación nueva con permiso: aparece "Indexando tu teléfono: N archivos y carpetas" con el número subiendo, y desaparece al terminar
	- [ ] Se puede navegar mientras indexa #condición
- [ ] Tocar una carpeta la abre y el título cambia a su nombre
	- [ ] Tocar el título abre el menú centrado bajo el título, como árbol: Raíz del sistema arriba con su ícono, luego `storage`, `emulated` e Interno (con el ícono de memoria), cada carpeta debajo más metida con una flecha, y la actual al final con carpeta abierta y marcada; luego Memorias (Nueva carpeta y Pestaña nueva ya no están aquí) #condición
	- [ ] Con más de 7 niveles la sangría deja de crecer y los nombres se cortan con puntos suspensivos #condición
	- [ ] Tocar una carpeta del menú va a ella #condición
	- [ ] Con un nombre muy largo, el título se corta con puntos suspensivos y la flecha sigue visible #condición
	- [ ] En la raíz de una memoria el título dice su nombre (Interno, la SD, Raíz del sistema) #condición
- [ ] Botón atrás del sistema dentro de una carpeta regresa a la anterior
	- [ ] Al abrir la app en una carpeta guardada (sin historial), atrás sube una carpeta #condición
	- [ ] En Interno sin historial, atrás sube a `emulated`, luego `storage` y Raíz del sistema; ahí sale de la app #condición
	- [ ] En Favoritos o Ajustes, atrás sale de la app aunque Explorar esté dentro de una carpeta #condición
- [ ] Carpetas primero y luego archivos, por nombre sin importar mayúsculas
- [ ] Con Ajustes de fábrica no aparecen nombres que empiezan con punto (por ejemplo `.thumbnails` en DCIM)
- [ ] Vista Lista: logo, nombre y debajo tamaño (archivos) o elementos (carpetas) y fecha
	- [ ] El número de elementos de las carpetas aparece un momento después #condición
- [ ] Carpeta con miles de archivos (DCIM/Camera): las primeras filas salen al instante y la ruedita de la barra de arriba desaparece al terminar
	- [ ] Desplazarse rápido no traba la pantalla #condición
- [ ] Carpeta vacía muestra "Esta carpeta está vacía."
- [ ] `Android/data` muestra "No se puede abrir esta carpeta." y la app no se cierra
- [ ] Deslizar hacia abajo recarga la carpeta (un archivo nuevo aparece)
- [ ] Logos: PDF, Word, Excel, PowerPoint, texto, código, imagen, video, audio, comprimido, APK, libro y desconocido con su color y etiqueta
- [ ] Fotos (jpg, png, webp, heic) muestran su miniatura en todas las vistas
	- [ ] Mientras carga se ve el logo y luego la miniatura #condición
	- [ ] Una imagen dañada se queda con el logo #condición
- [ ] Los videos muestran un cuadro como miniatura con un botón de reproducir al centro, en Lista, Detalles, Cuadrícula, Galería, Buscar, Favoritos y Espacio
	- [ ] Un video dañado se queda con el logo y la app no se cierra #condición
- [ ] Volver a una carpeta con fotos ya vistas: las miniaturas salen al instante (caché)
- [ ] Los PDF muestran su primera página como miniatura
	- [ ] Un PDF con contraseña o dañado se queda con el logo y la app no se cierra #condición
	- [ ] Cambiar de tema cambia solo el color de las carpetas #condición
- [ ] El ícono de ajustes abre Vista, orden y filtro; en Vista están Lista, Detalles, Cuadrícula y Galería, con la actual marcada (ya no está Lista compacta)
	- [ ] Quien tenía Lista compacta elegida, al actualizar ve Lista #condición
	- [ ] Detalles: encabezados Nombre, Tamaño y Modificado; en carpetas, Tamaño dice lo que pesan (o los elementos si todavía no hay índice) #condición
	- [ ] Cuadrícula: logo grande y nombre en máximo 2 líneas #condición
	- [ ] Cuadrícula en DCIM con nombres cortos y largos mezclados (por ejemplo Tapo, Recordings, ViajeMazamitla2026): los logos quedan alineados en columnas y cada nombre centrado bajo su logo (corregido el 2026-10-30) #condición
	- [ ] Cuadrícula: al seleccionar, el fondo de color cubre la celda completa #condición
	- [ ] Galería: fotos y videos ocupan toda la celda sin nombre; carpetas y documentos muestran logo y nombre #condición
	- [ ] Galería: mantener presionado selecciona (miniatura más oscura y círculo con palomita arriba a la izquierda) y tocar abre o marca como en las demás vistas #condición
	- [ ] La vista elegida se usa en todas las carpetas de la pestaña #condición
	- [ ] La vista se mantiene al cerrar y abrir la app #condición
- [ ] En Lista, abrir dos dedos sobre la lista pasa a Cuadrícula con una vibración chiquita; abrirlos otra vez pasa a Galería
	- [ ] Cerrar los dedos regresa: Galería, Cuadrícula, Lista, Detalles #condición
	- [ ] Abrir mucho los dedos en un solo gesto cambia una sola vista, no se brinca #condición
	- [ ] En Galería abrir los dedos y en Detalles cerrarlos no hace nada #condición
	- [ ] La hoja de ajustes marca la vista nueva y se mantiene al cerrar y abrir la app; las otras pestañas no cambian #condición
	- [ ] Deslizar con un dedo sigue desplazando y mantener presionado y deslizar sigue seleccionando #condición
	- [ ] También en Favoritos, la Papelera y los archivos de un tipo de Espacio (cada una guarda la suya) #condición
	- [ ] En Windows o Linux, Ctrl + rueda hacia arriba acerca y hacia abajo aleja, sin desplazar la lista; la rueda sola sigue desplazando #condición
- [ ] Al regresar a una carpeta ya visitada, la lista vuelve a la posición donde estaba
- [ ] Con una carpeta abierta, crear un archivo ahí con otra app (por ejemplo, tomar una captura en `Pictures/Screenshots`) y volver: el archivo ya está, sin deslizar para recargar
	- [ ] En pantalla dividida, aparece en menos de un segundo sin que la lista se vacíe ni salte de posición #condición
	- [ ] Borrarlo con otra app lo quita de la lista #condición
	- [ ] Con elementos seleccionados, la selección sigue #condición
	- [ ] En la SD y en un USB #condición

## Ordenar y filtrar
- [ ] El ícono de ajustes abre Vista, orden y filtro con Vista, Ordenar por y Mostrar solo; ya no hay ícono de vista ni de filtro aparte
- [ ] Un toque a Tamaño ordena del más chico al más grande con flecha hacia arriba; otro toque lo invierte con flecha hacia abajo
- [ ] Un toque a otro criterio (Nombre, Fecha, Tipo) siempre empieza de menor a mayor; las carpetas siempre quedan arriba
	- [ ] Por Tamaño, las carpetas se ordenan por lo que pesan con sus subcarpetas #condición
	- [ ] El orden se usa al entrar a otras carpetas de la misma pestaña; las demás pestañas no cambian #condición
	- [ ] El orden se mantiene al cerrar y abrir la app #condición
- [ ] En Detalles, tocar Tamaño ordena del más ligero al más pesado; tocarlo otra vez lo invierte; la flecha marca la columna y coincide con la hoja
- [ ] Mostrar solo PDF: quedan los PDF y las carpetas; arriba de la lista aparece el chip PDF
	- [ ] La X del chip quita ese filtro y el chip desaparece #condición
	- [ ] El ícono de ajustes no lleva número #condición
	- [ ] Marcar también Imágenes muestra 2 y deja ver los dos tipos #condición
	- [ ] En una carpeta sin PDF dice "Ningún archivo de este tipo en esta carpeta." #condición
	- [ ] Quitar filtro vuelve a mostrar todo #condición
	- [ ] Al cerrar y abrir la app el filtro sigue en esa pestaña #condición
	- [ ] El filtro de una pestaña no afecta a las otras #condición
- [ ] Agrupar por fecha en la hoja: la lista queda ordenada por fecha (más nuevo arriba) con encabezados Hoy, Ayer, Últimos 7 días y un grupo por mes ("Octubre de 2026")
	- [ ] En Ordenar por queda marcada Fecha con flecha hacia abajo #condición
	- [ ] Al desplazarse, el encabezado del grupo se queda pegado arriba hasta que llega el siguiente #condición
	- [ ] Funciona en Lista, Detalles, Cuadrícula y Galería; en Cuadrícula y Galería el encabezado ocupa todo el ancho #condición
	- [ ] Dentro de cada grupo las carpetas van primero #condición
	- [ ] Otro toque a Fecha invierte (más viejo arriba) y sigue agrupado #condición
	- [ ] Tocar Nombre, Tamaño o Tipo quita el agrupado #condición
	- [ ] Se mantiene al entrar a otras carpetas de la misma pestaña y al cerrar y abrir la app; las demás pestañas no cambian #condición
	- [ ] Con filtro por tipo, los grupos solo cuentan lo que se ve #condición
	- [ ] Los encabezados salen en los cuatro idiomas #condición
- [ ] Con la lista agrupada, tocar el encabezado Hoy selecciona todo lo de hoy; tocarlo otra vez lo desmarca
	- [ ] Con selección activa, cada encabezado tiene un círculo que se llena cuando todo su grupo está marcado #condición
	- [ ] Mantener presionado y deslizar a través de dos grupos marca el tramo completo #condición

## Buscar
- [ ] La lupa abre Buscar con el teclado listo
- [ ] Escribir parte de un nombre (por ejemplo "whats") muestra resultados mientras se escribe, cada uno con dónde está
- [ ] Con un error de escritura ("wahtsapp", "scrennshot") igual aparece lo buscado
- [ ] Primero salen los que empiezan con lo escrito
- [ ] No salen archivos ocultos ni lo que está dentro de carpetas que empiezan con punto
- [ ] Un nombre que no existe dice "Sin resultados."
- [ ] Tocar un archivo lo abre; tocar una carpeta cierra Buscar y la abre en Explorar
- [ ] Desde Interno no aparece la opción de carpeta; desde otra carpeta aparecen Todo el teléfono y Solo en esa carpeta
	- [ ] Desde una carpeta de un USB no aparece Solo en esa carpeta #condición
- [ ] Los archivos de la SD salen en Buscar; los del USB no
- [ ] Con Incluir en Buscar activado, salen los ocultos (por ejemplo ".thumbnails")
	- [ ] Solo en esa carpeta no muestra archivos de fuera (sí de sus subcarpetas) #condición
- [ ] Los chips de tipo dejan solo esos archivos
- [ ] Mantener presionado un resultado abre su hoja de opciones
- [ ] Teléfono con muchos archivos: escribir rápido no traba la pantalla #condición
- [ ] Instalación nueva, antes de terminar el primer indexado: Buscar muestra el progreso y luego los resultados solos

## Pestañas
- [ ] Con una sola pestaña no hay tira de pestañas; Pestaña nueva es un + al final de la barra de arriba, después del ícono de ajustes
	- [ ] Con dos o más pestañas el + de la barra de arriba desaparece y queda solo el + de la tira; al cerrar hasta quedar una, vuelve #condición
	- [ ] Teléfono angosto con una pestaña: el título de la carpeta no se encima con los íconos de la derecha (con nombres cortos puede quedar un poco a la izquierda del centro) #condición #visual
- [ ] Pestaña nueva abre una pestaña en Raíz del sistema y aparece la tira con las dos y un + al final
	- [ ] El + de la tira abre otra pestaña #condición
- [ ] Seleccionar una carpeta, Más, Abrir en pestaña nueva: abre otra pestaña en esa carpeta y la activa
- [ ] Cada pestaña dice su carpeta; en la raíz, el nombre de la memoria
- [ ] Tocar una pestaña la activa y muestra su carpeta, con su propio filtro
	- [ ] Pestaña A en Cuadrícula por Fecha descendente y pestaña B en Detalles por Nombre: al pasar de una a otra cada una conserva lo suyo #condición
	- [ ] Una pestaña nueva empieza con la vista y el orden de la pestaña activa, sin su filtro #condición
	- [ ] Cerrar y abrir la app: cada pestaña vuelve con su vista, orden, agrupar por fecha y filtro #condición
	- [ ] Al actualizar desde la versión anterior, las pestañas que ya estaban abiertas toman la vista y el orden que se usaban #condición
- [ ] La X cierra una pestaña; con una sola ya no hay X
- [ ] Las flechas atrás y adelante están arriba a la izquierda, recorren el historial de la pestaña y se desactivan sin historial
	- [ ] Con una selección activa no se ven (ahí está la X) #condición
	- [ ] Entrar a otra carpeta después de ir atrás desactiva adelante #condición
	- [ ] El historial de una pestaña no se mezcla con el de otra #condición
- [ ] Cerrar y abrir la app devuelve las mismas pestañas y la activa
- [ ] El botón atrás del sistema actúa sobre la pestaña activa

## Memorias
- [ ] En Explorar, menú del título, Memorias abre Memorias con Interno, su espacio libre y total y una barra
- [ ] Con una tarjeta SD puesta, aparece con su nombre; elegirla abre su raíz
	- [ ] En la SD no se puede subir más arriba de su raíz #condición
	- [ ] La SD aparece en Buscar después del indexado #condición
- [ ] Con un USB por OTG, aparece con su nombre y "No se incluye en Buscar"; se navega
- [ ] Conectar un USB con la app abierta y volver a ella: aparece en Memorias
- [ ] Quitar el USB con una pestaña abierta en él y volver a la app: la app no se cierra y la pestaña va a Interno al navegar
- [ ] Quitar o poner la SD vuelve a indexar (Ajustes, Índice, muestra el progreso)
- [ ] Recién instalada, Explorar abre en Interno y el título dice Interno
	- [ ] El menú del título muestra la ruta Raíz del sistema > storage > emulated > Interno #condición
	- [ ] Subir desde Interno llega a Raíz del sistema, que muestra carpetas como `apex`, `data`, `dev`, `proc`, `sdcard`, `storage`, `system` y `vendor` #condición
	- [ ] En una SD el menú muestra Raíz del sistema > storage > nombre de la SD #condición
	- [ ] + (pestaña nueva) también abre en Interno #condición
	- [ ] Tocar `sdcard` abre Interno #condición
- [ ] Al final de Memorias está Raíz del sistema con "Carpetas de Android; casi todo es de solo lectura"; elegirla abre `/` y el breadcrumb dice Raíz del sistema
	- [ ] Entrar a `storage`, `emulated` y `0`: el título cambia a Interno #condición
	- [ ] Carpetas como `data` se ven como sin acceso, sin cerrarse #condición
	- [ ] Crear, renombrar o eliminar ahí avisa que no se pudo #condición
	- [ ] En Espacio, Memorias no muestra Raíz del sistema #condición

## Espacio usado
- [ ] La pestaña Espacio de la barra abre en Interno con su breadcrumb
- [ ] Seleccionar una carpeta en Explorar, Más, Espacio usado: cambia a la pestaña Espacio en esa carpeta
	- [ ] Atrás sube carpeta por carpeta hasta la raíz y luego sale de la app #condición
- [ ] Tocar la memoria del breadcrumb permite ver la SD y el USB
	- [ ] En un USB dice "Calculando…" y luego muestra el espacio #condición
- [ ] Explorar ya no tiene el ícono de gráfica
- [ ] Muestra el total, Por tipo y Lo que más ocupa; debajo del total no hay texto con cuántos archivos y carpetas
	- [ ] Por tipo: cada tipo con logo, nombre, tamaño, porcentaje, barra y cantidad de archivos, del que más ocupa al que menos #condición
- [ ] Ordenar Por tipo: el ícono a la derecha de "Por tipo" abre Tamaño, Nombre y Archivos; el orden actual va en color con una flecha
	- [ ] Nombre ordena de la A a la Z; Tamaño y Archivos, del mayor al menor #condición
	- [ ] Elegir otra vez el orden actual le da la vuelta y la flecha cambia #condición
	- [ ] La barra de todo el espacio no cambia de orden #condición
	- [ ] El orden se mantiene al cambiar de carpeta y al cerrar y abrir la app #condición
	- [ ] Con un solo tipo no aparece el ícono #condición
- [ ] Tocar un tipo (por ejemplo Videos) lista sus archivos de esa carpeta y sus subcarpetas, del más pesado al más ligero, con tamaño y ubicación
	- [ ] Buscar (lupa) filtra la lista por nombre; sin coincidencias dice "Sin resultados." #condición
	- [ ] Ordenar ofrece Nombre, Modificado y Tamaño (sin Tipo); un toque de menor a mayor, otro lo invierte #condición
	- [ ] Vista cambia entre Lista, Detalles, Cuadrícula y Galería; al volver, Explorar sigue en su vista y su orden #condición
	- [ ] La cantidad coincide con la del tipo en Espacio (hasta 500) #condición
	- [ ] Tocar uno lo abre; mantener presionado lo selecciona (ya no abre la hoja) #condición
	- [ ] Mantener presionado y deslizar marca varios; arriba Información, estrella y Seleccionar todo; abajo Copiar, Cortar, Compartir, Renombrar, Eliminar y Más #condición
	- [ ] Eliminar varios los quita de la lista y avisa con Deshacer #condición
	- [ ] Copiar varios y pegarlos en una carpeta de Explorar #condición
	- [ ] Atrás o la X sueltan la selección; con nada seleccionado, atrás regresa a Espacio #condición
	- [ ] Ordenar ofrece también Agrupar por fecha; al salir y volver a entrar regresa a del más pesado al más ligero #condición
	- [ ] En un USB también funciona #condición
	- [ ] Lo que más ocupa: del más pesado al más ligero #condición
- [ ] Raíz de Interno: el número grande es "usado / total" y coincide con Ajustes de Android, Almacenamiento (por ejemplo 103 GB / 128 GB, no 108 GB)
	- [ ] En una subcarpeta el número grande vuelve a ser lo que pesa la carpeta, sin "/ total" #condición
	- [ ] La hoja Memorias muestra el mismo total y libre para Interno #condición
- [ ] Barra de todo el espacio en la raíz de Interno sin Acceso al uso: un tramo de color por tipo (del que más ocupa al que menos), luego Sistema y otros (gris oscuro) y Libre (gris claro); debajo "X libres" y el botón "Ver cuánto ocupan las apps"
	- [ ] El botón abre Acceso al uso en Ajustes de Android (en Gakoken o en la lista de apps, según el teléfono) #condición
	- [ ] Al darlo y volver, aparece el tramo Apps, el gris se llama Sistema y el botón ya no sale #condición
	- [ ] Apps y Sistema se parecen a lo que dice Ajustes de Android, Almacenamiento #condición
	- [ ] Quitar el permiso en Ajustes y volver: regresa Sistema y otros y el botón #condición
	- [ ] Volver sin darlo deja todo igual #condición
	- [ ] Los colores de cada tramo son los del logo de su tipo en Por tipo #condición
	- [ ] Tocar el tramo de Videos apaga los demás y debajo sale "Videos · N %" con una flecha #condición
	- [ ] Tocar el mismo tramo otra vez (o el aviso) abre la lista de Videos #condición
	- [ ] Tocar Libre dice "Libre · N %"; tocarlo otra vez lo suelta #condición
	- [ ] Tipos muy chicos se juntan en Otros; Otros con varios tipos no abre lista #condición
	- [ ] Los textos salen en los cuatro idiomas #condición
- [ ] Barra en una subcarpeta (por ejemplo DCIM): solo los tipos de esa carpeta, sin Apps, Sistema ni Libre ni "X libres"
	- [ ] Tocar un tramo dice solo el nombre del tipo (el porcentaje ya está en su fila) #condición
- [ ] Barra en la SD: igual que en Interno, con su propio libre y total, sin Apps ni el botón de Acceso al uso
- [ ] Una carpeta vacía no muestra barra
- [ ] El total coincide aproximadamente con lo que dice Android en Ajustes, Almacenamiento, para esa carpeta
- [ ] Tocar una carpeta de la lista entra a su espacio usado; atrás regresa
- [ ] Tocar un archivo lo abre
- [ ] El ícono de carpeta arriba abre esa carpeta en Explorar
- [ ] Una carpeta vacía dice "Esta carpeta está vacía."

## Archivos
- [ ] Tocar una imagen, un PDF y un video muestra el selector "Abrir con" de Android, aunque ya haya una app predeterminada
- [ ] Tocar un APK abre el instalador de Android
	- [ ] La primera vez Android pide permitir que Gakoken instale apps #condición
- [ ] Un archivo que ninguna app abre muestra "Ninguna app puede abrir este archivo."
- [ ] Seleccionar un solo archivo y tocar Más abre un menú que sale hacia arriba desde el botón (no una hoja desde abajo) con Abrir y Copiar ruta
	- [ ] Mientras el menú está abierto la selección sigue; tocar fuera lo cierra y la selección se queda #condición
	- [ ] Elegir una opción cierra el menú, suelta la selección y hace la acción #condición
	- [ ] El menú no repite lo que ya está a la vista: Compartir, Renombrar, Eliminar, Información y la estrella #condición
	- [ ] El menú se ve completo, sin salirse por la derecha ni tapar la barra de abajo #condición #visual
- [ ] Copiar ruta avisa "Ruta copiada"; al pegar en otra app (por ejemplo WhatsApp) sale la ruta completa del archivo
	- [ ] Con una carpeta también está y copia la ruta de la carpeta #condición
	- [ ] En Buscar, Favoritos y la lista de un tipo de Espacio, mantener presionado también la ofrece #condición
	- [ ] Lo que había en Copiar o Cortar de Gakoken no se pierde #condición
- [ ] Seleccionar una sola carpeta en Explorar y tocar Más muestra el menú con Abrir en pestaña nueva, Espacio usado y Copiar ruta
- [ ] En Buscar y en Lo que más ocupa de Espacio, mantener presionado abre directo esa hoja (no selecciona); en Favoritos, la Papelera y la lista de un tipo selecciona
- [ ] Compartir abre el menú del sistema y el archivo llega bien (por ejemplo a WhatsApp o Gmail)
	- [ ] Cancelar el menú no hace nada #condición
- [ ] Abrir y compartir un archivo con espacios, acentos o emojis en el nombre #condición
- [ ] Ninguna hoja inferior queda tapada por la barra de navegación #condición
	- [ ] Opciones de un archivo
	- [ ] Vista

## Selección y acciones
- [ ] Mantener presionado un elemento lo selecciona: palomita en lugar del logo y fondo de color; arriba "1 seleccionado"
	- [ ] En Cuadrícula el logo no cambia: fondo de color y un círculo con palomita en la esquina de arriba a la izquierda #condición
	- [ ] En Galería la miniatura se oscurece un poco y lleva el círculo arriba a la izquierda; ya no hay borde ni palomita a la derecha #condición
	- [ ] En Cuadrícula y Galería los no seleccionados no llevan círculo, aunque haya selección #condición
	- [ ] Tocar otros los suma; tocar uno seleccionado lo quita #condición
- [ ] Mantener presionado y, sin soltar, deslizar hacia abajo marca todo lo que el dedo va pasando; vibra al empezar y con cada uno
	- [ ] Regresar el dedo desmarca lo que sale del tramo; lo que ya estaba seleccionado antes sigue igual #condición
	- [ ] Deslizar hacia arriba desde el primero también marca el tramo #condición
	- [ ] Empezar sobre uno ya seleccionado desmarca el tramo en vez de marcarlo #condición
	- [ ] Llevar el dedo al borde de abajo (o de arriba) hace avanzar la lista sola y sigue marcando; al soltar se detiene #condición
	- [ ] Mientras se desliza, la lista no se mueve con el dedo; deslizar sin mantener antes sigue desplazando normal #condición
	- [ ] Funciona igual en Lista, Detalles, Cuadrícula (fila por fila) y Galería #condición
	- [ ] Mantener presionado sin mover selecciona solo ese, como antes #condición
- [ ] Con algo ya seleccionado, soltar el dedo y deslizar de lado sobre otro elemento (sin mantener presionado) marca el tramo que va pasando, como en las galerías
	- [ ] Después de ir de lado se puede bajar o subir y sigue marcando; al borde la lista avanza sola #condición
	- [ ] En diagonal también selecciona #condición
	- [ ] Recto hacia arriba o abajo desplaza la lista y no marca nada #condición
	- [ ] Empezar sobre uno ya seleccionado desmarca el tramo #condición
	- [ ] Sin selección, deslizar de lado no hace nada #condición
	- [ ] Funciona en Lista, Detalles, Cuadrícula y Galería, y en Favoritos, la Papelera y los archivos de un tipo #condición
	- [ ] Con encabezados por fecha, empezar sobre un encabezado no marca nada #condición
	- [ ] Tocar sigue abriendo el archivo o la carpeta cuando no hay selección #condición
	- [ ] Seleccionar todo marca todo lo visible (respeta el filtro) #condición
	- [ ] La X, el botón atrás o entrar a otra carpeta sueltan la selección #condición
- [ ] Información con un archivo: miniatura y nombre arriba; Tipo con la extensión, Tamaño, Modificado y Ubicación
	- [ ] Con una carpeta: Contenido con los elementos y Tamaño si el índice ya lo sabe #condición
	- [ ] Con varios: "N seleccionados", Tamaño total y cuántos archivos y carpetas #condición
	- [ ] La ubicación se puede seleccionar y copiar #condición
- [ ] La estrella con varios seleccionados los agrega todos a Favoritos y avisa cuántos
	- [ ] Si todos ya eran favoritos, la estrella se ve llena y los quita #condición
	- [ ] Con algunos favoritos y otros no, agrega los que faltan #condición
- [ ] Barra de abajo: Copiar, Cortar, Compartir, Renombrar, Eliminar y Más
	- [ ] Con dos o más, Renombrar y Más quedan desactivados #condición
	- [ ] Con solo carpetas, Compartir queda desactivado #condición
- [ ] Compartir varios archivos a la vez abre el menú del sistema con todos
- [ ] Copiar dos archivos, ir a otra carpeta y Pegar aquí: quedan en las dos carpetas
	- [ ] La barra "2 elementos copiados" sigue y se puede pegar otra vez en otra carpeta #condición
	- [ ] Cancelar en la barra vacía el portapapeles #condición
	- [ ] Pegar en la misma carpeta crea "nombre (1)" #condición
- [ ] Cortar y Pegar aquí mueve: desaparece del origen y la barra se va
	- [ ] Mover dentro de Interno es instantáneo aunque sea una carpeta grande #condición
	- [ ] Mover de Interno a la SD funciona y muestra progreso #condición
- [ ] Copiar y pegar entre dos pestañas
- [ ] Pegar donde ya hay un archivo igual pregunta: Mantener ambos, Reemplazar, Omitir o Cancelar
	- [ ] Mantener ambos crea "nombre (1)" #condición
	- [ ] Reemplazar deja el nuevo #condición
	- [ ] Omitir deja el viejo y no copia ese #condición
	- [ ] Cancelar no copia nada; si era cortado, la barra sigue #condición
- [ ] Pegar una carpeta dentro de sí misma avisa que no se pudo y no rompe nada
- [ ] Copiar una carpeta de varios GB: panel "Copiando 1 de 1" con porcentaje, nombre y bytes; la app sigue fluida
	- [ ] Cancelar a la mitad: avisa "Cancelado" y no queda el archivo a medias en el destino #condición
	- [ ] Al terminar avisa "Listo" y la carpeta destino ya lo muestra sin recargar #condición
	- [ ] Pegar otra cosa mientras copia: espera a que termine la primera #condición
- [ ] Después de copiar o mover, Buscar encuentra lo nuevo y Espacio cambia sin Volver a indexar
- [ ] Renombrar: el nombre viene seleccionado sin la extensión
	- [ ] Un nombre que ya existe avisa y no cambia nada #condición
	- [ ] Renombrar un favorito: en Favoritos aparece con el nombre nuevo y no dice "Ya no existe" #condición
	- [ ] Renombrar una carpeta con favoritos dentro: siguen funcionando #condición
- [ ] Eliminar: desaparece, avisa "Se movió a la papelera" con Ver papelera y Deshacer
	- [ ] Ver papelera abre la Papelera con lo que se acaba de borrar #condición
	- [ ] Deshacer lo regresa a su lugar #condición
	- [ ] Eliminar varios a la vez #condición
	- [ ] Con el aviso todavía visible, mantener presionado otro elemento: el aviso se cierra y la barra de abajo con las acciones se ve completa; igual en Favoritos, la Papelera y la lista de un tipo #condición
- [ ] Copiar, renombrar y eliminar también en la SD y en un USB

## Nueva carpeta
- [ ] El ícono de Nueva carpeta está en la barra de arriba de Explorar, a la izquierda de la lupa, sin nada copiado
	- [ ] Con algo seleccionado no se ve (arriba está la barra de selección) #condición
- [ ] Ícono de Nueva carpeta: pide el nombre; Crear la crea, avisa "Carpeta "nombre" creada" y aparece en la lista
	- [ ] Sin nada copiado, se queda en la carpeta actual #condición
	- [ ] Sin nada copiado, la carpeta nueva parpadea dos veces con el color del tema, en Lista, Detalles, Cuadrícula y Galería #condición
	- [ ] Después del parpadeo, bajar y volver a subir la lista no la hace parpadear otra vez #condición
	- [ ] Con las animaciones quitadas en Accesibilidad de Android, no parpadea #condición
	- [ ] La carpeta nueva sale en Buscar sin esperar a reindexar #condición
	- [ ] Espacios al inicio o al final del nombre se quitan #condición
- [ ] Con un nombre vacío, con /, solo puntos o .gakoken-trash, avisa en el diálogo y no se cierra
- [ ] Con un nombre que ya existe (carpeta o archivo), avisa "Ya hay algo con ese nombre aquí." y deja corregirlo
- [ ] En una carpeta de Raíz del sistema, avisa que es de solo lectura
- [ ] En una carpeta que no se pudo leer (por ejemplo Android/data), Nueva carpeta está desactivada
- [ ] Copiar algo, ir a otra carpeta y tocar el ícono de Nueva carpeta de arriba: al crearla entra a ella y la barra de Pegar aquí sigue (ya sin su propio ícono de Nueva carpeta)
	- [ ] Pegar aquí ahí deja lo copiado dentro de la carpeta nueva #condición
	- [ ] Con algo cortado, igual: entra, la barra sigue y Pegar aquí lo mueve #condición
	- [ ] Cancelar el diálogo no cambia de carpeta ni toca el portapapeles #condición
- [ ] Los textos del diálogo y los avisos salen en los cuatro idiomas

## Papelera
- [ ] Ajustes, Papelera, dice cuántos elementos hay y abre la lista
- [ ] Papelera vacía: dice que lo borrado se guarda 30 días
- [ ] Ajustes, Días en la papelera dice 30 días y abre el diálogo con 30; guardar 7 cambia el texto y los días restantes
	- [ ] Vacío, 0 o 1000 no deja guardar #condición
	- [ ] Con algo borrado hace más de 2 días (cambiando la fecha del teléfono), guardar 1 lo borra para siempre al momento #condición
	- [ ] Al cerrar y abrir la app se mantiene el número elegido #condición
- [ ] Cada elemento muestra su logo o miniatura, de dónde venía y "Quedan 30 días"
	- [ ] En Lista, con una ruta de origen muy larga (varias carpetas anidadas), "Quedan N días" se ve completo y lo que se recorta con "..." es la ruta (hecho 2026-11-05) #condición
- [ ] Tocar uno: Restaurar lo regresa a su carpeta
	- [ ] Si en su carpeta ya hay algo con ese nombre, vuelve como "nombre (1)" #condición
	- [ ] Si su carpeta ya no existe, se vuelve a crear #condición
- [ ] Eliminar para siempre pide confirmación y lo borra
- [ ] Vaciar pide confirmación y deja la papelera vacía; Espacio baja
	- [ ] En la confirmación de Vaciar y de Eliminar para siempre, el botón dice Eliminar y lleva el ícono de la basurita #visual
- [ ] La carpeta `.gakoken-trash` no aparece en Explorar aunque se muestren los ocultos, ni en Buscar
- [ ] Lo borrado en la SD o el USB solo aparece en la papelera con esa memoria conectada
- [ ] Lupa: escribir parte de un nombre deja solo lo que coincide; sin coincidencias dice "Sin resultados."; la flecha atrás de la lupa vuelve a mostrar todo
- [ ] Ícono de ajustes: Vista (Lista, Detalles, Cuadrícula, Galería), Ordenar por (Nombre, Borrado, Tipo; sin Tamaño), Agrupar por fecha y Mostrar solo
	- [ ] Cuadrícula y Galería muestran miniaturas de las fotos borradas #condición
	- [ ] En Detalles no hay columna Tamaño y la de fecha dice Borrado #condición
	- [ ] Agrupar por fecha separa lo borrado hoy, ayer, etc. #condición
	- [ ] Mostrar solo Imágenes deja ver solo imágenes y carpetas, con el chip arriba #condición
	- [ ] Al salir y volver a entrar, vista, orden y agrupar siguen; el filtro y la búsqueda no #condición
	- [ ] Cambiar la vista de la papelera no cambia la de Explorar ni la de Favoritos #condición
- [ ] Mantener presionado selecciona; deslizar marca varios; arriba cuántos, X y Seleccionar todo
	- [ ] Restaurar con 3 seleccionados los regresa a su lugar y avisa "3 elementos restaurados" #condición
	- [ ] Eliminar para siempre con 3 pide confirmación con el número y los borra #condición
	- [ ] Cancelar la confirmación deja la selección como estaba #condición
	- [ ] Con selección, tocar marca o desmarca (no abre la hoja) #condición
	- [ ] Atrás suelta la selección; otro atrás sale de la papelera #condición
	- [ ] La barra de abajo con Restaurar y Eliminar para siempre se ve completa, arriba de la barra de gestos o de botones del sistema, igual que en Explorar y Favoritos (hecho 2026-11-05) #visual
	- [ ] Lo mismo en la lista de archivos de un tipo de Espacio #visual
- [ ] Al restaurar, eliminar para siempre o vaciar algo grande, la ruedita chica de la barra de arriba se ve mientras termina

## Favoritos
- [ ] Sin favoritos, la pestaña dice cómo agregarlos
- [ ] Agregar un archivo y una carpeta desde Explorar; aparecen en Favoritos, el último arriba
	- [ ] Cada uno muestra dónde está (Interno / ...) #condición
	- [ ] En su hoja la opción ahora dice Quitar de favoritos #condición
- [ ] Tocar una carpeta favorita abre Explorar en esa carpeta
- [ ] Tocar un archivo favorito lo abre
- [ ] Quitar de favoritos desde Explorar y desde Favoritos
- [ ] Los favoritos se mantienen al cerrar y abrir la app
- [ ] Eliminar un favorito desde Favoritos (o desde Explorar): desaparece de Favoritos al momento y queda en la Papelera (hecho 2026-11-05)
	- [ ] Restaurarlo desde la Papelera (o con Deshacer): vuelve a aparecer en Favoritos #condición
	- [ ] Si al restaurar queda como "nombre (1)", el favorito aparece con ese nombre #condición
	- [ ] Eliminarlo para siempre (o vaciar la papelera): ya no vuelve a Favoritos #condición
	- [ ] Eliminar una carpeta que tiene favoritos dentro: esos favoritos también desaparecen y vuelven al restaurarla #condición
- [ ] Borrar un archivo favorito con otra app y volver a Favoritos: en Lista, logo atenuado y "Ya no existe" en rojo
	- [ ] Tocarlo solo avisa "Ya no existe" #condición
	- [ ] Seleccionarlo y tocar Más: el menú solo ofrece Copiar ruta; para quitarlo está la estrella de arriba #condición
	- [ ] En Cuadrícula y Galería se ve toda la celda atenuada #condición
- [ ] Lupa: filtra por nombre mientras se escribe; sin coincidencias dice "Sin resultados."
- [ ] Ícono de ajustes: Vista, Ordenar por (Nombre, Agregado, Tipo; sin Tamaño), Agrupar por fecha y Mostrar solo
	- [ ] Al abrir por primera vez, el orden es Agregado con el último arriba (como antes) #condición
	- [ ] Agrupar por fecha separa lo agregado hoy, ayer, en los últimos 7 días y por mes #condición
	- [ ] En Detalles no hay columna Tamaño y la de fecha dice Agregado #condición
	- [ ] Mostrar solo PDF deja ver los PDF y las carpetas favoritas, con el chip arriba #condición
	- [ ] Vista, orden y agrupar se mantienen al cerrar y abrir la app y no cambian Explorar #condición
	- [ ] Sin favoritos no hay lupa ni ícono de ajustes #condición
- [ ] Mantener presionado selecciona; deslizar marca varios; arriba la estrella llena y Seleccionar todo (sin Información)
	- [ ] La estrella quita todos los seleccionados de favoritos y avisa cuántos #condición
	- [ ] Abajo Copiar, Cortar, Compartir, Renombrar, Eliminar y Más funcionan como en Explorar #condición
	- [ ] Con selección, tocar una carpeta la marca (no la abre) #condición
	- [ ] Atrás suelta la selección; otro atrás sale de la app #condición
	- [ ] Cambiar a otra pestaña de la barra inferior suelta la selección #condición

## Ajustes
- [ ] Textos comunes de la serie (cambiados 2026-11-12): la pantalla se llama Ajustes (antes Configuración); en la papelera Eliminar definitivamente (antes Eliminar para siempre); títulos y botones con mayúscula solo al inicio en español, inglés y francés (Crear tema, Seleccionar color y los demás); el color Superposición traducido #idioma
- [ ] Cambiar idioma (es, en, fr, ja)
	- [ ] Los textos de Explorar, Buscar, Espacio usado, Favoritos y las hojas cambian de idioma; fechas, números y tamaños usan el formato del idioma #condición
	- [ ] Se mantiene al cerrar y abrir la app #condición
- [ ] Primera apertura con el teléfono en un idioma no soportado: la app sale en inglés
- [ ] Gakoken es el tema por defecto en una instalación nueva
	- [ ] Su fondo es casi blanco y neutro, sin tono naranja; su descripción dice "Gato naranja: blanco y naranja atigrado" (cambiado 2026-11-05) #visual
- [ ] Cambiar entre los temas integrados (Gakoken, Nekokag, Eloisa y los de la serie, hasta Bioka y Akoib)
	- [ ] El tema se mantiene al cerrar y abrir la app #condición
- [ ] Los temas integrados no tienen Editar ni Eliminar
- [ ] Crear, editar, aplicar y eliminar un tema propio
- [ ] Exportar un tema: copiar JSON y guardar en archivo
- [ ] Importar un tema pegando JSON y desde archivo
	- [ ] Un JSON inválido muestra error y no crea tema #condición
- [ ] Vista previa muestra Imágenes, Videos y PDF activados en una instalación nueva
	- [ ] Apagar Imágenes cambia las fotos por el logo en Explorar, Buscar y Favoritos sin reiniciar #condición
	- [ ] Apagar Videos cambia los videos por el logo #condición
	- [ ] Apagar PDF cambia los PDF por el logo #condición
	- [ ] La fila de Ajustes dice qué tipos tienen miniatura, o Desactivada #condición
	- [ ] La elección se mantiene al cerrar y abrir la app #condición
- [ ] Archivos ocultos muestra Mostrar en Explorar e Incluir en Buscar, los dos apagados en una instalación nueva
	- [ ] Activar Mostrar en Explorar muestra los ocultos al momento en la pestaña abierta #condición
	- [ ] Activar solo Incluir en Buscar no los muestra en Explorar #condición
	- [ ] La fila de Ajustes dice Ocultos, En Explorar, En Buscar o En Explorar y Buscar #condición
	- [ ] Se mantiene al cerrar y abrir la app #condición
- [ ] Vibrar al seleccionar está prendido en una instalación nueva
	- [ ] Mantener presionado un elemento vibra al empezar la selección #condición
	- [ ] Con selección activa, tocar otro elemento, tocar el encabezado de un grupo y Seleccionar todo vibran poquito #condición
	- [ ] Deslizar marcando vibra con cada elemento que pasa el dedo #condición
	- [ ] Igual en Favoritos, la Papelera y la lista de un tipo en Espacio #condición
	- [ ] Apagarlo (con la fila o con el interruptor) quita todas estas vibraciones sin reiniciar #condición
	- [ ] Se mantiene al cerrar y abrir la app #condición
	- [ ] Con la respuesta táctil apagada en Ajustes de Android no vibra aunque esté prendido #condición
	- [ ] El texto de la fila sale en los cuatro idiomas #condición
- [ ] Índice muestra cuántos archivos tiene, "Al día desde" con la fecha y "La última revisión tardó"
	- [ ] Volver a indexar muestra el progreso y el botón queda desactivado hasta terminar #condición
	- [ ] Abrir la app sin cambios: la revisión tarda menos de 2 s y no aparece el progreso #condición
	- [ ] Crear, borrar y renombrar un archivo con otra app en una carpeta que no esté abierta en Gakoken, volver a Gakoken: Buscar ya lo refleja sin Volver a indexar #condición
- [ ] Ninguna hoja inferior queda tapada por la barra de navegación #condición
	- [ ] Ordenar y filtrar
	- [ ] Memorias
	- [ ] Archivos ocultos
	- [ ] Vista previa
	- [ ] Índice
	- [ ] Idioma
	- [ ] Opciones de tema
	- [ ] Eliminar tema


## Pie de Ajustes (OR-16, 2026-11-17)
- [ ] Al final de Ajustes, 24 debajo de la tarjeta y centrado, sale el nombre de la app con su versión (la del pubspec, sin el número de compilación) y debajo "Hecho por Morobu" en el color principal del tema #ui
- [ ] Tocar "Hecho por Morobu" abre morobu.com en el navegador del sistema; al regresar, la app sigue en Ajustes #flujo
- [ ] El texto sale en todos los idiomas: Hecho por Morobu, Made by Morobu, Créé par Morobu, 制作: Morobu #idioma
- [ ] Sin navegador instalado, tocarlo no hace nada y la app no se cierra #condición
- [ ] Con cualquier tema (claro y oscuro) los dos renglones se leen bien #ui

## Tutorial
- [ ] Recién instalada (o con los datos borrados), cada recorrido sale solo la primera vez que se abre su pantalla (Explorar, Favoritos y Espacio)
	- [ ] Sin permiso, Explorar y Espacio no muestran recorrido; al conceder el permiso aparece el de la pestaña abierta #condición
	- [ ] Favoritos muestra su recorrido la primera vez que se abre, con o sin permiso #condición
	- [ ] Al volver a abrir la app o la pantalla, el recorrido ya no sale #condición
	- [ ] Si la pantalla tarda en cargar, el recorrido espera y sale cuando ya se ve lo que explica; nunca se salta sin haberse mostrado (corregido 2026-11-13) #condición
- [ ] La burbuja muestra título, texto, contador ("1 de 3"), Saltar y Siguiente; en el último paso, Listo y sin Saltar
	- [ ] Solo el control que se explica queda a la vista, ajustado a él y no a su contenedor (por ejemplo el botón, no toda la fila); los botones de ícono se resaltan con un círculo y lo demás con un rectángulo de esquinas suaves (cambiado 2026-11-13) #visual
	- [ ] En un teléfono con muesca o cámara perforada, el resaltado cae justo sobre el control, sin correrse a la derecha ni a la izquierda; también al girar el teléfono 180 grados con el recorrido abierto (corregido 2026-11-18) #visual
	- [ ] La burbuja va abajo del elemento si está en la mitad de arriba y arriba si está en la mitad de abajo; nunca tapa el elemento #visual
	- [ ] Tocar el elemento resaltado avanza; tocar fuera no hace nada #condición
	- [ ] El botón atrás del sistema cierra el recorrido y lo marca como hecho #condición
- [ ] Ajustes > Tutorial: lista los recorridos con "Hecho" en los terminados; tocar uno lo vuelve a mostrar
- [ ] En inglés, francés o japonés (y alemán si la app lo tiene) todos los textos del tutorial salen traducidos #idioma
- [ ] Con "Quitar animaciones" activo, la burbuja y el resaltado cambian sin animación #condición

# Bugs generales

# Cambios futuros

Casos que se agregan cuando cada función exista (vienen del plan anterior). Hoy no se pueden ejecutar.

## Versión Windows (Etapa 2)
Por definir.

# Prueba de rendimiento (eliminado)

Se quitó de la app el 2026-10-20, al cerrar la Fase 1 (ganó Rust). Los casos quedan como registro; ya no se ejecutan.

- [ ] El ícono de velocímetro arriba a la derecha de Explorar abre la prueba de rendimiento
- [ ] Sin permiso se ve la explicación y el botón Dar permiso, sin Iniciar prueba
- [ ] Dar permiso abre los ajustes de Android
	- [ ] Concederlo y regresar muestra Iniciar prueba #condición
	- [ ] Regresar sin concederlo deja Dar permiso y la app no se cierra #condición
- [ ] Con el permiso ya concedido, al entrar aparece directo Iniciar prueba
- [ ] Iniciar prueba muestra el paso actual (Rust 1 de 2, Dart 1 de 2, Dart 2 de 2, Rust 2 de 2, Buscando)
	- [ ] El botón Iniciar prueba queda desactivado mientras corre #condición
	- [ ] Se puede desplazar la pantalla mientras corre (la app no se congela) #condición
- [ ] La tabla se va llenando: celdas pendientes con `...`, las que no aplican con `-`
- [ ] Al terminar se ven todas las filas y el texto "Listo. Manda una captura de la tabla."
- [ ] Archivos y carpetas da una cantidad parecida en Rust y en Dart
- [ ] Sin acceso puede no ser cero (Android/data y Android/obb) #condición
- [ ] Correr la prueba otra vez limpia la tabla y vuelve a medir
- [ ] Salir de la pantalla mientras corre y volver a entrar no cierra la app
- [ ] Teléfono con muchos archivos (más de 100 000): la prueba termina sin cerrarse
