// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navSettings => 'Configuración';

  @override
  String get labelLanguage => 'Idioma';

  @override
  String get btnImport => 'Importar';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get btnSelect => 'Seleccionar';

  @override
  String get themesTitle => 'Temas';

  @override
  String get titleImportTheme => 'Importar Tema';

  @override
  String get instructionImportTheme => 'Pega el código JSON del tema aquí:';

  @override
  String get msgThemeImportSuccess => 'Tema importado correctamente';

  @override
  String get headerThemesDefault => 'Predeterminados';

  @override
  String get headerThemesCustom => 'Mis Temas';

  @override
  String get titleDeleteTheme => 'Eliminar Tema';

  @override
  String get statusActive => 'Activo';

  @override
  String get themeImportOr => 'O';

  @override
  String get themeSelectJson => 'Seleccionar Archivo JSON';

  @override
  String get themeImportFileSuccess => 'Tema importado desde archivo';

  @override
  String themeImportError(String error) {
    return 'Error al leer archivo: $error';
  }

  @override
  String themeExportError(String error) {
    return 'Error exportando: $error';
  }

  @override
  String themeSavedFile(String path) {
    return 'Tema guardado en: $path';
  }

  @override
  String get themeCopiedClipboard => 'JSON copiado al portapapeles';

  @override
  String get themeEmptyCustom =>
      'No has creado temas aún.\n¡Usa el botón + para empezar!';

  @override
  String themeConfirmDelete(String name) {
    return '¿Seguro que deseas eliminar \"$name\"?';
  }

  @override
  String get themeCreateTitle => 'Crear Tema';

  @override
  String get themeEditTitle => 'Editar Tema';

  @override
  String get themeGeneratorTitle => 'Generador';

  @override
  String get themeSeedColor => 'Semilla';

  @override
  String get themeBrightness => 'Brillo';

  @override
  String get themeGenerateAction => 'Generar Paleta';

  @override
  String get themeNameLabel => 'Nombre del Tema';

  @override
  String get themeDescLabel => 'Descripción';

  @override
  String get themeRequired => 'Requerido';

  @override
  String get btnOK => 'OK';

  @override
  String get themeSectionCore => 'Fondos y Textos (Core)';

  @override
  String get themeSectionBrand => 'Marca y Acción';

  @override
  String get themeSectionUI => 'Estados y UI';

  @override
  String get themeUseSecondary => 'Usar Color Secundario';

  @override
  String get themeUseSecondaryDesc =>
      'Estos colores no se usan en Gakoken, pero puedes definirlos aquí.';

  @override
  String get themeSelectColorTitle => 'Seleccionar Color';

  @override
  String get colorBgPrimary => 'Fondo Principal';

  @override
  String get colorBgSecondary => 'Fondo Secundario';

  @override
  String get colorBgElevated => 'Fondo Elevado';

  @override
  String get colorOverlay => 'Overlay';

  @override
  String get colorTextPrimary => 'Texto Principal';

  @override
  String get colorTextSecondary => 'Texto Secundario';

  @override
  String get colorTextDisabled => 'Deshabilitado';

  @override
  String get colorTextInverse => 'Invertido';

  @override
  String get colorPrimary => 'Color Primario';

  @override
  String get colorPrimaryHover => 'Hover';

  @override
  String get colorPrimaryActive => 'Active';

  @override
  String get colorSecondary => 'Color Secundario';

  @override
  String get colorSecondaryHover => 'Hover (Sec)';

  @override
  String get colorSecondaryActive => 'Active (Sec)';

  @override
  String get colorStateSuccess => 'Éxito (Verde)';

  @override
  String get colorStateWarning => 'Alerta (Amarillo)';

  @override
  String get colorStateError => 'Error (Rojo)';

  @override
  String get colorStateInfo => 'Info (Azul)';

  @override
  String get colorBorderSubtle => 'Borde Sutil';

  @override
  String get colorBorderFocus => 'Borde Foco';

  @override
  String get colorSurfaceHover => 'Sup. Hover';

  @override
  String get colorSurfaceActive => 'Sup. Active';

  @override
  String get themeStatusActive => 'Activo';

  @override
  String get themeActionApply => 'Aplicar Tema';

  @override
  String get themeActionCopyJson => 'Copiar JSON';

  @override
  String get themeActionSaveFile => 'Guardar Archivo';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get titleSelectColor => 'Seleccionar Color';

  @override
  String get themeDefaultName => 'Gakoken';

  @override
  String get themeDefaultDescription =>
      'Gato naranja: crema y naranja atigrado';

  @override
  String get themeDefaultName2 => 'Oturoja';

  @override
  String get themeDefaultDescription2 => 'Tema oscuro púrpura';

  @override
  String get themeDefaultName3 => 'Morobu';

  @override
  String get themeDefaultDescription3 => 'Tema claro gris, neutros cálidos';

  @override
  String get themeDefaultName4 => 'Uborom';

  @override
  String get themeDefaultDescription4 => 'Tema oscuro neutro';

  @override
  String get themeDefaultName5 => 'Zontle';

  @override
  String get themeDefaultDescription5 => 'Tema claro neutro, acento dorado';

  @override
  String get themeDefaultName6 => 'Eltnoz';

  @override
  String get themeDefaultDescription6 => 'Tema oscuro neutro, acento dorado';

  @override
  String get themeDefaultName7 => 'Ajoruto';

  @override
  String get themeDefaultDescription7 => 'Tema claro púrpura';

  @override
  String get themeDefaultName8 => 'Asiole';

  @override
  String get themeDefaultDescription8 =>
      'Tema colibrí oscuro: esmeralda y magenta';

  @override
  String get themeSectionBackgrounds => 'Fondos';

  @override
  String get themeSectionTexts => 'Textos';

  @override
  String get themeSectionPrimary => 'Primario';

  @override
  String get themeSectionSecondary => 'Secundario';

  @override
  String get themeSectionStates => 'Estados Semánticos';

  @override
  String get themeSectionComponents => 'Componentes';

  @override
  String get themeSaveTitle => 'Guardar tema';

  @override
  String get themeSelectFolderTitle => 'Seleccionar carpeta para guardar tema';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get favoritesEmpty =>
      'Todavía no tienes favoritos. Mantén presionado un archivo o carpeta en Explorar para agregarlo.';

  @override
  String get themeNameNekokag => 'Nekokag';

  @override
  String get themeDescNekokag =>
      'Gato naranja de noche: oscuro con naranja atigrado';

  @override
  String get themeNameEloisa => 'Eloisa';

  @override
  String get themeDescEloisa => 'Colibrí: esmeralda y magenta';

  @override
  String get searchPlaceholder => 'Buscar...';

  @override
  String get browserRoot => 'Interno';

  @override
  String get browserPermissionText =>
      'Para mostrar tus carpetas y archivos, Gakoken necesita acceso a todos los archivos.';

  @override
  String get btnGrantPermission => 'Dar permiso';

  @override
  String get browserEmpty => 'Esta carpeta está vacía.';

  @override
  String get browserCannotRead => 'No se puede abrir esta carpeta.';

  @override
  String browserItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Vacía',
    );
    return '$_temp0';
  }

  @override
  String get browserViewTitle => 'Vista';

  @override
  String get viewList => 'Lista';

  @override
  String get viewDetails => 'Detalles';

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get columnName => 'Nombre';

  @override
  String get columnSize => 'Tamaño';

  @override
  String get columnModified => 'Modificado';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionAddFavorite => 'Agregar a favoritos';

  @override
  String get actionRemoveFavorite => 'Quitar de favoritos';

  @override
  String get fileNoApp => 'Ninguna app puede abrir este archivo.';

  @override
  String get fileMissing => 'Ya no existe';

  @override
  String get fileOpenError => 'No se pudo abrir el archivo.';

  @override
  String get kindFolder => 'Carpeta';

  @override
  String get kindText => 'Texto';

  @override
  String get kindCode => 'Código';

  @override
  String get kindImage => 'Imágenes';

  @override
  String get kindVideo => 'Videos';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindArchive => 'Comprimidos';

  @override
  String get kindEbook => 'Libros';

  @override
  String get kindOther => 'Otros';

  @override
  String get openWithTitle => 'Abrir con';

  @override
  String get usageTitle => 'Espacio usado';

  @override
  String get usageOpenInExplore => 'Abrir en Explorar';

  @override
  String usageCounts(String files, String dirs) {
    return '$files archivos · $dirs carpetas';
  }

  @override
  String get usageUpdating =>
      'Actualizando el índice; los números pueden cambiar.';

  @override
  String get usageByKind => 'Por tipo';

  @override
  String get usageLargest => 'Lo que más ocupa';

  @override
  String usageFiles(String count) {
    return '$count archivos';
  }

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Buscar en tu teléfono';

  @override
  String get searchEverywhere => 'Todo el teléfono';

  @override
  String searchOnlyIn(String folder) {
    return 'Solo en $folder';
  }

  @override
  String get searchIntro =>
      'Escribe parte del nombre. Aunque te equivoques en una letra, lo encuentra.';

  @override
  String get searchNoResults => 'Sin resultados.';

  @override
  String indexingProgress(String count) {
    return 'Indexando tu teléfono: $count archivos y carpetas';
  }

  @override
  String get indexNotReady =>
      'Todavía no hay índice. Ve a Ajustes, Índice, para crearlo.';

  @override
  String get indexTitle => 'Índice';

  @override
  String get indexDescription =>
      'Gakoken guarda la lista de todos tus archivos para buscar y medir el espacio al instante. Al abrir la app revisa solo las carpetas que cambiaron, y una vez al día la recorre completa.';

  @override
  String get indexNever => 'Sin índice';

  @override
  String get indexingShort => 'Indexando…';

  @override
  String indexEntries(String count) {
    return '$count archivos';
  }

  @override
  String indexLastRun(String date) {
    return 'Al día desde: $date';
  }

  @override
  String get indexRebuild => 'Volver a indexar';

  @override
  String get indexError => 'El último indexado falló. Intenta de nuevo.';

  @override
  String get browserNoMatches => 'Ningún archivo de este tipo en esta carpeta.';

  @override
  String get sortFilterTitle => 'Ordenar y filtrar';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortAscending => 'Ascendente';

  @override
  String get sortDescending => 'Descendente';

  @override
  String get sortModified => 'Fecha';

  @override
  String get sortKind => 'Tipo';

  @override
  String get filterKinds => 'Mostrar solo';

  @override
  String get filterClear => 'Quitar filtro';

  @override
  String get previewTitle => 'Vista previa';

  @override
  String get previewDescription =>
      'Elige qué tipos muestran una miniatura en lugar de su logo.';

  @override
  String get previewOff => 'Desactivada';

  @override
  String get previewPdfNote => 'Primera página del documento';

  @override
  String get navUsage => 'Espacio';

  @override
  String get navBack => 'Atrás';

  @override
  String get navForward => 'Adelante';

  @override
  String get tabNew => 'Pestaña nueva';

  @override
  String get tabClose => 'Cerrar pestaña';

  @override
  String get tabOpenNew => 'Abrir en pestaña nueva';

  @override
  String get volumesTitle => 'Memorias';

  @override
  String volumeFree(String free, String total) {
    return '$free libres de $total';
  }

  @override
  String get volumeNotIndexed => 'No se incluye en Buscar';

  @override
  String get usageCalculating => 'Calculando…';

  @override
  String get hiddenTitle => 'Archivos ocultos';

  @override
  String get hiddenDescription =>
      'Son los archivos y carpetas cuyo nombre empieza con punto, como .thumbnails. Casi siempre los usan otras apps.';

  @override
  String get hiddenShowInExplore => 'Mostrar en Explorar';

  @override
  String get hiddenIncludeInSearch => 'Incluir en Buscar';

  @override
  String get hiddenOff => 'Ocultos';

  @override
  String get hiddenInExplore => 'En Explorar';

  @override
  String get hiddenInSearch => 'En Buscar';

  @override
  String get hiddenEverywhere => 'En Explorar y Buscar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionCut => 'Cortar';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionMore => 'Más';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get renameTitle => 'Renombrar';

  @override
  String get renameAction => 'Renombrar';

  @override
  String renameError(String name) {
    return 'No se pudo renombrar a \"$name\". Puede que ya exista o que el nombre no sea válido.';
  }

  @override
  String conflictTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ya existen $count elementos con esos nombres',
      one: 'Ya existe un elemento con ese nombre',
    );
    return '$_temp0';
  }

  @override
  String get conflictKeepBoth => 'Mantener ambos';

  @override
  String get conflictReplace => 'Reemplazar';

  @override
  String get conflictSkip => 'Omitir';

  @override
  String clipboardCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos copiados',
      one: '1 elemento copiado',
    );
    return '$_temp0';
  }

  @override
  String clipboardCut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos cortados',
      one: '1 elemento cortado',
    );
    return '$_temp0';
  }

  @override
  String get pasteHere => 'Pegar aquí';

  @override
  String jobCopying(int done, int total) {
    return 'Copiando $done de $total';
  }

  @override
  String jobMoving(int done, int total) {
    return 'Moviendo $done de $total';
  }

  @override
  String jobDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listo: $count elementos',
      one: 'Listo: 1 elemento',
      zero: 'No se pegó nada',
    );
    return '$_temp0';
  }

  @override
  String get jobCancelled => 'Cancelado. No quedó nada a medias.';

  @override
  String jobFailed(int count, String names) {
    return 'No se pudieron pasar $count: $names';
  }

  @override
  String get trashTitle => 'Papelera';

  @override
  String trashCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Vacía',
    );
    return '$_temp0';
  }

  @override
  String trashMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos se movieron a la papelera',
      one: 'Se movió a la papelera',
    );
    return '$_temp0';
  }

  @override
  String trashFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron mover $count elementos a la papelera',
      one: 'No se pudo mover 1 elemento a la papelera',
    );
    return '$_temp0';
  }

  @override
  String trashEmpty(int days) {
    return 'La papelera está vacía. Lo que borres se guarda aquí $days días.';
  }

  @override
  String get trashEmptyAction => 'Vaciar';

  @override
  String trashDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Quedan $days días',
      one: 'Queda 1 día',
      zero: 'Se borra hoy',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restaurar';

  @override
  String get trashRestored => 'Restaurado en su lugar';

  @override
  String get trashRestoreFailed => 'No se pudo restaurar';

  @override
  String get trashDeleteForever => 'Eliminar para siempre';

  @override
  String trashDeleteForeverMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se borrarán $count elementos para siempre. No se puede deshacer.',
      one: 'Se borrará para siempre. No se puede deshacer.',
    );
    return '$_temp0';
  }

  @override
  String get viewGallery => 'Galería';

  @override
  String get previewVideoNote => 'Un cuadro del video';

  @override
  String indexTook(String duration) {
    return 'La última revisión tardó $duration';
  }

  @override
  String get trashOpen => 'Ver papelera';

  @override
  String get actionInfo => 'Información';

  @override
  String get infoContents => 'Contenido';

  @override
  String get infoLocation => 'Ubicación';

  @override
  String favoritesAddedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count se agregaron a favoritos',
      one: 'Se agregó a favoritos',
    );
    return '$_temp0';
  }

  @override
  String favoritesRemovedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count se quitaron de favoritos',
      one: 'Se quitó de favoritos',
    );
    return '$_temp0';
  }

  @override
  String kindFilesLimit(String count) {
    return 'Se muestran los $count más grandes';
  }

  @override
  String get volumeSystem => 'Raíz del sistema';

  @override
  String get volumeSystemNote =>
      'Carpetas de Android; casi todo es de solo lectura';

  @override
  String get themeNameBioka => 'Bioka';

  @override
  String get themeDescBioka =>
      'La Tierra: azul océano y verde de los continentes';

  @override
  String get themeNameAkoib => 'Akoib';

  @override
  String get themeDescAkoib => 'La Tierra de noche: azul océano y verde';

  @override
  String get trashDaysTitle => 'Días en la papelera';

  @override
  String get trashDaysUnit => 'días';

  @override
  String trashDaysHelp(int max) {
    return 'De 1 a $max. Lo que ya lleve más días se borra para siempre al guardar.';
  }

  @override
  String get trashDaysInvalid => 'Escribe un número';

  @override
  String get browserDisplayTitle => 'Vista, orden y filtro';

  @override
  String get browserLocationTitle => 'Ubicación';

  @override
  String trashDaysValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get actionCopyPath => 'Copiar ruta';

  @override
  String get pathCopied => 'Ruta copiada';

  @override
  String get newFolderTitle => 'Nueva carpeta';

  @override
  String get newFolderHint => 'Nombre de la carpeta';

  @override
  String get newFolderCreate => 'Crear';

  @override
  String get newFolderInvalid =>
      'Escribe un nombre válido, sin / ni solo puntos.';

  @override
  String get newFolderExists => 'Ya hay algo con ese nombre aquí.';

  @override
  String get newFolderDenied =>
      'Esta carpeta es de solo lectura; aquí no se pueden crear carpetas.';

  @override
  String get newFolderFailed => 'No se pudo crear la carpeta.';

  @override
  String newFolderCreated(String name) {
    return 'Carpeta \"$name\" creada';
  }
}
