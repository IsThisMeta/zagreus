import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/api/bazarr/models.dart';

class SonarrSeriesEditState extends ChangeNotifier {
  SonarrSeries? _series;
  SonarrSeries? get series => _series;
  set series(SonarrSeries? series) {
    _series = series;
    initializeMonitored();
    initializeUseSeasonFolders();
    initializeSeriesPath();
    initializeSeriesType();
  }

  bool canExecuteAction = false;

  ZagLoadingState _state = ZagLoadingState.INACTIVE;
  ZagLoadingState get state => _state;
  set state(ZagLoadingState state) {
    _state = state;
    notifyListeners();
  }

  bool _monitored = true;
  bool get monitored => _monitored;
  set monitored(bool monitored) {
    _monitored = monitored;
    notifyListeners();
  }

  void initializeMonitored() {
    _monitored = series!.monitored ?? false;
  }

  bool _useSeasonFolders = true;
  bool get useSeasonFolders => _useSeasonFolders;
  set useSeasonFolders(bool useSeasonFolders) {
    _useSeasonFolders = useSeasonFolders;
    notifyListeners();
  }

  void initializeUseSeasonFolders() {
    _useSeasonFolders = series!.seasonFolder ?? false;
  }

  String _seriesPath = '';
  String _originalSeriesPath = '';
  String get seriesPath => _seriesPath;
  set seriesPath(String seriesPath) {
    _seriesPath = seriesPath;
    if (!seriesPathChanged) {
      _moveFiles = false;
    }
    notifyListeners();
  }

  void initializeSeriesPath() {
    _seriesPath = series!.path ?? '';
    _originalSeriesPath = _seriesPath;
    _moveFiles = false;
  }

  bool get seriesPathChanged => _seriesPath != _originalSeriesPath;

  bool _moveFiles = false;
  bool get moveFiles => _moveFiles;
  set moveFiles(bool moveFiles) {
    _moveFiles = seriesPathChanged ? moveFiles : false;
    notifyListeners();
  }

  SonarrSeriesType? _seriesType;
  SonarrSeriesType? get seriesType => _seriesType;
  set seriesType(SonarrSeriesType? seriesType) {
    _seriesType = seriesType;
    notifyListeners();
  }

  void initializeSeriesType() {
    _seriesType = series!.seriesType ?? SonarrSeriesType.STANDARD;
  }

  SonarrQualityProfile? _qualityProfile;
  SonarrQualityProfile? get qualityProfile => _qualityProfile;
  set qualityProfile(SonarrQualityProfile? qualityProfile) {
    _qualityProfile = qualityProfile;
    notifyListeners();
  }

  void initializeQualityProfile(List<SonarrQualityProfile> qualityProfiles) {
    _qualityProfile = qualityProfiles.firstWhere(
      (profile) => profile.id == series!.qualityProfileId,
      orElse: () => qualityProfiles[0],
    );
  }

  SonarrLanguageProfile? _languageProfile;
  SonarrLanguageProfile? get languageProfile => _languageProfile;
  set languageProfile(SonarrLanguageProfile? languageProfile) {
    _languageProfile = languageProfile;
    notifyListeners();
  }

  void initializeLanguageProfile(List<SonarrLanguageProfile> languageProfiles) {
    if (languageProfiles.isEmpty) return;
    _languageProfile = languageProfiles.firstWhere(
      (p) => p.id == series!.languageProfileId,
    );
  }

  List<SonarrTag>? _tags;
  List<SonarrTag>? get tags => _tags;
  set tags(List<SonarrTag>? tags) {
    _tags = tags;
    notifyListeners();
  }

  void initializeTags(List<SonarrTag> tags) {
    _tags = tags.where((tag) => (series!.tags ?? []).contains(tag.id)).toList();
  }

  // Bazarr subtitle language profile
  BazarrLanguageProfile? _bazarrLanguageProfile;
  BazarrLanguageProfile? get bazarrLanguageProfile => _bazarrLanguageProfile;
  set bazarrLanguageProfile(BazarrLanguageProfile? profile) {
    _bazarrLanguageProfile = profile;
    notifyListeners();
  }

  // Original Bazarr profile ID to detect changes
  int? _originalBazarrProfileId;
  int? get originalBazarrProfileId => _originalBazarrProfileId;

  // Whether Bazarr data was successfully loaded
  bool _bazarrDataLoaded = false;
  bool get bazarrDataLoaded => _bazarrDataLoaded;

  void initializeBazarrLanguageProfile({
    required int? currentProfileId,
    required List<BazarrLanguageProfile> profiles,
  }) {
    _originalBazarrProfileId = currentProfileId;
    _bazarrDataLoaded = true;
    if (currentProfileId == null) {
      _bazarrLanguageProfile = null;
    } else {
      _bazarrLanguageProfile = profiles.firstWhere(
        (p) => p.profileId == currentProfileId,
        orElse: () => profiles.isNotEmpty ? profiles.first : BazarrLanguageProfile(),
      );
    }
  }

  /// Returns true if Bazarr language profile was changed
  bool get bazarrProfileChanged {
    if (!_bazarrDataLoaded) return false;
    final newId = _bazarrLanguageProfile?.profileId;
    return newId != _originalBazarrProfileId;
  }
}
