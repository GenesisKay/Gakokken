import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/engine/file_engine.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/file_changes.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

/// Pestaña Favoritos. Los que ya no existen se marcan y se pueden quitar.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.visible,
    required this.onOpenFolder,
  });

  /// Si la pestaña está a la vista; al entrar se revisa qué sigue existiendo.
  final bool visible;
  final ValueChanged<String> onOpenFolder;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favorites = FavoritesService();
  Set<String> _missing = const {};
  // Borrar o mover un favorito desde otra pestaña lo deja marcado al momento.
  StreamSubscription<Set<String>>? _changes;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_checkMissing);
    _changes = FileChanges.stream.listen((_) => _checkMissing());
    _checkMissing();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) _checkMissing();
  }

  @override
  void dispose() {
    _favorites.removeListener(_checkMissing);
    _changes?.cancel();
    super.dispose();
  }

  Future<void> _checkMissing() async {
    final engine = FileEngine.instance;
    final missing = <String>{};
    for (final favorite in _favorites.all) {
      if (!await engine.exists(favorite.path)) missing.add(favorite.path);
    }
    if (mounted) setState(() => _missing = missing);
  }

  void _onTap(Favorite favorite) {
    if (_missing.contains(favorite.path)) {
      ScaffoldMessengerService.showInfo(
        AppLocalizations.of(context)!.fileMissing,
      );
    } else if (favorite.isDir) {
      widget.onOpenFolder(favorite.path);
    } else {
      openFileWithFeedback(context, favorite.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: GakokenAppBar(title: l10n.navFavorites, isRootScreen: true),
      body: ListenableBuilder(
        listenable: _favorites,
        builder: (context, _) {
          final favorites = _favorites.all;
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.favoritesEmpty,
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final favorite = favorites[i];
              final missing = _missing.contains(favorite.path);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Opacity(
                  opacity: missing ? 0.4 : 1,
                  child: FileThumbnail(
                    path: favorite.path,
                    name: favorite.name,
                    isDir: favorite.isDir,
                  ),
                ),
                title: Text(
                  favorite.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.body.copyWith(
                    color: missing ? colors.textSecondary : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  missing ? l10n.fileMissing : locationOf(l10n, favorite.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.small.copyWith(
                    color: missing ? colors.stateError : colors.textSecondary,
                  ),
                ),
                onTap: () => _onTap(favorite),
                onLongPress: () => showFileActionsSheet(
                  context,
                  path: favorite.path,
                  name: favorite.name,
                  isDir: favorite.isDir,
                  exists: !missing,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
