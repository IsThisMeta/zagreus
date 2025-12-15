part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to tags within Readarr.
class ReadarrControllerTag {
  final Dio _client;

  ReadarrControllerTag(this._client);

  /// Handler for `GET /api/v1/tag`.
  ///
  /// Get all tags.
  Future<List<ReadarrTag>> getAll() async => _commandGetAllTags(_client);

  /// Handler for `GET /api/v1/tag/{id}`.
  ///
  /// Get tag by ID.
  Future<ReadarrTag> get({required int tagId}) async =>
      _commandGetTag(_client, tagId: tagId);

  /// Handler for `POST /api/v1/tag`.
  ///
  /// Create a new tag.
  Future<ReadarrTag> create({required String label}) async =>
      _commandAddTag(_client, label: label);

  /// Handler for `PUT /api/v1/tag/{id}`.
  ///
  /// Update a tag.
  Future<ReadarrTag> update({required int tagId, required String label}) async =>
      _commandUpdateTag(_client, tagId: tagId, label: label);

  /// Handler for `DELETE /api/v1/tag/{id}`.
  ///
  /// Delete a tag.
  Future<void> delete({required int tagId}) async =>
      _commandDeleteTag(_client, tagId: tagId);
}
