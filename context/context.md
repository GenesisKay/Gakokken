# Gakoken — Contexto para agentes

> Lee esto primero. Producto, etapas y decisiones viven en Obsidian (ver [`documentacion-obsidian.md`](documentacion-obsidian.md)). Antes de implementar, lee `Gakoken-Arquitectura.md` y `Gakoken-Prototipo.md` en el vault.

Explorador de archivos rápido con indexación. UI en Flutter; el motor de indexación va en Rust (crate `gakoken_core` en `rust/`).

| Dato | Valor |
| --- | --- |
| Paquete | `gakoken` |
| applicationId (Android) / APPLICATION_ID (Linux) | `com.gakoken.gakoken` |
| Plataformas | Android (primero), Linux, Windows |
| minSdk Android | 24 |

## Arranque

```
main.dart
  ├── edge-to-edge
  ├── Hive.initFlutter() + HiveBootstrap (cajas themes, settings y favorites)
  ├── initializeDateFormatting()
  ├── RustLib.init() (carga el motor) + FileEngine.instance = RustFileEngine()
  ├── StorageVolumesService().start() (memorias: Interno, SD, USB y raíz del sistema `/`, donde abre recién instalada)
  └── runApp(GakokenApp)

GakokenApp (app.dart)
  ├── ThemeService, LocaleService (singletons ChangeNotifier)
  └── MaterialApp → home: MainScreen

MainScreen → NavigationBar: Explorar | Favoritos | Espacio | Ajustes
  (dueño de ExplorerController y UsageTabController: PopScope hace que atrás
   navegue el historial de la pestaña activa en Explorar y suba en Espacio;
   al haber permiso llama IndexService().start(): carga index.db y lo pone al día)
  ├── BrowserScreen   (features/browser: pestañas, historial, memorias, 4 vistas, orden y filtro,
  │                    selección múltiple, barras de pegar y de progreso, permiso)
  │     └── SearchScreen (features/search)
  ├── FavoritesScreen (features/favorites: lista, abrir, marca los que ya no existen)
  ├── StorageUsageTab (features/storage_usage: espacio usado; en la barra por ahora)
  └── SettingsScreen  (features/settings: idioma, temas, vista previa, ocultos, papelera, índice)
        └── TrashScreen (features/trash)
```

## Estructura de `lib/`

