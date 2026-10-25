import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class GakokenCardTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isThreeLine;
  final EdgeInsetsGeometry? margin;
  final Color? cardColor;
  final List<Widget>? subtitleWidgets;

  const GakokenCardTile({
    super.key,
    this.leading,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isThreeLine = false,
    this.margin,
    this.cardColor,
    this.subtitleWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: cardColor ?? Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.borderSubtle, width: 1),
      ),
      elevation: 0,
      child: ListTile(
        leading: leading,
        title:
            titleWidget ??
            Text(
              title,
              style: context.typography.cardTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        subtitle: subtitleWidgets != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subtitleWidgets!,
              )
            : (subtitle != null ? Text(subtitle!) : null),
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        isThreeLine: isThreeLine,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }
}
