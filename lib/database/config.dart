import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/table.dart';

class ZagConfig {
  Future<void> import(BuildContext context, String data) async {
    try {
      // Parse JSON first before clearing to avoid wiping data on invalid backup
      final decoded = json.decode(data);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup payload is not a JSON object');
      }
      final Map<String, dynamic> config = decoded;

      // Now that we know the backup is valid JSON, clear the database
      await ZagDatabase().clear();

      // Helper to safely import sections without failing the whole import
      void safeImport(String label, void Function() fn) {
        try {
          fn();
        } catch (error, stack) {
          ZagLogger().error('Failed to import $label', error, stack);
        }
      }

      safeImport('profiles', () => _setProfiles(config[ZagBox.profiles.key]));
      safeImport('indexers', () => _setIndexers(config[ZagBox.indexers.key]));
      safeImport(
        'external modules',
        () => _setExternalModules(config[ZagBox.externalModules.key]),
      );

      for (final table in ZagTable.values) {
        // Handle both new format (zagreus) and old format (lunasea)
        dynamic tableData = config[table.key];

        // Special handling for the main settings table - map lunasea -> zagreus
        if (table.key == 'zagreus' && tableData == null && config['lunasea'] != null) {
          tableData = config['lunasea'];
        }

        if (tableData == null) continue;

        safeImport('table ${table.key}', () => table.import(tableData));
      }

      // Gracefully ignore unknown tables (from newer app versions or future modules)
      final knownKeys = {
        ...ZagTable.values.map((t) => t.key),
        'lunasea', // Legacy table name
        ZagBox.externalModules.key,
        ZagBox.indexers.key,
        ZagBox.profiles.key,
      };
      final unknownTables = config.keys
          .where((key) => !knownKeys.contains(key))
          .toList(growable: false);
      if (unknownTables.isNotEmpty) {
        ZagLogger().debug(
          'Ignoring unknown tables in backup: ${unknownTables.join(', ')}',
        );
      }

      if (!ZagProfile.list.contains(ZagreusDatabase.ENABLED_PROFILE.read())) {
        ZagreusDatabase.ENABLED_PROFILE.update(ZagProfile.list[0]);
      }
    } catch (error, stack) {
      await ZagDatabase().bootstrap();
      ZagLogger().error(
        'Failed to import configuration, resetting to default',
        error,
        stack,
      );
    }

    ZagState.reset(context);
  }

  String export() {
    Map<String, dynamic> config = {};
    config[ZagBox.externalModules.key] = ZagBox.externalModules.export();
    config[ZagBox.indexers.key] = ZagBox.indexers.export();
    config[ZagBox.profiles.key] = ZagBox.profiles.export();
    for (final table in ZagTable.values) config[table.key] = table.export();

    return json.encode(config);
  }

  void _setProfiles(List? data) {
    if (data == null) return;

    for (final item in data) {
      final content = (item as Map).cast<String, dynamic>();
      final key = content['key'] ?? 'default';
      final obj = ZagProfile.fromJson(content);
      ZagBox.profiles.update(key, obj);
    }
  }

  void _setIndexers(List? data) {
    if (data == null) return;

    for (final indexer in data) {
      final obj = ZagIndexer.fromJson(indexer);
      ZagBox.indexers.create(obj);
    }
  }

  void _setExternalModules(List? data) {
    if (data == null) return;

    for (final module in data) {
      final obj = ZagExternalModule.fromJson(module);
      ZagBox.externalModules.create(obj);
    }
  }
}
