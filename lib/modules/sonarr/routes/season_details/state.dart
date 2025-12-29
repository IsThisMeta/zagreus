import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrSeasonDetailsState extends ChangeNotifier {
  final int seriesId;
  final int? seasonNumber;
  int _currentQueueItems = 0;
  int? currentEpisodeId;

  SonarrSeasonDetailsState({
    required BuildContext context,
    required this.seriesId,
    required this.seasonNumber,
  }) {
    fetchState(context, queueHardCheck: false);
  }

  Future<void> fetchState(
    BuildContext context, {
    bool shouldFetchEpisodes = true,
    bool shouldFetchFiles = true,
    bool shouldFetchHistory = true,
    bool shouldFetchQueue = true,
    bool queueHardCheck = true,
    bool shouldFetchMostRecentEpisodeHistory = true,
    bool shouldFetchBazarrEpisodes = true,
  }) async {
    if (shouldFetchEpisodes) fetchEpisodes(context);
    if (shouldFetchFiles) fetchFiles(context);
    if (shouldFetchHistory) fetchHistory(context);
    if (shouldFetchQueue) fetchQueue(context, hardCheck: queueHardCheck);
    if (shouldFetchMostRecentEpisodeHistory)
      fetchEpisodeHistory(context, currentEpisodeId);
    if (shouldFetchBazarrEpisodes) fetchBazarrEpisodes();
  }

  @override
  void dispose() {
    _queueTimer?.cancel();
    super.dispose();
  }

  ZagLoadingState _episodeSearchState = ZagLoadingState.INACTIVE;
  ZagLoadingState get episodeSearchState => _episodeSearchState;
  set episodeSearchState(ZagLoadingState state) {
    _episodeSearchState = state;
    notifyListeners();
  }

  final Map<int, Future<SonarrHistoryPage>> _episodeHistoryRequests = {};

  Future<void> fetchEpisodeHistory(BuildContext context, int? episodeId) async {
    if (episodeId == null) return;
    if (context.read<SonarrState>().enabled) {
      _episodeHistoryRequests[episodeId] = context
          .read<SonarrState>()
          .api!
          .history
          .get(
            pageSize: 1000,
            episodeId: episodeId,
          );
    }
    notifyListeners();
  }

  Future<SonarrHistoryPage?> getEpisodeHistory(int episodeId) {
    return _episodeHistoryRequests[episodeId] ?? Future.value(null);
  }

  Future<Map<int, SonarrEpisode>>? _episodes;
  Future<Map<int, SonarrEpisode>>? get episodes => _episodes;
  Future<void> fetchEpisodes(BuildContext context) async {
    if (context.read<SonarrState>().enabled) {
      _episodes = context
          .read<SonarrState>()
          .api!
          .episode
          .getMulti(seriesId: seriesId, seasonNumber: seasonNumber)
          .then((episodes) {
        return {
          for (SonarrEpisode e in episodes) e.id!: e,
        };
      });
    }
    notifyListeners();
  }

  Future<void> setSingleEpisode(SonarrEpisode episode) async {
    (await _episodes)![episode.id!] = episode;
    notifyListeners();
  }

  Future<List<SonarrHistoryRecord>>? _history;
  Future<List<SonarrHistoryRecord>>? get history => _history;
  Future<void> fetchHistory(BuildContext context) async {
    if (this.seasonNumber == null) return;
    if (context.read<SonarrState>().enabled) {
      _history = context.read<SonarrState>().api!.history.getBySeries(
            seriesId: seriesId,
            seasonNumber: seasonNumber,
          );
    }
    notifyListeners();
  }

  Future<Map<int, SonarrEpisodeFile>>? _files;
  Future<Map<int, SonarrEpisodeFile>>? get files => _files;
  Future<void> fetchFiles(BuildContext context) async {
    if (context.read<SonarrState>().enabled) {
      _files = context
          .read<SonarrState>()
          .api!
          .episodeFile
          .getSeries(seriesId: seriesId)
          .then((files) {
        return {
          for (SonarrEpisodeFile f in files) f.id!: f,
        };
      });
    }
    notifyListeners();
  }

  Timer? _queueTimer;
  void cancelQueueTimer() => _queueTimer?.cancel();
  void createQueueTimer(BuildContext context) {
    _queueTimer = Timer.periodic(
      Duration(seconds: SonarrDatabase.QUEUE_REFRESH_RATE.read()),
      (_) => fetchQueue(context),
    );
  }

  late Future<List<SonarrQueueRecord>> _queue;
  Future<List<SonarrQueueRecord>> get queue => _queue;
  set queue(Future<List<SonarrQueueRecord>> queue) {
    _queue = queue;
    notifyListeners();
  }

  Future<void> fetchQueue(
    BuildContext context, {
    bool hardCheck = false,
  }) async {
    cancelQueueTimer();
    if (context.read<SonarrState>().enabled) {
      // "Hard" check by telling Sonarr to refresh the monitored downloads
      // Give it 500 ms to internally check and then continue to fetch queue
      if (hardCheck) {
        await context
            .read<SonarrState>()
            .api!
            .command
            .refreshMonitoredDownloads()
            .then(
              (_) => Future.delayed(const Duration(milliseconds: 500), () {}),
            );
      }
      _queue = context
          .read<SonarrState>()
          .api!
          .queue
          .getDetails(
            seriesId: seriesId,
            includeEpisode: true,
          )
          .then((queue) {
        if (_currentQueueItems != queue.length) {
          fetchState(
            context,
            shouldFetchQueue: false,
          );
        }
        _currentQueueItems = queue.length;
        return queue;
      });
      createQueueTimer(context);
    }
    notifyListeners();
  }

  final Set<int> selectedEpisodes = {};

  void toggleSelectedEpisode(SonarrEpisode episode) {
    final id = episode.id!;
    if (selectedEpisodes.contains(id)) {
      selectedEpisodes.remove(id);
    } else {
      selectedEpisodes.add(id);
    }

    notifyListeners();
  }

  void clearSelectedEpisodes() {
    selectedEpisodes.clear();
    notifyListeners();
  }

  Future<void> toggleSeasonEpisodes(int seasonNumber) async {
    final eps = (await episodes)!
        .filter((ep) => ep.value.seasonNumber == seasonNumber)
        .map((ep) => ep.value.id!)
        .toList();
    final allSelected = eps.every(selectedEpisodes.contains);

    if (allSelected) {
      selectedEpisodes.removeAll(eps);
    } else {
      selectedEpisodes.addAll(eps);
    }

    notifyListeners();
  }

  // Bazarr subtitle data for episodes
  Future<Map<int, BazarrEpisode>>? _bazarrEpisodes;
  Future<Map<int, BazarrEpisode>>? get bazarrEpisodes => _bazarrEpisodes;

  BazarrAPI? _getBazarrApi() {
    if (!ZagreusPro.isEnabled) return null;
    final profile = ZagProfile.current;
    if (!profile.bazarrEnabled) return null;
    final host = profile.effectiveBazarrHost();
    if (host.isEmpty || profile.bazarrKey.isEmpty) return null;
    return BazarrAPI(
      host: host,
      apiKey: profile.bazarrKey,
      headers: Map<String, dynamic>.from(profile.bazarrHeaders),
    );
  }

  Future<void> fetchBazarrEpisodes() async {
    final api = _getBazarrApi();
    if (api == null) {
      _bazarrEpisodes = Future.value({});
      notifyListeners();
      return;
    }

    _bazarrEpisodes = api.episode.getForSeries(seriesId: seriesId).then(
      (episodes) {
        return {
          for (BazarrEpisode e in episodes)
            if (e.sonarrEpisodeId != null) e.sonarrEpisodeId!: e,
        };
      },
    ).catchError((e) {
      ZagLogger().error('Failed to load Bazarr episodes', e, StackTrace.current);
      return <int, BazarrEpisode>{};
    });
    notifyListeners();
  }
}
