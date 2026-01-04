import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';

class SABnzbdQueueTile extends StatefulWidget {
  final int index;
  final SABnzbdQueueData data;
  final Function refresh;
  final BuildContext queueContext;

  const SABnzbdQueueTile({
    required this.data,
    required this.index,
    required this.queueContext,
    required this.refresh,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SABnzbdQueueTile> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<SABnzbdState>();
    final isMultiSelect = state.isMultiSelectMode;
    final isSelected = state.isSelected(widget.data.nzoId);

    Color progressColor = widget.data.isPaused
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black)
        : ZagColours.currentAccent;

    return ZagBlock(
      title: widget.data.name,
      body: [TextSpan(text: widget.data.subtitle)],
      bottomHeight: ZagLinearPercentIndicator.compactHeight,
      bottom: ZagLinearPercentIndicator(
        compact: true,
        percent: min(1.0, max(0, widget.data.percentageDone / 100)),
        progressColor: progressColor,
      ),
      leading: isMultiSelect
          ? ZagIconButton(
              icon: isSelected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: isSelected ? ZagColours.currentAccent : ZagColours.grey,
              onPressed: () => state.toggleSelection(widget.data.nzoId),
            )
          : null,
      trailing: isMultiSelect
          ? null
          : ZagReorderableListViewDragger(index: widget.index),
      onTap: isMultiSelect
          ? () => state.toggleSelection(widget.data.nzoId)
          : _handlePopup,
      onLongPress: isMultiSelect
          ? null
          : () => state.enterMultiSelectMode(widget.data.nzoId),
      backgroundColor: isSelected
          ? ZagColours.currentAccent.withValues(alpha: 0.15)
          : null,
    );
  }

  Future<void> _handlePopup() async {
    _Helper _helper = _Helper(widget.queueContext, widget.data, widget.refresh);
    List values = await SABnzbdDialogs.queueSettings(
        widget.queueContext, widget.data.name, widget.data.isPaused);
    if (values[0])
      switch (values[1]) {
        case 'status':
          widget.data.isPaused ? _helper._resumeJob() : _helper._pauseJob();
          break;
        case 'category':
          _helper._category();
          break;
        case 'priority':
          _helper._priority();
          break;
        case 'password':
          _helper._password();
          break;
        case 'rename':
          _helper._rename();
          break;
        case 'delete':
          _helper._delete();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }
}

class _Helper {
  final BuildContext context;
  final SABnzbdQueueData data;
  final Function refresh;

  _Helper(
    this.context,
    this.data,
    this.refresh,
  );

  Future<void> _pauseJob() async {
    await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
        .pauseSingleJob(data.nzoId)
        .then((_) {
      showZagSuccessSnackBar(
        title: 'Job Paused',
        message: data.name,
      );
      refresh();
    }).catchError((error) {
      showZagErrorSnackBar(
        title: 'Failed to Pause Job',
        error: error,
      );
    });
  }

  Future<void> _resumeJob() async {
    await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
        .resumeSingleJob(data.nzoId)
        .then((_) {
      showZagSuccessSnackBar(
        title: 'Job Resumed',
        message: data.name,
      );
      refresh();
    }).catchError((error) {
      showZagErrorSnackBar(
        title: 'Failed to Resume Job',
        error: error,
      );
    });
  }

  Future<void> _category() async {
    List<SABnzbdCategoryData> categories =
        await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd')).getCategories();
    List values = await SABnzbdDialogs.changeCategory(context, categories);
    if (values[0])
      await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
          .setCategory(data.nzoId, values[1])
          .then((_) {
        showZagSuccessSnackBar(
          title: values[1] == ''
              ? 'Category Set (No Category)'
              : 'Category Set (${values[1]})',
          message: data.name,
        );
        refresh();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Set Category',
          error: error,
        );
      });
  }

  Future<void> _priority() async {
    List values = await SABnzbdDialogs.changePriority(context);
    if (values[0])
      await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
          .setJobPriority(data.nzoId, values[1])
          .then((_) {
        showZagSuccessSnackBar(
          title: 'Priority Set (${(values[2])})',
          message: data.name,
        );
        refresh();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Set Priority',
          error: error,
        );
      });
  }

  Future<void> _rename() async {
    List values = await SABnzbdDialogs.renameJob(context, data.name);
    if (values[0])
      SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
          .renameJob(data.nzoId, values[1])
          .then((_) {
        showZagSuccessSnackBar(
          title: 'Job Renamed',
          message: values[1],
        );
        refresh();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Rename Job',
          error: error,
        );
      });
  }

  Future<void> _delete() async {
    List values = await SABnzbdDialogs.deleteJob(context);
    if (values[0])
      await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd')).deleteJob(data.nzoId).then((_) {
        showZagSuccessSnackBar(
          title: 'Job Deleted',
          message: data.name,
        );
        refresh();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Delete Job',
          error: error,
        );
      });
  }

  Future<void> _password() async {
    List values = await SABnzbdDialogs.setPassword(context);
    if (values[0])
      await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
          .setJobPassword(data.nzoId, data.name, values[1])
          .then((_) {
        showZagSuccessSnackBar(
          title: 'Job Password Set',
          message: data.name,
        );
        refresh();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Set Job Password',
          error: error,
        );
      });
  }
}
