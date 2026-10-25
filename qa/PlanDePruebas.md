# Gakoken - Plan de pruebas

# Plan

## Objetivo
Asegurar que cada APK del prototipo se instala y funciona en un teléfono Android real: que se puede explorar el almacenamiento, buscar, ordenar, filtrar, ver el espacio usado, abrir, compartir, guardar favoritos y ver miniaturas, y que todo se siente rápido.

## Alcance
Dentro:
- Todo lo de `HistoriasDeUsuario.md`: instalación y pestañas, permiso de almacenamiento, explorar carpetas, vistas, logos y miniaturas, ordenar y filtrar, índice y búsqueda, espacio usado, abrir, compartir, favoritos, idioma, temas, vista previa e índice en Ajustes.

Fuera:
- Linux y Windows (todavía no se prueban).
- Lo listado en la sección "Pendientes del producto" de `AnalisisDeSistema.md`.

# Pruebas

## General
- [ ] Gakoken se instala con Eloisa (u otra app de la serie) ya instalada, y las dos siguen funcionando
- [ ] La barra inferior muestra Explorar, Favoritos, Espacio y Ajustes
- [ ] Cambiar de pestaña y regresar conserva lo que había #condición
- [ ] Nada queda tapado por la barra de estado ni por la barra de navegación #condición
	- [ ] Navegación con 3 botones
	- [ ] Navegación con gestos

## Explorar
- [ ] Instalación nueva: Explorar muestra la explicación del permiso y Dar permiso, sin listado
	- [ ] Conceder el permiso y regresar muestra el contenido de Interno #condición
	- [ ] Regresar sin concederlo deja la explicación y la app no se cierra #condición
- [ ] Con permiso, el título deja de decir Explorar y muestra la carpeta actual con una flecha hacia abajo; no hay fila de ruta debajo
- [ ] Instalación nueva con permiso: aparece "Indexando tu teléfono: N archivos y carpetas" con el número subiendo, y desaparece al terminar
	- [ ] Se puede navegar mientras indexa #condición
- [ ] Tocar una carpeta la abre y el título cambia a su nombre
	- [ ] Tocar el título abre el menú como árbol: la memoria arriba con su ícono, cada carpeta debajo más metida con una flecha, y la actual al final con carpeta abierta y marcada; luego Memorias y Pestaña nueva #condición
	- [ ] Con más de 7 niveles la sangría deja de crecer y los nombres se cortan con puntos suspensivos #condición
	- [ ] Tocar una carpeta del menú va a ella #condición
	- [ ] Con un nombre muy largo, el título se corta con puntos suspensivos y la flecha sigue visible #condición
	- [ ] En la raíz de una memoria el título dice su nombre (Interno, la SD, Raíz del sistema) #condición
- [ ] Botón atrás del sistema dentro de una carpeta regresa a la anterior
	- [ ] Al abrir la app en una carpeta guardada (sin historial), atrás sube una carpeta #condición
	- [ ] En Interno sin historial, atrás sale de la app #condición
	- [ ] En Favoritos o Ajustes, atrás sale de la app aunque Explorar esté dentro de una carpeta #condición
- [ ] Carpetas primero y luego archivos, por nombre sin importar mayúsculas
- [ ] Con Ajustes de fábrica no aparecen nombres que empiezan con punto (por ejemplo `.thumbnails` en DCIM)
- [ ] Vista Lista: logo, nombre y debajo tamaño (archivos) o elementos (carpetas) y fecha
	- [ ] El número de elementos de las carpetas aparece un momento después #condición
- [ ] Carpeta con miles de archivos (DCIM/Camera): las primeras filas salen al instante y la barra fina arriba desaparece al terminar
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
	- [ ] Galería: fotos y videos ocupan toda la celda sin nombre; carpetas y documentos muestran logo y nombre #condición
	- [ ] Galería: mantener presionado selecciona (borde, tinte y palomita) y tocar abre o marca como en las demás vistas #condición
	- [ ] La vista elegida se usa en todas las carpetas #condición
	- [ ] La vista se mantiene al cerrar y abrir la app #condición
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
	- [ ] El orden se usa al entrar a otras carpetas y en todas las pestañas #condición
	- [ ] El orden se mantiene al cerrar y abrir la app #condición
- [ ] En Detalles, tocar Tamaño ordena del más ligero al más pesado; tocarlo otra vez lo invierte; la flecha marca la columna y coincide con la hoja
- [ ] Mostrar solo PDF: quedan los PDF y las carpetas; arriba de la lista aparece el chip PDF
	- [ ] La X del chip quita ese filtro y el chip desaparece #condición
	- [ ] El ícono de ajustes no lleva número #condición
	- [ ] Marcar también Imágenes muestra 2 y deja ver los dos tipos #condición
	- [ ] En una carpeta sin PDF dice "Ningún archivo de este tipo en esta carpeta." #condición
	- [ ] Quitar filtro vuelve a mostrar todo #condición
	- [ ] Al cerrar y abrir la app el filtro ya no está #condición
	- [ ] El filtro de una pestaña no afecta a las otras #condición

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
- [ ] Con una sola pestaña no hay tira de pestañas; Pestaña nueva está en el menú del título
- [ ] Pestaña nueva abre una pestaña en Raíz del sistema y aparece la tira con las dos y un + al final
	- [ ] El + de la tira abre otra pestaña #condición
