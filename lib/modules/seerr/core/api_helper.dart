import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/seerr.dart';

class SeerrAPIHelper {
  /// Approve a request
  Future<bool> approveRequest({
    required BuildContext context,
    required SeerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<SeerrState>().enabled) {
      return await context
          .read<SeerrState>()
          .approveRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestApproved'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'seerr.FailedToApproveRequest'.tr(),
              error: 'seerr.UnableToApproveRequest'.tr(),
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
    required SeerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<SeerrState>().enabled) {
      return await context
          .read<SeerrState>()
          .declineRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestDeclined'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'seerr.FailedToDeclineRequest'.tr(),
              error: 'seerr.UnableToDeclineRequest'.tr(),
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
    required SeerrRequest request,
    bool showSnackbar = true,
  }) async {
    if (context.read<SeerrState>().enabled) {
      return await context
          .read<SeerrState>()
          .deleteRequest(request.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestDeleted'.tr(),
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'seerr.FailedToDeleteRequest'.tr(),
              error: 'seerr.UnableToDeleteRequest'.tr(),
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
    required SeerrIssue issue,
    bool showSnackbar = true,
  }) async {
    if (context.read<SeerrState>().enabled) {
      return await context
          .read<SeerrState>()
          .resolveIssue(issue.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.IssueResolved'.tr(),
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'seerr.FailedToResolveIssue'.tr(),
              error: 'seerr.UnableToResolveIssue'.tr(),
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
    required SeerrIssue issue,
    bool showSnackbar = true,
  }) async {
    if (context.read<SeerrState>().enabled) {
      return await context
          .read<SeerrState>()
          .reopenIssue(issue.id)
          .then((success) {
        if (showSnackbar) {
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.IssueReopened'.tr(),
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'seerr.FailedToReopenIssue'.tr(),
              error: 'seerr.UnableToReopenIssue'.tr(),
            );
          }
        }
        return success;
      });
    }
    return false;
  }
}
