import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/widgets/ui/colors.dart';

class ZagDialogs {
  /// Show an an edit text prompt.
  ///
  /// Can pass in [prefill] String to prefill the [TextFormField]. Can also pass in a list of [TextSpan] tp show text above the field.
  ///
  /// Returns list containing:
  /// - 0: Flag (true if they hit save, false if they cancelled the prompt)
  /// - 1: Value from the [TextEditingController].
  Future<Tuple2<bool, String>> editText(
      BuildContext context, String dialogTitle,
      {String prefill = '', List<TextSpan>? extraText}) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState?.validate() ?? false) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: dialogTitle,
      buttons: [
        ZagDialog.button(
          text: 'Save',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        if (extraText?.isNotEmpty ?? false)
          ZagDialog.richText(children: extraText),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: dialogTitle,
            onSubmitted: (_) => _setValues(true),
            validator: (_) => null,
          ),
        ),
      ],
      contentPadding: (extraText?.length ?? 0) == 0
          ? ZagDialog.inputDialogContentPadding()
          : ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  /// Show a text preview dialog.
  ///
  /// Can pass in boolean [alignLeft] to left align the text in the dialog (useful for bulleted lists)
  Future<void> textPreview(
      BuildContext context, String? dialogTitle, String text,
      {bool alignLeft = false}) async {
    await ZagDialog.dialog(
      context: context,
      title: dialogTitle,
      cancelButtonText: 'Close',
      buttons: [
        ZagDialog.button(
            text: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              showZagSuccessSnackBar(
                  title: 'Copied Content',
                  message: 'Copied text to the clipboard');
              Navigator.of(context, rootNavigator: true).pop();
            }),
      ],
      content: [
        ZagDialog.textContent(
          text: text,
          textAlign: alignLeft ? TextAlign.start : TextAlign.center,
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
  }

  /// Show a text preview dialog with Add button instead of Copy.
  ///
  /// Used for adding media items to Radarr/Sonarr with saved settings.
  /// If [onSettings] is provided, a tune icon will be shown in the lower left
  /// corner to configure quick add settings.
  Future<void> textPreviewWithAdd(
      BuildContext context, String? dialogTitle, String text,
      {required VoidCallback onAdd,
      VoidCallback? onSettings,
      bool alignLeft = false,
      // Inline quick add options
      String? rootFolderValue,
      String? qualityProfileValue,
      String? seriesTypeValue,
      Future<List<String>> Function()? getRootFolders,
      Future<List<({int id, String name})>> Function()? getQualityProfiles,
      List<String>? seriesTypes,
      void Function(String path)? onRootFolderChanged,
      void Function(int id, String name)? onQualityProfileChanged,
      void Function(String type)? onSeriesTypeChanged,
      // Seasons support (Sonarr)
      List<({int seasonNumber, int episodeCount})>? seasons,
      Set<int>? selectedSeasons,
      void Function(Set<int> seasons)? onSeasonsChanged,
      }) async {
    final hasInlineOptions = getRootFolders != null && getQualityProfiles != null;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => _QuickAddDialog(
        title: dialogTitle,
        text: text,
        alignLeft: alignLeft,
        onAdd: onAdd,
        onSettings: onSettings,
        hasInlineOptions: hasInlineOptions,
        rootFolderValue: rootFolderValue,
        qualityProfileValue: qualityProfileValue,
        seriesTypeValue: seriesTypeValue,
        getRootFolders: getRootFolders,
        getQualityProfiles: getQualityProfiles,
        seriesTypes: seriesTypes,
        onRootFolderChanged: onRootFolderChanged,
        onQualityProfileChanged: onQualityProfileChanged,
        onSeriesTypeChanged: onSeriesTypeChanged,
        seasons: seasons,
        selectedSeasons: selectedSeasons,
        onSeasonsChanged: onSeasonsChanged,
      ),
    );
  }

  Future<void> showRejections(
      BuildContext context, List<String> rejections) async {
    if (rejections.isEmpty)
      return textPreview(
        context,
        'Rejection Reasons',
        'No rejections found',
      );

    await ZagDialog.dialog(
      context: context,
      title: 'Rejection Reasons',
      cancelButtonText: 'Close',
      content: List.generate(
        rejections.length,
        (index) => ZagDialog.tile(
          text: rejections[index],
          icon: Icons.report_outlined,
          iconColor: ZagColours.red,
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> showMessages(BuildContext context, List<String> messages) async {
    if (messages.isEmpty) {
      return textPreview(context, 'Messages', 'No messages found');
    }
    await ZagDialog.dialog(
      context: context,
      title: 'Messages',
      cancelButtonText: 'Close',
      content: List.generate(
        messages.length,
        (index) => ZagDialog.tile(
          text: messages[index],
          icon: Icons.info_outline_rounded,
          iconColor: ZagColours.currentAccent,
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  /// **Will be removed in future**
  ///
  /// Show a delete catalogue with all files warning dialog.
  Future<List<dynamic>> deleteCatalogueWithFiles(
      BuildContext context, String moduleTitle) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Delete All Files',
      buttons: [
        ZagDialog.button(
          text: 'Delete',
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text:
                'Are you sure you want to delete all the files and folders for $moduleTitle?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  Future<ZagModule?> selectDownloadClient() async {
    final profile = ZagProfile.current;
    final context = ZagState.context;
    ZagModule? module;

    await ZagDialog.dialog(
      context: context,
      title: 'zagreus.DownloadClient'.tr(),
      content: [
        if (profile.nzbgetEnabled)
          ZagDialog.tile(
            text: ZagModule.NZBGET.title,
            icon: ZagModule.NZBGET.icon,
            iconColor: ZagModule.NZBGET.color,
            onTap: () {
              module = ZagModule.NZBGET;
              Navigator.of(context).pop();
            },
          ),
        if (profile.sabnzbdEnabled)
          ZagDialog.tile(
            text: ZagModule.SABNZBD.title,
            icon: ZagModule.SABNZBD.icon,
            iconColor: ZagModule.SABNZBD.color,
            onTap: () {
              module = ZagModule.SABNZBD;
              Navigator.of(context).pop();
            },
          ),
      ],
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    return module;
  }
}

class _QuickAddDialog extends StatefulWidget {
  final String? title;
  final String text;
  final bool alignLeft;
  final VoidCallback onAdd;
  final VoidCallback? onSettings;
  final bool hasInlineOptions;
  final String? rootFolderValue;
  final String? qualityProfileValue;
  final String? seriesTypeValue;
  final Future<List<String>> Function()? getRootFolders;
  final Future<List<({int id, String name})>> Function()? getQualityProfiles;
  final List<String>? seriesTypes;
  final void Function(String path)? onRootFolderChanged;
  final void Function(int id, String name)? onQualityProfileChanged;
  final void Function(String type)? onSeriesTypeChanged;
  // Seasons support
  final List<({int seasonNumber, int episodeCount})>? seasons;
  final Set<int>? selectedSeasons;
  final void Function(Set<int> seasons)? onSeasonsChanged;

  const _QuickAddDialog({
    this.title,
    required this.text,
    this.alignLeft = false,
    required this.onAdd,
    this.onSettings,
    this.hasInlineOptions = false,
    this.rootFolderValue,
    this.qualityProfileValue,
    this.seriesTypeValue,
    this.getRootFolders,
    this.getQualityProfiles,
    this.seriesTypes,
    this.onRootFolderChanged,
    this.onQualityProfileChanged,
    this.onSeriesTypeChanged,
    this.seasons,
    this.selectedSeasons,
    this.onSeasonsChanged,
  });

  @override
  State<_QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<_QuickAddDialog> {
  String? _rootFolder;
  String? _qualityProfile;
  String? _seriesType;
  late Set<int> _selectedSeasons;

  @override
  void initState() {
    super.initState();
    _rootFolder = widget.rootFolderValue;
    _qualityProfile = widget.qualityProfileValue;
    _seriesType = widget.seriesTypeValue;
    _selectedSeasons = widget.selectedSeasons ?? {};
  }

  void _showRootFolderPicker() async {
    if (widget.getRootFolders == null) return;
    
    final folders = await widget.getRootFolders!();
    if (!mounted || folders.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: folders.length,
        itemBuilder: (ctx, index) {
          final folder = folders[index];
          return ListTile(
            title: Text(
              folder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              setState(() => _rootFolder = folder);
              widget.onRootFolderChanged?.call(folder);
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _showQualityProfilePicker() async {
    if (widget.getQualityProfiles == null) return;
    
    final profiles = await widget.getQualityProfiles!();
    if (!mounted || profiles.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: profiles.length,
        itemBuilder: (ctx, index) {
          final profile = profiles[index];
          return ListTile(
            title: Text(profile.name),
            onTap: () {
              setState(() => _qualityProfile = profile.name);
              widget.onQualityProfileChanged?.call(profile.id, profile.name);
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _showSeriesTypePicker() {
    if (widget.seriesTypes == null || widget.seriesTypes!.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: widget.seriesTypes!.length,
        itemBuilder: (ctx, index) {
          final type = widget.seriesTypes![index];
          return ListTile(
            title: Text(type),
            onTap: () {
              setState(() => _seriesType = type);
              widget.onSeriesTypeChanged?.call(type);
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _showSeasonPicker() {
    // Sort seasons: regular seasons first (1, 2, 3...), specials (0) at the bottom
    final sortedSeasons = List.of(widget.seasons!)
      ..sort((a, b) {
        if (a.seasonNumber == 0) return 1; // Specials go to bottom
        if (b.seasonNumber == 0) return -1;
        return a.seasonNumber.compareTo(b.seasonNumber);
      });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final allSelected = _selectedSeasons.length == widget.seasons!.length;
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (ctx, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Select Seasons',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            if (allSelected) {
                              _selectedSeasons.clear();
                            } else {
                              // Select all except specials (season 0)
                              _selectedSeasons = widget.seasons!
                                  .where((s) => s.seasonNumber != 0)
                                  .map((s) => s.seasonNumber)
                                  .toSet();
                            }
                          });
                          setState(() {});
                          widget.onSeasonsChanged?.call(_selectedSeasons);
                        },
                        child: Text(allSelected ? 'Deselect All' : 'Select All'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: sortedSeasons.length,
                    itemBuilder: (ctx, index) {
                      final season = sortedSeasons[index];
                      final isSelected = _selectedSeasons.contains(season.seasonNumber);
                      final seasonLabel = season.seasonNumber == 0 
                          ? 'Specials' 
                          : 'Season ${season.seasonNumber}';
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(seasonLabel),
                        subtitle: Text(
                          '${season.episodeCount} episode${season.episodeCount == 1 ? '' : 's'}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        onChanged: (val) {
                          setSheetState(() {
                            if (val == true) {
                              _selectedSeasons.add(season.seasonNumber);
                            } else {
                              _selectedSeasons.remove(season.seasonNumber);
                            }
                          });
                          setState(() {});
                          widget.onSeasonsChanged?.call(_selectedSeasons);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title != null ? Text(widget.title!) : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              widget.text,
              textAlign: widget.alignLeft ? TextAlign.start : TextAlign.center,
            ),
            if (widget.hasInlineOptions) ...[
              const SizedBox(height: 16),
              // Root Folder row
              InkWell(
                onTap: _showRootFolderPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _rootFolder ?? 'Select Root Folder',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _rootFolder != null ? null : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Quality Profile and Series Type row
              Row(
                children: [
                  // Quality Profile (left half, or full width if no series types)
                  Expanded(
                    child: InkWell(
                      onTap: _showQualityProfilePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.high_quality_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _qualityProfile ?? 'Quality',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _qualityProfile != null ? null : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Series Type (right half, only for Sonarr)
                  if (widget.seriesTypes != null && widget.seriesTypes!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _showSeriesTypePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.category_outlined, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _seriesType ?? 'Type',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _seriesType != null ? null : Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Seasons selector (only for Sonarr)
              if (widget.seasons != null && widget.seasons!.isNotEmpty) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showSeasonPicker,
                  onLongPress: () {
                    // Select all non-specials
                    setState(() {
                      _selectedSeasons = widget.seasons!
                          .where((s) => s.seasonNumber != 0)
                          .map((s) => s.seasonNumber)
                          .toSet();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All seasons selected'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_list_numbered_rounded, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Seasons',
                          style: TextStyle(fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedSeasons.length} selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ] else if (widget.onSettings != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  tooltip: 'Quick Add Settings',
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    widget.onSettings!();
                  },
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onAdd();
          },
          child: Text('Add',
              style: TextStyle(color: ZagColours.accentColor(context))),
        ),
      ],
    );
  }
}
