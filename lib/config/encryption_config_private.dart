/// Private encryption configuration - DO NOT COMMIT TO GIT
/// Add this file to .gitignore
class EncryptionConfig {
  /// Generate backup encryption key with custom pattern
  static String getBackupEncryptionKey(String userId, String userEmail) {
    // Simple, unique per-user encryption key
    // userId is already a UUID (unique), email adds extra entropy
    return 'zag_${userId}_${userEmail.toLowerCase()}_backup';
  }
}