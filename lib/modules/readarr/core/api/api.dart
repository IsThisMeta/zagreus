import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrAPI {
  final Dio _dio;

  ReadarrAPI._internal(this._dio);
  factory ReadarrAPI.from(ZagProfile profile) {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: profile.effectiveReadarrHost().endsWith('/')
            ? '${profile.effectiveReadarrHost()}api/v1/'
            : '${profile.effectiveReadarrHost()}/api/v1/',
        queryParameters: {
          if (profile.readarrKey != '') 'apikey': profile.readarrKey,
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: profile.readarrHeaders,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    return ReadarrAPI._internal(_client);
  }

  void logError(String text, Object error, StackTrace trace) =>
      ZagLogger().error('Readarr: $text', error, trace);

  Future<dynamic> testConnection() async => await _dio.get('system/status');

  Future<List<ReadarrCatalogueData>> getAllAuthors() async {
    try {
      Map<int?, ReadarrQualityProfile> _qualities =
          await getQualityProfiles();
      Map<int?, ReadarrMetadataProfile> _metadatas =
          await getMetadataProfiles();
      Response response = await _dio.get('author');
      List<ReadarrCatalogueData> entries = [];
      for (var entry in response.data) {
        entries.add(ReadarrCatalogueData(
          title: entry['authorName'] ?? 'Unknown Author',
          sortTitle: entry['sortName'] ?? 'Unknown Author',
          overview: entry['overview'] ?? 'No Summary Available',
          path: entry['path'] ?? 'Unknown Path',
          authorID: entry['id'] ?? 0,
          authorType: entry['authorType'] ?? 'Unknown Author Type',
          monitored: entry['monitored'] ?? false,
          statistics: entry['statistics'] ?? {},
          qualityProfile: entry['qualityProfileId'] ?? 0,
          metadataProfile: entry['metadataProfileId'] ?? 0,
          quality: entry['qualityProfileId'] != null
              ? _qualities[entry['qualityProfileId']]?.name ??
                  'Unknown Quality Profile'
              : '',
          metadata: entry['metadataProfileId'] != null
              ? _metadatas[entry['metadataProfileId']]?.name ??
                  'Unknown Metadata Profile'
              : '',
          genres: entry['genres'] ?? [],
          links: entry['links'] ?? [],
          foreignAuthorID: entry['foreignAuthorId'] ?? '',
          sizeOnDisk: entry['statistics'] != null
              ? entry['statistics']['sizeOnDisk'] ?? 0
              : 0,
          added: entry['added'] ?? '',
        ));
      }
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch authors', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch authors', error, stack);
      return Future.error(error);
    }
  }

  Future<Map<int?, ReadarrQualityProfile>> getQualityProfiles() async {
    try {
      Response response = await _dio.get('qualityprofile');
      var _entries = <int?, ReadarrQualityProfile>{};
      for (var entry in response.data) {
        _entries[entry['id']] = ReadarrQualityProfile(
          id: entry['id'] ?? -1,
          name: entry['name'] ?? 'Unknown Quality Profile',
        );
      }
      return _entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch quality profiles', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch quality profiles', error, stack);
      return Future.error(error);
    }
  }

  Future<Map<int?, ReadarrMetadataProfile>> getMetadataProfiles() async {
    try {
      Response response = await _dio.get('metadataprofile');
      var _entries = <int?, ReadarrMetadataProfile>{};
      for (var entry in response.data) {
        _entries[entry['id']] = ReadarrMetadataProfile(
          id: entry['id'] ?? -1,
          name: entry['name'] ?? 'Unknown Metadata Profile',
        );
      }
      return _entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch metadata profiles', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch metadata profiles', error, stack);
      return Future.error(error);
    }
  }

  Future<List<String>> getAllAuthorIDs() async {
    try {
      Response response = await _dio.get('author');
      List<String> _entries = [];
      for (var entry in response.data) {
        _entries.add(entry['foreignAuthorId'] ?? '');
      }
      return _entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch author IDs', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch author IDs', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> refreshAuthor(int authorID) async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'RefreshAuthor',
          'authorId': authorID,
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to refresh author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to refresh author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<ReadarrCatalogueData> getAuthor(int? authorID) async {
    try {
      Map<int?, ReadarrQualityProfile> _qualities =
          await getQualityProfiles();
      Map<int?, ReadarrMetadataProfile> _metadatas =
          await getMetadataProfiles();
      Response response = await _dio.get('author/$authorID');
      return ReadarrCatalogueData(
        title: response.data['authorName'] ?? 'Unknown Author',
        sortTitle: response.data['sortName'] ?? 'Unknown Author',
        overview: response.data['overview'] ?? 'No Summary Available',
        authorType: response.data['authorType'] ?? 'Unknown Author Type',
        path: response.data['path'] ?? 'Unknown Path',
        authorID: response.data['id'] ?? 0,
        added: response.data['added'] ?? '',
        monitored: response.data['monitored'] ?? false,
        statistics: response.data['statistics'] ?? {},
        qualityProfile: response.data['qualityProfileId'] ?? 0,
        metadataProfile: response.data['metadataProfileId'] ?? 0,
        quality: response.data['qualityProfileId'] != null
            ? _qualities[response.data['qualityProfileId']]?.name ??
                'Unknown Quality Profile'
            : '',
        metadata: response.data['metadataProfileId'] != null
            ? _metadatas[response.data['metadataProfileId']]?.name ??
                'Unknown Metadata Profile'
            : '',
        genres: response.data['genres'] ?? [],
        links: response.data['links'] ?? [],
        foreignAuthorID: response.data['foreignAuthorId'] ?? '',
        sizeOnDisk: response.data['statistics'] != null
            ? response.data['statistics']['sizeOnDisk'] ?? 0
            : 0,
      );
    } on DioException catch (error, stack) {
      logError('Failed to fetch author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> removeAuthor(int authorID,
      {bool deleteFiles = false, bool addImportExclusion = false}) async {
    try {
      await _dio.delete(
        'author/$authorID',
        queryParameters: {
          'deleteFiles': deleteFiles,
          'addImportExclusion': addImportExclusion,
        },
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to remove author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to remove author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> editAuthor(
      int authorID,
      ReadarrQualityProfile qualityProfile,
      ReadarrMetadataProfile metadataProfile,
      String? path,
      bool? monitored) async {
    try {
      Response response = await _dio.get('author/$authorID');
      Map author = response.data;
      author['monitored'] = monitored;
      author['path'] = path;
      author['profileId'] = qualityProfile.id;
      author['qualityProfileId'] = qualityProfile.id;
      author['metadataProfileId'] = metadataProfile.id;
      response = await _dio.put(
        'author',
        data: json.encode(author),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to edit author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to edit author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrBookData>> getBooksForAuthor(int authorID) async {
    try {
      Response response = await _dio.get('book', queryParameters: {
        'authorId': authorID,
      });
      List<ReadarrBookData> entries = [];
      for (var entry in response.data) {
        entries.add(ReadarrBookData(
          bookID: entry['id'] ?? -1,
          title: entry['title'] ?? 'Unknown Book Title',
          monitored: entry['monitored'] ?? false,
          releaseDate: entry['releaseDate'] ?? '',
          editionCount: entry['editions'] != null
              ? (entry['editions'] as List).length
              : 0,
          grabbed: entry['grabbed'] ?? false,
          authorID: authorID,
        ));
      }
      entries.sort((a, b) {
        if (a.releaseDateObject == null) return 1;
        if (b.releaseDateObject == null) return -1;
        return b.releaseDateObject!.compareTo(a.releaseDateObject!);
      });
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch books for author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch books for author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<ReadarrBookData> getBook(int bookID) async {
    try {
      Response response = await _dio.get('book/$bookID');
      final data = response.data;

      // Extract edition data (use first edition if available)
      final editions = data['editions'] as List?;
      final firstEdition = editions?.isNotEmpty == true ? editions!.first : null;

      // Get overview from book or first edition
      String? overview = data['overview'];
      if ((overview == null || overview.isEmpty) && firstEdition != null) {
        overview = firstEdition['overview'];
      }

      // Get pageCount from first edition
      int? pageCount = firstEdition?['pageCount'];

      // Get rating value
      double? rating = data['ratings']?['value']?.toDouble();

      // Get author name
      String? authorName = data['author']?['authorName'];

      return ReadarrBookData(
        bookID: data['id'] ?? -1,
        title: data['title'] ?? 'Unknown Book Title',
        monitored: data['monitored'] ?? false,
        releaseDate: data['releaseDate'] ?? '',
        editionCount: editions?.length ?? 0,
        grabbed: data['grabbed'] ?? false,
        authorID: data['authorId'],
        overview: overview,
        pageCount: pageCount,
        rating: rating,
        authorName: authorName,
        images: data['images'] as List?,
        links: data['links'] as List?,
        editionsData: editions,
      );
    } on DioException catch (error, stack) {
      logError('Failed to fetch book ($bookID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch book ($bookID)', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrBookFileData>> getBookFilesForAuthor(int authorID) async {
    try {
      Response response = await _dio.get('bookfile', queryParameters: {
        'authorId': authorID,
      });
      List<ReadarrBookFileData> entries = [];
      for (var entry in response.data) {
        entries.add(ReadarrBookFileData(
          id: entry['id'] ?? -1,
          bookID: entry['bookId'],
          authorID: entry['authorId'],
          path: entry['path'],
          size: entry['size'],
          dateAdded: entry['dateAdded'] != null
              ? DateTime.tryParse(entry['dateAdded'])
              : null,
          quality: entry['quality']?['quality']?['name'],
        ));
      }
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch book files for author ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch book files for author ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrRootFolder>> getRootFolders() async {
    try {
      Response response = await _dio.get('rootfolder');
      List<ReadarrRootFolder> _entries = [];
      for (var entry in response.data) {
        _entries.add(ReadarrRootFolder(
          id: entry['id'] ?? -1,
          path: entry['path'] ?? 'Unknown Root Folder',
          freeSpace: entry['freeSpace'] ?? 0,
        ));
      }
      return _entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch root folders', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch root folders', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrHistoryData>> getHistory(
      {String sortKey = 'date',
      String sortDir = 'descending',
      int pageSize = 250}) async {
    try {
      Response response = await _dio.get('history', queryParameters: {
        'sortKey': sortKey,
        'pageSize': pageSize,
        'sortDirection': sortDir,
      });
      List<ReadarrHistoryData> _entries = [];
      for (var entry in response.data['records']) {
        switch (entry['eventType']) {
          case 'grabbed':
            {
              _entries.add(ReadarrHistoryDataGrabbed(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                indexer: entry['data']['indexer'] ?? 'Unknown Indexer',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'bookFileImported':
            {
              _entries.add(ReadarrHistoryDataBookFileImported(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                quality:
                    entry['quality']?['quality']?['name'] ?? 'Unknown Quality',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'bookImportIncomplete':
            {
              _entries.add(ReadarrHistoryDataBookImportIncomplete(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'downloadImported':
            {
              _entries.add(ReadarrHistoryDataDownloadImported(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                quality:
                    entry['quality']?['quality']?['name'] ?? 'Unknown Quality',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'bookFileDeleted':
            {
              _entries.add(ReadarrHistoryDataBookFileDeleted(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                reason: 'File Deleted',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'bookFileRenamed':
            {
              _entries.add(ReadarrHistoryDataBookFileRenamed(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          case 'bookFileRetagged':
            {
              _entries.add(ReadarrHistoryDataBookFileRetagged(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
          default:
            {
              _entries.add(ReadarrHistoryDataGeneric(
                title: entry['sourceTitle'] ?? 'Unknown Title',
                timestamp: entry['date'] ?? '',
                eventType: entry['eventType'] ?? 'Unknown Event Type',
                authorID: entry['authorId'] ?? -1,
                bookID: entry['bookId'] ?? -1,
              ));
              break;
            }
        }
      }
      return _entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch history', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch history', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrMissingData>> getMissing(
      {int pageSize = 250,
      String sortDir = 'descending',
      String sortKey = 'releaseDate',
      bool monitored = true}) async {
    try {
      Response response = await _dio.get('wanted/missing', queryParameters: {
        'pageSize': pageSize,
        'sortDirection': sortDir,
        'sortKey': sortKey,
        'monitored': monitored,
      });
      List<ReadarrMissingData> entries = [];
      for (var entry in response.data['records']) {
        entries.add(ReadarrMissingData(
          title: entry['title'] ?? 'Unknown Title',
          authorTitle: entry['author']?['authorName'] ?? 'Unknown Author',
          authorID: entry['authorId'] ?? -1,
          bookID: entry['id'] ?? -1,
          releaseDate: entry['releaseDate'] ?? '',
          monitored: entry['monitored'] ?? false,
        ));
      }
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch missing books', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch missing books', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> setBookMonitored(List<int> bookIds, bool monitored) async {
    try {
      await _dio.put(
        'book/monitor',
        data: json.encode({
          'bookIds': bookIds,
          'monitored': monitored,
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to set book monitoring (${bookIds.toString()})', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to set book monitoring (${bookIds.toString()})', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> searchBooks(List<int> books) async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'BookSearch',
          'bookIds': books,
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to search for books (${books.toString()})', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to search for books (${books.toString()})', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> searchAllMissing() async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'MissingBookSearch',
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to search for all missing books', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to search for all missing books', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> updateLibrary() async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'RefreshAuthor',
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to update library', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to update library', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> triggerRssSync() async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'RssSync',
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to trigger RSS sync', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to trigger RSS sync', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> triggerBackup() async {
    try {
      await _dio.post(
        'command',
        data: json.encode({
          'name': 'Backup',
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to backup database', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to backup database', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> toggleAuthorMonitored(int authorID, bool status) async {
    try {
      Response response = await _dio.get('author/$authorID');
      Map body = response.data;
      body['monitored'] = status;
      response = await _dio.put(
        'author',
        data: json.encode(body),
      );
      return true;
    } on DioException catch (error, stack) {
      logError(
          'Failed to toggle author monitored status ($authorID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError(
          'Failed to toggle author monitored status ($authorID)', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> toggleBookMonitored(int bookID, bool status) async {
    try {
      Response response = await _dio.get('book/$bookID');
      Map body = response.data;
      body['monitored'] = status;
      response = await _dio.put(
        'book',
        data: json.encode(body),
      );
      return true;
    } on DioException catch (error, stack) {
      logError(
          'Failed to toggle book monitored status ($bookID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError(
          'Failed to toggle book monitored status ($bookID)', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrSearchData>> searchAuthors(String search) async {
    if (search == '') return [];
    try {
      Response response = await _dio.get('author/lookup', queryParameters: {
        'term': search,
      });
      List<ReadarrSearchData> entries = [];
      for (var entry in response.data) {
        entries.add(ReadarrSearchData(
          title: entry['authorName'] ?? 'Unknown Author Name',
          foreignAuthorId: entry['foreignAuthorId'] ?? '',
          overview: entry['overview'] == null || entry['overview'] == ''
              ? 'No Summary Available'
              : entry['overview'],
          tadbId: entry['tadbId'] ?? 0,
          links: entry['links'] ?? [],
          images: entry['images'] ?? [],
        ));
      }
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to search ($search)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to search ($search)', error, stack);
      return Future.error(error);
    }
  }

  Future<int?> addAuthor(
      ReadarrSearchData entry,
      ReadarrQualityProfile quality,
      ReadarrRootFolder rootFolder,
      ReadarrMetadataProfile metadata,
      ReadarrMonitorStatus monitorStatus,
      {bool? search = false}) async {
    try {
      Response response = await _dio.post(
        'author',
        data: json.encode({
          'authorName': entry.title,
          'foreignAuthorId': entry.foreignAuthorId,
          'qualityProfileId': quality.id,
          'metadataProfileId': metadata.id,
          'rootFolderPath': rootFolder.path,
          'monitored': monitorStatus != ReadarrMonitorStatus.NONE,
          'addOptions': {
            'searchForMissingBooks': search,
            'monitor': monitorStatus.key,
          },
        }),
      );
      return response.data['id'];
    } on DioException catch (error, stack) {
      logError('Failed to add author (${entry.title})', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to add author (${entry.title})', error, stack);
      return Future.error(error);
    }
  }

  Future<List<ReadarrReleaseData>> getReleases(int bookID) async {
    try {
      Response response = await _dio.get(
        'release',
        queryParameters: {
          'bookId': bookID,
        },
      );
      List<ReadarrReleaseData> entries = [];
      for (var entry in response.data) {
        entries.add(ReadarrReleaseData(
          title: entry['title'] ?? 'Unknown Title',
          guid: entry['guid'] ?? '',
          quality: entry['quality']['quality']['name'] ?? 'Unknown',
          protocol: entry['protocol'] ?? 'Unknown Protocol',
          indexer: entry['indexer'] ?? 'Unknown Indexer',
          infoUrl: entry['infoUrl'] ?? '',
          approved: entry['approved'] ?? false,
          releaseWeight: entry['releaseWeight'] ?? 0,
          size: entry['size'] ?? 0,
          indexerId: entry['indexerId'] ?? 0,
          ageHours: entry['ageHours']?.toDouble() ?? 0.0,
          rejections: entry['rejections'] ?? [],
          seeders: entry['seeders'] ?? 0,
          leechers: entry['leechers'] ?? 0,
        ));
      }
      return entries;
    } on DioException catch (error, stack) {
      logError('Failed to fetch releases ($bookID)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to fetch releases ($bookID)', error, stack);
      return Future.error(error);
    }
  }

  Future<bool> downloadRelease(String guid, int indexerId) async {
    try {
      await _dio.post(
        'release',
        data: json.encode({
          'guid': guid,
          'indexerId': indexerId,
        }),
      );
      return true;
    } on DioException catch (error, stack) {
      logError('Failed to download release ($guid)', error, stack);
      return Future.error(error);
    } catch (error, stack) {
      logError('Failed to download release ($guid)', error, stack);
      return Future.error(error);
    }
  }
}
