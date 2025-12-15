part of bazarr_controllers;

Future<List<BazarrLanguageProfile>> _controllerGetLanguageProfiles(Dio client) async {
  Response response = await client.get('system/languages/profiles');

  final List<BazarrLanguageProfile> profiles = [];
  if (response.data is List) {
    for (final item in response.data as List) {
      if (item is Map<String, dynamic>) {
        profiles.add(BazarrLanguageProfile.fromJson(item));
      }
    }
  }
  return profiles;
}
