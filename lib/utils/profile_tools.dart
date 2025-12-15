import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/state.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/types/exception.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

class ZagProfileTools {
  bool changeTo(
    String profile, {
    bool showSnackbar = true,
    bool popToRootRoute = false,
  }) {
    try {
      if (ZagreusDatabase.ENABLED_PROFILE.read() == profile) return true;
      _changeTo(profile);

      if (showSnackbar) {
        showZagSuccessSnackBar(
          title: 'settings.ChangedProfile'.tr(),
          message: profile,
        );
      }

      if (popToRootRoute) {
        ZagRouter().popToRootRoute();
      }

      return true;
    } on ProfileNotFoundException catch (error, trace) {
      ZagLogger().exception(error, trace);
    }
    return false;
  }

  Future<bool> create(
    String profile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _create(profile);
      _changeTo(profile);

      if (showSnackbar) {
        showZagSuccessSnackBar(
          title: 'settings.AddedProfile'.tr(),
          message: profile,
        );
      }
    } on ProfileAlreadyExistsException catch (error, trace) {
      ZagLogger().exception(error, trace);
    } catch (error, trace) {
      ZagLogger().error('Failed to create profile', error, trace);
    }

    return false;
  }

  Future<bool> remove(
    String profile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _remove(profile);

      if (showSnackbar) {
        showZagSuccessSnackBar(
          title: 'settings.DeletedProfile'.tr(),
          message: profile,
        );
      }
    } on ProfileNotFoundException catch (error, trace) {
      ZagLogger().exception(error, trace);
    } on ActiveProfileRemovalException catch (error, trace) {
      ZagLogger().exception(error, trace);
    } catch (error, trace) {
      ZagLogger().error('Failed to delete profile', error, trace);
    }

    return false;
  }

  Future<bool> rename(
    String oldProfile,
    String newProfile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _rename(oldProfile, newProfile);

      if (showSnackbar) {
        showZagSuccessSnackBar(
          title: 'settings.RenamedProfile'.tr(),
          message: 'settings.ProfileToProfile'.tr(
            args: [oldProfile, newProfile],
          ),
        );
      }

      return true;
    } on ProfileNotFoundException catch (error, trace) {
      ZagLogger().exception(error, trace);
    } on ProfileAlreadyExistsException catch (error, trace) {
      ZagLogger().exception(error, trace);
    } catch (error, trace) {
      ZagLogger().error('Failed to rename profile', error, trace);
    }

    return false;
  }

  void _changeTo(String profile) {
    if (!ZagBox.profiles.contains(profile)) {
      throw ProfileNotFoundException(profile);
    }

    ZagreusDatabase.ENABLED_PROFILE.update(profile);
    ZagState.reset();
  }

  Future<void> _create(String profile) async {
    if (ZagBox.profiles.contains(profile)) {
      throw ProfileAlreadyExistsException(profile);
    }

    await ZagBox.profiles.update(profile, ZagProfile());
  }

  Future<void> _remove(String profile) async {
    if (ZagreusDatabase.ENABLED_PROFILE.read() == profile) {
      throw ActiveProfileRemovalException(profile);
    }

    if (!ZagBox.profiles.contains(profile)) {
      throw ProfileNotFoundException(profile);
    }

    await ZagBox.profiles.delete(profile);
  }

  Future<void> _rename(String oldProfile, String newProfile) async {
    if (!ZagBox.profiles.contains(oldProfile)) {
      throw ProfileNotFoundException(oldProfile);
    }

    if (ZagBox.profiles.contains(newProfile)) {
      throw ProfileAlreadyExistsException(newProfile);
    }

    final oldDb = ZagBox.profiles.read(oldProfile)!;
    final newDb = ZagProfile.clone(oldDb);

    await ZagBox.profiles.update(newProfile, newDb);
    _changeTo(newProfile);

    oldDb.delete();
  }
}

class ProfileNotFoundException with ErrorExceptionMixin {
  final String profile;
  const ProfileNotFoundException(this.profile);

  @override
  String toString() {
    return 'ProfileNotFoundException: "$profile" was not found';
  }
}

class ProfileAlreadyExistsException with ErrorExceptionMixin {
  final String profile;
  const ProfileAlreadyExistsException(this.profile);

  @override
  String toString() {
    return 'ProfileAlreadyExistsException: "$profile" already exists';
  }
}

class ActiveProfileRemovalException with ErrorExceptionMixin {
  final String profile;
  const ActiveProfileRemovalException(this.profile);

  @override
  String toString() {
    return 'ActiveProfileRemovalException: "$profile" can\'t be removed as it is in use';
  }
}
