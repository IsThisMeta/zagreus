/// Library containing all utility functions for Seerr data.
library seerr_utilities;

import 'package:zagreus/api/seerr/types.dart';

/// [SeerrUtilities] gives access to static, functional operations.
/// These are mainly used for the (de)serialization of received JSON data.
///
/// [SeerrUtilities] cannot be initialized, all available functions are available statically.
class SeerrUtilities {
  SeerrUtilities._();

  static DateTime? dateTimeFromJson(String? date) =>
      DateTime.tryParse(date ?? '');
  static String? dateTimeToJson(DateTime? date) => date?.toIso8601String();

  /**
   * Seerr Types
   */

  /// Converts an integer to an [SeerrRequestStatus] object.
  static SeerrRequestStatus? requestStatusFromJson(int? status) {
    if (status == null) return null;
    return SeerrRequestStatus.fromValue(status);
  }

  /// Converts an [SeerrRequestStatus] object back to its integer representation.
  static int? requestStatusToJson(SeerrRequestStatus? status) =>
      status?.value;

  /// Converts an integer to an [SeerrIssueType] object.
  static SeerrIssueType? issueTypeFromJson(int? type) {
    if (type == null) return null;
    return SeerrIssueType.fromValue(type);
  }

  /// Converts an [SeerrIssueType] object back to its integer representation.
  static int? issueTypeToJson(SeerrIssueType? type) => type?.value;

  /// Converts an integer to an [SeerrIssueStatus] object.
  static SeerrIssueStatus? issueStatusFromJson(int? status) {
    if (status == null) return null;
    return SeerrIssueStatus.fromValue(status);
  }

  /// Converts an [SeerrIssueStatus] object back to its integer representation.
  static int? issueStatusToJson(SeerrIssueStatus? status) => status?.value;

  /// Converts an integer to an [SeerrMediaStatus] object.
  static SeerrMediaStatus? mediaStatusFromJson(int? status) {
    if (status == null) return null;
    return SeerrMediaStatus.fromValue(status);
  }

  /// Converts an [SeerrMediaStatus] object back to its integer representation.
  static int? mediaStatusToJson(SeerrMediaStatus? status) => status?.value;
}
