import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/files/file_kind.dart';

void main() {
  test('Classifies by extension, ignoring case', () {
    expect(FileKind.fromName('Factura.PDF'), FileKind.pdf);
    expect(FileKind.fromName('notas.docx'), FileKind.word);
    expect(FileKind.fromName('gastos.xlsx'), FileKind.excel);
    expect(FileKind.fromName('IMG_2024.jpg'), FileKind.image);
    expect(FileKind.fromName('app-release.apk'), FileKind.apk);
    expect(FileKind.fromName('respaldo.tar.gz'), FileKind.archive);
  });

  test('Folders, unknown extensions and dotfiles', () {
    expect(FileKind.fromName('Descargas', isDir: true), FileKind.folder);
    expect(FileKind.fromName('datos.xyz'), FileKind.other);
    expect(FileKind.fromName('.nomedia'), FileKind.other);
    expect(FileKind.extensionOf('.nomedia'), '');
    expect(FileKind.extensionOf('archivo.'), '');
  });

  test('Every kind except folder has a fixed color', () {
    for (final kind in FileKind.values) {
      expect(kind.color == null, kind == FileKind.folder, reason: kind.name);
    }
  });
}
