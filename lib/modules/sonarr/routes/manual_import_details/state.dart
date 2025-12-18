import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportDetailsState extends ChangeNotifier {
  final String path;
  final String? downloadId;
  final int? hintSeriesId;
  final int? hintEpisodeId;

  SonarrManualImportDetailsState(
    BuildContext context, {
    required this.path,
    this.downloadId,
    this.hintSeriesId,
    this.hintEpisodeId,
  }) {
    fetchManualImport(context);
  }

  bool canExecuteAction = false;
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;
  ZagLoadingState get loadingState => _loadingState;
  set loadingState(ZagLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  Future<List<SonarrManualImport>>? _manualImport;
  Future<List<SonarrManualImport>>? get manualImport => _manualImport;
  Future<void> fetchManualImport(BuildContext context) async {
    if (context.read<SonarrState>().enabled) {
      final folder = (downloadId?.isNotEmpty ?? false) ? '' : path;
      _manualImport = context
          .read<SonarrState>()
          .api!
          .manualImport
          .get(
            folder: folder,
            downloadId: (downloadId?.isNotEmpty ?? false) ? downloadId : null,
            filterExistingFiles: true,
          )
          .then((files) => _applyHints(context, files));
    }
    notifyListeners();
  }

  Future<List<SonarrManualImport>> _applyHints(
    BuildContext context,
    List<SonarrManualImport> files,
  ) async {
    if (!context.mounted) return files;
    // If no hints provided, return files as-is
    if (hintSeriesId == null || files.isEmpty) return files;

    try {
      // Build update data for files using hints from queue
      List<SonarrManualImportUpdateData> updateData = files.map((file) {
        // Determine episode IDs: use hint if available, otherwise preserve existing
        List<int>? episodeIds;
        if (hintEpisodeId != null) {
          episodeIds = [hintEpisodeId!];
        } else if (file.episodes != null && file.episodes!.isNotEmpty) {
          episodeIds =
              file.episodes!.where((e) => e.id != null).map((e) => e.id!).toList();
        }

        return SonarrManualImportUpdateData(
          id: file.id,
          path: file.path,
          seriesId: hintSeriesId, // Use hint series ID
          episodeIds: episodeIds,
          quality: file.quality,
          languages: file.languages,
          releaseGroup: file.releaseGroup,
          downloadId: file.downloadId,
        );
      }).toList();

      // Update files with hints via API
      List<SonarrManualImportUpdate> updatedFiles =
          await context.read<SonarrState>().api!.manualImport.update(
                data: updateData,
              );

      // Convert update responses back to manual import objects
      return updatedFiles.map<SonarrManualImport>((updated) {
        // Find original file to preserve all fields
        SonarrManualImport original =
            files.firstWhere((f) => f.id == updated.id, orElse: () => files[0]);

        return SonarrManualImport(
          id: updated.id,
          path: updated.path,
          relativePath: original.relativePath,
          folderName: original.folderName,
          name: original.name,
          size: original.size,
          series: updated.series,
          episode: original.episode,
          episodes: updated.episodes,
          quality: original.quality,
          language: original.language,
          languages: original.languages,
          releaseGroup: original.releaseGroup,
          releaseType: original.releaseType,
          qualityWeight: original.qualityWeight,
          downloadId: original.downloadId,
          rejections: updated.rejections,
        );
      }).toList();
    } catch (e) {
      // If hint application fails, return original files
      ZagLogger().warning('Failed to apply queue hints to manual import', e.toString());
      return files;
    }
  }

  List<int> _selectedFiles = [];
  List<int> get selectedFiles => _selectedFiles;
  set selectedFiles(List<int> selectedFiles) {
    _selectedFiles = selectedFiles;
    notifyListeners();
  }

  void addSelectedFile(int id) {
    if (_selectedFiles.contains(id)) return;
    _selectedFiles.add(id);
    notifyListeners();
  }

  void removeSelectedFile(int id) {
    if (!_selectedFiles.contains(id)) return;
    _selectedFiles.remove(id);
    notifyListeners();
  }

  void toggleSelectedFile(int id) {
    _selectedFiles.contains(id) ? removeSelectedFile(id) : addSelectedFile(id);
  }

  void setSelectedFile(int id, bool state) {
    if (!_selectedFiles.contains(id) && state) addSelectedFile(id);
    if (_selectedFiles.contains(id) && !state) removeSelectedFile(id);
  }
}
