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
        headers: ZagProfile.current.readarrHeaders,
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
}
