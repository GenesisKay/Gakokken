# Arquitectura de Gakoken

Decidida el 2026-10-18 y validada con la prueba de rendimiento del 2026-10-20. El producto, las tareas y las decisiones de producto viven en la nota `Gakoken` del vault (`D:/3-Projects/Software/Vault/Proyectos/Gakoken.md`).

# Requisitos que guían la decisión

- Lo principal de Gakoken es la **rapidez**: indexación del almacenamiento, búsqueda instantánea y espacio usado sin esperar.
- Plataformas: **Android** primero, después **Linux** y **Windows**. Todas las apps de la serie se planean también para Linux.
- Sin red: todo trabaja sobre el almacenamiento local.

# Decisión

| Capa | Elección |
| --- | --- |
| Interfaz | **Flutter** (un solo código para Android, Linux y Windows) |
| Motor | **Rust** desde el inicio (crate `gakoken_core`) |
| Puente | `flutter_rust_bridge` (llamadas y streams de progreso) |
| Índice | SQLite (`rusqlite`): nombre, ruta, tamaño, fecha y tipo |
| Acceso en Android | Acceso a todos los archivos (`MANAGE_EXTERNAL_STORAGE`) |
| Configuración y favoritos | Hive (`hive_ce`), sin SharedPreferences |

# Por qué

- **La velocidad viene del índice, no de la UI.** Se indexa una vez y luego se consulta en milisegundos. Buscar, filtrar, ordenar y "espacio por ruta y por tipo" se vuelven consultas al índice en lugar de recorrer el disco.
- **Rust gana justo en eso:** recorrido paralelo de carpetas, índice compacto en memoria, búsqueda difusa rápida y acceso directo a APIs de cada sistema (journal de NTFS en Windows, inotify en Linux).
- **Flutter para la UI** porque toda la serie Morobu está en Flutter (temas, idiomas, componentes) y corre estable en Android, Linux y Windows. Una lista virtualizada en Flutter ya es fluida; la UI no limita la velocidad.
- **Acceso a todos los archivos** porque con SAF (carpetas elegidas por el usuario) no se puede indexar todo el almacenamiento rápido. Play Store permite este permiso a los gestores de archivos, con una declaración.
- **Salida a futuro:** como el motor está separado de la UI, si la UI de escritorio en Flutter no convence, se puede hacer otra UI de escritorio (por ejemplo Slint) sin tocar el motor.

## Límites conocidos

- En Android el primer indexado completo es lento sin importar el lenguaje: el acceso a archivos pasa por una capa del sistema desde Android 11. Rust no acelera el disco; acelera construir y consultar el índice.
- En Android nadie puede entrar a `Android/data` ni `Android/obb` desde Android 11, ni con acceso a todos los archivos.
- Costo de Rust: aprender el lenguaje, compilar con el NDK para cada arquitectura de Android y builds más lentos.

# Arquitectura planeada

```
Flutter (UI)                 Android | Linux | Windows
   | flutter_rust_bridge
Rust: gakoken_core
   - walker:  recorre carpetas en paralelo (jwalk o rayon)
   - index:   SQLite con los metadatos de cada archivo
   - search:  búsqueda difusa (nucleo) + subcadena en SQLite
   - stats:   espacio por carpeta y por tipo, sobre el índice
   - ops:     copiar y mover como jobs en cola, con progreso y cancelación
   - watcher: mantiene el índice al día
   | trait de backend por plataforma (list, stat, copy, move, delete, watch)
Android (todos los archivos) | Linux (inotify, freedesktop) | Windows (NTFS/USN)
Código nativo solo para lo propio de cada sistema: permisos, abrir con otra app, compartir
```

Reglas:

- **El motor no depende de la UI.** Se prueba con tests unitarios y se puede reutilizar en una CLI.
- **Las pantallas nunca tocan archivos directamente**: todo pasa por el motor.
- **Nada pesado en el hilo de la UI.** Indexar, buscar, calcular tamaños y copiar corren en hilos de Rust y reportan progreso por streams.
- **Listados en streaming:** mostrar las primeras entradas en cuanto llegan y seguir cargando.
- **Lista virtualizada:** solo se dibujan las filas visibles; el stat se pide bajo demanda.
- **Miniaturas asíncronas** con caché en disco por ruta y fecha de modificación.
- **Estado en Flutter:** `ChangeNotifier`, como el resto de la serie. Un controller por pantalla del explorador (ruta, selección, orden), pasado por constructor; un solo servicio global de portapapeles. Los servicios globales (tema, idioma) se quedan como están.
- **Navegación:** tabs Explorar | Favoritos | Ajustes. La pila de carpetas vive en el controller y el botón atrás sube de carpeta antes de salir de la app. La ruta actual se muestra una vez, como breadcrumb.

