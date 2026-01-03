import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/seerr.dart';

enum SeerrRequestActionType {
  APPROVE,
  DECLINE,
  DELETE,
}

enum SeerrIssueActionType {
  CLOSE,
  REOPEN,
  ADD_COMMENT,
}

extension SeerrRequestActionTypeExtension on SeerrRequestActionType {
  String get name {
    switch (this) {
      case SeerrRequestActionType.APPROVE:
        return 'seerr.ApproveRequest'.tr();
      case SeerrRequestActionType.DECLINE:
        return 'seerr.DeclineRequest'.tr();
      case SeerrRequestActionType.DELETE:
        return 'seerr.DeleteRequest'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case SeerrRequestActionType.APPROVE:
        return Icons.check_circle_rounded;
      case SeerrRequestActionType.DECLINE:
        return Icons.cancel_rounded;
      case SeerrRequestActionType.DELETE:
        return Icons.delete_rounded;
    }
  }

  bool isAvailable(SeerrRequest request) {
    final status = SeerrRequestStatus.fromValue(request.status);
    switch (this) {
      case SeerrRequestActionType.APPROVE:
        return status == SeerrRequestStatus.PENDING;
      case SeerrRequestActionType.DECLINE:
        return status == SeerrRequestStatus.PENDING;
      case SeerrRequestActionType.DELETE:
        return true; // Can always delete
    }
  }
}

extension SeerrIssueActionTypeExtension on SeerrIssueActionType {
  String get name {
    switch (this) {
      case SeerrIssueActionType.CLOSE:
        return 'seerr.CloseIssue'.tr();
      case SeerrIssueActionType.REOPEN:
        return 'seerr.ReopenIssue'.tr();
      case SeerrIssueActionType.ADD_COMMENT:
        return 'seerr.AddComment'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case SeerrIssueActionType.CLOSE:
        return Icons.check_circle_rounded;
      case SeerrIssueActionType.REOPEN:
        return Icons.refresh_rounded;
      case SeerrIssueActionType.ADD_COMMENT:
        return Icons.comment_rounded;
    }
  }

  bool isAvailable(SeerrIssue issue) {
    final status = SeerrIssueStatus.fromValue(issue.status);
    switch (this) {
      case SeerrIssueActionType.CLOSE:
        return status == SeerrIssueStatus.OPEN;
      case SeerrIssueActionType.REOPEN:
        return status == SeerrIssueStatus.RESOLVED;
      case SeerrIssueActionType.ADD_COMMENT:
        return true; // Can always add comments
    }
  }
}

class SeerrDialogs {
  Future<Tuple2<bool, SeerrRequestActionType?>> requestActions(
    BuildContext context,
    SeerrRequest request,
  ) async {
    bool _flag = false;
    SeerrRequestActionType? _value;

    void _setValues(bool flag, SeerrRequestActionType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    final availableActions = SeerrRequestActionType.values
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

  Future<Tuple2<bool, SeerrIssueActionType?>> issueActions(
    BuildContext context,
    SeerrIssue issue,
  ) async {
    bool _flag = false;
    SeerrIssueActionType? _value;

    void _setValues(bool flag, SeerrIssueActionType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    final availableActions = SeerrIssueActionType.values
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
      title: 'seerr.AddComment'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'seerr.Add'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'seerr.Comment'.tr(),
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'seerr.CommentCannotBeEmpty'.tr();
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
