part of bazarr_controllers;

Future<List<BazarrEpisode>> _controllerGetEpisodes(Dio client, int seriesId) async {
  Response response = await client.get(
    'episodes',
    queryParameters: {'seriesid[]': seriesId},
  );

  final List<BazarrEpisode> episodes = [];
  final List<dynamic> data;
  if (response.data is Map && response.data['data'] is List) {
    data = response.data['data'] as List;
  } else if (response.data is List) {
    data = response.data as List;
  } else {
    data = const [];
  }
  for (final item in data) {
    if (item is Map<String, dynamic>) {
      episodes.add(BazarrEpisode.fromJson(item));
    }
  }
  return episodes;
}