- [ ] Seleccionar una carpeta, Más, Abrir en pestaña nueva: abre otra pestaña en esa carpeta y la activa
- [ ] Cada pestaña dice su carpeta; en la raíz, el nombre de la memoria
- [ ] Tocar una pestaña la activa y muestra su carpeta, con su propio filtro
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
- [ ] Recién instalada, Explorar abre en Raíz del sistema y muestra carpetas como `apex`, `data`, `dev`, `proc`, `sdcard`, `storage`, `system` y `vendor`
	- [ ] + (pestaña nueva) también abre en Raíz del sistema #condición
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
- [ ] Muestra el total, cuántos archivos y carpetas, Por tipo y Lo que más ocupa
	- [ ] Por tipo: cada tipo con logo, nombre, tamaño, porcentaje, barra y cantidad de archivos, del que más ocupa al que menos #condición
- [ ] Tocar un tipo (por ejemplo Videos) lista sus archivos de esa carpeta y sus subcarpetas, del más pesado al más ligero, con tamaño y ubicación
	- [ ] Buscar (lupa) filtra la lista por nombre; sin coincidencias dice "Sin resultados." #condición
	- [ ] Ordenar ofrece Nombre, Modificado y Tamaño (sin Tipo); un toque de menor a mayor, otro lo invierte #condición
	- [ ] Vista cambia entre Lista, Detalles, Cuadrícula y Galería; al volver, Explorar sigue en su vista y su orden #condición
	- [ ] La cantidad coincide con la del tipo en Espacio (hasta 500) #condición
	- [ ] Tocar uno lo abre; mantener presionado abre su hoja y eliminarlo lo quita de la lista #condición
	- [ ] En un USB también funciona #condición
	- [ ] Lo que más ocupa: del más pesado al más ligero #condición
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
- [ ] Seleccionar un solo archivo y tocar Más muestra su logo y nombre con Abrir, Compartir, Copiar ruta, Agregar a favoritos, Renombrar y Eliminar
- [ ] Copiar ruta avisa "Ruta copiada"; al pegar en otra app (por ejemplo WhatsApp) sale la ruta completa del archivo
	- [ ] Con una carpeta también está y copia la ruta de la carpeta #condición
	- [ ] En Buscar, Favoritos y la lista de un tipo de Espacio, mantener presionado también la ofrece #condición
	- [ ] Lo que había en Copiar o Cortar de Gakoken no se pierde #condición
- [ ] Seleccionar una sola carpeta y tocar Más muestra Abrir en pestaña nueva, Espacio usado, Agregar a favoritos, Renombrar y Eliminar
- [ ] En Buscar, Favoritos y Espacio, mantener presionado abre directo esa hoja (no selecciona)
- [ ] Compartir abre el menú del sistema y el archivo llega bien (por ejemplo a WhatsApp o Gmail)
	- [ ] Cancelar el menú no hace nada #condición
- [ ] Abrir y compartir un archivo con espacios, acentos o emojis en el nombre #condición
- [ ] Ninguna hoja inferior queda tapada por la barra de navegación #condición
	- [ ] Opciones de un archivo
	- [ ] Vista

## Selección y acciones
- [ ] Mantener presionado un elemento lo selecciona: palomita en lugar del logo y fondo de color; arriba "1 seleccionado"
	- [ ] Tocar otros los suma; tocar uno seleccionado lo quita #condición
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
- [ ] Copiar, renombrar y eliminar también en la SD y en un USB

## Papelera
- [ ] Ajustes, Papelera, dice cuántos elementos hay y abre la lista
- [ ] Papelera vacía: dice que lo borrado se guarda 30 días
- [ ] Ajustes, Días en la papelera dice 30 días y abre el diálogo con 30; guardar 7 cambia el texto y los días restantes
	- [ ] Vacío, 0 o 1000 no deja guardar #condición
	- [ ] Con algo borrado hace más de 2 días (cambiando la fecha del teléfono), guardar 1 lo borra para siempre al momento #condición
	- [ ] Al cerrar y abrir la app se mantiene el número elegido #condición
- [ ] Cada elemento muestra su logo o miniatura, de dónde venía y "Quedan 30 días"
- [ ] Tocar uno: Restaurar lo regresa a su carpeta
	- [ ] Si en su carpeta ya hay algo con ese nombre, vuelve como "nombre (1)" #condición
	- [ ] Si su carpeta ya no existe, se vuelve a crear #condición
- [ ] Eliminar para siempre pide confirmación y lo borra
- [ ] Vaciar pide confirmación y deja la papelera vacía; Espacio baja
- [ ] La carpeta `.gakoken-trash` no aparece en Explorar aunque se muestren los ocultos, ni en Buscar
- [ ] Lo borrado en la SD o el USB solo aparece en la papelera con esa memoria conectada

## Favoritos
- [ ] Sin favoritos, la pestaña dice cómo agregarlos
- [ ] Agregar un archivo y una carpeta desde Explorar; aparecen en Favoritos, el último arriba
	- [ ] Cada uno muestra dónde está (Interno / ...) #condición
	- [ ] En su hoja la opción ahora dice Quitar de favoritos #condición
- [ ] Tocar una carpeta favorita abre Explorar en esa carpeta
- [ ] Tocar un archivo favorito lo abre
- [ ] Quitar de favoritos desde Explorar y desde Favoritos
- [ ] Los favoritos se mantienen al cerrar y abrir la app
- [ ] Borrar un archivo favorito con otra app y volver a Favoritos: logo atenuado y "Ya no existe" en rojo
	- [ ] Tocarlo solo avisa "Ya no existe" #condición
	- [ ] Su hoja solo ofrece Quitar de favoritos #condición

## Configuración
- [ ] Cambiar idioma (es, en, fr, ja)
	- [ ] Los textos de Explorar, Buscar, Espacio usado, Favoritos y las hojas cambian de idioma; fechas, números y tamaños usan el formato del idioma #condición
	- [ ] Se mantiene al cerrar y abrir la app #condición
- [ ] Primera apertura con el teléfono en un idioma no soportado: la app sale en inglés
- [ ] Gakoken es el tema por defecto en una instalación nueva
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
