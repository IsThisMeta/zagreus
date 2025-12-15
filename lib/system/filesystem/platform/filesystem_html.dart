// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:zagreus/system/filesystem/file.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

bool isPlatformSupported() => true;
ZagFileSystem getFileSystem() {
  if (isPlatformSupported()) return _Web();
  throw UnsupportedError('ZagFileSystem unsupported');
}

class _Web implements ZagFileSystem {
  @override
  Future<void> nuke() async {}

  @override
  Future<bool> save(BuildContext context, String name, List<int> data) async {
    try {
      final blob = Blob([utf8.decode(data)]);
      final anchor = AnchorElement(href: Url.createObjectUrlFromBlob(blob));
      anchor.setAttribute('download', name);
      anchor.click();
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to save to filesystem', error, stack);
      rethrow;
    }
  }

  @override
  Future<ZagFile?> read(BuildContext context, List<String> extensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);

      if (result?.files.isNotEmpty ?? false) {
        String? _ext = result!.files[0].extension;
        if (ZagFileSystem.isValidExtension(extensions, _ext)) {
          return ZagFile(
            name: result.files[0].name,
            data: result.files[0].bytes!,
          );
        } else {
          showZagErrorSnackBar(
            title: 'zagreus.InvalidFileTypeSelected'.tr(),
            message: extensions.map((s) => '.$s').join(', '),
          );
        }
      }

      return null;
    } catch (error, stack) {
      ZagLogger().error('Failed to read from filesystem', error, stack);
      rethrow;
    }
  }
}
