import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class ModalDragHandle extends StatelessWidget {
  const ModalDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