| Carpeta | Contenido |
| --- | --- |
| `core/theme/` | Sistema de temas compartido de la serie (`AppColorExtension`, `AppTheme`, `AppTypography`) |
| `core/engine/` | `FileEngine`: interfaz para listar carpetas (stream por partes, `exists`). La implementa `RustFileEngine`; las pruebas usan una falsa. `fileEntryOf` convierte el `FileItem` de Rust |
| `core/services/` | `ThemeService`, `LocaleService`, `ScaffoldMessengerService`, `PlatformDetectionService`, `StoragePermissionService` (permiso de todos los archivos y raíz a indexar), `FavoritesService` (caja `favorites`), `FileActionsService` (abrir con el selector de Android por el canal `gakoken/system`, compartir con `share_plus`), `IndexService` (índice de Interno y SD, búsqueda y espacio usado en Rust; al abrir y al volver a la app pone al día solo lo que cambió, completo una vez al día), `StorageVolumesService` (memorias montadas por el canal nativo; USB no se indexa), `ExplorerSettingsService` (vista, orden con un toque y ocultos, compartidos por todas las pestañas), `FileOpsService` (portapapeles de Gakoken, tareas de copiar y mover una tras otra, renombrar), `TrashService` (papelera: `.gakoken-trash` en cada memoria + caja `trash`, 30 días), `FileChanges` (aviso de carpetas que cambiaron para recargar pantallas), `PreviewSettingsService` (qué tipos muestran miniatura), `ThumbnailService` (miniaturas de imagen, video (con botón de reproducir encima, en `FileThumbnail`) y PDF; en Android por el canal nativo con caché en disco), `FolderWatchService` (avisos de cambios en la carpeta abierta por el canal de eventos `gakoken/changes`, juntados en ráfagas; solo Android) |
| `core/storage/` | `HiveBootstrap` |
| `core/files/` | `FileKind` (tipo por extensión, con etiqueta y color fijo de su logo), `FileEntry` (lo que entrega el motor), `formatBytes`/`formatDate`, `kindLabel`/`locationOf` (textos para tipos y ubicación) |
| `core/widgets/` | Widgets Morobu: `GakokenAppBar`, `GakokenCardTile`, `showGakokenBottomSheet`, selectores de color, `FileKindIcon` (logo de un tipo de archivo; sus colores no salen del tema), `showGakokenOptionsSheet` (hoja con encabezado y opciones), `file_actions.dart` (hoja de opciones de un archivo y abrir con aviso), `FileThumbnail` (miniatura o logo según Ajustes; usar siempre este en listas), `KindFilterChips`, `showVolumePickerSheet` (elegir memoria), `showEntryInfoSheet` (`file_info_sheet.dart`: información de lo seleccionado), `file_dialogs.dart` (renombrar, nombres repetidos, confirmar). En `file_actions.dart`: `transferWithFeedback`, `renameWithFeedback`, `trashWithUndo` |
| `features/<nombre>/presentation/` | Pantallas, widgets y controllers por función. `browser/`: `ExplorerController` (permiso y pestañas, guardadas en `settings`), `BrowserController` (una pestaña: carpeta, filtro, historial atrás y adelante), `EntryViews` (Lista, Lista compacta, Detalles, Cuadrícula), `BreadcrumbBar` (la primera parte abre Memorias), `ExplorerTabStrip` (solo con dos o más pestañas), `sort_filter_sheet.dart` (también `showSortSheet`, solo ordenar con un `SortChoice` propio), `view_mode_sheet.dart` (vistas, compartida con Espacio), `folder_title.dart` (título con la carpeta actual y menú de ubicación; reemplaza el breadcrumb en Explorar), `file_ops_bars.dart` (`SelectionBar`, `PasteBar`, `JobPanel`). `BrowserController` también lleva la selección. `search/`, `storage_usage/` (`UsageTabController` + `StorageUsageTab` + `KindFilesScreen`: archivos de un tipo con buscar, orden y vista propios), `settings/widgets/` (`preview_settings_sheet.dart`, `hidden_files_sheet.dart`, `index_sheet.dart`) |
| `screens/` | `MainScreen` |
| `l10n/` | ARB en es (plantilla), en, fr, ja |
| `src/rust/` | Puente generado por `flutter_rust_bridge`; no editar a mano |

## Temas

Default `Gakoken` (gato naranja, claro) y `nekokag` (su par oscuro), más los temas de la serie (`eloisa`, `asiole`, `ajoruto`, `oturoja`, `manubu`, `ubunam`, `zontle`, `eltnoz`, `bioka`, `akoib`). Valores en `lib/core/theme/color_extensions.dart`; paletas con nombre humano en Obsidian (`Design System/Paletas.md`).

## Motor Rust

| Ruta | Contenido |
| --- | --- |
| `rust/` | Crate `gakoken_core`. La API que ve Dart vive en `rust/src/api/engine.rs` (`list_dir`, `engine_open` con varias raíces, `index_build`, `index_update` (solo lo que cambió), `files_by_extension` (archivos de un tipo en Espacio), `search` con ocultos opcionales, `storage_usage`, que recorre en el momento lo que no está indexado). El índice en `rust/src/index.rs`: recorrido con `jwalk`, copia en SQLite (`save` completo y `save_paths` solo lo que cambió), `changes` y `apply` (un `stat` por carpeta y solo se leen las que cambiaron de fecha), tamaños por carpeta, búsqueda (subcadena, `nucleo` y errores de escritura con distancia de Sellers) y espacio usado. Tests al final de `index.rs`: `cargo test` dentro de `rust/` |
| `rust/src/ops.rs` + `rust/src/api/ops.rs` | Copiar y mover (`transfer` con progreso por stream y `cancel_job`; al cancelar borra el archivo a medias), nombres `(1)`, renombrar, `move_exact` (papelera y restaurar), borrar e `index_refresh` (pone al día solo las rutas tocadas). `TRASH_DIR` nunca sale en `list_dir` ni en `search` |
| `android/.../MainActivity.kt` | Canal `gakoken/system`: `openWith` (selector "Abrir con" con `FileProvider` `${applicationId}.files`), `thumbnail` (imagen y video con `ThumbnailUtils`, PDF con `PdfRenderer`; JPEG en `cacheDir/thumbs`, recortado a 100 MB al abrir si pasa de 150 MB), `watch` (`FileObserver` en las carpetas pedidas; los cambios salen por el `EventChannel` `gakoken/changes`) y `storageVolumes` (memorias montadas con nombre, tipo y espacio; si es USB se pregunta por reflexión y si no, por el nombre) |
| `rust_builder/` | Plugin de Flutter (cargokit) que compila el crate con cada `flutter build`/`run`. Solo Android, Linux y Windows |
| `flutter_rust_bridge.yaml` | Configuración del generador |