Estructura de carpetas planeada al decidir la arquitectura; la estructura real está en `context/context.md`:

```
lib/
  core/            temas, l10n, widgets Morobu, settings
  bridge/          código generado por flutter_rust_bridge
  features/
    browser/       lista, breadcrumb, selección, orden y filtros
    favorites/
    search/
    storage_usage/
    settings/
rust/gakoken_core/
```

## Mantener el índice al día

| Plataforma | Cómo |
| --- | --- |
| Android | Hecho así (2026-10-21): primer indexado completo; al abrir y al volver a la app, un `stat` por carpeta en paralelo y solo se leen las que cambiaron de fecha (`index::changes`), y en SQLite solo se reescribe lo que cambió; `FileObserver` en la carpeta de la pestaña activa; recorrido completo al abrir si el último tiene más de un día. WorkManager quedó fuera: correr el motor con la app cerrada pide un motor de Flutter en segundo plano y el recorrido diario al abrir cubre lo mismo |
| Linux | inotify (vigila carpeta por carpeta y tiene límite) + revisión por fecha de modificación |
| Windows | Journal USN de NTFS (normalmente requiere administrador); sin permisos, `ReadDirectoryChangesW` + revisión por fecha |

## Detalles por plataforma

- **Android:** permiso de todos los archivos y su declaración en Play Store; abrir archivos con FileProvider + intent y el selector "Abrir con" (código nativo en `MainActivity.kt`); compartir con `share_plus`; el tipo con `MimeTypeMap`; `<queries>` en el manifest; miniaturas de imágenes y videos con `ThumbnailUtils` (antes de Android 10, `BitmapFactory` reducido y `MediaMetadataRetriever`) y de PDF con `PdfRenderer`, guardadas como JPEG en `cacheDir/thumbs` con llave ruta + fecha + tamaño; al abrir, si el caché pasa de 150 MB se borran las menos usadas hasta 100 MB.
- **Linux:** papelera con el estándar de freedesktop; abrir con `xdg-open` o portales si se distribuye como Flatpak; detectar unidades montadas (USB, discos externos).
- **Windows:** rutas largas, permisos y archivos bloqueados por otros procesos.

# Alternativas descartadas

| Opción | Por qué no |
| --- | --- |
| Solo Flutter/Dart | Suficiente para un explorador que lista carpetas, pero la indexación es lo central y Rust gana ahí. Se confirma con la prueba de rendimiento |
| Rust + Slint | Slint en Android solo funciona con Rust y su página de móviles lo marca como planeado en el roadmap; no hay anuncio de soporte estable. Obliga a rehacer temas, idiomas e integración con Android (compartir, abrir, permisos por JNI). Su licencia gratuita 2.0 cubre móvil pero pide atribución (widget AboutSlint o insignia en la web de descarga) |
| Tauri 2 + Rust | Muy bueno en escritorio; en Android depende del WebView y su soporte móvil es reciente |
| Kotlin Multiplatform + Compose | Sólido, pero sería otro stack aparte de toda la serie |
| Kotlin en Android + otra app de escritorio | Dos UIs que mantener |
| SAF en Android | No permite indexar todo el almacenamiento rápido |
| tantivy para el índice | Es búsqueda de texto completo. Tiene sentido si después se busca dentro del contenido de los documentos; para nombre, tamaño y tipo basta SQLite + nucleo |
| tokio para leer archivos | Pensado para red; con archivos locales termina usando hilos. Mejor rayon o hilos |

# Métricas objetivo

Propuestas; se miden en un teléfono real con muchos archivos.

