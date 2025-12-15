import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/settings.dart';

class HeaderUtility {
  /// Show a dialog confirming the user wants to delete a header.
  ///
  /// If yes, delete the header from the map, and show a snackbar/toast.
  /// Updates the passed in headers map, and saves the database profile.
  Future<void> deleteHeader(
    BuildContext context, {
    required Map<String, String> headers,
    required String key,
    ZagIndexer? indexer,
  }) async {
    bool result = await SettingsDialogs().deleteHeader(context);
    if (result) {
      headers.remove(key);
      ZagProfile.current.save();
      indexer?.save();
      showZagSuccessSnackBar(
        title: 'settings.HeaderDeleted'.tr(),
        message: key,
      );
    }
  }

  /// Add a new header to the map.
  ///
  /// If yes, adds a header and shows a snackbar.
  /// Updates the passed in headers map, and saves the database profile.
  Future<void> addHeader(
    BuildContext context, {
    required Map<String, String> headers,
    ZagIndexer? indexer,
  }) async {
    final result = await SettingsDialogs().addHeader(context);
    if (result.item1)
      switch (result.item2) {
        case HeaderType.AUTHORIZATION:
          await _basicAuthenticationHeader(context, headers, indexer);
          break;
        case HeaderType.GENERIC:
          await _genericHeader(context, headers, indexer);
          break;
        default:
          ZagLogger().warning('Unknown case: ${result.item2}');
      }
  }

  /// Add a generic header.
  Future<void> _genericHeader(
    BuildContext context,
    Map<String, String> headers,
    ZagIndexer? indexer,
  ) async {
    final results = await SettingsDialogs().addCustomHeader(context);
    if (results.item1) {
      headers[results.item2] = results.item3;
      ZagProfile.current.save();
      indexer?.save();
      showZagSuccessSnackBar(
        title: 'settings.HeaderAdded'.tr(),
        message: results.item2,
      );
    }
  }

  /// Add an 'Authorization' header.
  Future<void> _basicAuthenticationHeader(
    BuildContext context,
    Map<String, String> headers,
    ZagIndexer? indexer,
  ) async {
    final results =
        await SettingsDialogs().addBasicAuthenticationHeader(context);
    if (results.item1) {
      String _auth = base64.encode(
        utf8.encode('${results.item2}:${results.item3}'),
      );
      headers['Authorization'] = 'Basic $_auth';
      ZagProfile.current.save();
      indexer?.save();
      showZagSuccessSnackBar(
        title: 'settings.HeaderAdded'.tr(),
        message: 'Authorization',
      );
    }
  }
}
