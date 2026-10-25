import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../../l10n/app_localizations.dart';

class GakokenAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;

  /// Ancho de [leading] cuando no cabe en el de un solo botón.
  final double? leadingWidth;
  final List<Widget>? actions;
  final bool isSearchable;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onSearchClosed;
  final VoidCallback? onFilterPressed;
  final int filterBadgeCount;
  final bool isRootScreen;

  const GakokenAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.leadingWidth,
    this.actions,
    this.isSearchable = false,
    this.isRootScreen = false,
    this.onSearch,
    this.onSearchClosed,
    this.onFilterPressed,
    this.filterBadgeCount = 0,
  }) : assert(
         title != null || titleWidget != null,
         'Title or titleWidget must be provided',
       );

  @override
  State<GakokenAppBar> createState() => _GakokenAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GakokenAppBarState extends State<GakokenAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _focusNode.requestFocus();
  }

  void _stopSearch() {
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    widget.onSearch?.call('');
    widget.onSearchClosed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: context.colors.bgPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: _isSearching ? null : widget.leadingWidth,
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildLeading(context),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _buildTitle(context),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Row(
            key: ValueKey<bool>(_isSearching),
            mainAxisSize: MainAxisSize.min,
            children: _buildActions(context),
          ),
        ),
        const SizedBox(width: 4),
      ],
      iconTheme: IconThemeData(color: context.colors.textPrimary),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (_isSearching) {
      return IconButton(
        key: const ValueKey('back_search'),
        icon: const Icon(Icons.arrow_back),
        onPressed: _stopSearch,
        color: context.colors.textPrimary,
      );
    }

    if (widget.leading != null) {
      return KeyedSubtree(
        key: const ValueKey('custom_leading'),
        child: widget.leading!,
      );
    }

    if (widget.isRootScreen) {
      return const SizedBox.shrink(key: ValueKey('empty_root'));
    }

    if (Navigator.of(context).canPop()) {
      return IconButton(
        key: const ValueKey('back_nav'),
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
        color: context.colors.textPrimary,
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Widget _buildTitle(BuildContext context) {
    if (_isSearching) {
      return TextField(
        key: const ValueKey('search_field'),
        controller: _searchController,
        focusNode: _focusNode,
        style: context.typography.body,
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context)?.searchPlaceholder ?? 'Search...',
          hintStyle: context.typography.body.copyWith(
            color: context.colors.textSecondary.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onSearch,
        onTapOutside: (_) => _stopSearch(),
      );
    }

    Widget titleChild;
    if (widget.titleWidget != null) {
      titleChild = KeyedSubtree(
        key: const ValueKey('custom_title'),
        child: widget.titleWidget!,
      );
    } else {
      titleChild = Text(
        widget.title!,
        key: const ValueKey('app_title'),
        style: context.typography.pageTitle.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (widget.isRootScreen) {
      return TweenAnimationBuilder<double>(
        key: ValueKey('root_title_${widget.title ?? 'custom'}'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0.0, 15.0 * (1.0 - value)),
              child: child,
            ),
          );
        },
        child: titleChild,
      );
    }

    return titleChild;
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _searchController.clear();
            widget.onSearch?.call('');
          },
          color: context.colors.textSecondary,
        ),
      ];
    }

    final List<Widget> finalActions = [];

    if (widget.isSearchable) {
      finalActions.add(
        IconButton(
          icon: Icon(context.icons.search),
          onPressed: _startSearch,
          color: context.colors.textPrimary,
        ),
      );
    }

    if (widget.onFilterPressed != null) {
      final filterIcon = Icon(
        context.icons.filter,
        color: context.colors.textPrimary,
      );
      finalActions.add(
        IconButton(
          onPressed: widget.onFilterPressed,
          color: context.colors.textPrimary,
          icon: widget.filterBadgeCount > 0
              ? Badge(
                  label: Text(
                    widget.filterBadgeCount > 99
                        ? '99+'
                        : '${widget.filterBadgeCount}',
                  ),
                  child: filterIcon,
                )
              : filterIcon,
        ),
      );
    }

    if (widget.actions != null) {
      finalActions.addAll(widget.actions!);
    }

    return finalActions;
  }
}