Después de cambiar algo en `rust/src/api/`, regenerar el puente (requiere `flutter_rust_bridge_codegen` 2.13.0, la misma versión que el crate y `pubspec.yaml`):

```powershell
$env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
flutter_rust_bridge_codegen generate
```

Herramientas necesarias: ver [`run.md`](run.md).

## Versiones fijadas

- `REQUEST_INSTALL_PACKAGES` es para abrir APKs con el instalador. `<queries>` con `ACTION_VIEW` `*/*` deja saber si alguna app abre un archivo antes de mostrar el selector.
- `androidx.core:core-ktx` en `android/app/build.gradle.kts` para el `FileProvider`.
- `permission_handler` en `^11.4.0` (la misma de Eloisa): la 13.x trae `permission_handler_android` 14.x, que no compila con la configuración de Gradle/Kotlin del proyecto (bloque `kotlin {}` sin resolver).

## Almacenamiento

- Hive (`hive_ce`): cajas `themes` (temas de usuario), `settings` (tema activo, idioma, `browserViewMode`, `browserSortField`, `browserSortAscending`, `showHidden`, `searchHidden`, `explorerTabs`, `explorerActiveTab`, `preview_image`, `preview_pdf`) `favorites` (mapas `{path, isDir, addedAt}` con clave automática, porque Hive no acepta claves de más de 255 caracteres) y `trash` (`{id, originalPath, trashedPath, deletedAt, isDir}`; el archivo vive en `<memoria>/.gakoken-trash/<id>`). Las abre solo `HiveBootstrap` en `main`; los servicios usan `Hive.box(HiveBootstrap.…)`.
- El índice (Interno y tarjetas SD; no USB) vive en memoria dentro del motor Rust y se guarda en `index.db` (SQLite) en la carpeta de soporte de la app, no en Hive. Si cambian las raíces (se pone o se quita una SD) se vuelve a indexar. Al abrir y al volver a la app se carga y se pone al día en segundo plano (`index_update`: solo las carpetas que cambiaron de fecha); si el último recorrido completo tiene más de un día, se recorre todo (`index_build`). Los cambios de la carpeta abierta llegan por `FolderWatchService` y se aplican con `index_refresh`.

## Reglas para agentes

1. Colores con `context.colors`, textos con `context.typography` (ver [`../docs/design_rules.md`](../docs/design_rules.md)).
2. Textos de UI siempre por l10n, en los 4 idiomas.
3. Toda hoja modal con `showGakokenBottomSheet` + `GakokenSheetInset` / `gakokenSheetBottomInset` (la app es edge-to-edge; sin eso la barra de navegación de Android tapa las acciones). No envolver hojas de altura mínima en `SafeArea`.
4. Las pantallas nunca tocan archivos directamente: todo pasa por el motor (ver `Gakoken-Arquitectura.md`).
5. Nada pesado en el hilo de la UI.
6. Correr en Android: [`run.md`](run.md).

## Firma de release

`android/app/build.gradle.kts` firma con `android/key.properties` si existe; si no, con la llave de debug. Gakoken necesita su propia llave; no reutilizar `../old-app-signing-backup` (es de otra app).
