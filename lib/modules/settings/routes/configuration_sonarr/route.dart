import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';

class ConfigurationSonarrRoute extends StatefulWidget {
  const ConfigurationSonarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSonarrRoute> createState() => _State();
}

class _State extends State<ConfigurationSonarrRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Sync webhook when page loads
    _syncWebhook();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final title = instanceName != null
        ? '${ZagModule.SONARR.title} $instanceName'
        : ZagModule.SONARR.title;
    
    // Check if there are instances to switch between
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
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
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
    final currentInstance = ZagInstanceContext().getActiveInstance('sonarr');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Instance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.SONARR.title
                : '${ZagModule.SONARR.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.SONARR.color)
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
      ZagInstanceContext().setActiveInstance('sonarr', result);
      setState(() {});
    }
  }

  Widget _body() {
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final isInstance = instanceName != null;
    
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.SONARR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultOptionsPage(),
        _defaultPagesPage(),
        _queueSize(),
        ZagDivider(),
        if (isInstance) ...[
          _renameInstance(),
          _deleteInstance(),
        ] else _addDuplicateInstance(),
      ],
    );
  }

  Widget _enabledToggle() {
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final displayName = instanceName != null
        ? '${ZagModule.SONARR.title} $instanceName'
        : ZagModule.SONARR.title;
    
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [displayName]),
        trailing: ZagSwitch(
          value: ZagProfile.forModule('sonarr').sonarrEnabled,
          onChanged: (value) {
            final profile = ZagProfile.forModule('sonarr');
            profile.sonarrEnabled = value;
            profile.save();
            context.read<SonarrState>().reset();
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
            args: [ZagModule.SONARR.title],
          ),
        )
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_PAGES.go,
    );
  }

  Widget _defaultOptionsPage() {
    return ZagBlock(
      title: 'settings.DefaultOptions'.tr(),
      body: [
        TextSpan(text: 'settings.DefaultOptionsDescription'.tr()),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_OPTIONS.go,
    );
  }

  Widget _queueSize() {
    const _db = SonarrDatabase.QUEUE_PAGE_SIZE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'sonarr.QueueSize'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'zagreus.OneItem'.tr()
                : 'zagreus.Items'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZagIconButton(icon: Icons.queue_play_next_rounded),
        onTap: () async {
          Tuple2<bool, int> result =
              await SonarrDialogs().setQueuePageSize(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported &&
          ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.forModule('sonarr');

        final effectiveHost = profile.effectiveSonarrHost();
        if (profile.sonarrEnabled &&
            effectiveHost.isNotEmpty &&
            profile.sonarrKey.isNotEmpty) {
          final api = SonarrAPI(
            host: effectiveHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );

          await SonarrWebhookManager.syncWebhook(api);
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook on page load', e, stack);
    }
  }

  Widget _addDuplicateInstance() {
    return ZagBlock(
      title: 'Add Duplicate Instance',
      body: [
        TextSpan(
          text: 'Create another ${ZagModule.SONARR.title} instance',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.ADD),
      onTap: () async {
        final controller = TextEditingController();
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Instance Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., 4K, Anime, Kids',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Create'),
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
          moduleKey: ZagModule.SONARR.key,
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
          message: '${ZagModule.SONARR.title} $result has been added',
        );

        ZagDrawer.clearModuleOrderCache();
        setState(() {});
      },
    );
  }

  Widget _renameInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final instanceKey = ZagInstanceContext().getActiveInstance('sonarr');
    
    return ZagBlock(
      title: 'Rename Instance',
      body: [
        TextSpan(
          text: 'Change the name of ${ZagModule.SONARR.title} $instanceName',
        ),
      ],
      trailing: const ZagIconButton(icon: Icons.edit_rounded),
      onTap: () async {
        final controller = TextEditingController(text: instanceName);
        
        final newName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rename Instance'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Instance Name',
                hintText: 'e.g. 4K, Anime, Kids',
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
        ZagInstanceContext().setActiveInstance('sonarr', newKey);
        
        // Refresh drawer
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Renamed',
          message: '${ZagModule.SONARR.title} is now "$newName"',
        );

        setState(() {});
      },
    );
  }

  Widget _deleteInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final instanceKey = ZagInstanceContext().getActiveInstance('sonarr');
    
    return ZagBlock(
      title: 'Delete Instance',
      body: [
        TextSpan(
          text: 'Remove ${ZagModule.SONARR.title} $instanceName and its settings',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.DELETE),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Instance?'),
            content: Text(
              'Are you sure you want to delete ${ZagModule.SONARR.title} $instanceName? This cannot be undone.',
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
        ZagInstanceContext().clearActiveInstance('sonarr');
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Deleted',
          message: '${ZagModule.SONARR.title} $instanceName has been removed',
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
