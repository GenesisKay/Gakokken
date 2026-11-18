// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navSettings => 'Settings';

  @override
  String get labelLanguage => 'Language';

  @override
  String get btnImport => 'Import';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnEdit => 'Edit';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get btnSelect => 'Select';

  @override
  String get themesTitle => 'Themes';

  @override
  String get titleImportTheme => 'Import theme';

  @override
  String get instructionImportTheme => 'Paste the theme JSON code here:';

  @override
  String get msgThemeImportSuccess => 'Theme imported successfully';

  @override
  String get headerThemesDefault => 'Defaults';

  @override
  String get headerThemesCustom => 'My themes';

  @override
  String get titleDeleteTheme => 'Delete theme';

  @override
  String get statusActive => 'Active';

  @override
  String get themeImportOr => 'Or';

  @override
  String get themeSelectJson => 'Select JSON file';

  @override
  String get themeImportFileSuccess => 'Theme imported from file';

  @override
  String themeImportError(String error) {
    return 'Error reading file: $error';
  }

  @override
  String themeExportError(String error) {
    return 'Error exporting: $error';
  }

  @override
  String themeSavedFile(String path) {
    return 'Theme saved at: $path';
  }

  @override
  String get themeCopiedClipboard => 'JSON copied to clipboard';

  @override
  String get themeEmptyCustom =>
      'You have not created themes yet.\nUse the + button to start!';

  @override
  String themeConfirmDelete(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get themeCreateTitle => 'Create theme';

  @override
  String get themeEditTitle => 'Edit theme';

  @override
  String get themeGeneratorTitle => 'Generator';

  @override
  String get themeSeedColor => 'Seed';

  @override
  String get themeBrightness => 'Brightness';

  @override
  String get themeGenerateAction => 'Generate palette';

  @override
  String get themeNameLabel => 'Theme name';

  @override
  String get themeDescLabel => 'Description';

  @override
  String get themeRequired => 'Required';

  @override
  String get btnOK => 'OK';

  @override
  String get themeSectionCore => 'Core (backgrounds & text)';

  @override
  String get themeSectionBrand => 'Brand & action';

  @override
  String get themeSectionUI => 'States & UI';

  @override
  String get themeUseSecondary => 'Use secondary color';

  @override
  String get themeUseSecondaryDesc =>
      'These colors are not used in Gakoken, but you can define them here.';

  @override
  String get themeSelectColorTitle => 'Select color';

  @override
  String get colorBgPrimary => 'Primary background';

  @override
  String get colorBgSecondary => 'Secondary background';

  @override
  String get colorBgElevated => 'Elevated background';

  @override
  String get colorOverlay => 'Overlay';

  @override
  String get colorTextPrimary => 'Primary text';

  @override
  String get colorTextSecondary => 'Secondary text';

  @override
  String get colorTextDisabled => 'Disabled';

  @override
  String get colorTextInverse => 'Inverse';

  @override
  String get colorPrimary => 'Primary color';

  @override
  String get colorPrimaryHover => 'Hover';

  @override
  String get colorPrimaryActive => 'Active';

  @override
  String get colorSecondary => 'Secondary color';

  @override
  String get colorSecondaryHover => 'Hover (Sec)';

  @override
  String get colorSecondaryActive => 'Active (Sec)';

  @override
  String get colorStateSuccess => 'Success (green)';

  @override
  String get colorStateWarning => 'Warning (yellow)';

  @override
  String get colorStateError => 'Error (red)';

  @override
  String get colorStateInfo => 'Info (blue)';

  @override
  String get colorBorderSubtle => 'Subtle border';

  @override
  String get colorBorderFocus => 'Focus border';

  @override
  String get colorSurfaceHover => 'Surface hover';

  @override
  String get colorSurfaceActive => 'Surface active';

  @override
  String get themeStatusActive => 'Active';

  @override
  String get themeActionApply => 'Apply theme';

  @override
  String get themeActionCopyJson => 'Copy JSON';

  @override
  String get themeActionSaveFile => 'Save file';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get titleSelectColor => 'Select color';

  @override
  String get themeDefaultName => 'Gakoken';

  @override
  String get themeDefaultDescription => 'Orange cat: white and tabby orange';

  @override
  String get themeDefaultName2 => 'Oturoja';

  @override
  String get themeDefaultDescription2 => 'Dark purple theme';

  @override
  String get themeDefaultName3 => 'Morobu';

  @override
  String get themeDefaultDescription3 => 'Light gray theme, warm neutrals';

  @override
  String get themeDefaultName4 => 'Uborom';

  @override
  String get themeDefaultDescription4 => 'Dark neutral theme';

  @override
  String get themeDefaultName5 => 'Zontle';

  @override
  String get themeDefaultDescription5 => 'Light neutral theme, golden accent';

  @override
  String get themeDefaultName6 => 'Eltnoz';

  @override
  String get themeDefaultDescription6 => 'Dark neutral theme, golden accent';

  @override
  String get themeDefaultName7 => 'Ajoruto';

  @override
  String get themeDefaultDescription7 => 'Light purple theme';

  @override
  String get themeDefaultName8 => 'Asiole';

  @override
  String get themeDefaultDescription8 =>
      'Dark hummingbird theme: emerald and magenta';

  @override
  String get themeSectionBackgrounds => 'Backgrounds';

  @override
  String get themeSectionTexts => 'Texts';

  @override
  String get themeSectionPrimary => 'Primary';

  @override
  String get themeSectionSecondary => 'Secondary';

  @override
  String get themeSectionStates => 'Semantic states';

  @override
  String get themeSectionComponents => 'Components';

  @override
  String get themeSaveTitle => 'Save theme';

  @override
  String get themeSelectFolderTitle => 'Select folder to save theme';

  @override
  String get navExplore => 'Explore';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get favoritesEmpty =>
      'No favorites yet. Long-press a file or folder in Explore to add it.';

  @override
  String get themeNameNekokag => 'Nekokag';

  @override
  String get themeDescNekokag => 'Orange cat at night: dark with tabby orange';

  @override
  String get themeNameEloisa => 'Eloisa';

  @override
  String get themeDescEloisa => 'Hummingbird: emerald and magenta';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get browserRoot => 'Internal storage';

  @override
  String get browserPermissionText =>
      'To show your folders and files, Gakoken needs access to all files.';

  @override
  String get btnGrantPermission => 'Grant permission';

  @override
  String get browserEmpty => 'This folder is empty.';

  @override
  String get browserCannotRead => 'This folder can\'t be opened.';

  @override
  String browserItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get browserViewTitle => 'View';

  @override
  String get viewList => 'List';

  @override
  String get viewDetails => 'Details';

  @override
  String get viewGrid => 'Grid';

  @override
  String get columnName => 'Name';

  @override
  String get columnSize => 'Size';

  @override
  String get columnModified => 'Modified';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionShare => 'Share';

  @override
  String get actionAddFavorite => 'Add to favorites';

  @override
  String get actionRemoveFavorite => 'Remove from favorites';

  @override
  String get fileNoApp => 'No app can open this file.';

  @override
  String get fileMissing => 'No longer exists';

  @override
  String get fileOpenError => 'Couldn\'t open the file.';

  @override
  String get kindFolder => 'Folder';

  @override
  String get kindText => 'Text';

  @override
  String get kindCode => 'Code';

  @override
  String get kindImage => 'Images';

  @override
  String get kindVideo => 'Videos';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindArchive => 'Archives';

  @override
  String get kindEbook => 'Books';

  @override
  String get kindOther => 'Other';

  @override
  String get openWithTitle => 'Open with';

  @override
  String get usageTitle => 'Storage used';

  @override
  String get usageOpenInExplore => 'Open in Explore';

  @override
  String usageCounts(String files, String dirs) {
    return '$files files · $dirs folders';
  }

  @override
  String get usageByKind => 'By type';

  @override
  String get usageLargest => 'Largest items';

  @override
  String get usageSortFiles => 'Files';

  @override
  String usageFiles(String count) {
    return '$count files';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search your phone';

  @override
  String get searchEverywhere => 'Whole phone';

  @override
  String searchOnlyIn(String folder) {
    return 'Only in $folder';
  }

  @override
  String get searchIntro =>
      'Type part of the name. It finds it even with a typo.';

  @override
  String get searchNoResults => 'No results.';

  @override
  String indexingProgress(String count) {
    return 'Indexing your phone: $count files and folders';
  }

  @override
  String get indexNotReady =>
      'There is no index yet. Go to Settings, Index, to build it.';

  @override
  String get indexTitle => 'Index';

  @override
  String get indexDescription =>
      'Gakoken keeps a list of all your files to search and measure space instantly. When you open the app it only checks the folders that changed, and once a day it goes through everything.';

  @override
  String get indexNever => 'No index';

  @override
  String get indexingShort => 'Indexing…';

  @override
  String indexEntries(String count) {
    return '$count files';
  }

  @override
  String indexLastRun(String date) {
    return 'Up to date as of: $date';
  }

  @override
  String get indexRebuild => 'Reindex';

  @override
  String get indexError => 'The last indexing failed. Try again.';

  @override
  String get browserNoMatches => 'No files of this type in this folder.';

  @override
  String get sortFilterTitle => 'Sort and filter';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortModified => 'Date';

  @override
  String get sortKind => 'Type';

  @override
  String get filterKinds => 'Show only';

  @override
  String get filterClear => 'Clear filter';

  @override
  String get previewTitle => 'Preview';

  @override
  String get previewDescription =>
      'Choose which types show a thumbnail instead of their logo.';

  @override
  String get previewOff => 'Off';

  @override
  String get previewPdfNote => 'First page of the document';

  @override
  String get navUsage => 'Storage';

  @override
  String get navBack => 'Back';

  @override
  String get navForward => 'Forward';

  @override
  String get tabNew => 'New tab';

  @override
  String get tabClose => 'Close tab';

  @override
  String get tabOpenNew => 'Open in new tab';

  @override
  String get volumesTitle => 'Storage devices';

  @override
  String volumeFree(String free, String total) {
    return '$free free of $total';
  }

  @override
  String get volumeNotIndexed => 'Not included in Search';

  @override
  String get usageCalculating => 'Calculating…';

  @override
  String get hiddenTitle => 'Hidden files';

  @override
  String get hapticsTitle => 'Vibrate when selecting';

  @override
  String get hiddenDescription =>
      'Files and folders whose name starts with a dot, like .thumbnails. Other apps usually use them.';

  @override
  String get hiddenShowInExplore => 'Show in Explore';

  @override
  String get hiddenIncludeInSearch => 'Include in Search';

  @override
  String get hiddenOff => 'Hidden';

  @override
  String get hiddenInExplore => 'In Explore';

  @override
  String get hiddenInSearch => 'In Search';

  @override
  String get hiddenEverywhere => 'In Explore and Search';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCut => 'Cut';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionMore => 'More';

  @override
  String get actionUndo => 'Undo';

  @override
  String get selectAll => 'Select all';

  @override
  String selectionCount(int count) {
    return '$count selected';
  }

  @override
  String get renameTitle => 'Rename';

  @override
  String get renameAction => 'Rename';

  @override
  String renameError(String name) {
    return 'Couldn\'t rename to \"$name\". It may already exist or the name isn\'t valid.';
  }

  @override
  String conflictTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items with those names already exist',
      one: 'An item with that name already exists',
    );
    return '$_temp0';
  }

  @override
  String get conflictKeepBoth => 'Keep both';

  @override
  String get conflictReplace => 'Replace';

  @override
  String get conflictSkip => 'Skip';

  @override
  String clipboardCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items copied',
      one: '1 item copied',
    );
    return '$_temp0';
  }

  @override
  String clipboardCut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items cut',
      one: '1 item cut',
    );
    return '$_temp0';
  }

  @override
  String get pasteHere => 'Paste here';

  @override
  String jobCopying(int done, int total) {
    return 'Copying $done of $total';
  }

  @override
  String jobMoving(int done, int total) {
    return 'Moving $done of $total';
  }

  @override
  String jobDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Done: $count items',
      one: 'Done: 1 item',
      zero: 'Nothing was pasted',
    );
    return '$_temp0';
  }

  @override
  String get jobCancelled => 'Cancelled. Nothing was left half-done.';

  @override
  String jobFailed(int count, String names) {
    return 'Couldn\'t transfer $count: $names';
  }

  @override
  String get trashTitle => 'Trash';

  @override
  String trashCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String trashMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items moved to trash',
      one: 'Moved to trash',
    );
    return '$_temp0';
  }

  @override
  String trashFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Couldn\'t move $count items to trash',
      one: 'Couldn\'t move 1 item to trash',
    );
    return '$_temp0';
  }

  @override
  String trashEmpty(int days) {
    return 'The trash is empty. What you delete stays here for $days days.';
  }

  @override
  String get trashEmptyAction => 'Empty';

  @override
  String trashDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Deleted today',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashRestored => 'Restored to its place';

  @override
  String get trashRestoreFailed => 'Couldn\'t restore';

  @override
  String get trashDeleteForever => 'Delete forever';

  @override
  String trashDeleteForeverMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items will be deleted forever. This can\'t be undone.',
      one: 'It will be deleted forever. This can\'t be undone.',
    );
    return '$_temp0';
  }

  @override
  String get viewGallery => 'Gallery';

  @override
  String get previewVideoNote => 'A frame from the video';

  @override
  String indexTook(String duration) {
    return 'The last check took $duration';
  }

  @override
  String get trashOpen => 'View trash';

  @override
  String get actionInfo => 'Details';

  @override
  String get infoContents => 'Contents';

  @override
  String get infoLocation => 'Location';

  @override
  String favoritesAddedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count added to favorites',
      one: 'Added to favorites',
    );
    return '$_temp0';
  }

  @override
  String favoritesRemovedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count removed from favorites',
      one: 'Removed from favorites',
    );
    return '$_temp0';
  }

  @override
  String kindFilesLimit(String count) {
    return 'Showing the $count largest';
  }

  @override
  String get volumeSystem => 'System root';

  @override
  String get volumeSystemNote => 'Android folders; mostly read-only';

  @override
  String get themeNameBioka => 'Bioka';

  @override
  String get themeDescBioka => 'Earth: ocean blue and continent green';

  @override
  String get themeNameAkoib => 'Akoib';

  @override
  String get themeDescAkoib => 'Earth at night: ocean blue and green';

  @override
  String get trashDaysTitle => 'Days in trash';

  @override
  String get trashDaysUnit => 'days';

  @override
  String trashDaysHelp(int max) {
    return 'From 1 to $max. Anything older is deleted forever when you save.';
  }

  @override
  String get trashDaysInvalid => 'Enter a number';

  @override
  String get browserDisplayTitle => 'View, sort and filter';

  @override
  String get browserLocationTitle => 'Location';

  @override
  String trashDaysValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get actionCopyPath => 'Copy path';

  @override
  String get pathCopied => 'Path copied';

  @override
  String get newFolderTitle => 'New folder';

  @override
  String get newFolderHint => 'Folder name';

  @override
  String get newFolderCreate => 'Create';

  @override
  String get newFolderInvalid => 'Enter a valid name, without / or only dots.';

  @override
  String get newFolderExists => 'Something with that name is already here.';

  @override
  String get newFolderDenied =>
      'This folder is read-only; folders can\'t be created here.';

  @override
  String get newFolderFailed => 'Couldn\'t create the folder.';

  @override
  String newFolderCreated(String name) {
    return 'Folder \"$name\" created';
  }

  @override
  String get groupByDate => 'Group by date';

  @override
  String get dateGroupToday => 'Today';

  @override
  String get dateGroupYesterday => 'Yesterday';

  @override
  String get dateGroupWeek => 'Last 7 days';

  @override
  String get sortAdded => 'Added';

  @override
  String get sortDeleted => 'Deleted';

  @override
  String trashRestoredMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items restored',
      one: '1 item restored',
    );
    return '$_temp0';
  }

  @override
  String get usageSystemOther => 'System and other';

  @override
  String get usageFreeSegment => 'Free';

  @override
  String usageFilesSize(String size, String files, String dirs) {
    return '$size in $files files · $dirs folders';
  }

  @override
  String usageFreeOnly(String free) {
    return '$free free';
  }

  @override
  String get usageApps => 'Apps';

  @override
  String get usageSystem => 'System';

  @override
  String get usageAppsAccess => 'See how much apps take';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourDone => 'Done';

  @override
  String tourStepCount(int current, int total) {
    return '$current of $total';
  }

  @override
  String get tutorialTitle => 'Tutorial';

  @override
  String get tutorialDone => 'Done';

  @override
  String get tourExpNavTitle => 'Your sections';

  @override
  String get tourExpNavBody =>
      'Explore, Favorites, Storage and Settings. Tap one to switch.';

  @override
  String get tourExpSearchTitle => 'Search the whole phone';

  @override
  String get tourExpSearchBody =>
      'Find files and folders by name instantly, without waiting for storage to be scanned.';

  @override
  String get tourExpDisplayTitle => 'View and order';

  @override
  String get tourExpDisplayBody =>
      'List or grid, sort, group by date and filter by file type.';

  @override
  String get tourExpSelectTitle => 'Select and act';

  @override
  String get tourExpSelectBody =>
      'Long-press a file or folder to select it: copy, move, rename, share or add it to Favorites.';

  @override
  String get tourFavTitle => 'Your favorites';

  @override
  String get tourFavBody =>
      'What you mark to open quickly. Long-press something in Explore to add it here.';

  @override
  String get tourUseBarTitle => 'Your storage';

  @override
  String get tourUseBarBody => 'How much each file type takes on your phone.';

  @override
  String get tourUseKindTitle => 'Free up space';

  @override
  String get tourUseKindBody =>
      'Tap a type to see its largest files and decide what to delete.';

  @override
  String get madeByMorobu => 'Made by Morobu';
}
