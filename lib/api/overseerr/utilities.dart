/// Library containing all utility functions for Overseerr data.
library overseerr_utilities;

import 'package:zagreus/api/overseerr/types.dart';

/// [OverseerrUtilities] gives access to static, functional operations.
/// These are mainly used for the (de)serialization of received JSON data.
///
/// [OverseerrUtilities] cannot be initialized, all available functions are available statically.
class OverseerrUtilities {
  OverseerrUtilities._();

  static DateTime? dateTimeFromJson(String? date) =>
      DateTime.tryParse(date ?? '');
  static String? dateTimeToJson(DateTime? date) => date?.toIso8601String();

  /**
   * Overseerr Types
   */

  /// Converts an integer to an [OverseerrRequestStatus] object.
  static OverseerrRequestStatus? requestStatusFromJson(int? status) {
    if (status == null) return null;
    return OverseerrRequestStatus.fromValue(status);
  }

  /// Converts an [OverseerrRequestStatus] object back to its integer representation.
  static int? requestStatusToJson(OverseerrRequestStatus? status) =>
      status?.value;

  /// Converts an integer to an [OverseerrIssueType] object.
  static OverseerrIssueType? issueTypeFromJson(int? type) {
    if (type == null) return null;
    return OverseerrIssueType.fromValue(type);
  }

  /// Converts an [OverseerrIssueType] object back to its integer representation.
  static int? issueTypeToJson(OverseerrIssueType? type) => type?.value;

  /// Converts an integer to an [OverseerrIssueStatus] object.
  static OverseerrIssueStatus? issueStatusFromJson(int? status) {
    if (status == null) return null;
    return OverseerrIssueStatus.fromValue(status);
  }

  /// Converts an [OverseerrIssueStatus] object back to its integer representation.
  static int? issueStatusToJson(OverseerrIssueStatus? status) => status?.value;

  /// Converts an integer to an [OverseerrMediaStatus] object.
  static OverseerrMediaStatus? mediaStatusFromJson(int? status) {
    if (status == null) return null;
    return OverseerrMediaStatus.fromValue(status);
  }

  /// Converts an [OverseerrMediaStatus] object back to its integer representation.
  static int? mediaStatusToJson(OverseerrMediaStatus? status) => status?.value;
}
