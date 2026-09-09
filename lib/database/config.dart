import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/database/table.dart';

class ZagConfig {
  Future<void> import(BuildContext context, String data) async {
    final incoming = _prepare(data);
    final previous = _prepare(export());

    try {
      await _apply(incoming);
    } catch (error, stack) {
      ZagLogger().error(
        'Failed to import configuration, restoring previous configuration',
        error,
        stack,
      );

      try {
        await _apply(previous);
      } catch (rollbackError, rollbackStack) {
        ZagLogger().error(
          'Failed to restore previous configuration after import failure',
          rollbackError,
          rollbackStack,
        );
        await ZagDatabase().bootstrap();
      }

      ZagState.reset(context);
      rethrow;
    }

    ZagState.reset(context);
  }

  String export() {
    Map<String, dynamic> config = {};
    config[ZagBox.externalModules.key] = ZagBox.externalModules.export();
    config[ZagBox.indexers.key] = ZagBox.indexers.export();
    config[ZagBox.profiles.key] = ZagBox.profiles.export();
    config[ZagBox.sshConnections.key] = ZagBox.sshConnections.export();
    for (final table in ZagTable.values) config[table.key] = table.export();

    return json.encode(config);
  }

  _PreparedConfig _prepare(String data) {
    final decoded = json.decode(data);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup payload is not a JSON object');
    }
    final config = decoded;

    List<dynamic> readList(String key, {bool required = false}) {
      final value = config[key];
      if (value == null && !required) return const [];
      if (value is! List) {
        throw FormatException('Backup section "$key" is not a list');
      }
      return value;
    }

    Map<String, dynamic> readObject(dynamic value, String label) {
      if (value is! Map) {
        throw FormatException('$label is not a JSON object');
      }
      return value.cast<String, dynamic>();
    }

    final profiles = readList(ZagBox.profiles.key, required: true).map((item) {
      final content = readObject(item, 'Profile');
      final key = content['key']?.toString() ?? ZagProfile.DEFAULT_PROFILE;
      if (key.isEmpty) throw const FormatException('Profile key is empty');
      return MapEntry(key, ZagProfile.fromJson(content));
    }).toList(growable: false);
    if (profiles.isEmpty) {
      throw const FormatException('Backup contains no profiles');
    }

    final indexers = readList(ZagBox.indexers.key)
        .map((item) => ZagIndexer.fromJson(readObject(item, 'Indexer')))
        .toList(growable: false);
    final externalModules = readList(ZagBox.externalModules.key)
        .map(
          (item) => ZagExternalModule.fromJson(
            readObject(item, 'External module'),
          ),
        )
        .toList(growable: false);
    final sshConnections = readList(ZagBox.sshConnections.key).map((item) {
      final connection = SSHConnection.fromJson(
        readObject(item, 'SSH connection'),
      );
      if (connection.id.isEmpty) {
        throw const FormatException('SSH connection ID is empty');
      }
      return connection;
    }).toList(growable: false);

    final tables = <ZagTable, Map<String, dynamic>>{};
    for (final table in ZagTable.values) {
      dynamic tableData = config[table.key];
      if (table.key == 'zagreus' && tableData == null) {
        tableData = config['lunasea'];
      }
      if (tableData != null) {
        tables[table] = readObject(tableData, 'Table "${table.key}"');
      }
    }

    final knownKeys = {
      ...ZagTable.values.map((table) => table.key),
      'lunasea',
      ZagBox.externalModules.key,
      ZagBox.indexers.key,
      ZagBox.profiles.key,
      ZagBox.sshConnections.key,
    };
    final unknownSections = config.keys
        .where((key) => !knownKeys.contains(key))
        .toList(growable: false);
    if (unknownSections.isNotEmpty) {
      ZagLogger().debug(
        'Ignoring unknown backup sections: ${unknownSections.join(', ')}',
      );
    }

    return _PreparedConfig(
      profiles: profiles,
      indexers: indexers,
      externalModules: externalModules,
      sshConnections: sshConnections,
      tables: tables,
    );
  }

  Future<void> _apply(_PreparedConfig config) async {
    await ZagDatabase().clear();

    for (final profile in config.profiles) {
      await ZagBox.profiles.update(profile.key, profile.value);
    }
    for (final indexer in config.indexers) {
      await ZagBox.indexers.create(indexer);
    }
    for (final module in config.externalModules) {
      await ZagBox.externalModules.create(module);
    }
    for (final connection in config.sshConnections) {
      await ZagBox.sshConnections.update(connection.id, connection);
    }
    for (final entry in config.tables.entries) {
      entry.key.import(entry.value);
    }

    final enabledProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    if (!ZagProfile.list.contains(enabledProfile)) {
      await ZagBox.zagreus.update(
        ZagreusDatabase.ENABLED_PROFILE.key,
        config.profiles.first.key,
      );
    }
  }
}

class _PreparedConfig {
  final List<MapEntry<String, ZagProfile>> profiles;
  final List<ZagIndexer> indexers;
  final List<ZagExternalModule> externalModules;
  final List<SSHConnection> sshConnections;
  final Map<ZagTable, Map<String, dynamic>> tables;

  const _PreparedConfig({
    required this.profiles,
    required this.indexers,
    required this.externalModules,
    required this.sshConnections,
    required this.tables,
  });
}
