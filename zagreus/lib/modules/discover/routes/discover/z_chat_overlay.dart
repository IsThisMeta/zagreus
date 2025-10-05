import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:zagreus/services/library_sync_service.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/modules/discover/routes/z_assistant_results/route.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';

/// Simple stateless Z chat page for Discover module
/// Resets conversation when you leave Discover
class ZChatPage extends StatefulWidget {
  const ZChatPage({Key? key}) : super(key: key);

  @override
  State<ZChatPage> createState() => _ZChatPageState();
}

class _ZChatPageState extends State<ZChatPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final StagedOperationsService _stagingService = StagedOperationsService();
  bool _isThinking = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    // Trigger library sync after 5 seconds to avoid UI lag
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final syncService = LibrarySyncService();
        if (syncService.needsSync) {
          ZagLogger().debug('Z Chat opened - triggering library sync...');
          syncService.syncIfNeeded(); // Fire and forget
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _forceResync() async {
    print('\n╔════════════════════════════════════════════╗');
    print('║   MANUAL SYNC BUTTON PRESSED             ║');
    print('╚════════════════════════════════════════════╝');

    setState(() => _isSyncing = true);

    try {
      print('→ Calling LibrarySyncService().syncLibrary(force: true)...\n');
      final success = await LibrarySyncService().syncLibrary(force: true);

      print('\n→ Sync returned: $success');

      if (mounted) {
        if (success) {
          print('→ Showing success snackbar');
          showZagSnackBar(
            title: 'Library Synced',
            message: 'Your library has been synced to Z Assistant',
            type: ZagSnackbarType.SUCCESS,
          );
        } else {
          print('→ Sync returned false - showing warning');
          showZagSnackBar(
            title: 'Sync Issue',
            message: 'Sync completed but may not have uploaded data. Check console.',
            type: ZagSnackbarType.INFO,
          );
        }
      }
    } catch (e, stack) {
      print('❌ EXCEPTION in _forceResync: $e');
      print('Stack trace: $stack');
      ZagLogger().error('Failed to sync library', e, stack);
      if (mounted) {
        showZagSnackBar(
          title: 'Sync Failed',
          message: 'Could not sync library. Please try again.',
          type: ZagSnackbarType.ERROR,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        print('→ Sync button released\n');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isThinking) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(content: userMessage, isUser: true));
      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final zAssistant = ZAssistantService();

      // ZERO-KNOWLEDGE: No server credentials sent to backend!
      // Backend uses library_cache from Supabase instead
      final response = await zAssistant.sendMessage(
        message: userMessage,
      );

      setState(() {
        _isThinking = false;
      });

      ZagLogger().debug('📨 Z Assistant response - isStaged: ${response.isStaged}, stageId: ${response.stageId}, text: ${response.text}');

      // Execute any commands from the response
      if (response.commands.isNotEmpty) {
        await _executeCommands(response.commands);
      }

      // Check if response is staged operation
      if (response.isStaged && response.stageId != null) {
        // Fetch the staged operation to check if it's queue or stage
        final stagedOp = await _stagingService.fetchStagedOperation(response.stageId!);

        if (stagedOp == null) {
          setState(() {
            _messages.add(_ChatMessage(
              content: 'Error: Could not fetch staged operation',
              isUser: false,
            ));
          });
          return;
        }

        // Check operation type: queue = auto-execute, stage = show modal
        if (stagedOp.operation == 'queue') {
          // Auto-execute queue operations (1-3 items)
          ZagLogger().debug('Auto-executing queue operation with ${stagedOp.items.length} items');

          // Show AI's message
          setState(() {
            _messages.add(_ChatMessage(
              content: response.text,
              isUser: false,
            ));
          });
          _scrollToBottom();

          // Execute in background using existing batch code
          await _executeQueueOperation(stagedOp);
        } else {
          // Show staging modal for review (4+ items or explicit staging)
          setState(() {
            _messages.add(_ChatMessage(
              content: null,  // Don't show the stage ID as text
              isUser: false,
              stageId: response.stageId,
            ));
          });
          _scrollToBottom();

          _showStagingModal(response.stageId!, response.text);
        }
      } else {
        // Regular text response
        setState(() {
          _messages.add(_ChatMessage(
            content: response.text,
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
        ));
        _isThinking = false;
      });

      _scrollToBottom();
    }
  }

  Future<void> _executeCommands(List<ZAssistantCommand> commands) async {
    for (final command in commands) {
      ZagLogger().debug('Executing command: ${command.action}');

      switch (command.action) {
        case 'sync_library':
          // Sync library to Supabase cache
          ZagLogger().debug('Syncing library to cache...');
          await LibrarySyncService().syncLibrary(force: true);
          break;
        default:
          ZagLogger().warning('Unknown command action: ${command.action}');
      }
    }
  }

  Future<void> _executeQueueOperation(StagedOperation operation) async {
    try {
      // Split items by media type
      final movies = operation.items.where((item) => item.isMovie).toList();
      final shows = operation.items.where((item) => item.isShow).toList();

      int successCount = 0;
      int failCount = 0;

      // Add movies to Radarr
      if (movies.isNotEmpty) {
        final radarrState = context.read<RadarrState>();

        // Get saved settings
        final qualityProfileId = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
        final rootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
        final searchForMissing = ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read() ?? true;

        if (qualityProfileId == null || rootFolder == null) {
          showZagSnackBar(
            title: 'Missing Radarr Config',
            message: 'Please configure Radarr settings',
            type: ZagSnackbarType.ERROR,
          );
          return;
        }

        final profiles = await radarrState.qualityProfiles;
        final folders = await radarrState.rootFolders;

        if (profiles == null || folders == null) {
          showZagSnackBar(
            title: 'Radarr Not Available',
            message: 'Could not connect to Radarr',
            type: ZagSnackbarType.ERROR,
          );
          return;
        }

        final selectedProfile = profiles.firstWhere((p) => p.id == qualityProfileId);
        final selectedFolder = folders.firstWhere((f) => f.path == rootFolder);

        for (final movie in movies) {
          try {
            final lookupResults = await radarrState.api!.movieLookup.get(term: "tmdb:${movie.tmdbId}");

            if (lookupResults.isEmpty) {
              failCount++;
              continue;
            }

            final radarrMovie = lookupResults.first;

            if (radarrMovie.id != null && radarrMovie.id! > 0) {
              failCount++;
              continue;
            }

            await radarrState.api!.movie.create(
              movie: radarrMovie,
              rootFolder: selectedFolder,
              monitored: true,
              minimumAvailability: RadarrAvailability.ANNOUNCED,
              qualityProfile: selectedProfile,
              searchForMovie: searchForMissing,
            );

            successCount++;
          } catch (e) {
            ZagLogger().error('Failed to add movie: ${movie.title}', e, StackTrace.current);
            failCount++;
          }
        }
      }

      // Add shows to Sonarr
      if (shows.isNotEmpty) {
        final sonarrState = context.read<SonarrState>();

        // Get saved settings
        final qualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
        final rootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
        final searchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read() ?? true;
        final monitorTypeValue = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
        final seriesTypeValue = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();

        if (qualityProfileId == null || rootFolder == null) {
          showZagSnackBar(
            title: 'Missing Sonarr Config',
            message: 'Please configure Sonarr settings',
            type: ZagSnackbarType.ERROR,
          );
          return;
        }

        final profiles = await sonarrState.qualityProfiles;
        final folders = await sonarrState.rootFolders;

        if (profiles == null || folders == null) {
          showZagSnackBar(
            title: 'Sonarr Not Available',
            message: 'Could not connect to Sonarr',
            type: ZagSnackbarType.ERROR,
          );
          return;
        }

        final selectedProfile = profiles.firstWhere((p) => p.id == qualityProfileId);
        final selectedFolder = folders.firstWhere((f) => f.path == rootFolder);

        // Get monitor and series types
        final monitorType = SonarrSeriesMonitorType.values.firstWhere(
          (type) => type.value == monitorTypeValue,
          orElse: () => SonarrSeriesMonitorType.ALL,
        );
        final seriesType = SonarrSeriesType.values.firstWhere(
          (type) => type.value == seriesTypeValue,
          orElse: () => SonarrSeriesType.STANDARD,
        );

        for (final show in shows) {
          try {
            final lookupResults = await sonarrState.api!.seriesLookup.get(term: "tvdb:${show.tvdbId}");

            if (lookupResults.isEmpty) {
              failCount++;
              continue;
            }

            final sonarrSeries = lookupResults.first;

            if (sonarrSeries.id != null && sonarrSeries.id! > 0) {
              failCount++;
              continue;
            }

            await sonarrState.api!.series.create(
              series: sonarrSeries,
              rootFolder: selectedFolder,
              monitored: true,
              qualityProfile: selectedProfile,
              seriesType: seriesType,
              seasonFolder: true,
              searchForMissingEpisodes: searchForMissing,
              monitor: monitorType,
            );

            successCount++;
          } catch (e) {
            ZagLogger().error('Failed to add show: ${show.title}', e, StackTrace.current);
            failCount++;
          }
        }
      }

      // Show result
      if (successCount > 0) {
        showZagSnackBar(
          title: 'Success',
          message: 'Added $successCount item${successCount == 1 ? '' : 's'} to library',
          type: ZagSnackbarType.SUCCESS,
        );
      }

      if (failCount > 0) {
        showZagSnackBar(
          title: 'Warning',
          message: '$failCount item${failCount == 1 ? '' : 's'} failed or already in library',
          type: ZagSnackbarType.INFO,
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Queue execution failed', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to execute operation',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Column(
            children: [
              // Messages
              Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'z',
                          style: TextStyle(
                            fontFamily: 'Zebrra',
                            fontSize: 80,
                            color: ZagColours.accent.withOpacity(0.15),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ask Z anything about movies or shows',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isThinking) {
                        return _buildThinkingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),

          // Input bar at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (_) => setState(() {}), // Update UI for send button
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Z anything...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                ),
                suffixIcon: _controller.text.isNotEmpty && !_isThinking
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: ZagColours.accent,
                        ),
                        onPressed: _sendMessage,
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ZagColours.accent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
            ],
          ),

          // Sync button at top right
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSyncing ? null : _forceResync,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isSyncing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ZagColours.accent,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.sync,
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStagingModal(String stageId, String operation) async {
    // Show the staging modal bottom sheet
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StagingModal(
        stageId: stageId,
        operation: operation,
      ),
    );

    // Update chat based on result
    if (result == true) {
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Operation completed successfully!',
          isUser: false,
        ));
      });
    } else if (result == false) {
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Operation cancelled.',
          isUser: false,
        ));
      });
    }
    _scrollToBottom();
  }

  Widget _buildMessage(_ChatMessage message) {
    final theme = Theme.of(context);

    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: SizedBox()),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ZagColours.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Check if message has a stage ID - if so, show only the button
    if (message.stageId != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Stage button
                    InkWell(
                      onTap: () => _showStagingModal(message.stageId!, message.content ?? ''),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: ZagColours.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ZagColours.accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '📁',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Open Stage',
                              style: TextStyle(
                                color: ZagColours.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Regular text message
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message.content ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                child: _BouncingDot(delay: index * 200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String? content;
  final bool isUser;
  final String? stageId;

  _ChatMessage({
    this.content,
    this.stageId,
    required this.isUser,
  });
}

// Staging Modal - Power user list-based staging UI for Z Chat
class _StagingModal extends StatefulWidget {
  final String stageId;
  final String operation;

  const _StagingModal({
    required this.stageId,
    required this.operation,
  });

  @override
  State<_StagingModal> createState() => _StagingModalState();
}

class _StagingModalState extends State<_StagingModal> {
  final _service = StagedOperationsService();

  StagedOperation? _stagedOperation;
  bool _loading = true;
  String? _error;

  // Multi-select state
  final Set<int> _selectedIndices = {};
  bool _isMultiSelectMode = false;

  // Radarr/Sonarr config state
  int? _selectedRadarrQualityProfileId;
  String? _selectedRadarrQualityProfileName;
  String? _selectedRadarrRootFolder;
  bool _radarrSearchForMissing = true;

  int? _selectedSonarrQualityProfileId;
  String? _selectedSonarrQualityProfileName;
  String? _selectedSonarrRootFolder;
  SonarrSeriesMonitorType _sonarrMonitorType = SonarrSeriesMonitorType.ALL;
  SonarrSeriesType _sonarrSeriesType = SonarrSeriesType.STANDARD;
  bool _sonarrSearchForMissing = true;
  bool _sonarrSearchForCutoffUnmet = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadData();
  }

  void _loadSavedSettings() {
    _selectedRadarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _selectedRadarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _selectedRadarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read() ?? true;

    _selectedSonarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
    _selectedSonarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.read();
    _selectedSonarrRootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
    final savedMonitorType = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
    _sonarrMonitorType = SonarrSeriesMonitorType.values.firstWhere(
      (type) => type.value == savedMonitorType,
      orElse: () => SonarrSeriesMonitorType.ALL,
    );
    final savedSeriesType = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();
    _sonarrSeriesType = SonarrSeriesType.values.firstWhere(
      (type) => type.value == savedSeriesType,
      orElse: () => SonarrSeriesType.STANDARD,
    );
    _sonarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read() ?? true;
    _sonarrSearchForCutoffUnmet = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read() ?? false;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });

    try {
      final operation = await _service.fetchStagedOperation(widget.stageId);

      if (operation == null) {
        setState(() {
          _error = 'Failed to load staged operation';
          _loading = false;
        });
        return;
      }

      setState(() {
        _stagedOperation = operation;
        _loading = false;
      });
    } catch (e, stack) {
      ZagLogger().error('Error loading staged operation', e, stack);
      setState(() {
        _error = 'Error loading operation: $e';
        _loading = false;
      });
    }
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleItemSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get operation color and label from the actual staged operation
    Color badgeColor;
    String badgeText;
    final operationType = _stagedOperation?.operation ?? widget.operation;

    switch (operationType) {
      case 'add':
        badgeColor = Colors.green;
        badgeText = 'ADD ${_stagedOperation?.items.length ?? 0} ITEMS';
        break;
      case 'remove':
        badgeColor = Colors.red;
        badgeText = 'REMOVE ${_stagedOperation?.items.length ?? 0} ITEMS';
        break;
      case 'update':
        badgeColor = const Color(0xFF89CFF0); // Pastel blue
        badgeText = 'UPDATE ${_stagedOperation?.items.length ?? 0} ITEMS';
        break;
      case 'discover':
      default:
        badgeColor = ZagColours.accent;
        badgeText = '${_stagedOperation?.items.length ?? 0} RESULTS';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with icons and badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Icon buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.movie),
                      onPressed: _showRadarrConfig,
                      tooltip: 'Radarr Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.tv),
                      onPressed: _showSonarrConfig,
                      tooltip: 'Sonarr Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.checklist),
                      onPressed: _toggleMultiSelectMode,
                      tooltip: 'Select Items',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _buildBody(),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badgeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: ZagLoader());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error Loading Operation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }

    if (_stagedOperation == null || _stagedOperation!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stagedOperation!.items.length,
      itemBuilder: (context, index) {
        final item = _stagedOperation!.items[index];
        final isSelected = _selectedIndices.contains(index);

        return GestureDetector(
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleItemSelection(index);
            } else {
              _showItemCustomization(item, index);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected && _isMultiSelectMode
                  ? ZagColours.accent.withOpacity(0.2)
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: isSelected && _isMultiSelectMode
                  ? Border.all(color: ZagColours.accent, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Checkbox (if multi-select mode)
                if (_isMultiSelectMode) ...[
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? ZagColours.accent : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                ],

                // Poster thumbnail
                if (item.posterPath != null && item.posterPath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w92${item.posterPath}',
                      width: 40,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 60,
                        color: Colors.grey.withOpacity(0.3),
                        child: const Icon(Icons.movie, size: 20),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      item.isMovie ? Icons.movie : Icons.tv,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),

                // Title and year
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      if (item.year != null)
                        Text(
                          item.year.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),

                // Media type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isMovie ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isMovie ? 'MOVIE' : 'TV',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isMovie ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemCustomization(StagedMediaItem item, int index) {
    // TODO: Show dialog to customize quality profile, root folder, etc. for this specific item
    // For now, just show a preview
    showZagSnackBar(
      title: 'Per-item Customization',
      message: 'Tap and hold to customize settings for ${item.title}',
      type: ZagSnackbarType.INFO,
    );
  }

  void _showRadarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Radarr Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.high_quality),
                title: const Text('Quality Profile'),
                subtitle: _selectedRadarrQualityProfileName != null ? Text(_selectedRadarrQualityProfileName!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectRadarrQualityProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Root Folder'),
                subtitle: _selectedRadarrRootFolder != null ? Text(_selectedRadarrRootFolder!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectRadarrRootFolder();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.search),
                title: const Text('Start search for missing'),
                value: _radarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _radarrSearchForMissing = value;
                      ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.update(value);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSonarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sonarr Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.high_quality),
                title: const Text('Quality Profile'),
                subtitle: _selectedSonarrQualityProfileName != null ? Text(_selectedSonarrQualityProfileName!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrQualityProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Root Folder'),
                subtitle: _selectedSonarrRootFolder != null ? Text(_selectedSonarrRootFolder!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrRootFolder();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.search),
                title: const Text('Start search for missing'),
                value: _sonarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _sonarrSearchForMissing = value;
                      ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.update(value);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectRadarrQualityProfile() async {
    try {
      final profiles = await context.read<RadarrState>().qualityProfiles;

      if (profiles == null || profiles.isEmpty) {
        showZagSnackBar(title: 'No Quality Profiles', message: 'No Radarr quality profiles found', type: ZagSnackbarType.INFO);
        return;
      }

      final Tuple2<bool, RadarrQualityProfile?> result = await RadarrDialogs().editQualityProfile(context, profiles);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedRadarrQualityProfileId = result.item2!.id;
          _selectedRadarrQualityProfileName = result.item2!.name;
        });

        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(_selectedRadarrQualityProfileId);
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(_selectedRadarrQualityProfileName);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Radarr quality profile', e, stack);
      showZagSnackBar(title: 'Error', message: 'Failed to load quality profiles', type: ZagSnackbarType.ERROR);
    }
  }

  Future<void> _selectRadarrRootFolder() async {
    try {
      final folders = await context.read<RadarrState>().rootFolders;

      if (folders == null || folders.isEmpty) {
        showZagSnackBar(title: 'No Root Folders', message: 'No Radarr root folders found', type: ZagSnackbarType.INFO);
        return;
      }

      final Tuple2<bool, RadarrRootFolder?> result = await RadarrDialogs().editRootFolder(context, folders);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedRadarrRootFolder = result.item2!.path;
        });

        ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(_selectedRadarrRootFolder);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Radarr root folder', e, stack);
      showZagSnackBar(title: 'Error', message: 'Failed to load root folders', type: ZagSnackbarType.ERROR);
    }
  }

  Future<void> _selectSonarrQualityProfile() async {
    try {
      final profiles = await context.read<SonarrState>().qualityProfiles;

      if (profiles == null || profiles.isEmpty) {
        showZagSnackBar(title: 'No Quality Profiles', message: 'No Sonarr quality profiles found', type: ZagSnackbarType.INFO);
        return;
      }

      final Tuple2<bool, SonarrQualityProfile?> result = await SonarrDialogs().editQualityProfile(context, profiles);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedSonarrQualityProfileId = result.item2!.id;
          _selectedSonarrQualityProfileName = result.item2!.name;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.update(_selectedSonarrQualityProfileId);
        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.update(_selectedSonarrQualityProfileName);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr quality profile', e, stack);
      showZagSnackBar(title: 'Error', message: 'Failed to load quality profiles', type: ZagSnackbarType.ERROR);
    }
  }

  Future<void> _selectSonarrRootFolder() async {
    try {
      final folders = await context.read<SonarrState>().rootFolders;

      if (folders == null || folders.isEmpty) {
        showZagSnackBar(title: 'No Root Folders', message: 'No Sonarr root folders found', type: ZagSnackbarType.INFO);
        return;
      }

      final Tuple2<bool, SonarrRootFolder?> result = await SonarrDialogs().editRootFolder(context, folders);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedSonarrRootFolder = result.item2!.path;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.update(_selectedSonarrRootFolder);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr root folder', e, stack);
      showZagSnackBar(title: 'Error', message: 'Failed to load root folders', type: ZagSnackbarType.ERROR);
    }
  }

  Future<void> _handleConfirm() async {
    // TODO: Execute the staged operation via backend
    // For now, just close the modal
    Navigator.of(context).pop(true);
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: ZagColours.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
