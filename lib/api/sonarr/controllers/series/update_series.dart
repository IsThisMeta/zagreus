part of sonarr_commands;

Future<SonarrSeries> _commandUpdateSeries(
  Dio client, {
  required SonarrSeries series,
  bool moveFiles = false,
}) async {
  Response response = await client.put(
    'series',
    data: series.toJson(),
    queryParameters: moveFiles ? {'moveFiles': true} : null,
  );
  return SonarrSeries.fromJson(response.data);
}
