import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';

enum SearchDownloadType {
  NZBGET,
  SABNZBD,
  FILESYSTEM,
}

extension SearchDownloadTypeExtension on SearchDownloadType {
  String get name {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return 'NZBGet';
      case SearchDownloadType.SABNZBD:
        return 'SABnzbd';
      case SearchDownloadType.FILESYSTEM:
        return 'search.DownloadToDevice'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return ZagModule.NZBGET.icon;
      case SearchDownloadType.SABNZBD:
        return ZagModule.SABNZBD.icon;
      case SearchDownloadType.FILESYSTEM:
        return Icons.download_rounded;
    }
  }

  Future<void> execute(BuildContext context, NewznabResultData data) async {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return _executeNZBGet(context, data);
      case SearchDownloadType.SABNZBD:
        return _executeSABnzbd(context, data);
      case SearchDownloadType.FILESYSTEM:
        return _executeFileSystem(context, data);
    }
  }

  Future<void> _executeNZBGet(
      BuildContext context, NewznabResultData data) async {
    NZBGetAPI api = NZBGetAPI.from(ZagProfile.current);
    await api
        .uploadURL(data.linkDownload)
        .then((_) => showZagSuccessSnackBar(
              title: 'search.SentNZBData'.tr(),
              message:
                  'search.SentTo'.tr(args: [SearchDownloadType.NZBGET.name]),
              showButton: true,
              buttonOnPressed: ZagModule.NZBGET.launch,
            ))
        .catchError((error, stack) {
      ZagLogger().error('Failed to download data', error, stack);
      return showZagErrorSnackBar(
          title: 'search.FailedToSend'.tr(), error: error);
    });
  }

  Future<void> _executeSABnzbd(
      BuildContext context, NewznabResultData data) async {
    SABnzbdAPI api = SABnzbdAPI.from(ZagProfile.current);
    await api
        .uploadURL(data.linkDownload)
        .then((_) => showZagSuccessSnackBar(
              title: 'search.SentNZBData'.tr(),
              message:
                  'search.SentTo'.tr(args: [SearchDownloadType.SABNZBD.name]),
              showButton: true,
              buttonOnPressed: ZagModule.SABNZBD.launch,
            ))
        .catchError((error, stack) {
      ZagLogger().error('Failed to download data', error, stack);
      return showZagErrorSnackBar(
          title: 'search.FailedToSend'.tr(), error: error);
    });
  }

  Future<void> _executeFileSystem(
      BuildContext context, NewznabResultData data) async {
    showZagInfoSnackBar(
      title: 'search.Downloading'.tr(),
      message: 'search.DownloadingNZBToDevice'.tr(),
    );
    String cleanTitle = data.title.replaceAll(RegExp(r'[^0-9a-zA-Z. -]+'), '');
    try {
      context
          .read<SearchState>()
          .api
          .downloadRelease(data)
          .then((download) async {
        bool result = await ZagFileSystem().save(
          context,
          '$cleanTitle.nzb',
          utf8.encode(download!),
        );
        if (result)
          showZagSuccessSnackBar(
              title: 'Saved NZB', message: 'NZB has been successfully saved');
      });
    } catch (error, stack) {
      ZagLogger().error('Error downloading NZB', error, stack);
      showZagErrorSnackBar(
          title: 'search.FailedToDownloadNZB'.tr(), error: error);
    }
  }
}
