import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrAPIHelper {
  /// Approve a request
  Future<bool> approveRequest({
    required BuildContext context,
    required OverseerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<OverseerrState>().enabled) {
      return await context
          .read<OverseerrState>()
          .approveRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'overseerr.RequestApproved'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'overseerr.FailedToApproveRequest'.tr(),
              error: 'overseerr.UnableToApproveRequest'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }

  /// Decline a request
  Future<bool> declineRequest({
    required BuildContext context,
    required OverseerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<OverseerrState>().enabled) {
      return await context
          .read<OverseerrState>()
          .declineRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'overseerr.RequestDeclined'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'overseerr.FailedToDeclineRequest'.tr(),
              error: 'overseerr.UnableToDeclineRequest'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }

  /// Delete a request
  Future<bool> deleteRequest({
    required BuildContext context,
    required OverseerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<OverseerrState>().enabled) {
      return await context
          .read<OverseerrState>()
          .deleteRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'overseerr.RequestDeleted'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'overseerr.FailedToDeleteRequest'.tr(),
              error: 'overseerr.UnableToDeleteRequest'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }

  /// Resolve an issue
  Future<bool> resolveIssue({
    required BuildContext context,
    required OverseerrIssue issue,
    bool showSnackbar = true,
  }) async {
    if (context.read<OverseerrState>().enabled) {
      return await context
          .read<OverseerrState>()
          .resolveIssue(issue.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'overseerr.IssueResolved'.tr(),
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'overseerr.FailedToResolveIssue'.tr(),
              error: 'overseerr.UnableToResolveIssue'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }

  /// Reopen an issue
  Future<bool> reopenIssue({
    required BuildContext context,
    required OverseerrIssue issue,
    bool showSnackbar = true,
  }) async {
    if (context.read<OverseerrState>().enabled) {
      return await context
          .read<OverseerrState>()
          .reopenIssue(issue.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'overseerr.IssueReopened'.tr(),
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'overseerr.FailedToReopenIssue'.tr(),
              error: 'overseerr.UnableToReopenIssue'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }
}
