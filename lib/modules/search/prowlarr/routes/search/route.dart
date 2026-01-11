import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search/prowlarr/core.dart';
import 'package:zagreus/modules/search/prowlarr/widgets/widgets.dart';
import 'package:zagreus/widgets/sheets/download_client/button.dart';

/// Prowlarr search page - search bar and results
class ProwlarrSearchPage extends StatefulWidget {
  final ProwlarrAPIWrapper apiWrapper;
  final ProwlarrState state;
  final int? categoryId;
  final String? categoryName;
  final String? initialQuery;
  final bool showSearchBar;

  const ProwlarrSearchPage({
    super.key,
    required this.apiWrapper,
    required this.state,
    this.categoryId,
    this.categoryName,
    this.initialQuery,
    this.showSearchBar = false,
  });

  @override
  State<ProwlarrSearchPage> createState() => _State();
}

class _State extends State<ProwlarrSearchPage> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _searchController;
  bool _hasSearched = false;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    // Show search bar if requested or if there's an initial query
    if (widget.showSearchBar ||
        (widget.initialQuery != null && widget.initialQuery!.isNotEmpty)) {
      _showSearchBar = true;
    }
    // Auto-load results if category is provided or initial query exists
    if (widget.categoryId != null ||
        (widget.initialQuery != null && widget.initialQuery!.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery ?? '');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Allow empty query if category is provided (loads all results for category)
    if (query.isEmpty && widget.categoryId == null) return;

    widget.state.setLoading(true);
    if (query.isNotEmpty) {
      widget.state.addSearchToHistory(query);
    }

    try {
      final results = await widget.apiWrapper.search(
        query,
        categoryId: widget.categoryId,
      );
      if (!mounted) return;
      widget.state.setSearchResults(results.cast<ProwlarrItem>());
      widget.state.clearError();
      setState(() => _hasSearched = true);
    } catch (e) {
      if (!mounted) return;
      widget.state.setError(e.toString());
    } finally {
      if (mounted) {
        widget.state.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProwlarrState>.value(
      value: widget.state,
      child: ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    String title = widget.categoryName ?? 'search.Search'.tr();
    return ZagAppBar(
      title: title,
      scrollControllers: [scrollController],
      bottom: _showSearchBar
          ? ProwlarrSearchBar(
              controller: _searchController,
              scrollController: scrollController,
              onSubmitted: _performSearch,
            )
          : null,
      actions: [
        Consumer<ProwlarrState>(
          builder: (context, state, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZagIconButton(
                  icon: _showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                    });
                  },
                ),
                if (state.searchResults.isNotEmpty) ...[
                  ZagIconButton(
                    icon: Icons.sort_rounded,
                    onPressed: () => _showSortSheet(context),
                  ),
                  ZagIconButton(
                    icon: Icons.filter_list_rounded,
                    onPressed: () => _showFilterSheet(context),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _body() {
    return Consumer<ProwlarrState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const ZagLoader();
        }

        if (state.error != null) {
          return ZagMessage.error(
            onTap: () => _performSearch(_searchController.text),
          );
        }

        if (!_hasSearched) {
          return Container();
        }

        final results = state.filteredAndSortedResults;

        if (results.isEmpty) {
          return ZagMessage(
            text: state.searchResults.isEmpty
                ? 'search.NoResultsFound'.tr()
                : 'search.NoResultsMatchFilters'.tr(),
            buttonText:
                state.filterConfig.hasActiveFilters
                    ? 'search.ClearFilters'.tr()
                    : null,
            onTap:
                state.filterConfig.hasActiveFilters ? state.clearFilters : null,
          );
        }

        return ZagListViewBuilder(
          controller: scrollController,
          itemCount: results.length,
          // Only build items actually visible on screen
          cacheExtent: 0,
          itemBuilder: (context, index) {
            final item = results[index];
            return ProwlarrResultTile(item: item);
          },
        );
      },
    );
  }

  void _showSortSheet(BuildContext context) {
    final backgroundColor = ZagTheme.themeMode == 'light'
        ? ZagColours.primaryLight
        : (ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Provide state to the sheet since it's in a new overlay context
        return ChangeNotifierProvider<ProwlarrState>.value(
          value: widget.state,
          child: Consumer<ProwlarrState>(
            builder: (context, state, _) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'search.SortBy'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ...ProwlarrSortOption.values.map((option) {
                      final isSelected = state.sortOption == option;
                      return ListTile(
                        leading: Icon(
                          option.icon,
                          color: isSelected
                              ? ZagColours.accentColor(context)
                              : null,
                        ),
                        title: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected
                                ? ZagColours.accentColor(context)
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: ZagColours.accentColor(context),
                              )
                            : null,
                        onTap: () {
                          state.setSortOption(option);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final backgroundColor = ZagTheme.themeMode == 'light'
        ? ZagColours.primaryLight
        : (ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Provide state to the sheet since it's in a new overlay context
        return ChangeNotifierProvider<ProwlarrState>.value(
          value: widget.state,
          child: Consumer<ProwlarrState>(
            builder: (context, state, _) {
              return DraggableScrollableSheet(
                expand: false,
                maxChildSize: 0.85,
                initialChildSize: 0.85,
                minChildSize: 0.5,
                builder: (context, scrollController) {
                  return ProwlarrFilterSheetContent(
                    scrollController: scrollController,
                    state: state,
                    onClose: () => Navigator.of(sheetContext).pop(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Search bar widget for Prowlarr
class ProwlarrSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final Function(String) onSubmitted;

  const ProwlarrSearchBar({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: ZagTextInputBar(
        controller: controller,
        scrollController: scrollController,
        autofocus: true,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Filter sheet content widget
class ProwlarrFilterSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final ProwlarrState state;
  final VoidCallback onClose;

  const ProwlarrFilterSheetContent({
    super.key,
    required this.scrollController,
    required this.state,
    required this.onClose,
  });

  @override
  State<ProwlarrFilterSheetContent> createState() =>
      _ProwlarrFilterSheetContentState();
}

class _ProwlarrFilterSheetContentState
    extends State<ProwlarrFilterSheetContent> {
  late Set<String> _selectedIndexers;
  late RangeValues _sizeRange;
  late RangeValues _grabsRange;
  late ProwlarrProtocolFilter _protocol;
  late double _maxSizeGB;
  late int _maxGrabs;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    final config = widget.state.filterConfig;
    _selectedIndexers = Set.from(config.selectedIndexers);
    _searchQuery = config.searchQuery;

    // Get dynamic max values from search results
    _maxSizeGB = widget.state.maxSizeInResults;
    _maxGrabs = widget.state.maxGrabsInResults;

    // Clamp existing filter values to actual data range
    _sizeRange = RangeValues(
      config.minSizeGB.clamp(0, _maxSizeGB),
      config.maxSizeGB >= ProwlarrFilterConfig.maxSizeValue
          ? _maxSizeGB
          : config.maxSizeGB.clamp(0, _maxSizeGB),
    );
    _grabsRange = RangeValues(
      config.minGrabs.toDouble().clamp(0, _maxGrabs.toDouble()),
      config.maxGrabs >= ProwlarrFilterConfig.maxGrabsValue
          ? _maxGrabs.toDouble()
          : config.maxGrabs.toDouble().clamp(0, _maxGrabs.toDouble()),
    );
    _protocol = config.protocol;
  }

  void _updateFilters() {
    widget.state.setFilterConfig(
      ProwlarrFilterConfig(
        selectedIndexers: _selectedIndexers,
        minSizeGB: _sizeRange.start,
        maxSizeGB: _sizeRange.end,
        minGrabs: _grabsRange.start.toInt(),
        maxGrabs: _grabsRange.end.toInt(),
        protocol: _protocol,
        searchQuery: _searchQuery,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedIndexers.clear();
      _sizeRange = RangeValues(0, _maxSizeGB);
      _grabsRange = RangeValues(0, _maxGrabs.toDouble());
      _protocol = ProwlarrProtocolFilter.all;
      _searchQuery = '';
    });
    _updateFilters();
  }

  void _showIndexerMultiSelect(BuildContext context, List<String> availableIndexers, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'search.Indexer'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _selectedIndexers.clear();
                            _selectedIndexers.addAll(availableIndexers);
                          });
                          setState(() {});
                          _updateFilters();
                        },
                        child: Text(
                          'search.All'.tr(),
                          style: TextStyle(color: accentColor),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableIndexers.length,
                      itemBuilder: (ctx, index) {
                        final indexer = availableIndexers[index];
                        final isSelected = _selectedIndexers.contains(indexer);
                        return ListTile(
                          title: Text(indexer),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: accentColor)
                              : Icon(Icons.circle_outlined, color: Colors.grey[600]),
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                _selectedIndexers.remove(indexer);
                              } else {
                                _selectedIndexers.add(indexer);
                              }
                            });
                            setState(() {});
                            _updateFilters();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSearchDialog() async {
    final textController = TextEditingController(text: _searchQuery);
    final formKey = GlobalKey<FormState>();
    bool confirmed = false;

    void submit() {
      confirmed = true;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'search.SearchResults'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Ok'.tr(),
          onPressed: submit,
        ),
      ],
      content: [
        Form(
          key: formKey,
          child: ZagDialog.textFormInput(
            controller: textController,
            title: 'search.SearchResults'.tr(),
            onSubmitted: (_) => submit(),
            validator: (_) => null,
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );

    if (confirmed) {
      setState(() {
        _searchQuery = textController.text;
      });
      _updateFilters();
    }
  }

  String _formatSizeLabel(double value, {bool isMax = false}) {
    final label = value.toInt().toString();
    return 'search.SizeGB'.tr(args: [label]);
  }

  String _formatGrabsLabel(int value, {bool isMax = false}) {
    final label = value.toString();
    return 'search.GrabsCount'.tr(args: [label]);
  }

  String _protocolLabel(ProwlarrProtocolFilter protocol) {
    switch (protocol) {
      case ProwlarrProtocolFilter.usenet:
        return 'search.Usenet'.tr();
      case ProwlarrProtocolFilter.torrent:
        return 'search.Torrent'.tr();
      case ProwlarrProtocolFilter.all:
      default:
        return 'search.All'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableIndexers = widget.state.availableIndexers.toList()..sort();
    final accentColor = ZagColours.accentColor(context);
    final filteredCount = widget.state.searchResults.length -
        widget.state.filteredAndSortedResults.length;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'search.ItemsFiltered'.tr(
                    args: [filteredCount.toString()],
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Size Range Slider
                Text(
                  'search.Size'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: accentColor.withValues(alpha: 0.3),
                    thumbColor: accentColor,
                    overlayColor: accentColor.withValues(alpha: 0.2),
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: RangeSlider(
                    values: _sizeRange,
                    min: 0,
                    max: _maxSizeGB,
                    divisions: _maxSizeGB.toInt().clamp(1, 100),
                    onChanged: (values) {
                      setState(() => _sizeRange = values);
                    },
                    onChangeEnd: (_) => _updateFilters(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'search.MinLabel'.tr(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      _formatSizeLabel(_sizeRange.start),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'search.MaxLabel'.tr(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      _formatSizeLabel(_sizeRange.end, isMax: true),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grabs Range Slider
                Text(
                  'search.Grabs'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: accentColor.withValues(alpha: 0.3),
                    thumbColor: accentColor,
                    overlayColor: accentColor.withValues(alpha: 0.2),
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: RangeSlider(
                    values: _grabsRange,
                    min: 0,
                    max: _maxGrabs.toDouble(),
                    divisions: _maxGrabs.clamp(1, 100),
                    onChanged: (values) {
                      setState(() => _grabsRange = values);
                    },
                    onChangeEnd: (_) => _updateFilters(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'search.MinLabel'.tr(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      _formatGrabsLabel(_grabsRange.start.toInt()),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'search.MaxLabel'.tr(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      _formatGrabsLabel(_grabsRange.end.toInt(), isMax: true),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Protocol Segmented Button
                Text(
                  'search.Protocol'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: ProwlarrProtocolFilter.values.map((protocol) {
                      final isSelected = _protocol == protocol;
                      final label = _protocolLabel(protocol);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _protocol = protocol);
                            _updateFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor : Colors.transparent,
                              borderRadius: BorderRadius.horizontal(
                                left: protocol == ProwlarrProtocolFilter.all
                                    ? const Radius.circular(7)
                                    : Radius.zero,
                                right: protocol == ProwlarrProtocolFilter.torrent
                                    ? const Radius.circular(7)
                                    : Radius.zero,
                              ),
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Indexer Dropdown
                Text(
                  'search.Indexer'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (availableIndexers.isEmpty)
                  Text(
                    'search.NoIndexersAvailable'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  InkWell(
                    onTap: () => _showIndexerMultiSelect(context, availableIndexers, accentColor),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedIndexers.isEmpty || _selectedIndexers.length == availableIndexers.length
                                  ? 'search.All'.tr()
                                  : 'search.SelectedCount'.tr(
                                      args: [_selectedIndexers.length.toString()],
                                    ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZagColours.red,
                  side: BorderSide(color: ZagColours.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'search.ClearFilters'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showSearchDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZagColours.textColor(context),
                  side: BorderSide(color: Colors.grey[600]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'search.SearchResults'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _searchQuery,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
