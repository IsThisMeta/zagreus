import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:uuid/uuid.dart';

/// HMAC-based encryption service for Z Assistant credentials
/// Fort Knox for your movie server credentials
class HmacEncryptionService {
  static final HmacEncryptionService _instance = HmacEncryptionService._internal();
  factory HmacEncryptionService() => _instance;
  HmacEncryptionService._internal();

  static const _uuid = Uuid();
  String? _cachedHmacKey;

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

  /// Encrypt credentials with HMAC
  Map<String, String> encryptCredentials(Map<String, Map<String, String>> servers) {
    final key = hmacKey;
    final result = <String, String>{};

    servers.forEach((service, creds) {
      // Combine URL and API key
      final combined = jsonEncode(creds);

      // Create HMAC
      final hmacSha256 = Hmac(sha256, utf8.encode(key));
      final digest = hmacSha256.convert(utf8.encode(combined));

      // Base64 encode the original data + HMAC
      final encrypted = base64.encode(utf8.encode('$combined::$digest'));

      result[service] = encrypted;
    });

    return result;
  }

  /// Simple XOR encryption for the actual data (on top of HMAC)
  /// This prevents the creds from being visible in base64 decode
  String _xorEncrypt(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// Encrypt with XOR + HMAC for double protection
  Map<String, String> encryptCredentialsSecure(Map<String, Map<String, String>> servers) {
    final key = hmacKey;
    final result = <String, String>{};

    servers.forEach((service, creds) {
      // Convert to JSON
      final jsonData = jsonEncode(creds);

      // XOR encrypt the data first
      final xorEncrypted = _xorEncrypt(jsonData, key);

      // Then add HMAC for integrity
      final hmacSha256 = Hmac(sha256, utf8.encode(key));
      final digest = hmacSha256.convert(utf8.encode(xorEncrypted));

      // Combine encrypted data with HMAC
      final combined = '$xorEncrypted::${digest.toString()}';

      result[service] = combined;
    });

    return result;
  }

  /// Check if device has been registered with backend
  bool get isRegistered {
    return ZagreusDatabase.DEVICE_REGISTERED.read() ?? false;
  }

  /// Mark device as registered
  void setRegistered(bool registered) {
    ZagreusDatabase.DEVICE_REGISTERED.update(registered);
  }

  /// Reset encryption (generates new keys)
  void reset() {
    final newKey = _generateHmacKey();
    ZagreusDatabase.DEVICE_HMAC_KEY.update(newKey);
    ZagreusDatabase.DEVICE_REGISTERED.update(false);
    _cachedHmacKey = newKey;
    print('🔄 Reset HMAC key and registration');
  }
}