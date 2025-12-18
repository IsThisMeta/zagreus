import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationTautulliRoute extends StatefulWidget {
  const ConfigurationTautulliRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationTautulliRoute> createState() => _State();
}

class _State extends State<ConfigurationTautulliRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    final instanceName = ZagProfile.getActiveInstanceName('tautulli');
    final title = instanceName != null
        ? '${ZagModule.TAUTULLI.title} $instanceName'
        : ZagModule.TAUTULLI.title;
    
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'tautulli');
    final hasInstances = instances.isNotEmpty;
    
    return ZagAppBar(
      title: title,
      scrollControllers: [scrollController],
      actions: [
        if (hasInstances)
          ZagIconButton(
            icon: Icons.swap_horiz_rounded,
            onPressed: _showInstanceSelector,
          ),
      ],
    );
  }

  void _showInstanceSelector() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'tautulli');
    final currentInstance = ZagInstanceContext().getActiveInstance('tautulli');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Instance', style: TextStyle(color: ZagColours.textColor(ctx))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.TAUTULLI.title
                : '${ZagModule.TAUTULLI.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name, style: TextStyle(color: ZagColours.textColor(ctx))),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.TAUTULLI.color)
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(ctx, instanceKey),
            );
          }).toList(),
        ),
      ),
    );
    
    if (!mounted) return;
    
    final didSelect = result != null || (result == null && currentInstance != null);
    if (didSelect && result != currentInstance) {
      ZagInstanceContext().setActiveInstance('tautulli', result);
      setState(() {});
    }
  }

  Widget _body() {
    final instanceName = ZagProfile.getActiveInstanceName('tautulli');
    final isInstance = instanceName != null;
    
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.TAUTULLI.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _activityRefreshRate(),
        _defaultPagesPage(),
        _defaultTerminationMessage(),
        _statisticsItemCount(),
        ZagDivider(),
        if (isInstance) ...[
          _renameInstance(),
          _deleteInstance(),
        ] else _addDuplicateInstance(),
      ],
    );
  }

  Widget _enabledToggle() {
    final instanceName = ZagProfile.getActiveInstanceName('tautulli');
    final displayName = instanceName != null
        ? '${ZagModule.TAUTULLI.title} $instanceName'
        : ZagModule.TAUTULLI.title;
    
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [displayName]),
        trailing: ZagSwitch(
          value: ZagProfile.forModule('tautulli').tautulliEnabled,
          onChanged: (value) {
            final profile = ZagProfile.forModule('tautulli');
            profile.tautulliEnabled = value;
            profile.save();
            context.read<TautulliState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZagModule.TAUTULLI.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_TAUTULLI_DEFAULT_PAGES.go,
    );
  }

  Widget _defaultTerminationMessage() {
    const _db = TautulliDatabase.TERMINATION_MESSAGE;
    return _db.listenableBuilder(
      builder: (context, _) {
        String message = _db.read();
        return ZagBlock(
          title: 'tautulli.DefaultTerminationMessage'.tr(),
          body: [
            TextSpan(text: message.isEmpty ? 'zagreus.NotSet'.tr() : message),
          ],
          trailing: const ZagIconButton(icon: Icons.videocam_off_rounded),
          onTap: () async {
            Tuple2<bool, String> result =
                await TautulliDialogs.setTerminationMessage(context);
            if (result.item1) _db.update(result.item2);
          },
        );
      },
    );
  }

  Widget _activityRefreshRate() {
    const _db = TautulliDatabase.REFRESH_RATE;
    return _db.listenableBuilder(builder: (context, _) {
      String refreshRate = _db.read() == 1
          ? 'zagreus.EverySecond'.tr()
          : 'zagreus.EverySeconds'.tr(args: [_db.read().toString()]);
      return ZagBlock(
        title: 'tautulli.ActivityRefreshRate'.tr(),
        body: [TextSpan(text: refreshRate)],
        trailing: const ZagIconButton(icon: ZagIcons.REFRESH),
        onTap: () async {
          List<dynamic> _values = await TautulliDialogs.setRefreshRate(context);
          if (_values[0]) _db.update(_values[1]);
        },
      );
    });
  }

  Widget _statisticsItemCount() {
    const _db = TautulliDatabase.STATISTICS_STATS_COUNT;
    return _db.listenableBuilder(
      builder: (context, _) {
        String statisticsItems = _db.read() == 1
            ? 'zagreus.OneItem'.tr()
            : 'zagreus.Items'.tr(args: [_db.read().toString()]);
        return ZagBlock(
          title: 'tautulli.StatisticsItemCount'.tr(),
          body: [TextSpan(text: statisticsItems)],
          trailing: const ZagIconButton(icon: Icons.format_list_numbered),
          onTap: () async {
            List<dynamic> _values =
                await TautulliDialogs.setStatisticsItemCount(context);
            if (_values[0]) _db.update(_values[1]);
          },
        );
      },
    );
  }

  Widget _addDuplicateInstance() {
    return ZagBlock(
      title: 'Add Duplicate Instance',
      body: [
        TextSpan(
          text: 'Create another ${ZagModule.TAUTULLI.title} instance',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.ADD),
      onTap: () async {
        final controller = TextEditingController();
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Instance Name', style: TextStyle(color: ZagColours.textColor(context))),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g., Home, Remote',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ZagColours.currentAccent),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: ZagColours.currentAccent.withOpacity(ZagUI.OPACITY_SPLASH),
                  ),
                ),
              ),
              autofocus: true,
              cursorColor: ZagColours.currentAccent,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            actions: [
              ZagDialog.cancel(context),
              ZagDialog.button(
                text: 'Create',
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ],
          ),
        );

        if (result == null || result.isEmpty) return;

        if (result.contains('_')) {
          showZagErrorSnackBar(
            title: 'Invalid Name',
            message: 'Instance names cannot contain underscores',
          );
          return;
        }

        final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
        final shadowKey = await ZagProfile.createInstance(
          moduleKey: ZagModule.TAUTULLI.key,
          instanceName: result,
          parentProfile: currentProfile,
        );

        if (shadowKey == null) {
          showZagErrorSnackBar(
            title: 'Failed to Create Instance',
            message: 'An instance with that name may already exist',
          );
          return;
        }

        showZagSuccessSnackBar(
          title: 'Instance Created',
          message: '${ZagModule.TAUTULLI.title} $result has been added',
        );

        ZagDrawer.clearModuleOrderCache();
        setState(() {});
      },
    );
  }

  Widget _renameInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('tautulli');
    final instanceKey = ZagInstanceContext().getActiveInstance('tautulli');
    
    return ZagBlock(
      title: 'Rename Instance',
      body: [
        TextSpan(
          text: 'Change the name of ${ZagModule.TAUTULLI.title} $instanceName',
        ),
      ],
      trailing: const ZagIconButton(icon: Icons.edit_rounded),
      onTap: () async {
        final controller = TextEditingController(text: instanceName);
        
        final newName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Rename Instance', style: TextStyle(color: ZagColours.textColor(context))),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Instance Name',
                hintText: 'e.g. Main, Kids',
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Rename'),
              ),
            ],
          ),
        );

        if (newName == null || newName.trim().isEmpty || instanceKey == null) return;
        
        if (newName.contains('_')) {
          showZagErrorSnackBar(
            title: 'Invalid Name',
            message: 'Instance names cannot contain underscores',
          );
          return;
        }

        final newKey = await ZagProfile.renameInstance(instanceKey, newName);
        if (newKey == null) {
          showZagErrorSnackBar(
            title: 'Rename Failed',
            message: 'Could not rename the instance',
          );
          return;
        }
        
        // Update active instance to new key
        ZagInstanceContext().setActiveInstance('tautulli', newKey);
        
        // Refresh drawer
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Renamed',
          message: '${ZagModule.TAUTULLI.title} is now "$newName"',
        );

        setState(() {});
      },
    );
  }

  Widget _deleteInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('tautulli');
    final instanceKey = ZagInstanceContext().getActiveInstance('tautulli');
    
    return ZagBlock(
      title: 'Delete Instance',
      body: [
        TextSpan(
          text: 'Remove ${ZagModule.TAUTULLI.title} $instanceName and its settings',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.DELETE),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Instance?', style: TextStyle(color: ZagColours.textColor(context))),
            content: Text(
              'Are you sure you want to delete ${ZagModule.TAUTULLI.title} $instanceName? This cannot be undone.',
              style: TextStyle(color: ZagColours.textColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm != true || instanceKey == null) return;

        await ZagProfile.deleteInstance(instanceKey);
        ZagInstanceContext().clearActiveInstance('tautulli');
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Deleted',
          message: '${ZagModule.TAUTULLI.title} $instanceName has been removed',
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
