part of bazarr_controllers;

Future<List<BazarrSubtitleSearchResult>> _controllerSearchMovieSubtitles(
  Dio client,
  int radarrId,
) async {
  Response response = await client.get(
    'providers/movies',
    queryParameters: {'radarrid': radarrId},
  );

  final List<BazarrSubtitleSearchResult> results = [];
  if (response.data is Map && response.data['data'] is List) {
    for (final item in response.data['data'] as List) {
      if (item is Map<String, dynamic>) {
        results.add(BazarrSubtitleSearchResult.fromJson(item));
      }
    }
  } else if (response.data is List) {
    for (final item in response.data as List) {
      if (item is Map<String, dynamic>) {
        results.add(BazarrSubtitleSearchResult.fromJson(item));
      }
    }
  }
  return results;
}
