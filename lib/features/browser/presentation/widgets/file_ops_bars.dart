import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_format.dart';
import '../../../../core/services/file_ops_service.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Contenedor común de las barras de abajo de Explorar.
class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.bgElevated,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      // En las pantallas que se abren encima (Papelera, archivos de un tipo)
      // no hay barra inferior: el fondo llega al borde y los botones quedan
      // arriba de la barra de gestos del sistema. En las pestañas no cambia
      // nada, porque la barra inferior ya ocupa ese espacio.
      child: SafeArea(top: false, left: false, right: false, child: child),
    );
  }
}

class SelectionAction {
  const SelectionAction(this.icon, this.label, this.onTap) : menu = null;

  /// Abre un menú pegado al botón, como el de la ruta del título, en vez de
  /// una hoja desde abajo (pedido el 2026-11-13). Sin opciones se muestra
  /// desactivada.
  const SelectionAction.menu(this.icon, this.label, List<SelectionAction> items)
    : menu = items,
      onTap = null;

  final IconData icon;
  final String label;

  /// null la muestra desactivada.
  final VoidCallback? onTap;

  /// Opciones del menú; cada una con su ícono, texto y acción.
  final List<SelectionAction>? menu;

  bool get enabled => onTap != null || (menu?.isNotEmpty ?? false);
}

/// Abre el menú de [action] pegado a [button]: sale hacia arriba, porque la
/// barra está abajo, y alineado al lado del botón más cercano al borde.
Future<void> _openSelectionMenu(
  BuildContext button,
  SelectionAction action,
) async {
  final colors = button.colors;
  final items = action.menu!;
  final box = button.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(button).context.findRenderObject()! as RenderBox;
  final rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  // Alto de cada opción del menú más su relleno de arriba y abajo.
  final height = items.length * kMinInteractiveDimension + 16;
  final chosen = await showMenu<VoidCallback>(
    context: button,
    position: RelativeRect.fromLTRB(
      rect.left,
      rect.top - height - 4,
      overlay.size.width - rect.right,
      overlay.size.height - rect.top,
    ),
    color: colors.bgElevated,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
    items: [
      for (final item in items)
        PopupMenuItem(
          value: item.onTap,
          enabled: item.onTap != null,
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: button.typography.body.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
  // El menú se cierra antes de la acción: las acciones usan el contexto de
  // la pantalla, no el del menú.
  chosen?.call();
}

/// Acciones sobre lo seleccionado: copiar, cortar, compartir, renombrar,
/// eliminar y más.
class SelectionBar extends StatefulWidget {
  const SelectionBar({super.key, required this.actions});

  final List<SelectionAction> actions;

  @override
  State<SelectionBar> createState() => _SelectionBarState();
}

class _SelectionBarState extends State<SelectionBar> {
  @override
  void initState() {
    super.initState();
    // El aviso de abajo (por ejemplo "Movido a la papelera" con Deshacer)
    // tapa esta barra. Al empezar a seleccionar se cierra para que las
    // acciones queden a la vista (pedido el 2026-11-12).
    ScaffoldMessengerService.messengerKey.currentState?.hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Bar(
      child: Row(
        children: [
          for (final action in widget.actions)
            Expanded(
              child: Builder(
                builder: (button) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: action.menu != null
                      ? (action.enabled
                            ? () => _openSelectionMenu(button, action)
                            : null)
                      : action.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          action.icon,
                          color: action.enabled
                              ? colors.textPrimary
                              : colors.textDisabled,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.small.copyWith(
                            color: action.enabled
                                ? colors.textSecondary
                                : colors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lo que está en el portapapeles, con Pegar aquí. Sirve en cualquier
/// pestaña y carpeta. Nueva carpeta está arriba, siempre a la vista.
class PasteBar extends StatelessWidget {
  const PasteBar({super.key, required this.onPaste});

  final VoidCallback? onPaste;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ops = FileOpsService();
    final count = ops.clipboard.length;
    return _Bar(
      child: Row(
        children: [
          Icon(
            ops.clipboardMode == ClipboardMode.cut
                ? Icons.content_cut_rounded
                : Icons.content_copy_rounded,
            color: context.colors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ops.clipboardMode == ClipboardMode.cut
                  ? l10n.clipboardCut(count)
                  : l10n.clipboardCopied(count),
              style: context.typography.body,
            ),
          ),
          TextButton(
            onPressed: ops.clearClipboard,
            child: Text(l10n.btnCancel),
          ),
          FilledButton(onPressed: onPaste, child: Text(l10n.pasteHere)),
        ],
      ),
    );
  }
}

/// Progreso de la tarea de copiar o mover, con Cancelar.
class JobPanel extends StatelessWidget {
  const JobPanel({super.key, required this.job});

  final FileJob job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final progress = job.progress;
    final done = (progress?.doneItems ?? 0) + 1;
    final title = job.isMove
        ? l10n.jobMoving(done.clamp(1, job.total), job.total)
        : l10n.jobCopying(done.clamp(1, job.total), job.total);
    final detail = progress == null
        ? ''
        : '${progress.current} · ${formatBytes(progress.doneBytes, locale)} / '
              '${formatBytes(progress.totalBytes, locale)}';
    final percent = NumberFormat.percentPattern(locale).format(job.fraction);

    return _Bar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(percent, style: context.typography.small),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: job.fraction,
                      minHeight: 6,
                      color: colors.primary,
                      backgroundColor: colors.surfaceHover,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: FileOpsService().cancel,
              child: Text(l10n.btnCancel),
            ),
          ],
        ),
      ),
    );
  }
}
