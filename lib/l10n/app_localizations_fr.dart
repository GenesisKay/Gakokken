// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navSettings => 'Paramètres';

  @override
  String get labelLanguage => 'Langue';

  @override
  String get btnImport => 'Importer';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnSave => 'Enregistrer';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get btnEdit => 'Modifier';

  @override
  String get errorPrefix => 'Erreur : ';

  @override
  String get btnSelect => 'Sélectionner';

  @override
  String get themesTitle => 'Thèmes';

  @override
  String get titleImportTheme => 'Importer le thème';

  @override
  String get instructionImportTheme => 'Collez le code JSON du thème ici :';

  @override
  String get msgThemeImportSuccess => 'Thème importé avec succès';

  @override
  String get headerThemesDefault => 'Par défaut';

  @override
  String get headerThemesCustom => 'Mes thèmes';

  @override
  String get titleDeleteTheme => 'Supprimer le thème';

  @override
  String get statusActive => 'Actif';

  @override
  String get themeImportOr => 'Ou';

  @override
  String get themeSelectJson => 'Sélectionner un fichier JSON';

  @override
  String get themeImportFileSuccess => 'Thème importé depuis le fichier';

  @override
  String themeImportError(String error) {
    return 'Erreur lors de la lecture du fichier : $error';
  }

  @override
  String themeExportError(String error) {
    return 'Erreur lors de l’exportation : $error';
  }

  @override
  String themeSavedFile(String path) {
    return 'Thème enregistré à : $path';
  }

  @override
  String get themeCopiedClipboard => 'JSON copié dans le presse-papiers';

  @override
  String get themeEmptyCustom =>
      'Vous n’avez pas encore créé de thèmes.\nUtilisez le bouton + pour commencer !';

  @override
  String themeConfirmDelete(String name) {
    return 'Êtes-vous sûr de vouloir supprimer « $name » ?';
  }

  @override
  String get themeCreateTitle => 'Créer un thème';

  @override
  String get themeEditTitle => 'Modifier le thème';

  @override
  String get themeGeneratorTitle => 'Générateur';

  @override
  String get themeSeedColor => 'Couleur de base';

  @override
  String get themeBrightness => 'Luminosité';

  @override
  String get themeGenerateAction => 'Générer la palette';

  @override
  String get themeNameLabel => 'Nom du thème';

  @override
  String get themeDescLabel => 'Description';

  @override
  String get themeRequired => 'Obligatoire';

  @override
  String get btnOK => 'OK';

  @override
  String get themeSectionCore => 'Base (Arrière-plans & Texte)';

  @override
  String get themeSectionBrand => 'Marque & Actions';

  @override
  String get themeSectionUI => 'États & UI';

  @override
  String get themeUseSecondary => 'Utiliser la couleur secondaire';

  @override
  String get themeUseSecondaryDesc =>
      'Ces couleurs ne sont pas utilisées dans Gakoken, mais vous pouvez les définir ici.';

  @override
  String get themeSelectColorTitle => 'Sélectionner une couleur';

  @override
  String get colorBgPrimary => 'Arrière-plan principal';

  @override
  String get colorBgSecondary => 'Arrière-plan secondaire';

  @override
  String get colorBgElevated => 'Arrière-plan surélevé';

  @override
  String get colorOverlay => 'Superposition';

  @override
  String get colorTextPrimary => 'Texte principal';

  @override
  String get colorTextSecondary => 'Texte secondaire';

  @override
  String get colorTextDisabled => 'Désactivé';

  @override
  String get colorTextInverse => 'Inverse';

  @override
  String get colorPrimary => 'Couleur principale';

  @override
  String get colorPrimaryHover => 'Survol';

  @override
  String get colorPrimaryActive => 'Actif';

  @override
  String get colorSecondary => 'Couleur secondaire';

  @override
  String get colorSecondaryHover => 'Survol (Sec)';

  @override
  String get colorSecondaryActive => 'Actif (Sec)';

  @override
  String get colorStateSuccess => 'Succès (Vert)';

  @override
  String get colorStateWarning => 'Avertissement (Jaune)';

  @override
  String get colorStateError => 'Erreur (Rouge)';

  @override
  String get colorStateInfo => 'Info (Bleu)';

  @override
  String get colorBorderSubtle => 'Bord subtil';

  @override
  String get colorBorderFocus => 'Bord en focus';

  @override
  String get colorSurfaceHover => 'Survol de surface';

  @override
  String get colorSurfaceActive => 'Surface active';

  @override
  String get themeStatusActive => 'Actif';

  @override
  String get themeActionApply => 'Appliquer le thème';

  @override
  String get themeActionCopyJson => 'Copier le JSON';

  @override
  String get themeActionSaveFile => 'Enregistrer le fichier';

  @override
  String get btnConfirm => 'Confirmer';

  @override
  String get titleSelectColor => 'Sélectionner une couleur';

  @override
  String get themeDefaultName => 'Gakoken';

  @override
  String get themeDefaultDescription => 'Chat roux : crème et orange tigré';

  @override
  String get themeDefaultName2 => 'Oturoja';

  @override
  String get themeDefaultDescription2 => 'Thème violet foncé';

  @override
  String get themeDefaultName3 => 'Morobu';

  @override
  String get themeDefaultDescription3 => 'Thème gris clair, neutres chauds';

  @override
  String get themeDefaultName4 => 'Uborom';

  @override
  String get themeDefaultDescription4 => 'Thème sombre neutre';

  @override
  String get themeDefaultName5 => 'Zontle';

  @override
  String get themeDefaultDescription5 => 'Thème clair neutre, accent doré';

  @override
  String get themeDefaultName6 => 'Eltnoz';

  @override
  String get themeDefaultDescription6 => 'Thème sombre neutre, accent doré';

  @override
  String get themeDefaultName7 => 'Ajoruto';

  @override
  String get themeDefaultDescription7 => 'Thème violet clair';

  @override
  String get themeDefaultName8 => 'Asiole';

  @override
  String get themeDefaultDescription8 =>
      'Thème colibri sombre : émeraude et magenta';

  @override
  String get themeSectionBackgrounds => 'Arrière-plans';

  @override
  String get themeSectionTexts => 'Textes';

  @override
  String get themeSectionPrimary => 'Primaire';

  @override
  String get themeSectionSecondary => 'Secondaire';

  @override
  String get themeSectionStates => 'États sémantiques';

  @override
  String get themeSectionComponents => 'Composants';

  @override
  String get themeSaveTitle => 'Enregistrer le thème';

  @override
  String get themeSelectFolderTitle =>
      'Sélectionnez le dossier pour enregistrer le thème';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get favoritesEmpty =>
      'Pas encore de favoris. Appuyez longuement sur un fichier ou un dossier dans Explorer pour l\'ajouter.';

  @override
  String get themeNameNekokag => 'Nekokag';

  @override
  String get themeDescNekokag => 'Chat roux la nuit : sombre avec orange tigré';

  @override
  String get themeNameEloisa => 'Eloisa';

  @override
  String get themeDescEloisa => 'Colibri : émeraude et magenta';

  @override
  String get searchPlaceholder => 'Rechercher...';

  @override
  String get browserRoot => 'Stockage interne';

  @override
  String get browserPermissionText =>
      'Pour afficher vos dossiers et fichiers, Gakoken a besoin d\'accéder à tous les fichiers.';

  @override
  String get btnGrantPermission => 'Autoriser';

  @override
  String get browserEmpty => 'Ce dossier est vide.';

  @override
  String get browserCannotRead => 'Impossible d\'ouvrir ce dossier.';

  @override
  String browserItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
      zero: 'Vide',
    );
    return '$_temp0';
  }

  @override
  String get browserViewTitle => 'Affichage';

  @override
  String get viewList => 'Liste';

  @override
  String get viewDetails => 'Détails';

  @override
  String get viewGrid => 'Grille';

  @override
  String get columnName => 'Nom';

  @override
  String get columnSize => 'Taille';

  @override
  String get columnModified => 'Modifié';

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionAddFavorite => 'Ajouter aux favoris';

  @override
  String get actionRemoveFavorite => 'Retirer des favoris';

  @override
  String get fileNoApp => 'Aucune application ne peut ouvrir ce fichier.';

  @override
  String get fileMissing => 'N\'existe plus';

  @override
  String get fileOpenError => 'Impossible d\'ouvrir le fichier.';

  @override
  String get kindFolder => 'Dossier';

  @override
  String get kindText => 'Texte';

  @override
  String get kindCode => 'Code';

  @override
  String get kindImage => 'Images';

  @override
  String get kindVideo => 'Vidéos';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindArchive => 'Archives';

  @override
  String get kindEbook => 'Livres';

  @override
  String get kindOther => 'Autres';

  @override
  String get openWithTitle => 'Ouvrir avec';

  @override
  String get usageTitle => 'Espace utilisé';

  @override
  String get usageOpenInExplore => 'Ouvrir dans Explorer';

  @override
  String usageCounts(String files, String dirs) {
    return '$files fichiers · $dirs dossiers';
  }

  @override
  String get usageUpdating =>
      'Mise à jour de l\'index ; les chiffres peuvent changer.';

  @override
  String get usageByKind => 'Par type';

  @override
  String get usageLargest => 'Les plus volumineux';

  @override
  String usageFiles(String count) {
    return '$count fichiers';
  }

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchHint => 'Rechercher sur votre téléphone';

  @override
  String get searchEverywhere => 'Tout le téléphone';

  @override
  String searchOnlyIn(String folder) {
    return 'Seulement dans $folder';
  }

  @override
  String get searchIntro =>
      'Tapez une partie du nom. Il le trouve même avec une faute.';

  @override
  String get searchNoResults => 'Aucun résultat.';

  @override
  String indexingProgress(String count) {
    return 'Indexation du téléphone : $count fichiers et dossiers';
  }

  @override
  String get indexNotReady =>
      'Pas encore d\'index. Allez dans Réglages, Index, pour le créer.';

  @override
  String get indexTitle => 'Index';

  @override
  String get indexDescription =>
      'Gakoken garde la liste de tous vos fichiers pour rechercher et mesurer l\'espace instantanément. À l\'ouverture, seuls les dossiers modifiés sont vérifiés, et une fois par jour tout est parcouru.';

  @override
  String get indexNever => 'Pas d\'index';

  @override
  String get indexingShort => 'Indexation…';

  @override
  String indexEntries(String count) {
    return '$count fichiers';
  }

  @override
  String indexLastRun(String date) {
    return 'À jour depuis : $date';
  }

  @override
  String get indexRebuild => 'Réindexer';

  @override
  String get indexError => 'La dernière indexation a échoué. Réessayez.';

  @override
  String get browserNoMatches => 'Aucun fichier de ce type dans ce dossier.';

  @override
  String get sortFilterTitle => 'Trier et filtrer';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortAscending => 'Croissant';

  @override
  String get sortDescending => 'Décroissant';

  @override
  String get sortModified => 'Date';

  @override
  String get sortKind => 'Type';

  @override
  String get filterKinds => 'Afficher seulement';

  @override
  String get filterClear => 'Effacer le filtre';

  @override
  String get previewTitle => 'Aperçu';

  @override
  String get previewDescription =>
      'Choisissez les types qui affichent une miniature au lieu de leur logo.';

  @override
  String get previewOff => 'Désactivé';

  @override
  String get previewPdfNote => 'Première page du document';

  @override
  String get navUsage => 'Espace';

  @override
  String get navBack => 'Précédent';

  @override
  String get navForward => 'Suivant';

  @override
  String get tabNew => 'Nouvel onglet';

  @override
  String get tabClose => 'Fermer l\'onglet';

  @override
  String get tabOpenNew => 'Ouvrir dans un nouvel onglet';

  @override
  String get volumesTitle => 'Stockages';

  @override
  String volumeFree(String free, String total) {
    return '$free libres sur $total';
  }

  @override
  String get volumeNotIndexed => 'Non inclus dans la recherche';

  @override
  String get usageCalculating => 'Calcul en cours…';

  @override
  String get hiddenTitle => 'Fichiers masqués';

  @override
  String get hiddenDescription =>
      'Fichiers et dossiers dont le nom commence par un point, comme .thumbnails. D\'autres applications les utilisent en général.';

  @override
  String get hiddenShowInExplore => 'Afficher dans Explorer';

  @override
  String get hiddenIncludeInSearch => 'Inclure dans la recherche';

  @override
  String get hiddenOff => 'Masqués';

  @override
  String get hiddenInExplore => 'Dans Explorer';

  @override
  String get hiddenInSearch => 'Dans la recherche';

  @override
  String get hiddenEverywhere => 'Dans Explorer et la recherche';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionCut => 'Couper';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionMore => 'Plus';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get renameTitle => 'Renommer';

  @override
  String get renameAction => 'Renommer';

  @override
  String renameError(String name) {
    return 'Impossible de renommer en « $name ». Il existe peut-être déjà ou le nom n\'est pas valide.';
  }

  @override
  String conflictTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments de ces noms existent déjà',
      one: 'Un élément de ce nom existe déjà',
    );
    return '$_temp0';
  }

  @override
  String get conflictKeepBoth => 'Garder les deux';

  @override
  String get conflictReplace => 'Remplacer';

  @override
  String get conflictSkip => 'Ignorer';

  @override
  String clipboardCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments copiés',
      one: '1 élément copié',
    );
    return '$_temp0';
  }

  @override
  String clipboardCut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments coupés',
      one: '1 élément coupé',
    );
    return '$_temp0';
  }

  @override
  String get pasteHere => 'Coller ici';

  @override
  String jobCopying(int done, int total) {
    return 'Copie $done sur $total';
  }

  @override
  String jobMoving(int done, int total) {
    return 'Déplacement $done sur $total';
  }

  @override
  String jobDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Terminé : $count éléments',
      one: 'Terminé : 1 élément',
      zero: 'Rien n\'a été collé',
    );
    return '$_temp0';
  }

  @override
  String get jobCancelled => 'Annulé. Rien n\'est resté à moitié.';

  @override
  String jobFailed(int count, String names) {
    return 'Impossible de transférer $count : $names';
  }

  @override
  String get trashTitle => 'Corbeille';

  @override
  String trashCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
      zero: 'Vide',
    );
    return '$_temp0';
  }

  @override
  String trashMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments déplacés dans la corbeille',
      one: 'Déplacé dans la corbeille',
    );
    return '$_temp0';
  }

  @override
  String trashFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impossible de déplacer $count éléments dans la corbeille',
      one: 'Impossible de déplacer 1 élément dans la corbeille',
    );
    return '$_temp0';
  }

  @override
  String trashEmpty(int days) {
    return 'La corbeille est vide. Ce que vous supprimez y reste $days jours.';
  }

  @override
  String get trashEmptyAction => 'Vider';

  @override
  String trashDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Restent $days jours',
      one: 'Reste 1 jour',
      zero: 'Supprimé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restaurer';

  @override
  String get trashRestored => 'Restauré à son emplacement';

  @override
  String get trashRestoreFailed => 'Impossible de restaurer';

  @override
  String get trashDeleteForever => 'Supprimer définitivement';

  @override
  String trashDeleteForeverMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count éléments seront supprimés définitivement. Action irréversible.',
      one: 'Il sera supprimé définitivement. Action irréversible.',
    );
    return '$_temp0';
  }

  @override
  String get viewGallery => 'Galerie';

  @override
  String get previewVideoNote => 'Une image de la vidéo';

  @override
  String indexTook(String duration) {
    return 'La dernière vérification a pris $duration';
  }

  @override
  String get trashOpen => 'Voir la corbeille';

  @override
  String get actionInfo => 'Informations';

  @override
  String get infoContents => 'Contenu';

  @override
  String get infoLocation => 'Emplacement';

  @override
  String favoritesAddedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajoutés aux favoris',
      one: 'Ajouté aux favoris',
    );
    return '$_temp0';
  }

  @override
  String favoritesRemovedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count retirés des favoris',
      one: 'Retiré des favoris',
    );
    return '$_temp0';
  }

  @override
  String kindFilesLimit(String count) {
    return 'Les $count plus volumineux sont affichés';
  }

  @override
  String get volumeSystem => 'Racine du système';

  @override
  String get volumeSystemNote =>
      'Dossiers d\'Android ; presque tout est en lecture seule';

  @override
  String get themeNameBioka => 'Bioka';

  @override
  String get themeDescBioka => 'La Terre : bleu océan et vert des continents';

  @override
  String get themeNameAkoib => 'Akoib';

  @override
  String get themeDescAkoib => 'La Terre la nuit : bleu océan et vert';

  @override
  String get trashDaysTitle => 'Jours dans la corbeille';

  @override
  String get trashDaysUnit => 'jours';

  @override
  String trashDaysHelp(int max) {
    return 'De 1 à $max. Ce qui est plus ancien est supprimé définitivement à l\'enregistrement.';
  }

  @override
  String get trashDaysInvalid => 'Saisissez un nombre';

  @override
  String get browserDisplayTitle => 'Affichage, tri et filtre';

  @override
  String get browserLocationTitle => 'Emplacement';

  @override
  String trashDaysValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get actionCopyPath => 'Copier le chemin';

  @override
  String get pathCopied => 'Chemin copié';

  @override
  String get newFolderTitle => 'Nouveau dossier';

  @override
  String get newFolderHint => 'Nom du dossier';

  @override
  String get newFolderCreate => 'Créer';

  @override
  String get newFolderInvalid =>
      'Saisissez un nom valide, sans / ni seulement des points.';

  @override
  String get newFolderExists => 'Un élément porte déjà ce nom ici.';

  @override
  String get newFolderDenied =>
      'Ce dossier est en lecture seule ; impossible d\'y créer des dossiers.';

  @override
  String get newFolderFailed => 'Impossible de créer le dossier.';

  @override
  String newFolderCreated(String name) {
    return 'Dossier « $name » créé';
  }
}
