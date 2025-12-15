part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to profiles within Readarr.
class ReadarrControllerProfile {
  final Dio _client;

  ReadarrControllerProfile(this._client);

  /// Handler for `GET /api/v1/qualityprofile`.
  ///
  /// Get quality profiles.
  Future<List<ReadarrQualityProfile>> getQualityProfiles() async =>
      _commandGetQualityProfiles(_client);

  /// Handler for `GET /api/v1/metadataprofile`.
  ///
  /// Get metadata profiles.
  Future<List<ReadarrMetadataProfile>> getMetadataProfiles() async =>
      _commandGetMetadataProfiles(_client);
}
