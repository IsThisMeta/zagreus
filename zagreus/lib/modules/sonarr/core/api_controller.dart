import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/api/sonarr/models/manual_import/manual_import.dart';
import 'package:zagreus/api/sonarr/models/manual_import/manual_import_file.dart';

class SonarrAPIController {
  Future<bool> downloadRelease({
    required BuildContext context,
    required SonarrRelease release,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .release
          .add(
            indexerId: release.indexerId!,
            guid: release.guid!,
          )
          .then((_) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.DownloadingRelease'.tr(),
            message: release.title.uiSafe(),
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to set download release (${release.guid})',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToDownloadRelease'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> toggleEpisodeMonitored({
    required BuildContext context,
    required SonarrEpisode episode,
    bool showSnackbar = true,
  }) async {
    SonarrEpisode _episode = episode.clone();
    _episode.monitored = !_episode.monitored!;
    if (context.read<SonarrState>().enabled) {
      return context.read<SonarrState>().api!.episode.setMonitored(
        episodeIds: [_episode.id!],
        monitored: _episode.monitored!,
      ).then((_) {
        context.read<SonarrSeasonDetailsState>().setSingleEpisode(_episode);
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: _episode.monitored!
                ? 'sonarr.Monitoring'.tr()
                : 'sonarr.NoLongerMonitoring'.tr(),
            message: _episode.title,
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to set episode monitored state (${_episode.id})',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: _episode.monitored!
                ? 'sonarr.FailedToMonitorEpisode'.tr()
                : 'sonarr.FailedToUnmonitorEpisode'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> deleteEpisode({
    required BuildContext context,
    required SonarrEpisode episode,
    required SonarrEpisodeFile episodeFile,
    bool showSnackbar = true,
  }) async {
    SonarrEpisode _episode = episode.clone();
    _episode.hasFile = false;
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .episodeFile
          .delete(episodeFileId: episodeFile.id!)
          .then((response) {
        context.read<SonarrSeasonDetailsState>().setSingleEpisode(_episode);
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.EpisodeFileDeleted'.tr(),
            message: episodeFile.relativePath,
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to delete episode (${episodeFile.id})',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToDeleteEpisodeFile'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> deleteEpisodes({
    required BuildContext context,
    required List<int> episodeFileIds,
    bool showSnackbar = true,
  }) async {
    if (episodeFileIds.isEmpty) {
      showZagInfoSnackBar(
        title: 'sonarr.NoEpisodeFilesFound'.tr(),
        message: 'sonarr.NoEpisodeFilesFoundDeleteMessage'.tr(),
      );
      return true;
    }

    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .episodeFile
          .deleteBulk(episodeFileIds: episodeFileIds)
          .then((response) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.EpisodeFilesDeleted'.tr(),
            message: episodeFileIds.length > 1
                ? 'sonarr.EpisodesCount'
                    .tr(args: [episodeFileIds.length.toString()])
                : 'sonarr.OneEpisode'.tr(),
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to delete episodes (${episodeFileIds.join(',')})',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToDeleteEpisodeFiles'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> episodeSearch({
    required BuildContext context,
    required SonarrEpisode episode,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .command
          .episodeSearch(episodeIds: [episode.id!]).then((response) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.SearchingForEpisode'.tr(),
            message: episode.title,
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to search for episode: ${episode.id}',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToSearch'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> multiEpisodeSearch({
    required BuildContext context,
    required List<int> episodeIds,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .command
          .episodeSearch(episodeIds: episodeIds)
          .then((response) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.SearchingForEpisodes'.tr(),
            message: episodeIds.length > 1
                ? 'sonarr.EpisodesCount'
                    .tr(args: [episodeIds.length.toString()])
                : 'sonarr.OneEpisode'.tr(),
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to search for episode: ${episodeIds.join(',')}',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToSearchForEpisodes'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  Future<bool> toggleSeasonMonitored({
    required BuildContext context,
    required SonarrSeriesSeason season,
    required int? seriesId,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return context.read<SonarrState>().series!.then((series) {
        if (series[seriesId] == null) {
          throw Exception('Series does not exist in catalogue');
        }
        return series[seriesId]!.clone();
      }).then((series) async {
        series.seasons!.forEach((seriesSeason) {
          if (seriesSeason.seasonNumber == season.seasonNumber) {
            seriesSeason.monitored = !seriesSeason.monitored!;
          }
        });
        await context.read<SonarrState>().api!.series.update(series: series);
        return series;
      }).then((series) {
        return context.read<SonarrState>().setSingleSeries(series);
      }).then((series) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: season.monitored!
                ? 'sonarr.NoLongerMonitoring'.tr()
                : 'sonarr.Monitoring'.tr(),
            message: season.seasonNumber == 0
                ? 'Specials'
                : 'Season ${season.seasonNumber}',
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Unable to toggle season monitored state: ${season.monitored.toString()} to ${(!season.monitored!).toString()}',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: season.monitored!
                ? 'sonarr.FailedToUnmonitorSeason'.tr()
                : 'sonarr.FailedToMonitorSeason'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> toggleSeriesMonitored({
    required BuildContext context,
    required SonarrSeries series,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      SonarrSeries seriesCopy = series.clone();
      seriesCopy.monitored = !series.monitored!;
      return await context
          .read<SonarrState>()
          .api!
          .series
          .update(series: seriesCopy)
          .then((data) async {
        return await context
            .read<SonarrState>()
            .setSingleSeries(seriesCopy)
            .then((_) {
          if (showSnackbar) {
            showZagSuccessSnackBar(
              title: seriesCopy.monitored!
                  ? 'sonarr.Monitoring'.tr()
                  : 'sonarr.NoLongerMonitoring'.tr(),
              message: seriesCopy.title,
            );
          }
          return true;
        });
      }).catchError((error, stack) {
        ZagLogger().error(
          'Unable to toggle monitored state: ${series.monitored.toString()} to ${seriesCopy.monitored.toString()}',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: series.monitored!
                ? 'sonarr.FailedToUnmonitorSeries'.tr()
                : 'sonarr.FailedToMonitorSeries'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> addTag({
    required BuildContext context,
    required String label,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .tag
          .create(label: label)
          .then((tag) {
        showZagSuccessSnackBar(
          title: 'sonarr.AddedTag'.tr(),
          message: tag.label,
        );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error('Failed to add tag: $label', error, stack);
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToAddTag'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> updateSeries({
    required BuildContext context,
    required SonarrSeries series,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .series
          .update(series: series)
          .then((_) async {
        return await context
            .read<SonarrState>()
            .setSingleSeries(series)
            .then((_) {
          if (showSnackbar) {
            showZagSuccessSnackBar(
              title: 'sonarr.UpdatedSeries'.tr(),
              message: series.title,
            );
          }
          return true;
        });
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to update series: ${series.id}',
          error,
          stack,
        );
        showZagErrorSnackBar(
          title: 'sonarr.FailedToUpdateSeries'.tr(),
          error: error,
        );
        return false;
      });
    }
    return true;
  }

  Future<bool> backupDatabase({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context.read<SonarrState>().api!.command.backup().then((_) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.BackingUpDatabase'.tr(args: [ZagUI.TEXT_ELLIPSIS]),
            message: 'sonarr.BackingUpDatabaseDescription'.tr(),
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Sonarr: Unable to backup database',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToBackupDatabase'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> automaticSeasonSearch({
    required BuildContext context,
    required int? seriesId,
    required int? seasonNumber,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .command
          .seasonSearch(seriesId: seriesId!, seasonNumber: seasonNumber!)
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.SearchingForSeason'.tr(args: [ZagUI.TEXT_ELLIPSIS]),
            message: seasonNumber == 0
                ? 'sonarr.Specials'.tr()
                : 'sonarr.SeasonNumber'.tr(args: [seasonNumber.toString()]),
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to season search ($seriesId, $seasonNumber)',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToSeasonSearch'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> seasonCleanup({
    required BuildContext context,
    required SonarrSeriesSeason season,
    required int? seriesId,
    bool showSnackbar = true,
  }) async {
    if (!context.read<SonarrState>().enabled) return false;

    try {
      final sonarrState = context.read<SonarrState>();

      // Step 1: Unmonitor the season
      final series = await sonarrState.series!.then((allSeries) {
        if (allSeries[seriesId] == null) {
          throw Exception('Series does not exist in catalogue');
        }
        return allSeries[seriesId]!.clone();
      });

      series.seasons!.forEach((seriesSeason) {
        if (seriesSeason.seasonNumber == season.seasonNumber) {
          seriesSeason.monitored = false;
        }
      });

      await sonarrState.api!.series.update(series: series);
      await sonarrState.setSingleSeries(series);

      // Step 2: Get all episodes for the series
      final episodes = await sonarrState.api!.episode.getMulti(seriesId: seriesId!);

      // Step 3: Filter episodes for this season that have files
      final seasonEpisodes = episodes
          .where((ep) => ep.seasonNumber == season.seasonNumber && ep.hasFile == true)
          .toList();

      if (seasonEpisodes.isEmpty) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'Season Cleanup Complete',
            message: season.seasonNumber == 0
                ? 'Specials unmonitored (no files to delete)'
                : 'Season ${season.seasonNumber} unmonitored (no files to delete)',
          );
        }
        return true;
      }

      // Step 4: Delete all episode files with progress dialog
      final episodeFileIds = seasonEpisodes
          .map((ep) => ep.episodeFileId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (episodeFileIds.isNotEmpty) {
        // Show progress dialog
        int remaining = episodeFileIds.length;
        late void Function(void Function()) updateDialog;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              updateDialog = setState;
              return AlertDialog(
                title: Text('Deleting Episode Files'),
                content: Text(remaining == episodeFileIds.length
                    ? 'Deleting ${episodeFileIds.length} files...'
                    : 'Deleting: $remaining files left'),
              );
            },
          ),
        );

        // Delete files one by one with progress updates
        for (int i = 0; i < episodeFileIds.length; i++) {
          try {
            await sonarrState.api!.episodeFile.delete(episodeFileId: episodeFileIds[i]);
            remaining--;

            // Update progress dialog
            if (remaining > 0) {
              updateDialog(() {});
            }
          } catch (e) {
            ZagLogger().error('Failed to delete episode file ${episodeFileIds[i]}', e, null);
          }
        }

        // Dismiss progress dialog
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (showSnackbar) {
        showZagSuccessSnackBar(
          title: 'Season Cleanup Complete',
          message: season.seasonNumber == 0
              ? 'Specials unmonitored and ${episodeFileIds.length} files deleted'
              : 'Season ${season.seasonNumber} unmonitored and ${episodeFileIds.length} files deleted',
        );
      }

      return true;
    } catch (error, stack) {
      ZagLogger().error(
        'Failed to perform season cleanup ($seriesId, ${season.seasonNumber})',
        error,
        stack,
      );
      if (showSnackbar) {
        showZagErrorSnackBar(
          title: 'Season Cleanup Failed',
          error: error,
        );
      }
      return false;
    }
  }

  Future<bool> seriesSearch({
    required BuildContext context,
    required SonarrSeries series,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .command
          .seriesSearch(seriesId: series.id!)
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.SearchingForMonitoredEpisodes'.tr(),
            message: series.title!,
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to search for monitored episodes (${series.id})',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToSearchForMonitoredEpisodes'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> runRSSSync({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context.read<SonarrState>().api!.command.rssSync().then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.RunningRSSSync'.tr(args: [ZagUI.TEXT_ELLIPSIS]),
            message: 'sonarr.RunningRSSSyncDescription'.tr(),
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Unable to run RSS sync',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToRunRSSSync'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> updateLibrary({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .command
          .refreshSeries()
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.UpdatingLibrary'.tr(args: [ZagUI.TEXT_ELLIPSIS]),
            message: 'sonarr.UpdatingLibraryDescription'.tr(),
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Unable to update library',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToUpdateLibrary'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> missingEpisodesSearch({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .command
          .missingEpisodeSearch()
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.Searching'.tr(args: [ZagUI.TEXT_ELLIPSIS]),
            message: 'sonarr.SearchingDescription'.tr(),
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Sonarr: Unable to search for all missing episodes',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToSearch'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> refreshSeries({
    required BuildContext context,
    required SonarrSeries series,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .command
          .refreshSeries(seriesId: series.id)
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'zagreus.Refreshing'.tr(),
            message: series.title,
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Sonarr: Unable to refresh movie: ${series.id}',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToRefresh'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> removeSeries({
    required BuildContext context,
    required SonarrSeries series,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return await context
          .read<SonarrState>()
          .api!
          .series
          .delete(
            seriesId: series.id!,
            deleteFiles: SonarrDatabase.REMOVE_SERIES_DELETE_FILES.read(),
            addImportListExclusion:
                SonarrDatabase.REMOVE_SERIES_EXCLUSION_LIST.read(),
          )
          .then((_) async {
        return await context
            .read<SonarrState>()
            .removeSingleSeries(series.id!)
            .then((_) {
          if (showSnackbar)
            showZagSuccessSnackBar(
              title: SonarrDatabase.REMOVE_SERIES_DELETE_FILES.read()
                  ? 'sonarr.RemovedSeriesWithFiles'.tr()
                  : 'sonarr.RemovedSeries'.tr(),
              message: series.title,
            );
          return true;
        });
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to remove series: ${series.id}',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToRemoveSeries'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<SonarrSeries?> addSeries({
    required BuildContext context,
    required SonarrSeries series,
    required SonarrSeriesType seriesType,
    required bool seasonFolder,
    required SonarrQualityProfile qualityProfile,
    required SonarrRootFolder rootFolder,
    required SonarrSeriesMonitorType monitorType,
    required List<SonarrTag> tags,
    SonarrLanguageProfile? languageProfile,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      series.id = 0;
      final result = await context
          .read<SonarrState>()
          .api!
          .series
          .create(
            series: series,
            seriesType: seriesType,
            seasonFolder: seasonFolder,
            qualityProfile: qualityProfile,
            languageProfile: languageProfile,
            rootFolder: rootFolder,
            monitorType: monitorType,
            tags: tags,
            searchForMissingEpisodes:
                SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.read(),
            searchForCutoffUnmetEpisodes:
                SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.read(),
          )
          .then((series) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.AddedSeries'.tr(),
            message: series.title,
          );
        }
        return series;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to add series (tmdbId: ${series.tvdbId})',
          error,
          stack,
        );
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToAddSeries'.tr(),
            error: error,
          );
        }
        return SonarrSeries();
      });
      if (result.id == null) return null;
      return result;
    }
    return null;
  }

  Future<bool> removeFromQueue({
    required BuildContext context,
    required SonarrQueueRecord queueRecord,
    bool showSnackbar = true,
  }) async {
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .queue
          .delete(id: queueRecord.id!)
          .then((_) {
        if (showSnackbar)
          showZagSuccessSnackBar(
            title: 'sonarr.RemovedFromQueue'.tr(),
            message: queueRecord.title,
          );
        return true;
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to remove queue record: ${queueRecord.id}',
          error,
          stack,
        );
        if (showSnackbar)
          showZagErrorSnackBar(
            title: 'sonarr.FailedToRemoveFromQueue'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  Future<bool> triggerManualImport({
    required BuildContext context,
    required List<SonarrManualImportFile> files,
    bool showSnackbar = true,
  }) async {
    if (files.isEmpty) {
      showZagInfoSnackBar(
        title: 'Nothing Selected',
        message: 'Please select at least one file to import',
      );
      return false;
    }
    if (context.read<SonarrState>().enabled) {
      return context
          .read<SonarrState>()
          .api!
          .manualImport
          .import(files: files)
          .then((_) {
        if (showSnackbar) {
          showZagSuccessSnackBar(
            title: 'sonarr.ManualImport'.tr(),
            message: '${files.length} files queued for import',
          );
        }
        return true;
      }).catchError((error, stack) {
        ZagLogger().error('Failed to trigger Sonarr manual import', error, stack);
        if (showSnackbar) {
          showZagErrorSnackBar(
            title: 'sonarr.FailedToImport'.tr(),
            error: error,
          );
        }
        return false;
      });
    }
    return false;
  }

  /// Given a [SonarrManualImport] instance, create a [SonarrManualImportFile]
  /// which is sent within the manual import call.
  Tuple2<SonarrManualImportFile?, String?> buildManualImportFile({
    required SonarrManualImport import,
  }) {
    if (import.series?.id == null) {
      return const Tuple2(null, 'All selections must have a series set');
    }
    final episodeIds =
        import.episodes?.map((episode) => episode.id).whereType<int>().toList() ??
            [];
    if (episodeIds.isEmpty) {
      return const Tuple2(null, 'All selections must have at least one episode');
    }
    if (import.quality == null ||
        (import.quality?.quality?.id ?? -1) < 0 ||
        import.languages == null ||
        import.languages!.isEmpty) {
      return const Tuple2(null, 'Quality and language are required');
    }
    return Tuple2(
      SonarrManualImportFile(
        path: import.path,
        seriesId: import.series!.id,
        episodeIds: episodeIds,
        quality: import.quality,
        languages: import.languages,
        releaseGroup: import.releaseGroup,
        downloadId: import.downloadId,
      ),
      null,
    );
  }
}
