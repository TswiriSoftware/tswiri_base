import 'package:flutter/material.dart';
import 'package:tswiri_base/functions/capitalize_first_character.dart';
import 'package:tswiri_base/colors/colors.dart';
import 'package:tswiri_base/widgets/general/sunbird_filter_chip.dart';

class SearchBar extends StatefulWidget {
  ///Default Sunbird Search Bar.
  ///
  /// - ```filters```       => Active Filters.
  /// - ```filterTypes```   => All Possible Filters.
  /// - ```onFilterChange()```=> Filter Change.
  /// - ```onCancel()```    => Cancel Search.
  /// - ```onChanged()```   => TextField Change.
  /// - ```onSubmitted()``` => TextField Submitted.

  const SearchBar({
    Key? key,
    required this.filters,
    required this.filterTypes,
    required this.onFilterChange,
    required this.onCancel,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  ///Refernece to activeFilters;
  final List<String> filters;

  ///A list of filters to display.
  final List<String> filterTypes;

  ///On Filter change
  final void Function(String filter) onFilterChange;

  ///On Search Cancel.
  final void Function() onCancel;

  ///On value change.
  final void Function(String value) onChanged;

  ///On search submitted
  final void Function(String value) onSubmitted;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchNode = FocusNode();

  @override
  void initState() {
    _searchNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _searchController,
        focusNode: _searchNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
      actions: [
        IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(
            Icons.close_sharp,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 150),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // spacing: 5,
              children: widget.filterTypes
                  .map(
                    (filterType) => CustomFilterChip(
                      label: filterType,
                      toolTip: '',
                      selected: widget.filters.contains(filterType),
                      onSelected: (value) {
                        _onSelected(value, filterType);
                        widget.onFilterChange(_searchController.text);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelected(bool selected, String filter) {
    if (widget.filters.contains(filter)) {
      setState(() {
        widget.filters.removeWhere((element) => element == filter);
      });
    } else {
      setState(() {
        widget.filters.add(filter);
      });
    }
  }
}

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    Key? key,
    required this.filters,
    required this.filterTypes,
    required this.filterChange,
    required this.onCancel,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  ///Refernece to activeFilters;
  final List<String> filters;

  ///A list of filters to display.
  final List<String> filterTypes;

  ///On Filter change
  final void Function(String) filterChange;

  ///On Search Cancel.
  final void Function() onCancel;

  ///On value change.
  final void Function(String) onChanged;

  ///On search submitted
  final void Function(String) onSubmitted;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchNode = FocusNode();

  @override
  void initState() {
    _searchNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background[500],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const SizedBox(
                width: kMinInteractiveDimension / 2,
              ),
              Flexible(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchNode,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onCancel();
                  _searchController.clear();
                },
                icon: const Icon(
                  Icons.close_sharp,
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // spacing: 5,
                children: widget.filterTypes
                    .map(
                      (filterType) => CustomFilterChip(
                        label: filterType.capitalizeFirstCharacter(),
                        toolTip: '',
                        selected: widget.filters.contains(filterType),
                        onSelected: (value) {
                          _onSelected(value, filterType);
                          widget.filterChange(_searchController.text);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelected(bool selected, String filter) {
    if (widget.filters.contains(filter)) {
      setState(() {
        widget.filters.removeWhere((element) => element == filter);
      });
    } else {
      setState(() {
        widget.filters.add(filter);
      });
    }
  }
}
