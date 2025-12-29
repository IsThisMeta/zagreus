part of bazarr_controllers;

Future<BazarrMovie?> _controllerGetMovie(Dio client, int radarrId) async {
  Response response = await client.get(
    'movies',
    queryParameters: {'radarrid[]': radarrId},
  );

  final List<dynamic> data;
  if (response.data is Map && response.data['data'] is List) {
    data = response.data['data'] as List;
  } else if (response.data is List) {
    data = response.data as List;
  } else {
    data = const [];
  }

  BazarrMovie? fallback;
  for (final item in data) {
    if (item is Map<String, dynamic>) {
      final movie = BazarrMovie.fromJson(item);
      fallback ??= movie;
      if (movie.radarrId == radarrId) {
        return movie;
      }
    }
  }
  return fallback;
}
