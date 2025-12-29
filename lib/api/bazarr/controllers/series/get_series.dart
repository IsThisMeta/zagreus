part of bazarr_controllers;

Future<BazarrSeries?> _controllerGetSeries(Dio client, int seriesId) async {
  Response response = await client.get(
    'series',
    queryParameters: {'seriesid[]': seriesId},
  );

  final List<dynamic> data;
  if (response.data is Map && response.data['data'] is List) {
    data = response.data['data'] as List;
  } else if (response.data is List) {
    data = response.data as List;
  } else {
    data = const [];
  }

  BazarrSeries? fallback;
  for (final item in data) {
    if (item is Map<String, dynamic>) {
      final series = BazarrSeries.fromJson(item);
      fallback ??= series;
      if (series.sonarrSeriesId == seriesId) {
        return series;
      }
    }
  }
  return fallback;
}
