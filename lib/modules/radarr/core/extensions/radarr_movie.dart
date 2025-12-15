import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/int/duration.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrMovieExtension on RadarrMovie {
  String get zagRuntime {
    return this.runtime.asVideoDuration();
  }

  String get zagAlternateTitles {
    if (this.alternateTitles?.isNotEmpty ?? false) {
      return this.alternateTitles!.map((title) => title.title).join('\n');
    }
    return ZagUI.TEXT_EMDASH;
  }

  String get zagGenres {
    if (this.genres?.isNotEmpty ?? false) return this.genres!.join('\n');
    return ZagUI.TEXT_EMDASH;
  }

  String get zagStudio {
    if (this.studio?.isNotEmpty ?? false) return this.studio!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagYear {
    if (this.year != null && this.year != 0) return this.year.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String get zagMinimumAvailability {
    if (this.minimumAvailability != null) {
      return this.minimumAvailability!.readable;
    }
    return ZagUI.TEXT_EMDASH;
  }

  String zagDateAdded([bool short = false]) {
    if (this.added != null) return this.added!.asDateOnly(shortenMonth: short);
    return ZagUI.TEXT_EMDASH;
  }

  bool get zagIsInCinemas {
    if (this.inCinemas != null)
      return this.inCinemas!.toLocal().isBefore(DateTime.now());
    return false;
  }

  String zagInCinemasOn([bool short = false]) {
    if (this.inCinemas != null)
      return this.inCinemas!.asDateOnly(shortenMonth: short);
    return ZagUI.TEXT_EMDASH;
  }

  String zagPhysicalReleaseDate([bool short = false]) {
    if (this.physicalRelease != null)
      return this.physicalRelease!.asDateOnly(shortenMonth: short);
    return ZagUI.TEXT_EMDASH;
  }

  String zagDigitalReleaseDate([bool short = false]) {
    if (this.digitalRelease != null)
      return this.digitalRelease!.asDateOnly(shortenMonth: short);
    return ZagUI.TEXT_EMDASH;
  }

  String get zagReleaseDate {
    if (this.zagEarlierReleaseDate != null)
      return this.zagEarlierReleaseDate!.asDateOnly();
    return ZagUI.TEXT_EMDASH;
  }

  String zagTags(List<RadarrTag> tags) {
    if (tags.isNotEmpty) return tags.map<String?>((t) => t.label).join('\n');
    return ZagUI.TEXT_EMDASH;
  }

  bool get zagIsReleased {
    if (this.status == RadarrAvailability.RELEASED) return true;
    if (this.digitalRelease != null)
      return this.digitalRelease!.toLocal().isBefore(DateTime.now());
    if (this.physicalRelease != null)
      return this.physicalRelease!.toLocal().isBefore(DateTime.now());
    return false;
  }

  String get zagFileSize {
    if (!this.hasFile!) return ZagUI.TEXT_EMDASH;
    return this.sizeOnDisk.asBytes();
  }

  Text zagHasFileTextObject() {
    if (this.hasFile!)
      return Text(
        zagFileSize,
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontSize: ZagUI.FONT_SIZE_H3,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );
    return const Text(
      '',
      style: TextStyle(
        fontSize: ZagUI.FONT_SIZE_H3,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  Text zagNextReleaseTextObject() {
    DateTime now = DateTime.now();
    // If we already have a file or it is released
    if (this.hasFile! || zagIsReleased)
      return const Text(
        '',
        style: TextStyle(fontSize: ZagUI.FONT_SIZE_H3),
      );
    // In Cinemas
    if (this.inCinemas != null && this.inCinemas!.toLocal().isAfter(now)) {
      String _date = this.inCinemas!.asDaysDifference().toUpperCase();
      return Text(
        _date == 'TODAY' ? _date : 'IN $_date',
        style: const TextStyle(
          color: ZagColours.orange,
          fontSize: ZagUI.FONT_SIZE_H3,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );
    }
    DateTime? _release = zagEarlierReleaseDate;
    // Releases
    if (_release != null) {
      String _date = _release.asDaysDifference().toUpperCase();
      return Text(
        _date == 'TODAY' ? _date : 'IN $_date',
        style: const TextStyle(
          color: ZagColours.blue,
          fontSize: ZagUI.FONT_SIZE_H3,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );
    }
    // Unknown case
    return const Text(
      '',
      style: TextStyle(
        fontSize: ZagUI.FONT_SIZE_H3,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  /// Compare two movies by their release dates. Returns an integer value compatible with `.sort()` in arrays.
  ///
  /// Compares and uses the earlier date between `physicalRelease` and `digitalRelease`.
  int zagCompareToByReleaseDate(RadarrMovie movie) {
    if (this.physicalRelease == null &&
        this.digitalRelease == null &&
        movie.physicalRelease == null &&
        movie.digitalRelease == null)
      return this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    if (this.physicalRelease == null && this.digitalRelease == null) return 1;
    if (movie.physicalRelease == null && movie.digitalRelease == null)
      return -1;
    DateTime a = (this.physicalRelease ?? DateTime(9999))
            .isBefore((this.digitalRelease ?? DateTime(9999)))
        ? this.physicalRelease!
        : this.digitalRelease!;
    DateTime b = (movie.physicalRelease ?? DateTime(9999))
            .isBefore((movie.digitalRelease ?? DateTime(9999)))
        ? movie.physicalRelease!
        : movie.digitalRelease!;
    int comparison = a.compareTo(b);
    if (comparison == 0)
      comparison = this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    return comparison;
  }

  /// Compare two movies by their cinema release date. Returns an integer value compatible with `.sort()` in arrays.
  int zagCompareToByInCinemas(RadarrMovie movie) {
    if (this.inCinemas == null && movie.inCinemas == null)
      return this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    if (this.inCinemas == null) return 1;
    if (movie.inCinemas == null) return -1;
    int comparison = this.inCinemas!.compareTo(movie.inCinemas!);
    if (comparison == 0)
      comparison = this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    return comparison;
  }

  /// Compares the digital and physical release dates and returns the earlier date.
  ///
  /// If both are null, returns null.
  DateTime? get zagEarlierReleaseDate {
    if (this.physicalRelease == null && this.digitalRelease == null)
      return null;
    if (this.physicalRelease == null) return this.digitalRelease;
    if (this.digitalRelease == null) return this.physicalRelease;
    return this.digitalRelease!.isBefore(this.physicalRelease!)
        ? this.digitalRelease
        : this.physicalRelease;
  }

  /// Creates a clone of the [RadarrMovie] object (deep copy).
  RadarrMovie clone() => RadarrMovie.fromJson(this.toJson());

  /// Copies changes from a [RadarrMoviesEditState] state object into a new [RadarrMovie] object.
  RadarrMovie updateEdits(RadarrMoviesEditState edits) {
    RadarrMovie movie = this.clone();
    movie.monitored = edits.monitored;
    movie.minimumAvailability = edits.availability;
    movie.qualityProfileId = edits.qualityProfile.id ?? this.qualityProfileId;
    movie.path = edits.path;
    movie.tags = edits.tags.map((t) => t.id).toList();
    return movie;
  }
}
