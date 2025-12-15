class ReadarrSearchData {
  String title;
  String foreignAuthorId;
  String? overview;
  int? tadbId;
  List<dynamic> links;
  List<dynamic> images;

  ReadarrSearchData({
    required this.title,
    required this.foreignAuthorId,
    required this.overview,
    required this.tadbId,
    required this.links,
    required this.images,
  });

  String? get bannerURI {
    for (var image in images) {
      if (image['coverType'] == 'banner') {
        return image['url'];
      }
    }
    return '';
  }

  String? get fanartURI {
    for (var image in images) {
      if (image['coverType'] == 'fanart') {
        return image['url'];
      }
    }
    return '';
  }

  String? get posterURI {
    for (var image in images) {
      if (image['coverType'] == 'poster') {
        return image['url'];
      }
    }
    return '';
  }

  String? get goodreadsLink {
    for (var link in links) {
      if (link['name'] == 'goodreads') {
        return link['url'];
      }
    }
    return '';
  }
}
