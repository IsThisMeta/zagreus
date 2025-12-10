part of bazarr_controllers;

Future<BazarrSeries?> _controllerGetSeries(Dio client, int seriesId) async {
  Response response = await client.get(
    'series',
    queryParameters: {'seriesid[]': seriesId},
  );

  // Response is a list, we want the first item matching our seriesId
  if (response.data is List && (response.data as List).isNotEmpty) {
    final data = response.data as List;
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final series = BazarrSeries.fromJson(item);
        if (series.sonarrSeriesId == seriesId) {
          return series;
        }
      }
    }
  }
  return null;
}
