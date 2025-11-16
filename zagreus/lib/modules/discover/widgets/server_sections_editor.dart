import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/server.dart';

class ServerSectionsEditor extends StatefulWidget {
  const ServerSectionsEditor({
    super.key,
    this.onHasChangesChanged,
  });

  final ValueChanged<bool>? onHasChangesChanged;

  @override
  ServerSectionsEditorState createState() => ServerSectionsEditorState();
}

class ServerSectionsEditorState extends State<ServerSectionsEditor> {
  static const List<String> _defaultSections = [
    'server_issues',
    'overseerr_requests',
    'disk_space',
    'download_history',
  ];

  static const Map<String, String> _sectionNames = {
    'server_issues': 'Server Issues',
    'overseerr_requests': 'Overseerr Requests',
    'disk_space': 'Disk Space',
    'download_history': 'Download History',
  };

  late List<String> _sections;
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  void _loadSectionOrder() {
    final savedOrder = ServerDatabase.SECTION_ORDER.read() as List;
    _sections = savedOrder.isNotEmpty
        ? List<String>.from(savedOrder)
        : List<String>.from(_defaultSections);
  }

  Future<void> saveChanges() async {
    if (!_hasChanges) {
      return;
    }
    ServerDatabase.SECTION_ORDER.update(_sections);
    setState(() => _hasChanges = false);
    widget.onHasChangesChanged?.call(_hasChanges);
    showZagInfoSnackBar(
      title: 'Section Order Saved',
      message: 'Server sections have been reordered',
    );
  }

  void resetToDefaults() {
    setState(() {
      _sections = List<String>.from(_defaultSections);
      _hasChanges = true;
    });
    widget.onHasChangesChanged?.call(_hasChanges);
  }

  void _setHasChanges() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
      widget.onHasChangesChanged?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _sections.isEmpty
              ? _emptySectionsPlaceholder()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _sections.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _sections.removeAt(oldIndex);
                      _sections.insert(newIndex, item);
                      _setHasChanges();
                    });
                  },
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    final name = _sectionNames[section] ?? section;
                    final theme = Theme.of(context);

                    return Container(
                      key: ValueKey(section),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? ZagColours.secondary
                            : ZagColours.secondaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getSectionIcon(section),
                          color: ZagColours.accentColor(context),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: 'Remove Section',
                              onPressed: () => _removeSection(section),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white30
                                    : Colors.black26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
          child: Column(
            children: [
              ZagButton.text(
                text: _availableSections().isEmpty
                    ? 'All Sections Added'
                    : 'Add Section',
                icon: _availableSections().isEmpty ? null : Icons.add_rounded,
                color: ZagColours.currentAccent,
                onTap: _availableSections().isEmpty
                    ? null
                    : _showAddSectionSheet,
              ),
              const SizedBox(height: 8),
              ZagButton.text(
                text: 'Reset to Defaults',
                icon: Icons.restart_alt_rounded,
                color: ZagColours.currentAccent,
                onTap: resetToDefaults,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptySectionsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dns_rounded,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white24
                  : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'No server sections are currently shown.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use the button below to add sections back.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _availableSections() {
    return _defaultSections
        .where((section) => !_sections.contains(section))
        .toList();
  }

  void _removeSection(String section) {
    setState(() {
      _sections.remove(section);
      _setHasChanges();
    });
  }

  void _showAddSectionSheet() {
    final available = _availableSections();

    if (available.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Add Section',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemBuilder: (context, index) {
                    final section = available[index];
                    final name = _sectionNames[section] ?? section;
                    return ListTile(
                      leading: Icon(
                        _getSectionIcon(section),
                        color: ZagColours.accentColor(context),
                      ),
                      title: Text(name),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          _sections.add(section);
                          _setHasChanges();
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: available.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'server_issues':
        return Icons.warning_rounded;
      case 'overseerr_requests':
        return Icons.movie_filter_rounded;
      case 'disk_space':
        return Icons.storage_rounded;
      case 'download_history':
        return Icons.history_rounded;
      default:
        return Icons.view_list_rounded;
    }
  }
}

Future<bool?> showServerSectionsEditorSheet(BuildContext context) {
  final editorKey = GlobalKey<ServerSectionsEditorState>();
  bool hasChanges = false;
  bool isSaving = false;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).canvasColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final mediaQuery = MediaQuery.of(sheetContext);
      final height = mediaQuery.size.height * 0.75;

      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> handleSave() async {
            if (!hasChanges || isSaving) return;
            final state = editorKey.currentState;
            if (state == null) return;
            setModalState(() => isSaving = true);
            await state.saveChanges();
            setModalState(() => isSaving = false);
            Navigator.of(sheetContext).pop(true);
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: mediaQuery.viewInsets.bottom,
              ),
              child: SizedBox(
                height: height,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(sheetContext).brightness == Brightness.dark
                                ? Colors.white24
                                : Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            'Server Sections',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.save_rounded),
                            tooltip: 'Save Order',
                            color: hasChanges
                                ? ZagColours.currentAccent
                                : Colors.grey,
                            onPressed:
                                (!hasChanges || isSaving) ? null : handleSave,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(false),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ServerSectionsEditor(
                        key: editorKey,
                        onHasChangesChanged: (value) =>
                            setModalState(() => hasChanges = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
