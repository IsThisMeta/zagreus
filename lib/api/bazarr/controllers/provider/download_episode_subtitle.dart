part of bazarr_controllers;

Future<void> _controllerDownloadEpisodeSubtitle(
  Dio client,
  int seriesId,
  int episodeId,
  String language,
  String provider,
  String subtitle,
  bool? hearingImpaired,
  bool? forced,
) async {
  await client.post(
    'providers/episodes',
    data: {
      'seriesid': seriesId,
      'episodeid': episodeId,
      'language': language,
      'provider': provider,
      'subtitle': subtitle,
      if (hearingImpaired != null) 'hi': hearingImpaired ? 'True' : 'False',
      if (forced != null) 'forced': forced ? 'True' : 'False',
    },
  );
}
