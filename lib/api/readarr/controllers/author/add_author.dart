part of readarr_commands;

Future<ReadarrAuthor> _commandAddAuthor(
  Dio client, {
  required ReadarrAuthor author,
  required ReadarrQualityProfile qualityProfile,
  required ReadarrMetadataProfile metadataProfile,
  required ReadarrRootFolder rootFolder,
  required bool monitored,
  String monitorNewItems = 'all',
  bool searchForMissingBooks = false,
}) async {
  Response response = await client.post(
    'author',
    data: {
      ...author.toJson(),
      'qualityProfileId': qualityProfile.id,
      'metadataProfileId': metadataProfile.id,
      'rootFolderPath': rootFolder.path,
      'monitored': monitored,
      'monitorNewItems': monitorNewItems,
      'addOptions': {
        'monitor': monitored ? 'all' : 'none',
        'searchForMissingBooks': searchForMissingBooks,
      },
    },
  );
  return ReadarrAuthor.fromJson(response.data);
}
