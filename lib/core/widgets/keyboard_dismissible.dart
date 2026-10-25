import 'package:flutter/material.dart';

/// Dismisses the soft keyboard by unfocusing when the user taps outside a
/// focused field and/or when a descendant [Scrollable] starts scrolling.
///
/// Search + list screens should use [dismissOnScroll] on the list region so
/// dragging the list closes the keyboard even when list items absorb taps.
class KeyboardDismissible extends StatelessWidget {
  const KeyboardDismissible({
    super.key,
    required this.child,
    this.dismissOnTapOutside = true,
    this.dismissOnScroll = false,
  });

  final Widget child;
  final bool dismissOnTapOutside;
  final bool dismissOnScroll;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (dismissOnScroll) {
      result = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false;
        },
        child: result,
      );
    }

    if (!dismissOnTapOutside) {
      return result;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: result,
    );
  }
}
