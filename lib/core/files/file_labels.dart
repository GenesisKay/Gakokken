import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../services/storage_volumes_service.dart';
import 'file_kind.dart';

/// Nombre de un tipo de archivo para filtros y gráficas.
String kindLabel(AppLocalizations l10n, FileKind kind) => switch (kind) {
  FileKind.folder => l10n.kindFolder,
  FileKind.pdf => 'PDF',
  FileKind.word => 'Word',
  FileKind.excel => 'Excel',
  FileKind.powerpoint => 'PowerPoint',
  FileKind.text => l10n.kindText,
  FileKind.code => l10n.kindCode,
  FileKind.image => l10n.kindImage,
  FileKind.video => l10n.kindVideo,
  FileKind.audio => l10n.kindAudio,
  FileKind.archive => l10n.kindArchive,
  FileKind.apk => 'APK',
  FileKind.ebook => l10n.kindEbook,
  FileKind.other => l10n.kindOther,
};

/// Nombre de una memoria: Interno para la del teléfono; para SD y USB, el
/// que da Android.
String volumeLabel(AppLocalizations l10n, StorageVolume volume) =>
    switch (volume.kind) {
      VolumeKind.system => l10n.volumeSystem,
      _ when volume.kind == VolumeKind.internal || volume.label.isEmpty =>
        l10n.browserRoot,
      _ => volume.label,
    };

/// Carpeta donde está [path], como en el breadcrumb de Explorar:
/// `Interno / Download / Facturas`.
String locationOf(AppLocalizations l10n, String path) {
  final volume = StorageVolumesService().volumeOf(path);
  final root = volume.path;
  final parent = p.dirname(path);
  if (!p.isWithin(root, parent)) {
    return p.equals(root, parent) ? volumeLabel(l10n, volume) : parent;
  }
  return [
    volumeLabel(l10n, volume),
    ...p.split(p.relative(parent, from: root)),
  ].join(' / ');
}
