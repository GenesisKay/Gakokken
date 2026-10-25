import 'package:flutter/material.dart';

import '../files/file_kind.dart';
import '../theme/theme_extensions.dart';

/// Logo de un tipo de archivo: cuadrado redondeado de color con una etiqueta
/// blanca al centro (ver `FileKind`). Sirve en cualquier tamaño: listas,
/// cuadrícula, búsqueda y favoritos.
class FileKindIcon extends StatelessWidget {
  const FileKindIcon({
    super.key,
    required this.kind,
    this.size = 40,
    this.extension = '',
  });

  /// Logo para un nombre de archivo o carpeta.
  factory FileKindIcon.forName(
    String name, {
    Key? key,
    bool isDir = false,
    double size = 40,
  }) {
    return FileKindIcon(
      key: key,
      kind: FileKind.fromName(name, isDir: isDir),
      size: size,
      extension: FileKind.extensionOf(name),
    );
  }

  final FileKind kind;
  final double size;

  /// Solo se usa con `FileKind.other`, para mostrar su primera letra.
  final String extension;

  @override
  Widget build(BuildContext context) {
    final isFolder = kind == FileKind.folder;
    final color = kind.color ?? context.colors.primary;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: Center(
          child: isFolder
              ? Icon(
                  Icons.folder_rounded,
                  color: Colors.white,
                  size: size * 0.6,
                )
              : _label(context),
        ),
      ),
    );
  }

  Widget _label(BuildContext context) {
    final text =
        kind.label ??
        (extension.isEmpty ? '?' : extension.substring(0, 1).toUpperCase());
    // Más letras, letra más chica, para que quepan en el cuadrado.
    final scale = switch (text.length) {
      1 => 0.5,
      2 => 0.38,
      _ => 0.28,
    };
    return Text(
      text,
      maxLines: 1,
      style: context.typography.badge.copyWith(
        color: Colors.white,
        fontSize: size * scale,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 0,
      ),
    );
  }
}
