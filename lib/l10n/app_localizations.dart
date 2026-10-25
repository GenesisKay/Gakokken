import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
  ];

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get navSettings;

  /// No description provided for @labelLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get labelLanguage;

  /// No description provided for @btnImport.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get btnImport;

  /// No description provided for @btnCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get btnSave;

  /// No description provided for @btnDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get btnDelete;

  /// No description provided for @btnEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get btnEdit;

  /// No description provided for @errorPrefix.
  ///
  /// In es, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @btnSelect.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get btnSelect;

  /// No description provided for @themesTitle.
  ///
  /// In es, this message translates to:
  /// **'Temas'**
  String get themesTitle;

  /// No description provided for @titleImportTheme.
  ///
  /// In es, this message translates to:
  /// **'Importar Tema'**
  String get titleImportTheme;

  /// No description provided for @instructionImportTheme.
  ///
  /// In es, this message translates to:
  /// **'Pega el código JSON del tema aquí:'**
  String get instructionImportTheme;

  /// No description provided for @msgThemeImportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Tema importado correctamente'**
  String get msgThemeImportSuccess;

  /// No description provided for @headerThemesDefault.
  ///
  /// In es, this message translates to:
  /// **'Predeterminados'**
  String get headerThemesDefault;

  /// No description provided for @headerThemesCustom.
  ///
  /// In es, this message translates to:
  /// **'Mis Temas'**
  String get headerThemesCustom;

  /// No description provided for @titleDeleteTheme.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Tema'**
  String get titleDeleteTheme;

  /// No description provided for @statusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get statusActive;

  /// No description provided for @themeImportOr.
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get themeImportOr;

  /// No description provided for @themeSelectJson.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Archivo JSON'**
  String get themeSelectJson;

  /// No description provided for @themeImportFileSuccess.
  ///
  /// In es, this message translates to:
  /// **'Tema importado desde archivo'**
  String get themeImportFileSuccess;

  /// No description provided for @themeImportError.
  ///
  /// In es, this message translates to:
  /// **'Error al leer archivo: {error}'**
  String themeImportError(String error);

  /// No description provided for @themeExportError.
  ///
  /// In es, this message translates to:
  /// **'Error exportando: {error}'**
  String themeExportError(String error);

  /// No description provided for @themeSavedFile.
  ///
  /// In es, this message translates to:
  /// **'Tema guardado en: {path}'**
  String themeSavedFile(String path);

  /// No description provided for @themeCopiedClipboard.
  ///
  /// In es, this message translates to:
  /// **'JSON copiado al portapapeles'**
  String get themeCopiedClipboard;

  /// No description provided for @themeEmptyCustom.
  ///
  /// In es, this message translates to:
  /// **'No has creado temas aún.\n¡Usa el botón + para empezar!'**
  String get themeEmptyCustom;

  /// No description provided for @themeConfirmDelete.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas eliminar \"{name}\"?'**
  String themeConfirmDelete(String name);

  /// No description provided for @themeCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Tema'**
  String get themeCreateTitle;

  /// No description provided for @themeEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Tema'**
  String get themeEditTitle;

  /// No description provided for @themeGeneratorTitle.
  ///
  /// In es, this message translates to:
  /// **'Generador'**
  String get themeGeneratorTitle;

  /// No description provided for @themeSeedColor.
  ///
  /// In es, this message translates to:
  /// **'Semilla'**
  String get themeSeedColor;

  /// No description provided for @themeBrightness.
  ///
  /// In es, this message translates to:
  /// **'Brillo'**
  String get themeBrightness;

  /// No description provided for @themeGenerateAction.
  ///
  /// In es, this message translates to:
  /// **'Generar Paleta'**
  String get themeGenerateAction;

  /// No description provided for @themeNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Tema'**
  String get themeNameLabel;

  /// No description provided for @themeDescLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get themeDescLabel;

  /// No description provided for @themeRequired.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get themeRequired;

  /// No description provided for @btnOK.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get btnOK;

  /// No description provided for @themeSectionCore.
  ///
  /// In es, this message translates to:
  /// **'Fondos y Textos (Core)'**
  String get themeSectionCore;

  /// No description provided for @themeSectionBrand.
  ///
  /// In es, this message translates to:
  /// **'Marca y Acción'**
  String get themeSectionBrand;

  /// No description provided for @themeSectionUI.
  ///
  /// In es, this message translates to:
  /// **'Estados y UI'**
  String get themeSectionUI;

  /// No description provided for @themeUseSecondary.
  ///
  /// In es, this message translates to:
  /// **'Usar Color Secundario'**
  String get themeUseSecondary;

  /// No description provided for @themeUseSecondaryDesc.
  ///
  /// In es, this message translates to:
  /// **'Estos colores no se usan en Gakoken, pero puedes definirlos aquí.'**
  String get themeUseSecondaryDesc;

  /// No description provided for @themeSelectColorTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Color'**
  String get themeSelectColorTitle;

  /// No description provided for @colorBgPrimary.
  ///
  /// In es, this message translates to:
  /// **'Fondo Principal'**
  String get colorBgPrimary;

  /// No description provided for @colorBgSecondary.
  ///
  /// In es, this message translates to:
  /// **'Fondo Secundario'**
  String get colorBgSecondary;

  /// No description provided for @colorBgElevated.
  ///
  /// In es, this message translates to:
  /// **'Fondo Elevado'**
  String get colorBgElevated;

  /// No description provided for @colorOverlay.
  ///
  /// In es, this message translates to:
  /// **'Overlay'**
  String get colorOverlay;

  /// No description provided for @colorTextPrimary.
  ///
  /// In es, this message translates to:
  /// **'Texto Principal'**
  String get colorTextPrimary;

  /// No description provided for @colorTextSecondary.
  ///
  /// In es, this message translates to:
  /// **'Texto Secundario'**
  String get colorTextSecondary;

  /// No description provided for @colorTextDisabled.
  ///
  /// In es, this message translates to:
  /// **'Deshabilitado'**
  String get colorTextDisabled;

  /// No description provided for @colorTextInverse.
  ///
  /// In es, this message translates to:
  /// **'Invertido'**
  String get colorTextInverse;

  /// No description provided for @colorPrimary.
  ///
  /// In es, this message translates to:
  /// **'Color Primario'**
  String get colorPrimary;

  /// No description provided for @colorPrimaryHover.
  ///
  /// In es, this message translates to:
  /// **'Hover'**
  String get colorPrimaryHover;

  /// No description provided for @colorPrimaryActive.
  ///
  /// In es, this message translates to:
  /// **'Active'**
  String get colorPrimaryActive;

  /// No description provided for @colorSecondary.
  ///
  /// In es, this message translates to:
  /// **'Color Secundario'**
  String get colorSecondary;

  /// No description provided for @colorSecondaryHover.
  ///
  /// In es, this message translates to:
  /// **'Hover (Sec)'**
  String get colorSecondaryHover;

  /// No description provided for @colorSecondaryActive.
  ///
  /// In es, this message translates to:
  /// **'Active (Sec)'**
  String get colorSecondaryActive;

  /// No description provided for @colorStateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Éxito (Verde)'**
  String get colorStateSuccess;

  /// No description provided for @colorStateWarning.
  ///
  /// In es, this message translates to:
  /// **'Alerta (Amarillo)'**
  String get colorStateWarning;

  /// No description provided for @colorStateError.
  ///
  /// In es, this message translates to:
  /// **'Error (Rojo)'**
  String get colorStateError;

  /// No description provided for @colorStateInfo.
  ///
  /// In es, this message translates to:
  /// **'Info (Azul)'**
  String get colorStateInfo;

  /// No description provided for @colorBorderSubtle.
  ///
  /// In es, this message translates to:
  /// **'Borde Sutil'**
  String get colorBorderSubtle;

  /// No description provided for @colorBorderFocus.
  ///
  /// In es, this message translates to:
  /// **'Borde Foco'**
  String get colorBorderFocus;

  /// No description provided for @colorSurfaceHover.
  ///
  /// In es, this message translates to:
  /// **'Sup. Hover'**
  String get colorSurfaceHover;

  /// No description provided for @colorSurfaceActive.
  ///
  /// In es, this message translates to:
  /// **'Sup. Active'**
  String get colorSurfaceActive;

  /// No description provided for @themeStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get themeStatusActive;

  /// No description provided for @themeActionApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar Tema'**
  String get themeActionApply;

  /// No description provided for @themeActionCopyJson.
  ///
  /// In es, this message translates to:
  /// **'Copiar JSON'**
  String get themeActionCopyJson;

  /// No description provided for @themeActionSaveFile.
  ///
  /// In es, this message translates to:
  /// **'Guardar Archivo'**
  String get themeActionSaveFile;

  /// No description provided for @btnConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get btnConfirm;

  /// No description provided for @titleSelectColor.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Color'**
  String get titleSelectColor;

  /// No description provided for @themeDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Gakoken'**
  String get themeDefaultName;

  /// No description provided for @themeDefaultDescription.
  ///
  /// In es, this message translates to:
  /// **'Gato naranja: crema y naranja atigrado'**
  String get themeDefaultDescription;

  /// No description provided for @themeDefaultName2.
  ///
  /// In es, this message translates to:
  /// **'Oturoja'**
  String get themeDefaultName2;

  /// No description provided for @themeDefaultDescription2.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro púrpura'**
  String get themeDefaultDescription2;

  /// No description provided for @themeDefaultName3.
  ///
  /// In es, this message translates to:
  /// **'Morobu'**
  String get themeDefaultName3;

  /// No description provided for @themeDefaultDescription3.
  ///
  /// In es, this message translates to:
  /// **'Tema claro gris, neutros cálidos'**
  String get themeDefaultDescription3;

  /// No description provided for @themeDefaultName4.
  ///
  /// In es, this message translates to:
  /// **'Uborom'**
  String get themeDefaultName4;

  /// No description provided for @themeDefaultDescription4.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro neutro'**
  String get themeDefaultDescription4;

  /// No description provided for @themeDefaultName5.
  ///
  /// In es, this message translates to:
  /// **'Zontle'**
  String get themeDefaultName5;

  /// No description provided for @themeDefaultDescription5.
  ///
  /// In es, this message translates to:
  /// **'Tema claro neutro, acento dorado'**
  String get themeDefaultDescription5;

  /// No description provided for @themeDefaultName6.
  ///
  /// In es, this message translates to:
  /// **'Eltnoz'**
  String get themeDefaultName6;

  /// No description provided for @themeDefaultDescription6.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro neutro, acento dorado'**
  String get themeDefaultDescription6;

  /// No description provided for @themeDefaultName7.
  ///
  /// In es, this message translates to:
  /// **'Ajoruto'**
  String get themeDefaultName7;

  /// No description provided for @themeDefaultDescription7.
  ///
  /// In es, this message translates to:
  /// **'Tema claro púrpura'**
  String get themeDefaultDescription7;

  /// No description provided for @themeDefaultName8.
  ///
  /// In es, this message translates to:
  /// **'Asiole'**
  String get themeDefaultName8;

  /// No description provided for @themeDefaultDescription8.
  ///
  /// In es, this message translates to:
  /// **'Tema colibrí oscuro: esmeralda y magenta'**
  String get themeDefaultDescription8;

  /// No description provided for @themeSectionBackgrounds.
  ///
  /// In es, this message translates to:
  /// **'Fondos'**
  String get themeSectionBackgrounds;

  /// No description provided for @themeSectionTexts.
  ///
  /// In es, this message translates to:
  /// **'Textos'**
  String get themeSectionTexts;

  /// No description provided for @themeSectionPrimary.
  ///
  /// In es, this message translates to:
  /// **'Primario'**
  String get themeSectionPrimary;

  /// No description provided for @themeSectionSecondary.
  ///
  /// In es, this message translates to:
  /// **'Secundario'**
  String get themeSectionSecondary;

  /// No description provided for @themeSectionStates.
  ///
  /// In es, this message translates to:
  /// **'Estados Semánticos'**
  String get themeSectionStates;

  /// No description provided for @themeSectionComponents.
  ///
  /// In es, this message translates to:
  /// **'Componentes'**
  String get themeSectionComponents;

  /// No description provided for @themeSaveTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar tema'**
  String get themeSaveTitle;

  /// No description provided for @themeSelectFolderTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar carpeta para guardar tema'**
  String get themeSelectFolderTitle;

  /// No description provided for @navExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get navExplore;

  /// No description provided for @navFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// No description provided for @favoritesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes favoritos. Mantén presionado un archivo o carpeta en Explorar para agregarlo.'**
  String get favoritesEmpty;

  /// No description provided for @themeNameNekokag.
  ///
  /// In es, this message translates to:
  /// **'Nekokag'**
  String get themeNameNekokag;

  /// No description provided for @themeDescNekokag.
  ///
  /// In es, this message translates to:
  /// **'Gato naranja de noche: oscuro con naranja atigrado'**
  String get themeDescNekokag;

  /// No description provided for @themeNameEloisa.
  ///
  /// In es, this message translates to:
  /// **'Eloisa'**
  String get themeNameEloisa;

  /// No description provided for @themeDescEloisa.
  ///
  /// In es, this message translates to:
  /// **'Colibrí: esmeralda y magenta'**
  String get themeDescEloisa;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get searchPlaceholder;

  /// No description provided for @browserRoot.
  ///
  /// In es, this message translates to:
  /// **'Interno'**
  String get browserRoot;

  /// No description provided for @browserPermissionText.
  ///
  /// In es, this message translates to:
  /// **'Para mostrar tus carpetas y archivos, Gakoken necesita acceso a todos los archivos.'**
  String get browserPermissionText;

  /// No description provided for @btnGrantPermission.
  ///
  /// In es, this message translates to:
  /// **'Dar permiso'**
  String get btnGrantPermission;

  /// No description provided for @browserEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta carpeta está vacía.'**
  String get browserEmpty;

  /// No description provided for @browserCannotRead.
  ///
  /// In es, this message translates to:
  /// **'No se puede abrir esta carpeta.'**
  String get browserCannotRead;

  /// No description provided for @browserItemCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Vacía} =1{1 elemento} other{{count} elementos}}'**
  String browserItemCount(int count);

  /// No description provided for @browserViewTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista'**
  String get browserViewTitle;

  /// No description provided for @viewList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get viewList;

  /// No description provided for @viewDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get viewDetails;

  /// No description provided for @viewGrid.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula'**
  String get viewGrid;

  /// No description provided for @columnName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get columnName;

  /// No description provided for @columnSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get columnSize;

  /// No description provided for @columnModified.
  ///
  /// In es, this message translates to:
  /// **'Modificado'**
  String get columnModified;

  /// No description provided for @actionOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get actionOpen;

  /// No description provided for @actionShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get actionShare;

  /// No description provided for @actionAddFavorite.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get actionAddFavorite;

  /// No description provided for @actionRemoveFavorite.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get actionRemoveFavorite;

  /// No description provided for @fileNoApp.
  ///
  /// In es, this message translates to:
  /// **'Ninguna app puede abrir este archivo.'**
  String get fileNoApp;

  /// No description provided for @fileMissing.
  ///
  /// In es, this message translates to:
  /// **'Ya no existe'**
  String get fileMissing;

  /// No description provided for @fileOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el archivo.'**
  String get fileOpenError;

  /// No description provided for @kindFolder.
  ///
  /// In es, this message translates to:
  /// **'Carpeta'**
  String get kindFolder;

  /// No description provided for @kindText.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get kindText;

  /// No description provided for @kindCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get kindCode;

  /// No description provided for @kindImage.
  ///
  /// In es, this message translates to:
  /// **'Imágenes'**
  String get kindImage;

  /// No description provided for @kindVideo.
  ///
  /// In es, this message translates to:
  /// **'Videos'**
  String get kindVideo;

  /// No description provided for @kindAudio.
  ///
  /// In es, this message translates to:
  /// **'Audio'**
  String get kindAudio;

  /// No description provided for @kindArchive.
  ///
  /// In es, this message translates to:
  /// **'Comprimidos'**
  String get kindArchive;

  /// No description provided for @kindEbook.
  ///
  /// In es, this message translates to:
  /// **'Libros'**
  String get kindEbook;

  /// No description provided for @kindOther.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get kindOther;

  /// No description provided for @openWithTitle.
  ///
  /// In es, this message translates to:
  /// **'Abrir con'**
  String get openWithTitle;

  /// No description provided for @usageTitle.
  ///
  /// In es, this message translates to:
  /// **'Espacio usado'**
  String get usageTitle;

  /// No description provided for @usageOpenInExplore.
  ///
  /// In es, this message translates to:
  /// **'Abrir en Explorar'**
  String get usageOpenInExplore;

  /// No description provided for @usageCounts.
  ///
  /// In es, this message translates to:
  /// **'{files} archivos · {dirs} carpetas'**
  String usageCounts(String files, String dirs);

  /// No description provided for @usageUpdating.
  ///
  /// In es, this message translates to:
  /// **'Actualizando el índice; los números pueden cambiar.'**
  String get usageUpdating;

  /// No description provided for @usageByKind.
  ///
  /// In es, this message translates to:
  /// **'Por tipo'**
  String get usageByKind;

  /// No description provided for @usageLargest.
  ///
  /// In es, this message translates to:
  /// **'Lo que más ocupa'**
  String get usageLargest;

  /// No description provided for @usageFiles.
  ///
  /// In es, this message translates to:
  /// **'{count} archivos'**
  String usageFiles(String count);

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar en tu teléfono'**
  String get searchHint;

  /// No description provided for @searchEverywhere.
  ///
  /// In es, this message translates to:
  /// **'Todo el teléfono'**
  String get searchEverywhere;

  /// No description provided for @searchOnlyIn.
  ///
  /// In es, this message translates to:
  /// **'Solo en {folder}'**
  String searchOnlyIn(String folder);

  /// No description provided for @searchIntro.
  ///
  /// In es, this message translates to:
  /// **'Escribe parte del nombre. Aunque te equivoques en una letra, lo encuentra.'**
  String get searchIntro;

  /// No description provided for @searchNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados.'**
  String get searchNoResults;

  /// No description provided for @indexingProgress.
  ///
  /// In es, this message translates to:
  /// **'Indexando tu teléfono: {count} archivos y carpetas'**
  String indexingProgress(String count);

  /// No description provided for @indexNotReady.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay índice. Ve a Ajustes, Índice, para crearlo.'**
  String get indexNotReady;

  /// No description provided for @indexTitle.
  ///
  /// In es, this message translates to:
  /// **'Índice'**
  String get indexTitle;

  /// No description provided for @indexDescription.
  ///
  /// In es, this message translates to:
  /// **'Gakoken guarda la lista de todos tus archivos para buscar y medir el espacio al instante. Al abrir la app revisa solo las carpetas que cambiaron, y una vez al día la recorre completa.'**
  String get indexDescription;

  /// No description provided for @indexNever.
  ///
  /// In es, this message translates to:
  /// **'Sin índice'**
  String get indexNever;

  /// No description provided for @indexingShort.
  ///
  /// In es, this message translates to:
  /// **'Indexando…'**
  String get indexingShort;

  /// No description provided for @indexEntries.
  ///
  /// In es, this message translates to:
  /// **'{count} archivos'**
  String indexEntries(String count);

  /// No description provided for @indexLastRun.
  ///
  /// In es, this message translates to:
  /// **'Al día desde: {date}'**
  String indexLastRun(String date);

  /// No description provided for @indexRebuild.
  ///
  /// In es, this message translates to:
  /// **'Volver a indexar'**
  String get indexRebuild;

  /// No description provided for @indexError.
  ///
  /// In es, this message translates to:
  /// **'El último indexado falló. Intenta de nuevo.'**
  String get indexError;

  /// No description provided for @browserNoMatches.
  ///
  /// In es, this message translates to:
  /// **'Ningún archivo de este tipo en esta carpeta.'**
  String get browserNoMatches;

  /// No description provided for @sortFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Ordenar y filtrar'**
  String get sortFilterTitle;

  /// No description provided for @sortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// No description provided for @sortAscending.
  ///
  /// In es, this message translates to:
  /// **'Ascendente'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In es, this message translates to:
  /// **'Descendente'**
  String get sortDescending;

  /// No description provided for @sortModified.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get sortModified;

  /// No description provided for @sortKind.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get sortKind;

  /// No description provided for @filterKinds.
  ///
  /// In es, this message translates to:
  /// **'Mostrar solo'**
  String get filterKinds;

  /// No description provided for @filterClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtro'**
  String get filterClear;

  /// No description provided for @previewTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get previewTitle;

  /// No description provided for @previewDescription.
  ///
  /// In es, this message translates to:
  /// **'Elige qué tipos muestran una miniatura en lugar de su logo.'**
  String get previewDescription;

  /// No description provided for @previewOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivada'**
  String get previewOff;

  /// No description provided for @previewPdfNote.
  ///
  /// In es, this message translates to:
  /// **'Primera página del documento'**
  String get previewPdfNote;

  /// No description provided for @navUsage.
  ///
  /// In es, this message translates to:
  /// **'Espacio'**
  String get navUsage;

  /// No description provided for @navBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get navBack;

  /// No description provided for @navForward.
  ///
  /// In es, this message translates to:
  /// **'Adelante'**
  String get navForward;

  /// No description provided for @tabNew.
  ///
  /// In es, this message translates to:
  /// **'Pestaña nueva'**
  String get tabNew;

  /// No description provided for @tabClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar pestaña'**
  String get tabClose;

  /// No description provided for @tabOpenNew.
  ///
  /// In es, this message translates to:
  /// **'Abrir en pestaña nueva'**
  String get tabOpenNew;

  /// No description provided for @volumesTitle.
  ///
  /// In es, this message translates to:
  /// **'Memorias'**
  String get volumesTitle;

  /// No description provided for @volumeFree.
  ///
  /// In es, this message translates to:
  /// **'{free} libres de {total}'**
  String volumeFree(String free, String total);

  /// No description provided for @volumeNotIndexed.
  ///
  /// In es, this message translates to:
  /// **'No se incluye en Buscar'**
  String get volumeNotIndexed;

  /// No description provided for @usageCalculating.
  ///
  /// In es, this message translates to:
  /// **'Calculando…'**
  String get usageCalculating;

  /// No description provided for @hiddenTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivos ocultos'**
  String get hiddenTitle;

  /// No description provided for @hiddenDescription.
  ///
  /// In es, this message translates to:
  /// **'Son los archivos y carpetas cuyo nombre empieza con punto, como .thumbnails. Casi siempre los usan otras apps.'**
  String get hiddenDescription;

  /// No description provided for @hiddenShowInExplore.
  ///
  /// In es, this message translates to:
  /// **'Mostrar en Explorar'**
  String get hiddenShowInExplore;

  /// No description provided for @hiddenIncludeInSearch.
  ///
  /// In es, this message translates to:
  /// **'Incluir en Buscar'**
  String get hiddenIncludeInSearch;

  /// No description provided for @hiddenOff.
  ///
  /// In es, this message translates to:
  /// **'Ocultos'**
  String get hiddenOff;

  /// No description provided for @hiddenInExplore.
  ///
  /// In es, this message translates to:
  /// **'En Explorar'**
  String get hiddenInExplore;

  /// No description provided for @hiddenInSearch.
  ///
  /// In es, this message translates to:
  /// **'En Buscar'**
  String get hiddenInSearch;

  /// No description provided for @hiddenEverywhere.
  ///
  /// In es, this message translates to:
  /// **'En Explorar y Buscar'**
  String get hiddenEverywhere;

  /// No description provided for @actionCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get actionCopy;

  /// No description provided for @actionCut.
  ///
  /// In es, this message translates to:
  /// **'Cortar'**
  String get actionCut;

  /// No description provided for @actionRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get actionRename;

  /// No description provided for @actionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// No description provided for @actionMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get actionMore;

  /// No description provided for @actionUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get actionUndo;

  /// No description provided for @selectAll.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar todo'**
  String get selectAll;

  /// No description provided for @selectionCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 seleccionado} other{{count} seleccionados}}'**
  String selectionCount(int count);

  /// No description provided for @renameTitle.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get renameTitle;

  /// No description provided for @renameAction.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get renameAction;

  /// No description provided for @renameError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo renombrar a \"{name}\". Puede que ya exista o que el nombre no sea válido.'**
  String renameError(String name);

  /// No description provided for @conflictTitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Ya existe un elemento con ese nombre} other{Ya existen {count} elementos con esos nombres}}'**
  String conflictTitle(int count);

  /// No description provided for @conflictKeepBoth.
  ///
  /// In es, this message translates to:
  /// **'Mantener ambos'**
  String get conflictKeepBoth;

  /// No description provided for @conflictReplace.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get conflictReplace;

  /// No description provided for @conflictSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get conflictSkip;

  /// No description provided for @clipboardCopied.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 elemento copiado} other{{count} elementos copiados}}'**
  String clipboardCopied(int count);

  /// No description provided for @clipboardCut.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 elemento cortado} other{{count} elementos cortados}}'**
  String clipboardCut(int count);

  /// No description provided for @pasteHere.
  ///
  /// In es, this message translates to:
  /// **'Pegar aquí'**
  String get pasteHere;

  /// No description provided for @jobCopying.
  ///
  /// In es, this message translates to:
  /// **'Copiando {done} de {total}'**
  String jobCopying(int done, int total);

  /// No description provided for @jobMoving.
  ///
  /// In es, this message translates to:
  /// **'Moviendo {done} de {total}'**
  String jobMoving(int done, int total);

  /// No description provided for @jobDone.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No se pegó nada} =1{Listo: 1 elemento} other{Listo: {count} elementos}}'**
  String jobDone(int count);

  /// No description provided for @jobCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado. No quedó nada a medias.'**
  String get jobCancelled;

  /// No description provided for @jobFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron pasar {count}: {names}'**
  String jobFailed(int count, String names);

  /// No description provided for @trashTitle.
  ///
  /// In es, this message translates to:
  /// **'Papelera'**
  String get trashTitle;

  /// No description provided for @trashCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Vacía} =1{1 elemento} other{{count} elementos}}'**
  String trashCount(int count);

  /// No description provided for @trashMoved.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se movió a la papelera} other{{count} elementos se movieron a la papelera}}'**
  String trashMoved(int count);

  /// No description provided for @trashFailed.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{No se pudo mover 1 elemento a la papelera} other{No se pudieron mover {count} elementos a la papelera}}'**
  String trashFailed(int count);

  /// No description provided for @trashEmpty.
  ///
  /// In es, this message translates to:
  /// **'La papelera está vacía. Lo que borres se guarda aquí {days} días.'**
  String trashEmpty(int days);

  /// No description provided for @trashEmptyAction.
  ///
  /// In es, this message translates to:
  /// **'Vaciar'**
  String get trashEmptyAction;

  /// No description provided for @trashDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{Se borra hoy} =1{Queda 1 día} other{Quedan {days} días}}'**
  String trashDaysLeft(int days);

  /// No description provided for @trashRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get trashRestore;

  /// No description provided for @trashRestored.
  ///
  /// In es, this message translates to:
  /// **'Restaurado en su lugar'**
  String get trashRestored;

  /// No description provided for @trashRestoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo restaurar'**
  String get trashRestoreFailed;

  /// No description provided for @trashDeleteForever.
  ///
  /// In es, this message translates to:
  /// **'Eliminar para siempre'**
  String get trashDeleteForever;

  /// No description provided for @trashDeleteForeverMessage.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se borrará para siempre. No se puede deshacer.} other{Se borrarán {count} elementos para siempre. No se puede deshacer.}}'**
  String trashDeleteForeverMessage(int count);

  /// No description provided for @viewGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get viewGallery;

  /// No description provided for @previewVideoNote.
  ///
  /// In es, this message translates to:
  /// **'Un cuadro del video'**
  String get previewVideoNote;

  /// No description provided for @indexTook.
  ///
  /// In es, this message translates to:
  /// **'La última revisión tardó {duration}'**
  String indexTook(String duration);

  /// No description provided for @trashOpen.
  ///
  /// In es, this message translates to:
  /// **'Ver papelera'**
  String get trashOpen;

  /// No description provided for @actionInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get actionInfo;

  /// No description provided for @infoContents.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get infoContents;

  /// No description provided for @infoLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get infoLocation;

  /// No description provided for @favoritesAddedMany.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se agregó a favoritos} other{{count} se agregaron a favoritos}}'**
  String favoritesAddedMany(int count);

  /// No description provided for @favoritesRemovedMany.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se quitó de favoritos} other{{count} se quitaron de favoritos}}'**
  String favoritesRemovedMany(int count);

  /// No description provided for @kindFilesLimit.
  ///
  /// In es, this message translates to:
  /// **'Se muestran los {count} más grandes'**
  String kindFilesLimit(String count);

  /// No description provided for @volumeSystem.
  ///
  /// In es, this message translates to:
  /// **'Raíz del sistema'**
  String get volumeSystem;

  /// No description provided for @volumeSystemNote.
  ///
  /// In es, this message translates to:
  /// **'Carpetas de Android; casi todo es de solo lectura'**
  String get volumeSystemNote;

  /// No description provided for @themeNameBioka.
  ///
  /// In es, this message translates to:
  /// **'Bioka'**
  String get themeNameBioka;

  /// No description provided for @themeDescBioka.
  ///
  /// In es, this message translates to:
  /// **'La Tierra: azul océano y verde de los continentes'**
  String get themeDescBioka;

  /// No description provided for @themeNameAkoib.
  ///
  /// In es, this message translates to:
  /// **'Akoib'**
  String get themeNameAkoib;

  /// No description provided for @themeDescAkoib.
  ///
  /// In es, this message translates to:
  /// **'La Tierra de noche: azul océano y verde'**
  String get themeDescAkoib;

  /// No description provided for @trashDaysTitle.
  ///
  /// In es, this message translates to:
  /// **'Días en la papelera'**
  String get trashDaysTitle;

  /// No description provided for @trashDaysUnit.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get trashDaysUnit;

  /// No description provided for @trashDaysHelp.
  ///
  /// In es, this message translates to:
  /// **'De 1 a {max}. Lo que ya lleve más días se borra para siempre al guardar.'**
  String trashDaysHelp(int max);

  /// No description provided for @trashDaysInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número'**
  String get trashDaysInvalid;

  /// No description provided for @browserDisplayTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista, orden y filtro'**
  String get browserDisplayTitle;

  /// No description provided for @browserLocationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get browserLocationTitle;

  /// No description provided for @trashDaysValue.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{1 día} other{{days} días}}'**
  String trashDaysValue(int days);

  /// No description provided for @actionCopyPath.
  ///
  /// In es, this message translates to:
  /// **'Copiar ruta'**
  String get actionCopyPath;

  /// No description provided for @pathCopied.
  ///
  /// In es, this message translates to:
  /// **'Ruta copiada'**
  String get pathCopied;

  /// No description provided for @newFolderTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva carpeta'**
  String get newFolderTitle;

  /// No description provided for @newFolderHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la carpeta'**
  String get newFolderHint;

  /// No description provided for @newFolderCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get newFolderCreate;

  /// No description provided for @newFolderInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre válido, sin / ni solo puntos.'**
  String get newFolderInvalid;

  /// No description provided for @newFolderExists.
  ///
  /// In es, this message translates to:
  /// **'Ya hay algo con ese nombre aquí.'**
  String get newFolderExists;

  /// No description provided for @newFolderDenied.
  ///
  /// In es, this message translates to:
  /// **'Esta carpeta es de solo lectura; aquí no se pueden crear carpetas.'**
  String get newFolderDenied;

  /// No description provided for @newFolderFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la carpeta.'**
  String get newFolderFailed;

  /// No description provided for @newFolderCreated.
  ///
  /// In es, this message translates to:
  /// **'Carpeta \"{name}\" creada'**
  String newFolderCreated(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
