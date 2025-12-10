part of bazarr_controllers;

Future<BazarrMovie?> _controllerGetMovie(Dio client, int radarrId) async {
  Response response = await client.get(
    'movies',
    queryParameters: {'radarrid[]': radarrId},
  );

  // Response is a list, we want the first item matching our radarrId
  if (response.data is List && (response.data as List).isNotEmpty) {
    final data = response.data as List;
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final movie = BazarrMovie.fromJson(item);
        if (movie.radarrId == radarrId) {
          return movie;
        }
      }
    }
  }
  return null;
}
