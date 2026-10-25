import 'package:flutter/material.dart';
import '../exceptions/gakoken_exception.dart';
import '../theme/theme_extensions.dart';

class ScaffoldMessengerService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    final state = messengerKey.currentState;
    if (state == null) return;
    final context = state.context;
    state.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Aviso neutro, sin prefijo de error.
  static void showInfo(String message) {
    messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Aviso con un botón (por ejemplo Deshacer) y, si se da, otro antes que
  /// él (por ejemplo Ver papelera).
  static void showWithAction(
    String message, {
    required String action,
    required VoidCallback onAction,
    String? secondAction,
    VoidCallback? onSecondAction,
  }) {
    final state = messengerKey.currentState;
    if (state == null) return;
    final scheme = Theme.of(state.context).colorScheme;
    final second = secondAction != null && onSecondAction != null
        ? TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(state.context).snackBarTheme.actionTextColor ??
                  scheme.inversePrimary,
            ),
            onPressed: () {
              state.hideCurrentSnackBar();
              onSecondAction();
            },
            child: Text(secondAction),
          )
        : null;
    state
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: second == null
              ? Text(message)
              : Row(
                  children: [
                    Expanded(child: Text(message)),
                    second,
                  ],
                ),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(label: action, onPressed: onAction),
        ),
      );
  }

  static void showException(dynamic e) {
    final state = messengerKey.currentState;
    if (state == null) return;
    final context = state.context;
    final isWarning = e is GakokenException && e.isWarning;
    state.showSnackBar(
      SnackBar(
        content: Text('${isWarning ? 'Atención: ' : 'Error: '}${e.toString()}'),
        backgroundColor: isWarning
            ? context.colors.stateWarning
            : context.colors.stateError,
      ),
    );
  }
}
