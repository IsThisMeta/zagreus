/// Library containing all utilities and helpers for Readarr.
library readarr_utilities;

class ReadarrUtilities {
  ReadarrUtilities._();

  /// Convert a [DateTime] object to a JSON string for API requests.
  static String? dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

  /// Convert a JSON string to a [DateTime] object from API responses.
  static DateTime? dateTimeFromJson(String? dateTime) =>
      dateTime == null || dateTime.isEmpty ? null : DateTime.tryParse(dateTime);
}
