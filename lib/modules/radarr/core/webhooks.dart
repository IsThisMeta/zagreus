import 'package:zagreus/core.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/system/webhooks.dart';

class RadarrWebhooks extends ZagWebhooks {
  @override
  Future<void> handle(Map data) async {
    _EventType? event = _EventType.GRAB.fromKey(data['event']);
    if (event == null)
      ZagLogger().warning(
        'Unknown event type: ${data['event'] ?? 'null'}',
      );
    event?.execute(data);
  }
}

enum _EventType {
  DOWNLOAD,
  GRAB,
  HEALTH,
  RENAME,
  TEST,
}

extension _EventTypeExtension on _EventType? {
  _EventType? fromKey(String? key) {
    switch (key) {
      case 'Download':
        return _EventType.DOWNLOAD;
      case 'Grab':
        return _EventType.GRAB;
      case 'Health':
        return _EventType.HEALTH;
      case 'Rename':
        return _EventType.RENAME;
      case 'Test':
        return _EventType.TEST;
    }
    return null;
  }

  Future<void> execute(Map<dynamic, dynamic> data) async {
    switch (this) {
      case _EventType.GRAB:
        return _grabEvent(data);
      case _EventType.DOWNLOAD:
        return _downloadEvent(data);
      case _EventType.HEALTH:
        return _healthEvent(data);
      case _EventType.RENAME:
        return _renameEvent(data);
      case _EventType.TEST:
        return _testEvent(data);
      default:
        break;
    }
  }

  Future<void> _downloadEvent(Map data) async {
    _goToMovieDetails(int.tryParse(data['id']));
  }

  Future<void> _renameEvent(Map data) async {
    _goToMovieDetails(int.tryParse(data['id']));
  }

  Future<void> _grabEvent(Map data) async {
    RadarrRoutes.QUEUE.go(buildTree: true);
  }

  Future<void> _healthEvent(Map data) async {
    RadarrRoutes.SYSTEM_STATUS.go(buildTree: true);
  }

  Future<void> _testEvent(Map data) async => ZagModule.RADARR.launch();

  Future<void> _goToMovieDetails(int? movieId) async {
    if (movieId != null) {
      return RadarrRoutes.MOVIE.go(
        buildTree: true,
        params: {
          'movie': movieId.toString(),
        },
      );
    }
    return ZagModule.RADARR.launch();
  }
}
