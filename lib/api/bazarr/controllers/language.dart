part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to language profiles within Bazarr.
class BazarrControllerLanguage {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerLanguage(this._client);

  /// Handler for `system/languages/profiles`.
  ///
  /// Returns all language profiles configured in Bazarr.
  Future<List<BazarrLanguageProfile>> getProfiles() async =>
      _controllerGetLanguageProfiles(_client);
}
