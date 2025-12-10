part of bazarr_controllers;

Future<void> _controllerDownloadMovieSubtitle(
  Dio client,
  int radarrId,
  String language,
  String provider,
  String subtitle,
  bool? hearingImpaired,
  bool? forced,
) async {
  await client.post(
    'providers/movies',
    data: {
      'radarrid': radarrId,
      'language': language,
      'provider': provider,
      'subtitle': subtitle,
      if (hearingImpaired != null) 'hi': hearingImpaired ? 'True' : 'False',
      if (forced != null) 'forced': forced ? 'True' : 'False',
    },
  );
}
