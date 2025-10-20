import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:uuid/uuid.dart';

/// HMAC key service for device authentication with Z Assistant
/// Zero-knowledge architecture: NO credentials are ever encrypted or sent!
/// This only generates a device identifier for backend authentication
class HmacEncryptionService {
  static final HmacEncryptionService _instance = HmacEncryptionService._internal();
  factory HmacEncryptionService() => _instance;
  HmacEncryptionService._internal();

  static const _uuid = Uuid();
  String? _cachedHmacKey;
  bool? _cachedRegistered;
  String? _cachedRegisteredUserId;

  /// Get or generate device's HMAC key
  String get hmacKey {
    // Return cached if available
    if (_cachedHmacKey != null && _cachedHmacKey!.isNotEmpty) {
      return _cachedHmacKey!;
    }

    // Check stored key
    final stored = ZagreusDatabase.DEVICE_HMAC_KEY.read();
    if (stored.isNotEmpty) {
      _cachedHmacKey = stored;
      return stored;
    }

    // Generate new HMAC key (256-bit)
    final newKey = _generateHmacKey();
    ZagreusDatabase.DEVICE_HMAC_KEY.update(newKey);
    _cachedHmacKey = newKey;

    print('🔐 Generated new HMAC key for device');
    return newKey;
  }

  /// Generate a cryptographically secure HMAC key
  String _generateHmacKey() {
    // Generate random UUID and hash it for extra entropy
    final uuid1 = _uuid.v4();
    final uuid2 = _uuid.v4();
    final combined = '$uuid1-$uuid2-${DateTime.now().millisecondsSinceEpoch}';

    // SHA256 hash for the key
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Check if device is registered with backend
  bool get isRegistered {
    if (_cachedRegistered != null) {
      return _cachedRegistered!;
    }
    final stored = ZagreusDatabase.DEVICE_REGISTERED.read();
    _cachedRegistered = stored;
    return stored;
  }

  /// Return the Supabase user ID the device is registered for, if any
  String? get registeredUserId {
    if (_cachedRegisteredUserId != null) {
      return _cachedRegisteredUserId!.isEmpty ? null : _cachedRegisteredUserId;
    }
    final stored = ZagreusDatabase.DEVICE_REGISTERED_USER_ID.read();
    _cachedRegisteredUserId = stored;
    return stored.isEmpty ? null : stored;
  }

  /// Set registration status
  void setRegistered(bool registered, {String? userId}) {
    _cachedRegistered = registered;
    ZagreusDatabase.DEVICE_REGISTERED.update(registered);

    final normalizedUserId = registered ? (userId ?? '') : '';
    _cachedRegisteredUserId = normalizedUserId;
    ZagreusDatabase.DEVICE_REGISTERED_USER_ID.update(normalizedUserId);
  }

  /// Clear cached registration state so the device re-registers on next request
  void resetRegistration() {
    setRegistered(false);
  }
}
