part of bazarr_controllers;

Future<List<BazarrEpisode>> _controllerGetEpisodes(Dio client, int seriesId) async {
  Response response = await client.get(
    'episodes',
    queryParameters: {'seriesid[]': seriesId},
  );

  final List<BazarrEpisode> episodes = [];
  if (response.data is List) {
    for (final item in response.data as List) {
      if (item is Map<String, dynamic>) {
        episodes.add(BazarrEpisode.fromJson(item));
      }
    }
  }
  return episodes;
}
