import 'package:flutter/painting.dart';

/// Tipo de un archivo según su extensión.
///
/// Cada tipo tiene su logo: una etiqueta blanca sobre un cuadrado de color
/// (ver `FileKindIcon`). Los colores son fijos y no dependen del tema, para
/// que un PDF se vea igual con cualquier tema. La única excepción es la
/// carpeta, que usa el color principal del tema y no tiene etiqueta.
/// Colores fijos por tipo, aparte del tema (decisión en Vault/Proyectos/Gakoken.md).
enum FileKind {
  folder(null, null),
  pdf('PDF', Color(0xFFD93025)),
  word('W', Color(0xFF2B579A)),
  excel('X', Color(0xFF217346)),
  powerpoint('P', Color(0xFFD24726)),
  text('T', Color(0xFF616161)),
  code('</>', Color(0xFF3949AB)),
  image('I', Color(0xFFD81B60)),
  video('V', Color(0xFF7B1FA2)),
  audio('A', Color(0xFF00838F)),
  archive('Z', Color(0xFF6D4C41)),
  apk('APK', Color(0xFF558B2F)),
  ebook('E', Color(0xFF9E7C00)),

  /// Extensión desconocida: el logo muestra la primera letra de la extensión.
  other(null, Color(0xFF757575));

  const FileKind(this.label, this.color);

  final String? label;
  final Color? color;

  static FileKind fromName(String name, {bool isDir = false}) {
    if (isDir) return FileKind.folder;
    return _byExtension[extensionOf(name)] ?? FileKind.other;
  }

  /// Extensión en minúsculas, sin el punto; vacía si no tiene. Un nombre que
  /// empieza con punto (`.nomedia`) no cuenta como extensión.
  static String extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }
}

const _extensions = <FileKind, List<String>>{
  FileKind.pdf: ['pdf'],
  FileKind.word: ['doc', 'docx', 'odt', 'rtf', 'pages'],
  FileKind.excel: ['xls', 'xlsx', 'ods', 'csv', 'numbers'],
  FileKind.powerpoint: ['ppt', 'pptx', 'odp', 'key'],
  FileKind.text: ['txt', 'md', 'log', 'ini', 'cfg', 'conf'],
  FileKind.code: [
    'dart',
    'rs',
    'js',
    'ts',
    'jsx',
    'tsx',
    'py',
    'java',
    'kt',
    'kts',
    'c',
    'cpp',
    'h',
    'hpp',
    'cs',
    'go',
    'swift',
    'php',
    'rb',
    'html',
    'htm',
    'css',
    'scss',
    'json',
    'xml',
    'yaml',
    'yml',
    'toml',
    'sh',
    'bat',
    'ps1',
    'sql',
    'gradle',
  ],
  FileKind.image: [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'heic',
    'heif',
    'svg',
    'tif',
    'tiff',
    'ico',
    'raw',
    'dng',
  ],
  FileKind.video: [
    'mp4',
    'mkv',
    'avi',
    'mov',
    'webm',
    '3gp',
    'flv',
    'wmv',
    'm4v',
  ],
  FileKind.audio: [
    'mp3',
    'wav',
    'flac',
    'aac',
    'ogg',
    'oga',
    'm4a',
    'opus',
    'wma',
    'amr',
    'mid',
    'midi',
  ],
  FileKind.archive: [
    'zip',
    'rar',
    '7z',
    'tar',
    'gz',
    'tgz',
    'bz2',
    'xz',
    'zst',
  ],
  FileKind.apk: ['apk', 'apks', 'xapk', 'aab'],
  FileKind.ebook: ['epub', 'mobi', 'azw', 'azw3', 'fb2', 'cbz', 'cbr'],
};

final Map<String, FileKind> _byExtension = {
  for (final entry in _extensions.entries)
    for (final ext in entry.value) ext: entry.key,
};
