// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navSettings => '設定';

  @override
  String get labelLanguage => '言語';

  @override
  String get btnImport => 'インポート';

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get btnSave => '保存';

  @override
  String get btnDelete => '削除';

  @override
  String get btnEdit => '編集';

  @override
  String get errorPrefix => 'エラー: ';

  @override
  String get btnSelect => '選択';

  @override
  String get themesTitle => 'テーマ';

  @override
  String get titleImportTheme => 'テーマをインポート';

  @override
  String get instructionImportTheme => 'テーマのJSONコードをここに貼り付けてください:';

  @override
  String get msgThemeImportSuccess => 'テーマのインポートが完了した';

  @override
  String get headerThemesDefault => 'デフォルト';

  @override
  String get headerThemesCustom => 'マイテーマ';

  @override
  String get titleDeleteTheme => 'テーマを削除';

  @override
  String get statusActive => '有効';

  @override
  String get themeImportOr => 'または';

  @override
  String get themeSelectJson => 'JSONファイルを選択';

  @override
  String get themeImportFileSuccess => 'ファイルからテーマをインポートした';

  @override
  String themeImportError(String error) {
    return 'ファイルの読み込み中にエラーが発生した: $error';
  }

  @override
  String themeExportError(String error) {
    return 'エクスポート中にエラーが発生した: $error';
  }

  @override
  String themeSavedFile(String path) {
    return 'テーマを保存した場所: $path';
  }

  @override
  String get themeCopiedClipboard => 'JSONをクリップボードにコピーした';

  @override
  String get themeEmptyCustom => 'まだテーマを作成していない。\n＋ボタンを使って始めてね！';

  @override
  String themeConfirmDelete(String name) {
    return '\"$name\" を削除してもよい？';
  }

  @override
  String get themeCreateTitle => 'テーマを作成';

  @override
  String get themeEditTitle => 'テーマを編集';

  @override
  String get themeGeneratorTitle => 'ジェネレーター';

  @override
  String get themeSeedColor => 'シード';

  @override
  String get themeBrightness => '明るさ';

  @override
  String get themeGenerateAction => 'パレットを生成';

  @override
  String get themeNameLabel => 'テーマ名';

  @override
  String get themeDescLabel => '説明';

  @override
  String get themeRequired => '必須';

  @override
  String get btnOK => 'OK';

  @override
  String get themeSectionCore => 'コア（背景・テキスト）';

  @override
  String get themeSectionBrand => 'ブランド・アクション';

  @override
  String get themeSectionUI => '状態・UI';

  @override
  String get themeUseSecondary => 'セカンダリカラーを使用';

  @override
  String get themeUseSecondaryDesc => 'これらの色はGakokenでは使われませんが、ここで定義できます。';

  @override
  String get themeSelectColorTitle => '色を選択';

  @override
  String get colorBgPrimary => 'プライマリ背景';

  @override
  String get colorBgSecondary => 'セカンダリ背景';

  @override
  String get colorBgElevated => '浮き上がり背景';

  @override
  String get colorOverlay => 'オーバーレイ';

  @override
  String get colorTextPrimary => 'プライマリテキスト';

  @override
  String get colorTextSecondary => 'セカンダリテキスト';

  @override
  String get colorTextDisabled => '無効テキスト';

  @override
  String get colorTextInverse => '反転テキスト';

  @override
  String get colorPrimary => 'プライマリカラー';

  @override
  String get colorPrimaryHover => 'ホバー';

  @override
  String get colorPrimaryActive => 'アクティブ';

  @override
  String get colorSecondary => 'セカンダリカラー';

  @override
  String get colorSecondaryHover => 'ホバー（セカンダリ）';

  @override
  String get colorSecondaryActive => 'アクティブ（セカンダリ）';

  @override
  String get colorStateSuccess => '成功（緑）';

  @override
  String get colorStateWarning => '警告（黄）';

  @override
  String get colorStateError => 'エラー（赤）';

  @override
  String get colorStateInfo => '情報（青）';

  @override
  String get colorBorderSubtle => '控えめなボーダー';

  @override
  String get colorBorderFocus => 'フォーカスボーダー';

  @override
  String get colorSurfaceHover => 'サーフェス・ホバー';

  @override
  String get colorSurfaceActive => 'サーフェス・アクティブ';

  @override
  String get themeStatusActive => '有効';

  @override
  String get themeActionApply => 'テーマを適用';

  @override
  String get themeActionCopyJson => 'JSONをコピー';

  @override
  String get themeActionSaveFile => 'ファイルを保存';

  @override
  String get btnConfirm => '確認';

  @override
  String get titleSelectColor => '色を選択';

  @override
  String get themeDefaultName => 'Gakoken';

  @override
  String get themeDefaultDescription => '茶トラ猫：クリームとオレンジ';

  @override
  String get themeDefaultName2 => 'Oturoja';

  @override
  String get themeDefaultDescription2 => 'ダークパープルテーマ';

  @override
  String get themeDefaultName3 => 'Morobu';

  @override
  String get themeDefaultDescription3 => 'ライトグレー、ウォームニュートラル';

  @override
  String get themeDefaultName4 => 'Uborom';

  @override
  String get themeDefaultDescription4 => 'ダークニュートラルテーマ';

  @override
  String get themeDefaultName5 => 'Zontle';

  @override
  String get themeDefaultDescription5 => 'ライトニュートラルテーマ（金のアクセント）';

  @override
  String get themeDefaultName6 => 'Eltnoz';

  @override
  String get themeDefaultDescription6 => 'ダークニュートラルテーマ（金のアクセント）';

  @override
  String get themeDefaultName7 => 'Ajoruto';

  @override
  String get themeDefaultDescription7 => 'ライトパープルテーマ';

  @override
  String get themeDefaultName8 => 'Asiole';

  @override
  String get themeDefaultDescription8 => 'ダークハチドリテーマ：エメラルドとマゼンタ';

  @override
  String get themeSectionBackgrounds => '背景';

  @override
  String get themeSectionTexts => 'テキスト';

  @override
  String get themeSectionPrimary => 'プライマリ';

  @override
  String get themeSectionSecondary => 'セカンダリ';

  @override
  String get themeSectionStates => 'セマンティック状態';

  @override
  String get themeSectionComponents => 'コンポーネント';

  @override
  String get themeSaveTitle => 'テーマを保存';

  @override
  String get themeSelectFolderTitle => 'テーマを保存するフォルダーを選択';

  @override
  String get navExplore => '探す';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get favoritesEmpty => 'お気に入りはまだありません。「探す」でファイルやフォルダーを長押しすると追加できます。';

  @override
  String get themeNameNekokag => 'Nekokag';

  @override
  String get themeDescNekokag => '夜の茶トラ猫：ダークにオレンジ';

  @override
  String get themeNameEloisa => 'Eloisa';

  @override
  String get themeDescEloisa => 'ハチドリ：エメラルドとマゼンタ';

  @override
  String get searchPlaceholder => '検索...';

  @override
  String get browserRoot => '内部ストレージ';

  @override
  String get browserPermissionText =>
      'フォルダーとファイルを表示するには、Gakoken にすべてのファイルへのアクセスを許可してください。';

  @override
  String get btnGrantPermission => '許可する';

  @override
  String get browserEmpty => 'このフォルダーは空です。';

  @override
  String get browserCannotRead => 'このフォルダーは開けません。';

  @override
  String browserItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項目',
      zero: '空',
    );
    return '$_temp0';
  }

  @override
  String get browserViewTitle => '表示';

  @override
  String get viewList => 'リスト';

  @override
  String get viewDetails => '詳細';

  @override
  String get viewGrid => 'グリッド';

  @override
  String get columnName => '名前';

  @override
  String get columnSize => 'サイズ';

  @override
  String get columnModified => '更新日';

  @override
  String get actionOpen => '開く';

  @override
  String get actionShare => '共有';

  @override
  String get actionAddFavorite => 'お気に入りに追加';

  @override
  String get actionRemoveFavorite => 'お気に入りから削除';

  @override
  String get fileNoApp => 'このファイルを開けるアプリがありません。';

  @override
  String get fileMissing => '存在しません';

  @override
  String get fileOpenError => 'ファイルを開けませんでした。';

  @override
  String get kindFolder => 'フォルダー';

  @override
  String get kindText => 'テキスト';

  @override
  String get kindCode => 'コード';

  @override
  String get kindImage => '画像';

  @override
  String get kindVideo => '動画';

  @override
  String get kindAudio => '音声';

  @override
  String get kindArchive => '圧縮ファイル';

  @override
  String get kindEbook => '電子書籍';

  @override
  String get kindOther => 'その他';

  @override
  String get openWithTitle => 'アプリで開く';

  @override
  String get usageTitle => '使用容量';

  @override
  String get usageOpenInExplore => '「探す」で開く';

  @override
  String usageCounts(String files, String dirs) {
    return '$files ファイル · $dirs フォルダー';
  }

  @override
  String get usageUpdating => 'インデックスを更新中です。数値が変わることがあります。';

  @override
  String get usageByKind => '種類別';

  @override
  String get usageLargest => 'サイズの大きい項目';

  @override
  String usageFiles(String count) {
    return '$count ファイル';
  }

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'スマホ内を検索';

  @override
  String get searchEverywhere => 'スマホ全体';

  @override
  String searchOnlyIn(String folder) {
    return '$folder のみ';
  }

  @override
  String get searchIntro => '名前の一部を入力してください。1文字間違えても見つかります。';

  @override
  String get searchNoResults => '見つかりませんでした。';

  @override
  String indexingProgress(String count) {
    return 'スマホをインデックス中: $count 件';
  }

  @override
  String get indexNotReady => 'インデックスがまだありません。設定の「インデックス」で作成してください。';

  @override
  String get indexTitle => 'インデックス';

  @override
  String get indexDescription =>
      'Gakoken はすべてのファイルの一覧を保存し、検索や容量の計算をすぐに行います。アプリを開くと変更されたフォルダーだけを確認し、1日1回はすべてを確認します。';

  @override
  String get indexNever => '未作成';

  @override
  String get indexingShort => 'インデックス中…';

  @override
  String indexEntries(String count) {
    return '$count 件';
  }

  @override
  String indexLastRun(String date) {
    return '最終更新: $date';
  }

  @override
  String get indexRebuild => '再インデックス';

  @override
  String get indexError => '前回のインデックス作成に失敗しました。もう一度お試しください。';

  @override
  String get browserNoMatches => 'このフォルダーにはこの種類のファイルがありません。';

  @override
  String get sortFilterTitle => '並べ替えと絞り込み';

  @override
  String get sortBy => '並べ替え';

  @override
  String get sortAscending => '昇順';

  @override
  String get sortDescending => '降順';

  @override
  String get sortModified => '日付';

  @override
  String get sortKind => '種類';

  @override
  String get filterKinds => '表示する種類';

  @override
  String get filterClear => '解除';

  @override
  String get previewTitle => 'プレビュー';

  @override
  String get previewDescription => 'ロゴの代わりにサムネイルを表示する種類を選んでください。';

  @override
  String get previewOff => 'オフ';

  @override
  String get previewPdfNote => '文書の1ページ目';

  @override
  String get navUsage => '容量';

  @override
  String get navBack => '戻る';

  @override
  String get navForward => '進む';

  @override
  String get tabNew => '新しいタブ';

  @override
  String get tabClose => 'タブを閉じる';

  @override
  String get tabOpenNew => '新しいタブで開く';

  @override
  String get volumesTitle => 'ストレージ';

  @override
  String volumeFree(String free, String total) {
    return '$total 中 $free 空き';
  }

  @override
  String get volumeNotIndexed => '検索の対象外';

  @override
  String get usageCalculating => '計算中…';

  @override
  String get hiddenTitle => '隠しファイル';

  @override
  String get hiddenDescription =>
      '.thumbnails のように名前がドットで始まるファイルとフォルダーです。たいてい他のアプリが使っています。';

  @override
  String get hiddenShowInExplore => '「探す」に表示';

  @override
  String get hiddenIncludeInSearch => '検索に含める';

  @override
  String get hiddenOff => '非表示';

  @override
  String get hiddenInExplore => '「探す」のみ';

  @override
  String get hiddenInSearch => '検索のみ';

  @override
  String get hiddenEverywhere => '「探す」と検索';

  @override
  String get actionCopy => 'コピー';

  @override
  String get actionCut => '切り取り';

  @override
  String get actionRename => '名前を変更';

  @override
  String get actionDelete => '削除';

  @override
  String get actionMore => 'その他';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get selectAll => 'すべて選択';

  @override
  String selectionCount(int count) {
    return '$count 件選択';
  }

  @override
  String get renameTitle => '名前を変更';

  @override
  String get renameAction => '変更';

  @override
  String renameError(String name) {
    return '「$name」に変更できませんでした。すでに存在するか、名前が正しくない可能性があります。';
  }

  @override
  String conflictTitle(int count) {
    return '同じ名前の項目が $count 件あります';
  }

  @override
  String get conflictKeepBoth => '両方残す';

  @override
  String get conflictReplace => '置き換える';

  @override
  String get conflictSkip => 'スキップ';

  @override
  String clipboardCopied(int count) {
    return '$count 件をコピー';
  }

  @override
  String clipboardCut(int count) {
    return '$count 件を切り取り';
  }

  @override
  String get pasteHere => 'ここに貼り付け';

  @override
  String jobCopying(int done, int total) {
    return 'コピー中 $done/$total';
  }

  @override
  String jobMoving(int done, int total) {
    return '移動中 $done/$total';
  }

  @override
  String jobDone(int count) {
    return '完了: $count 件';
  }

  @override
  String get jobCancelled => 'キャンセルしました。途中のファイルは残っていません。';

  @override
  String jobFailed(int count, String names) {
    return '$count 件を移せませんでした: $names';
  }

  @override
  String get trashTitle => 'ゴミ箱';

  @override
  String trashCount(int count) {
    return '$count 件';
  }

  @override
  String trashMoved(int count) {
    return '$count 件をゴミ箱に移動しました';
  }

  @override
  String trashFailed(int count) {
    return '$count 件をゴミ箱に移動できませんでした';
  }

  @override
  String trashEmpty(int days) {
    return 'ゴミ箱は空です。削除したものはここに $days 日間保存されます。';
  }

  @override
  String get trashEmptyAction => '空にする';

  @override
  String trashDaysLeft(int days) {
    return '残り $days 日';
  }

  @override
  String get trashRestore => '元に戻す';

  @override
  String get trashRestored => '元の場所に戻しました';

  @override
  String get trashRestoreFailed => '元に戻せませんでした';

  @override
  String get trashDeleteForever => '完全に削除';

  @override
  String trashDeleteForeverMessage(int count) {
    return '$count 件を完全に削除します。元に戻せません。';
  }

  @override
  String get viewGallery => 'ギャラリー';

  @override
  String get previewVideoNote => '動画の1コマ';

  @override
  String indexTook(String duration) {
    return '前回の確認にかかった時間: $duration';
  }

  @override
  String get trashOpen => 'ゴミ箱を表示';

  @override
  String get actionInfo => '詳細';

  @override
  String get infoContents => '内容';

  @override
  String get infoLocation => '場所';

  @override
  String favoritesAddedMany(int count) {
    return '$count 件をお気に入りに追加';
  }

  @override
  String favoritesRemovedMany(int count) {
    return '$count 件をお気に入りから削除';
  }

  @override
  String kindFilesLimit(String count) {
    return '大きい順に $count 件を表示';
  }

  @override
  String get volumeSystem => 'システムのルート';

  @override
  String get volumeSystemNote => 'Android のフォルダ。ほとんどが読み取り専用';

  @override
  String get themeNameBioka => 'Bioka';

  @override
  String get themeDescBioka => '地球：海の青と大陸の緑';

  @override
  String get themeNameAkoib => 'Akoib';

  @override
  String get themeDescAkoib => '夜の地球：海の青と緑';

  @override
  String get trashDaysTitle => 'ゴミ箱に残す日数';

  @override
  String get trashDaysUnit => '日';

  @override
  String trashDaysHelp(int max) {
    return '1〜$max。保存すると、それより古いものは完全に削除されます。';
  }

  @override
  String get trashDaysInvalid => '数字を入力してください';

  @override
  String get browserDisplayTitle => '表示・並べ替え・絞り込み';

  @override
  String get browserLocationTitle => '場所';

  @override
  String trashDaysValue(int days) {
    return '$days 日';
  }

  @override
  String get actionCopyPath => 'パスをコピー';

  @override
  String get pathCopied => 'パスをコピーしました';

  @override
  String get newFolderTitle => '新しいフォルダ';

  @override
  String get newFolderHint => 'フォルダ名';

  @override
  String get newFolderCreate => '作成';

  @override
  String get newFolderInvalid => '/ を含まない、ドットだけでない名前を入力してください。';

  @override
  String get newFolderExists => '同じ名前のものがすでにあります。';

  @override
  String get newFolderDenied => 'このフォルダは読み取り専用のため、ここにはフォルダを作成できません。';

  @override
  String get newFolderFailed => 'フォルダを作成できませんでした。';

  @override
  String newFolderCreated(String name) {
    return 'フォルダ「$name」を作成しました';
  }
}
