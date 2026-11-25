import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Una opción de [showAnchoredMenu].
class AnchoredMenuOption {
  const AnchoredMenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
    this.selected = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;

  /// null la muestra desactivada.
  final VoidCallback? onTap;

  /// Línea chica debajo, por ejemplo por qué está desactivada.
  final String? hint;

  /// Marca la opción actual (primario y palomita).
  final bool selected;

  /// Eliminar y parecidas: en el color de error del tema.
  final bool destructive;
}

const double _itemHeight = kMinInteractiveDimension;
const double _menuPadding = 8;
const double _gap = 4;

/// Opciones de un elemento concreto (pulsación larga, tres puntos, botón)
/// en una lista flotante pegada a [anchor], en vez de una hoja inferior
/// (regla G-13 del Design System). Sale debajo del elemento, o arriba si no
/// cabe, alineada al lado del elemento más cercano al borde. El menú se
/// cierra antes de correr la acción, que usa el contexto de la pantalla.
/// Con [at] (posición global del toque) sale de ese punto en vez de todo el
/// elemento, para listas que no entregan el contexto de cada fila.
Future<void> showAnchoredMenu({
  required BuildContext anchor,
  required List<AnchoredMenuOption> options,
  Offset? at,
}) async {
  if (options.isEmpty) return;
  final colors = anchor.colors;
  final box = anchor.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(anchor).context.findRenderObject()! as RenderBox;
  final rect = at != null
      ? overlay.globalToLocal(at) & Size.zero
      : box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  final padding = MediaQuery.paddingOf(anchor);

  final height = options.fold<double>(
        0,
        (sum, o) => sum + (o.hint == null ? _itemHeight : _itemHeight + 16),
      ) +
      _menuPadding * 2;
  final fitsBelow =
      rect.bottom + _gap + height <= overlay.size.height - padding.bottom;
  final top = fitsBelow ? rect.bottom + _gap : rect.top - _gap - height;

  // G-09: menús de 150 a 250 ms, entrada ease-out y salida 20% más corta.
  final reduceMotion = MediaQuery.disableAnimationsOf(anchor);
  final chosen = await showMenu<VoidCallback>(
    context: anchor,
    position: RelativeRect.fromLTRB(
      rect.left,
      top,
      overlay.size.width - rect.right,
      overlay.size.height - top - height,
    ),
    color: colors.bgElevated,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
    popUpAnimationStyle: reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            curve: Curves.easeOut,
            duration: Duration(milliseconds: 200),
            reverseDuration: Duration(milliseconds: 160),
          ),
    items: [
      for (final option in options)
        PopupMenuItem(
          value: option.onTap,
          enabled: option.onTap != null,
          height: option.hint == null ? _itemHeight : _itemHeight + 16,
          child: _AnchoredMenuRow(option: option),
        ),
    ],
  );
  chosen?.call();
}

class _AnchoredMenuRow extends StatelessWidget {
  const _AnchoredMenuRow({required this.option});

  final AnchoredMenuOption option;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = option.onTap != null;
    final fg = !enabled
        ? colors.textDisabled
        : option.destructive
        ? colors.stateError
        : option.selected
        ? colors.primary
        : colors.textPrimary;
    final iconColor = !enabled
        ? colors.textDisabled
        : option.destructive
        ? colors.stateError
        : option.selected
        ? colors.primary
        : colors.textSecondary;
    final body = context.typography.body;
    final small = context.typography.small;
    return Row(
      children: [
        Icon(option.icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body.copyWith(
                  color: fg,
                  fontWeight: option.selected ? FontWeight.bold : null,
                ),
              ),
              if (option.hint != null)
                Text(
                  option.hint!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: small.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
        if (option.selected) ...[
          const SizedBox(width: 8),
          Icon(Icons.check, size: 20, color: colors.primary),
        ],
      ],
    );
  }
}
