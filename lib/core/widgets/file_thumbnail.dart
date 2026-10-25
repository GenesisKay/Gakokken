import 'package:flutter/material.dart';

import '../files/file_kind.dart';
import '../services/preview_settings_service.dart';
import '../services/thumbnail_service.dart';
import '../theme/theme_extensions.dart';
import 'file_kind_icon.dart';

/// Miniatura de un archivo si su tipo la tiene y está activada en Ajustes;
/// si no, o mientras carga, el logo de su tipo ([FileKindIcon]) o [fallback].
class FileThumbnail extends StatefulWidget {
  const FileThumbnail({
    super.key,
    required this.path,
    required this.name,
    this.isDir = false,
    this.size = 40,
    this.radius,
    this.fallback,
  });

  final String path;
  final String name;
  final bool isDir;
  final double size;

  /// Redondeo de la miniatura; por defecto el mismo que el logo.
  final double? radius;

  /// Lo que se ve sin miniatura, en lugar del logo.
  final Widget? fallback;

  @override
  State<FileThumbnail> createState() => _FileThumbnailState();
}

class _FileThumbnailState extends State<FileThumbnail> {
  final _settings = PreviewSettingsService();
  Future<ImageProvider?>? _image;
  int _pixels = 0;

  FileKind get _kind => FileKind.fromName(widget.name, isDir: widget.isDir);

  bool get _wanted =>
      _settings.isEnabled(_kind) &&
      ThumbnailService.supports(_kind, FileKind.extensionOf(widget.name));

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettings);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(FileThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path || oldWidget.size != widget.size) {
      _image = null;
      _load();
    }
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    super.dispose();
  }

  void _onSettings() => setState(_load);

  void _load() {
    if (!_wanted) {
      _image = null;
      return;
    }
    final pixels = (widget.size * MediaQuery.devicePixelRatioOf(context))
        .round();
    if (_image != null && pixels == _pixels) return;
    _pixels = pixels;
    _image = ThumbnailService.of(widget.path, _kind, pixels);
  }

  @override
  Widget build(BuildContext context) {
    final icon =
        widget.fallback ??
        FileKindIcon(
          kind: _kind,
          size: widget.size,
          extension: FileKind.extensionOf(widget.name),
        );
    final image = _image;
    if (image == null) return icon;

    return FutureBuilder<ImageProvider?>(
      future: image,
      builder: (context, snapshot) {
        final provider = snapshot.data;
        if (provider == null) return icon;
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.radius ?? widget.size * 0.22,
          ),
          child: Image(
            image: provider,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, _) => frame == null
                ? icon
                : _kind == FileKind.video
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      child,
                      _PlayBadge(size: widget.size),
                    ],
                  )
                : child,
            errorBuilder: (_, _, _) => icon,
          ),
        );
      },
    );
  }
}

/// Botón de reproducir sobre la miniatura de un video, para distinguirla de
/// una foto.
class _PlayBadge extends StatelessWidget {
  const _PlayBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimension = (size * 0.45).clamp(14.0, 40.0);
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: colors.bgElevated.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: dimension * 0.75,
        color: colors.textPrimary,
      ),
    );
  }
}
