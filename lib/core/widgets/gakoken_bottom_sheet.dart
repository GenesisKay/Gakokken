import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Extra bottom space so modal-sheet actions sit above the Android 3-button
/// / gesture navigation bar and the keyboard.
///
/// Gakoken runs [SystemUiMode.edgeToEdge]. Inside a [ModalBottomSheetRoute],
/// [MediaQuery.padding] is often 0 while [MediaQuery.viewPadding] still has
/// the system inset. Wrapping a min-height sheet in [SafeArea] shrinks the
/// child *inside* the sheet's intrinsic height and clips the last buttons —
/// add this inset as padding so the sheet **grows** instead.
double gakokenSheetBottomInset(BuildContext context) {
  final mq = MediaQuery.of(context);
  final navBar = mq.viewPadding.bottom > mq.padding.bottom
      ? mq.viewPadding.bottom
      : mq.padding.bottom;
  final keyboard = mq.viewInsets.bottom;
  return navBar > keyboard ? navBar : keyboard;
}

/// Pads [child] with [padding] plus [gakokenSheetBottomInset].
///
/// Use as the root of every `showModalBottomSheet` builder. Set [scrollable]
/// on compact (min-height) sheets so large text / small phones can scroll
/// instead of clipping. Do not set it on sheets that use [Expanded].
class GakokenSheetInset extends StatelessWidget {
  const GakokenSheetInset({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.scrollable = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: padding.copyWith(
        bottom: padding.bottom + gakokenSheetBottomInset(context),
      ),
      child: child,
    );
    if (!scrollable) return padded;
    return SingleChildScrollView(child: padded);
  }
}

/// [showModalBottomSheet] with defaults that avoid nav-bar clipping:
/// [isScrollControlled] so content + inset can exceed 9/16 of the screen.
Future<T?> showGakokenBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool showDragHandle = true,
  bool isScrollControlled = true,
  bool useSafeArea = false,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor ?? context.colors.bgPrimary,
    shape: shape,
    builder: builder,
  );
}
