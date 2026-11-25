import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/files/path_input.dart';
import 'package:path/path.dart' as p;

void main() {
  group('parsePathInput', () {
    final root = Directory.systemTemp.path;
    final folder = p.join(root, 'Fotos');

    test('acepta la ruta tal cual', () {
      expect(parsePathInput(folder), folder);
    });

    test('quita espacios, comillas y la barra del final', () {
      expect(parsePathInput('  "$folder${p.separator}"  '), folder);
      expect(parsePathInput("'$folder'"), folder);
    });

    test('acepta file://', () {
      expect(parsePathInput(Uri.file(folder).toString()), folder);
    });

    test('no toma como ruta un nombre o texto suelto', () {
      expect(parsePathInput('Fotos'), isNull);
      expect(parsePathInput(''), isNull);
      expect(parsePathInput('$folder\n$folder'), isNull);
    });
  });
}
