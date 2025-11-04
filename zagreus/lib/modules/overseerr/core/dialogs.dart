import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

enum OverseerrRequestActionType {
  APPROVE,
  DECLINE,
  DELETE,
}

extension OverseerrRequestActionTypeExtension on OverseerrRequestActionType {
  String get name {
    switch (this) {
      case OverseerrRequestActionType.APPROVE:
        return 'Approve Request';
      case OverseerrRequestActionType.DECLINE:
        return 'Decline Request';
      case OverseerrRequestActionType.DELETE:
        return 'Delete Request';
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
}