| Métrica | Objetivo |
| --- | --- |
| Primeras entradas de una carpeta con 10 000 archivos | Menos de 100 ms |
| Búsqueda sobre un índice de 200 000 archivos | Menos de 50 ms por consulta |
| Espacio por carpeta y por tipo, con índice listo | Menos de 100 ms |
| Reindexado al abrir la app sin cambios | Menos de 2 s (Ajustes, Índice, muestra cuánto tardó la última revisión) |
| UI durante indexado o copia | Sin tirones (60 fps) |
| Memoria del índice | 2,04 MB con 7 347 archivos; fijar el límite al medir con más |

# Prueba de rendimiento (2026-10-20)

Medido el 2026-10-20 en el teléfono del usuario (Android, 7 347 archivos y carpetas).

| Medida | Rust | Dart | Rust contra Dart |
| --- | --- | --- | --- |
| Archivos y carpetas | 7 347 | 7 347 | Iguales |
| Sin acceso | 0 | 2 | - |
| Indexado, vuelta 1 (caché en frío para Rust) | 575 ms | 1 907 ms | 3,3 veces más rápido |
| Indexado, vuelta 2 | 480 ms | 2 223 ms | 4,6 veces más rápido |
| Guardar en SQLite | 147 ms | - | - |
| Índice en disco | 1,86 MB | - | - |
| Memoria del índice | 2,04 MB | sin dato | - |
| Búsqueda por texto (promedio de 10) | 0,79 ms | 3,06 ms | 3,9 veces más rápido |
| Búsqueda con errores de escritura | 1,75 ms | no existe | - |
| Búsqueda en SQLite | 2,55 ms | - | - |

Regla para decidir (propuesta y aceptada el 2026-10-20): Rust si Dart pasa de 50 ms al buscar, si usa mucha más memoria o si Rust es al menos el doble de rápido indexando o buscando; Dart si queda cerca en todo.

**Decidido el 2026-10-20: el motor va en Rust.**
- Rust es entre 3 y 4,6 veces más rápido indexando y casi 4 veces más rápido buscando.
- Este teléfono tiene pocos archivos. Si el tiempo crece en proporción, con 200 000 archivos (la meta) la búsqueda en Dart rondaría 80 ms (pasa la meta de 50 ms) y en Rust unos 20 ms. El indexado completo sería de casi un minuto en Dart y unos 15 s en Rust.
- Solo Rust tiene búsqueda con errores de escritura, que es requisito, y aun así tarda menos que la búsqueda simple de Dart.
- La memoria de Dart salió sin dato: medir la memoria del proceso en Dart no es confiable (el recolector de basura la mueve). No cambia la decisión.
- Sin acceso: Dart cuenta 2 carpetas que Rust salta sin contarlas como error. No cambia los conteos.

## Cómo se midió

La pantalla de prueba (ya retirada del código):
- Indexa todo `/storage/emulated/0` dos vueltas con cada motor. Orden: Rust, Dart, Dart, Rust (en la vuelta 1 a Rust le toca el caché del sistema en frío).
- Rust: recorrido en paralelo (`jwalk`), guardado en SQLite (WAL, una transacción), búsqueda por subcadena y difusa (`nucleo`) en paralelo, y `LIKE` en SQLite.
- Dart: recorrido en un isolate con `listSync` y `statSync`, búsqueda por subcadena en un hilo. Sin SQLite ni búsqueda difusa (no hay equivalente directo).
- Memoria: crecimiento de la memoria del proceso al guardar el índice (`VmRSS` en Rust, `ProcessInfo.currentRss` en Dart). Es aproximada.
- Búsqueda: promedio de 10 consultas, dos de ellas con errores de escritura (`wahtsapp`, `scrennshot`).

# Fuentes (consultadas el 2026-10-18)

- [Slint en Android](https://docs.slint.dev/latest/docs/slint/guide/platforms/android)
- [Slint en móviles (roadmap)](https://snapshots.slint.dev/master/docs/slint/guide/platforms/mobile)
- [Licencia Slint Royalty-free 2.0](https://unpkg.com/slint-ui@1.12.0/LICENSES/LicenseRef-Slint-Royalty-free-2.0.md)
- [Flutter en Linux (Canonical)](https://canonical.com/blog/bring-multi-platform-apps-to-linux-desktop-with-flutter-3?format=md)
- [Flutter en escritorio en 2026](https://ecorpit.com/flutter-desktop-2026-production-ready/)
