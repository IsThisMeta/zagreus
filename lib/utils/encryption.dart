import 'package:encrypt/encrypt.dart';
import 'package:zagreus/system/logger.dart';

class ZagEncryption {
  Key _generateKey(String key) {
    const _length = 32;
    const _pad = '0';
    String _morphed = (key + key).padRight(_length, _pad).substring(0, _length);
    return Key.fromUtf8(_morphed);
  }

  IV _generateIV() {
    // Use a fixed IV (all zeros) for consistent encryption/decryption
    // This matches LunaSea's behavior
    return IV.allZerosOfLength(16);
  }

  /// Encrypt the unencrypted string [data] using the given encryption [key]
  String encrypt(String key, String data) {
    try {
      final _encrypter = Encrypter(AES(_generateKey(key)));
      return _encrypter.encrypt(data, iv: _generateIV()).base64;
    } catch (error, stack) {
      ZagLogger().error('Failed to encrypt data', error, stack);
      rethrow;
    }
  }

  /// Decrypt the encrypted string [data] using the given encryption [key]
  String decrypt(String key, String data) {
    try {
      final _encrypter = Encrypter(AES(_generateKey(key)));
      return _encrypter.decrypt64(data, iv: _generateIV());
    } catch (error, stack) {
      ZagLogger().error('Failed to decrypt data', error, stack);
      rethrow;
    }
  }
}
