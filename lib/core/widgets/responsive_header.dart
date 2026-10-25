import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class ResponsiveHeader extends StatelessWidget {
  final Widget? title;
  final Widget? mobileFilterButton;
  final Widget? mobileSearchBar;
  final VoidCallback? onMobileFilterPressed;
  final bool showMobileFilter;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const ResponsiveHeader({
    super.key,
    this.title,
    this.mobileFilterButton,
    this.mobileSearchBar,
    this.onMobileFilterPressed,
    this.showMobileFilter = true,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              if (showBack) ...[
                IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (title != null)
                Expanded(
                  child: title is Text
                      ? DefaultTextStyle(
                          style: context.typography.pageTitle.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          child: title!,
                        )
                      : title!,
                ),
              if (showMobileFilter) ...[
                if (mobileSearchBar != null) ...[
                  Expanded(child: mobileSearchBar!),
                  const SizedBox(width: 12),
                ],
                _buildMobileFilterButton(context),
              ],
              if (actions != null) ...actions!,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilterButton(BuildContext context) {
    if (mobileFilterButton != null) {
      return mobileFilterButton!;
    }

    if (onMobileFilterPressed == null) return const SizedBox.shrink();

    return IconButton(
      onPressed: onMobileFilterPressed,
      icon: Icon(context.icons.filter, color: context.colors.primary),
      tooltip: 'Filtrar',
    );
  }
}
