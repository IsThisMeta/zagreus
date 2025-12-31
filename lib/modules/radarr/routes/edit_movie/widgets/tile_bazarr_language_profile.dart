import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RadarrMoviesEditBazarrLanguageProfileTile extends StatefulWidget {
  final int radarrId;

  const RadarrMoviesEditBazarrLanguageProfileTile({
    Key? key,
    required this.radarrId,
  }) : super(key: key);

  @override
  State<RadarrMoviesEditBazarrLanguageProfileTile> createState() => _State();
}

class _State extends State<RadarrMoviesEditBazarrLanguageProfileTile> {
  List<BazarrLanguageProfile> _profiles = [];
  bool _loading = true;
  bool _initialized = false;
  bool _movieFoundInBazarr = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBazarrData();
  }

  BazarrAPI? _getApi() {
    if (!ZagreusPro.isEnabled) return null;
    final profile = ZagProfile.current;
    if (!profile.bazarrEnabled) return null;
    final host = profile.effectiveBazarrHost();
    if (host.isEmpty || profile.bazarrKey.isEmpty) return null;
    return BazarrAPI(
      host: host,
      apiKey: profile.bazarrKey,
      headers: Map<String, dynamic>.from(profile.bazarrHeaders),
    );
  }

  Future<void> _loadBazarrData() async {
    final api = _getApi();
    if (api == null) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    try {
      final results = await Future.wait([
        api.movie.get(radarrId: widget.radarrId),
        api.language.getProfiles(),
      ]);
      final movie = results[0] as BazarrMovie?;
      final profiles = results[1] as List<BazarrLanguageProfile>;

      if (mounted) {
        // Only show tile if movie is found in Bazarr library
        _movieFoundInBazarr = movie != null;

        setState(() {
          _profiles = profiles;
          _loading = false;
          _error = null;
        });

        // Initialize state with current profile
        if (!_initialized && movie != null) {
          _initialized = true;
          context.read<RadarrMoviesEditState>().initializeBazarrLanguageProfile(
            currentProfileId: movie.profileId,
            profiles: profiles,
          );
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to load Bazarr data', e, stack);
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if Bazarr is not enabled or not Pro
    if (!ZagProfile.current.bazarrEnabled || !ZagreusPro.isEnabled) {
      return const SizedBox.shrink();
    }

    // Check if Bazarr is configured
    final host = ZagProfile.current.effectiveBazarrHost();
    if (host.isEmpty || ZagProfile.current.bazarrKey.isEmpty) {
      return const SizedBox.shrink();
    }

    // Don't show anything until we confirm movie is in Bazarr's library
    if (_loading || _error != null || !_movieFoundInBazarr) {
      return const SizedBox.shrink();
    }

    return Selector<RadarrMoviesEditState, BazarrLanguageProfile?>(
      selector: (_, state) => state.bazarrLanguageProfile,
      builder: (context, profile, _) => ZagBlock(
        title: 'bazarr.SubtitleLanguageProfile'.tr(),
        body: [TextSpan(text: profile?.name ?? 'bazarr.None'.tr())],
        trailing: const ZagIconButton.arrow(),
        onTap: () async => _onTap(context),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final currentProfile = context.read<RadarrMoviesEditState>().bazarrLanguageProfile;

    bool flag = false;
    BazarrLanguageProfile? selectedProfile;

    void setValues(bool f, BazarrLanguageProfile? p) {
      flag = f;
      selectedProfile = p;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'bazarr.SubtitleLanguageProfile'.tr(),
      content: [
        // "None" option
        ZagDialog.tile(
          text: 'bazarr.None'.tr(),
          icon: Icons.not_interested_rounded,
          iconColor: ZagColours().byListIndex(0),
          onTap: () => setValues(true, null),
        ),
        // Profile options
        ...List.generate(
          _profiles.length,
          (index) => ZagDialog.tile(
            text: _profiles[index].name ?? ZagUI.TEXT_EMDASH,
            icon: Icons.subtitles_rounded,
            iconColor: ZagColours().byListIndex(index + 1),
            onTap: () => setValues(true, _profiles[index]),
          ),
        ),
      ],
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    if (flag) {
      context.read<RadarrMoviesEditState>().bazarrLanguageProfile = selectedProfile;
    }
  }
}
