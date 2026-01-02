import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

enum OverseerrRequestActionType {
  APPROVE,
  DECLINE,
  DELETE,
}

enum OverseerrIssueActionType {
  CLOSE,
  REOPEN,
  ADD_COMMENT,
}

extension OverseerrRequestActionTypeExtension on OverseerrRequestActionType {
  String get name {
    switch (this) {
      case OverseerrRequestActionType.APPROVE:
        return 'overseerr.ApproveRequest'.tr();
      case OverseerrRequestActionType.DECLINE:
        return 'overseerr.DeclineRequest'.tr();
      case OverseerrRequestActionType.DELETE:
        return 'overseerr.DeleteRequest'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case OverseerrRequestActionType.APPROVE:
        return Icons.check_circle_rounded;
      case OverseerrRequestActionType.DECLINE:
        return Icons.cancel_rounded;
      case OverseerrRequestActionType.DELETE:
        return Icons.delete_rounded;
    }
  }

  bool isAvailable(OverseerrRequest request) {
    final status = OverseerrRequestStatus.fromValue(request.status);
    switch (this) {
      case OverseerrRequestActionType.APPROVE:
        return status == OverseerrRequestStatus.PENDING;
      case OverseerrRequestActionType.DECLINE:
        return status == OverseerrRequestStatus.PENDING;
      case OverseerrRequestActionType.DELETE:
        return true; // Can always delete
    }
  }
}

extension OverseerrIssueActionTypeExtension on OverseerrIssueActionType {
  String get name {
    switch (this) {
      case OverseerrIssueActionType.CLOSE:
        return 'overseerr.CloseIssue'.tr();
      case OverseerrIssueActionType.REOPEN:
        return 'overseerr.ReopenIssue'.tr();
      case OverseerrIssueActionType.ADD_COMMENT:
        return 'overseerr.AddComment'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case OverseerrIssueActionType.CLOSE:
        return Icons.check_circle_rounded;
      case OverseerrIssueActionType.REOPEN:
        return Icons.refresh_rounded;
      case OverseerrIssueActionType.ADD_COMMENT:
        return Icons.comment_rounded;
    }
  }

  bool isAvailable(OverseerrIssue issue) {
    final status = OverseerrIssueStatus.fromValue(issue.status);
    switch (this) {
      case OverseerrIssueActionType.CLOSE:
        return status == OverseerrIssueStatus.OPEN;
      case OverseerrIssueActionType.REOPEN:
        return status == OverseerrIssueStatus.RESOLVED;
      case OverseerrIssueActionType.ADD_COMMENT:
        return true; // Can always add comments
    }
  }
}

class OverseerrDialogs {
  Future<Tuple2<bool, OverseerrRequestActionType?>> requestActions(
    BuildContext context,
    OverseerrRequest request,
  ) async {
    bool _flag = false;
    OverseerrRequestActionType? _value;

    void _setValues(bool flag, OverseerrRequestActionType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    final availableActions = OverseerrRequestActionType.values
        .where((action) => action.isAvailable(request))
        .toList();

    await ZagDialog.dialog(
      context: context,
      title: request.media.getTitle(),
      content: List.generate(
        availableActions.length,
        (index) => ZagDialog.tile(
          text: availableActions[index].name,
          icon: availableActions[index].icon,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, availableActions[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, OverseerrIssueActionType?>> issueActions(
    BuildContext context,
    OverseerrIssue issue,
  ) async {
    bool _flag = false;
    OverseerrIssueActionType? _value;

    void _setValues(bool flag, OverseerrIssueActionType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    final availableActions = OverseerrIssueActionType.values
        .where((action) => action.isAvailable(issue))
        .toList();

    await ZagDialog.dialog(
      context: context,
      title: issue.media.getTitle(),
      content: List.generate(
        availableActions.length,
        (index) => ZagDialog.tile(
          text: availableActions[index].name,
          icon: availableActions[index].icon,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, availableActions[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, String>> addComment(BuildContext context) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'overseerr.AddComment'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'overseerr.Add'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'overseerr.Comment'.tr(),
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'overseerr.CommentCannotBeEmpty'.tr();
              }
              return null;
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );

    return Tuple2(_flag, _textController.text);
  }
}
