part of '../multi_dropdown.dart';

/// Dropdown widget for the multiselect dropdown.
///
class _Dropdown<T> extends StatelessWidget {
  /// Creates a dropdown widget.
  const _Dropdown({
    required this.decoration,
    required this.width,
    required this.searchEnabled,
    required this.dropdownItemDecoration,
    required this.searchDecoration,
    required this.maxSelections,
    required this.items,
    required this.onItemTap,
    required this.searchOnReturnClicked,
    required this.searchReadOnly,
    required this.searchShowCursor,
    required this.searchMaxLengthEnforcement,
    Key? key,
    this.onSearchFieldTap,
    this.searchKeyboardType,
    this.searchController,
    this.onSearchChange,
    this.itemBuilder,
    this.itemSeparator,
    this.singleSelect = false,
    this.searchTextStyle,
  }) : super(key: key);

  /// The decoration of the dropdown.
  final DropdownDecoration decoration;

  /// Whether the search field is enabled.
  final bool searchEnabled;

  /// The width of the dropdown.
  final double width;

  /// The decoration of the dropdown items.
  final DropdownItemDecoration dropdownItemDecoration;

  /// Dropdown item builder, if not provided, the default ListTile will be used.
  final DropdownItemBuilder<T>? itemBuilder;

  /// The separator between the dropdown items.
  final Widget? itemSeparator;

  /// The decoration of the search field.
  final SearchFieldDecoration searchDecoration;

  /// The maximum number of selections allowed.
  final int maxSelections;

  /// The list of dropdown items.
  final List<DropdownItem<T>> items;

  /// The callback when an item is tapped.
  final ValueChanged<DropdownItem<T>> onItemTap;

  /// The callback when the search field value changes.
  final ValueChanged<String>? onSearchChange;

  /// Whether the selection is single.
  final bool singleSelect;

  /// The callback when the search field is tapped.
  final VoidCallback? onSearchFieldTap;

  /// The keyboard type of the search field.
  final TextInputType? searchKeyboardType;

  /// The controller of the search field.
  final TextEditingController? searchController;

  /// The text style of the search field.
  final TextStyle? searchTextStyle;

  /// The callback when the return key is clicked.
  final dynamic Function()? searchOnReturnClicked;

  /// The read only of the search field.
  final bool searchReadOnly;

  /// The show cursor of the search field.
  final bool searchShowCursor;

  /// The max length enforcement of the search field.
  final MaxLengthEnforcement? searchMaxLengthEnforcement;

  /// The max length enforcement of the search field.
  int get _selectedCount => items.where((element) => element.selected).length;

  static const Map<ShortcutActivator, Intent> _webShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Material(
      elevation: decoration.elevation,
      borderRadius: decoration.borderRadius,
      clipBehavior: Clip.antiAlias,
      color: decoration.backgroundColor,
      surfaceTintColor: decoration.backgroundColor,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: decoration.borderRadius,
            color: decoration.backgroundColor,
            backgroundBlendMode: BlendMode.dstATop,
          ),
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: decoration.maxHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (searchEnabled)
                _SearchField(
                  decoration: searchDecoration,
                  onChanged: _onSearchChange,
                  onTap: onSearchFieldTap,
                  keyboardType: searchKeyboardType,
                  controller: searchController,
                  textStyle: searchTextStyle,
                  onReturnClicked: searchOnReturnClicked,
                  readOnly: searchReadOnly,
                  showCursor: searchShowCursor,
                  maxLengthEnforcement: searchMaxLengthEnforcement,
                ),
              if (decoration.header != null) Flexible(child: decoration.header!),
              Flexible(
                child: ListView.separated(
                  separatorBuilder: (_, __) => itemSeparator ?? const SizedBox.shrink(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, int index) => _buildOption(index, theme),
                ),
              ),
              if (items.isEmpty && searchEnabled)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No items found',
                    textAlign: TextAlign.center,
                    style: searchTextStyle?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              if (decoration.footer != null) Flexible(child: decoration.footer!),
            ],
          ),
        ),
      ),
    );

    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return Shortcuts(shortcuts: _webShortcuts, child: child);
    }

    return child;
  }

  Widget _buildOption(int index, ThemeData theme) {
    final option = items[index];

    if (itemBuilder != null) {
      return itemBuilder!(option, index, () => onItemTap(option));
    }

    final disabledColor = dropdownItemDecoration.disabledBackgroundColor ?? dropdownItemDecoration.backgroundColor?.withAlpha(100);

    final tileColor = option.disabled
        ? disabledColor
        : option.selected
            ? dropdownItemDecoration.selectedBackgroundColor
            : dropdownItemDecoration.backgroundColor;

    final trailing = option.disabled
        ? dropdownItemDecoration.disabledIcon
        : option.selected
            ? dropdownItemDecoration.selectedIcon
            : null;

    return Ink(
      child: ListTile(
        title: Text(option.label),
        trailing: trailing,
        dense: true,
        autofocus: true,
        enabled: !option.disabled,
        selected: option.selected,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        focusColor: dropdownItemDecoration.backgroundColor?.withAlpha(100),
        selectedColor: dropdownItemDecoration.selectedTextColor ?? theme.colorScheme.onSurface,
        textColor: dropdownItemDecoration.textColor ?? theme.colorScheme.onSurface,
        tileColor: tileColor ?? Colors.transparent,
        selectedTileColor: dropdownItemDecoration.selectedBackgroundColor ?? Colors.grey.shade200,
        onTap: () {
          if (option.disabled) return;

          if (singleSelect || !_reachedMaxSelection(option)) {
            onItemTap(option);
            return;
          }
        },
      ),
    );
  }

  void _onSearchChange(String value) => onSearchChange?.call(value);

  bool _reachedMaxSelection(DropdownItem<dynamic> option) {
    return !option.selected && maxSelections > 0 && _selectedCount >= maxSelections;
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.decoration,
    required this.onChanged,
    this.onTap,
    this.keyboardType,
    this.controller,
    this.textStyle,
    this.onReturnClicked,
    this.readOnly = false,
    this.showCursor = true,
    this.maxLengthEnforcement,
  });

  final SearchFieldDecoration decoration;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final dynamic Function()? onReturnClicked;
  final bool readOnly;
  final bool showCursor;
  final MaxLengthEnforcement? maxLengthEnforcement;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();

    // Listen to controller changes
    _controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (_controller.text != widget.onChanged) {
      widget.onChanged(_controller.text);
    }
  }

  @override
  void didUpdateWidget(_SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if it changed externally
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChange);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.decoration.hintText,
          border: widget.decoration.border,
          focusedBorder: widget.decoration.focusedBorder,
          suffixIcon: widget.decoration.searchIcon,
          suffixIconColor: widget.textStyle?.color,
          hintStyle: widget.textStyle?.copyWith(color: widget.textStyle?.color?.withOpacity(0.8)),
        ),
        onChanged: (value) {
          widget.onChanged(value);
        },
        onTap: () {
          widget.onTap?.call();
          _focusNode.requestFocus();
        },
        keyboardType: widget.keyboardType,
        style: widget.textStyle,
        readOnly: widget.readOnly,
        showCursor: widget.showCursor,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        onSubmitted: (_) => widget.onReturnClicked?.call(),
        // Add these properties to better handle external input
        enableInteractiveSelection: true,
        autocorrect: false,
      ),
    );
  }
}
