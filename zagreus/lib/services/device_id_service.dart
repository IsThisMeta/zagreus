import 'package:uuid/uuid.dart';
import 'package:zagreus/database/tables/zagreus.dart';

/// Simple device ID service for Z Assistant
/// No email or Supabase auth required - just a unique device identifier
class DeviceIdService {
  static final DeviceIdService _instance = DeviceIdService._internal();
  factory DeviceIdService() => _instance;
  DeviceIdService._internal();

  static const _uuid = Uuid();
  String? _cachedDeviceId;

  /// Get or create a persistent device ID
  String get deviceId {
    // Return cached if available
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    // Check stored ID
    final stored = ZagreusDatabase.DEVICE_ID.read();
    if (stored.isNotEmpty) {
      _cachedDeviceId = stored;
      return stored;
    }

    // Generate new UUID v4
    final newId = _uuid.v4();
    ZagreusDatabase.DEVICE_ID.update(newId);
    _cachedDeviceId = newId;

    print('🆔 Generated new device ID: ${newId.substring(0, 8)}...');
    return newId;
  }

  /// Reset device ID (like "sign out of all devices")
  void reset() {
    final newId = _uuid.v4();
    ZagreusDatabase.DEVICE_ID.update(newId);
    _cachedDeviceId = newId;
    print('🔄 Reset device ID to: ${newId.substring(0, 8)}...');
  }

  /// Get a shortened version for display (first 8 chars)
  String get shortId {
    return deviceId.substring(0, 8);
  }
}