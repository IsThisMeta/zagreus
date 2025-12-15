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
              title: 'Request Approved',
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'Failed to Approve Request',
              error: 'Unable to approve request',
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
              title: 'Request Declined',
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'Failed to Decline Request',
              error: 'Unable to decline request',
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
              title: 'Request Deleted',
              message: request.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'Failed to Delete Request',
              error: 'Unable to delete request',
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
              title: 'Issue Resolved',
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'Failed to Resolve Issue',
              error: 'Unable to resolve issue',
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
              title: 'Issue Reopened',
              message: issue.media.getTitle(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'Failed to Reopen Issue',
              error: 'Unable to reopen issue',
            );
          }
        }
        return success;
      });
    }
    return false;
  }
}
