/// Store details about credits for a person who has worked on the series.
///
/// Unlike Radarr which gets credits from its API, Sonarr credits come from
/// TMDB API since Sonarr doesn't have a native credits endpoint.
class SonarrSeriesCredits {
  /// Person's name
  String? personName;

  /// TMDB person ID (for linking to person details)
  int? personTmdbId;

  /// Character name (for cast members)
  String? character;

  /// Job title (for crew members)
  String? job;

  /// Department (for crew members)
  String? department;

  /// Type: 'cast' or 'crew'
  String? type;

  /// Display order (lower numbers appear first)
  int? order;

  /// TMDB profile image path (e.g., '/j7d083zIMhwnKro3tQqDz2Fq1UD.jpg')
  String? profilePath;

  /// Associated series ID
  int? seriesId;

  SonarrSeriesCredits({
    this.personName,
    this.personTmdbId,
    this.character,
    this.job,
    this.department,
    this.type,
    this.order,
    this.profilePath,
    this.seriesId,
  });

  /// Create from TMDB cast member data
  factory SonarrSeriesCredits.fromTmdbCast(
    Map<String, dynamic> json,
    int seriesId,
  ) {
    return SonarrSeriesCredits(
      personName: json['name'],
      personTmdbId: json['id'],
      character: json['character'],
      type: 'cast',
      order: json['order'],
      profilePath: json['profile_path'],
      seriesId: seriesId,
    );
  }

  /// Create from TMDB crew member data
  factory SonarrSeriesCredits.fromTmdbCrew(
    Map<String, dynamic> json,
    int seriesId,
  ) {
    return SonarrSeriesCredits(
      personName: json['name'],
      personTmdbId: json['id'],
      job: json['job'],
      department: json['department'],
      type: 'crew',
      profilePath: json['profile_path'],
      seriesId: seriesId,
    );
  }
}
