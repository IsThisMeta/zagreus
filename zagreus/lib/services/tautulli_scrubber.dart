import 'dart:convert';

/// Scrubs sensitive user data from Tautulli responses before sending to AI
class TautulliScrubber {
  final Map<String, String> _userAliases = {};
  final Map<String, String> _deviceAliases = {};
  final Map<int, String> _userIdAliases = {};
  int _userCounter = 1;
  int _deviceCounter = 1;

  /// Scrub sensitive data from Tautulli history response
  Map<String, dynamic> scrubHistory(Map<String, dynamic> response) {
    final scrubbed = Map<String, dynamic>.from(response);

    if (scrubbed['data'] != null && scrubbed['data'] is List) {
      scrubbed['data'] = (scrubbed['data'] as List).map((item) {
        final cleaned = Map<String, dynamic>.from(item);

        // Scrub user data
        if (cleaned['user'] != null) {
          cleaned['user'] = _getUserAlias(cleaned['user']);
        }
        if (cleaned['friendly_name'] != null) {
          cleaned['friendly_name'] = _getUserAlias(cleaned['friendly_name']);
        }
        if (cleaned['user_id'] != null) {
          cleaned['user_id'] = _getUserIdAlias(cleaned['user_id']);
        }

        // Scrub device/player data
        if (cleaned['player'] != null) {
          cleaned['player'] = _getDeviceAlias(cleaned['player']);
        }

        // Remove sensitive fields entirely
        cleaned.remove('ip_address');
        cleaned.remove('machine_id');
        cleaned.remove('session_key');

        // Optionally mask location
        if (cleaned['location'] == 'lan') {
          cleaned['location'] = 'local';
        } else if (cleaned['location'] == 'wan') {
          cleaned['location'] = 'remote';
        }

        return cleaned;
      }).toList();
    }

    return scrubbed;
  }

  /// Scrub sensitive data from Tautulli users response
  Map<String, dynamic> scrubUsers(Map<String, dynamic> response) {
    final scrubbed = Map<String, dynamic>.from(response);

    if (scrubbed['response'] != null && scrubbed['response']['data'] is List) {
      scrubbed['response']['data'] = (scrubbed['response']['data'] as List).map((user) {
        final cleaned = Map<String, dynamic>.from(user);

        // Scrub usernames
        if (cleaned['username'] != null) {
          cleaned['username'] = _getUserAlias(cleaned['username']);
        }
        if (cleaned['friendly_name'] != null) {
          cleaned['friendly_name'] = _getUserAlias(cleaned['friendly_name']);
        }
        if (cleaned['user_id'] != null) {
          cleaned['user_id'] = _getUserIdAlias(cleaned['user_id']);
        }

        // Remove sensitive fields
        cleaned.remove('email');
        cleaned.remove('user_thumb');
        cleaned.remove('server_token');

        return cleaned;
      }).toList();
    }

    return scrubbed;
  }

  /// Scrub activity data
  Map<String, dynamic> scrubActivity(Map<String, dynamic> response) {
    final scrubbed = Map<String, dynamic>.from(response);

    if (scrubbed['response'] != null && scrubbed['response']['data']['sessions'] is List) {
      scrubbed['response']['data']['sessions'] =
        (scrubbed['response']['data']['sessions'] as List).map((session) {
          final cleaned = Map<String, dynamic>.from(session);

          // Scrub user info
          if (cleaned['user'] != null) {
            cleaned['user'] = _getUserAlias(cleaned['user']);
          }
          if (cleaned['friendly_name'] != null) {
            cleaned['friendly_name'] = _getUserAlias(cleaned['friendly_name']);
          }

          // Scrub device info
          if (cleaned['player'] != null) {
            cleaned['player'] = _getDeviceAlias(cleaned['player']);
          }
          if (cleaned['device'] != null) {
            cleaned['device'] = _getDeviceAlias(cleaned['device']);
          }

          // Remove sensitive fields
          cleaned.remove('ip_address');
          cleaned.remove('machine_id');
          cleaned.remove('session_key');
          cleaned.remove('session_id');

          return cleaned;
        }).toList();
    }

    return scrubbed;
  }

  String _getUserAlias(String realUsername) {
    if (!_userAliases.containsKey(realUsername)) {
      _userAliases[realUsername] = 'User$_userCounter';
      _userCounter++;
    }
    return _userAliases[realUsername]!;
  }

  String _getUserIdAlias(int userId) {
    if (!_userIdAliases.containsKey(userId)) {
      _userIdAliases[userId] = 'UserID${_userCounter - 1}';
    }
    return _userIdAliases[userId]!;
  }

  String _getDeviceAlias(String realDevice) {
    if (!_deviceAliases.containsKey(realDevice)) {
      _deviceAliases[realDevice] = 'Device$_deviceCounter';
      _deviceCounter++;
    }
    return _deviceAliases[realDevice]!;
  }

  /// Public method to get user ID alias (for watch history sync)
  String getUserIdAlias(int userId) {
    return _getUserIdAlias(userId);
  }

  /// Get a summary of what was scrubbed (for debugging)
  Map<String, dynamic> getScrubSummary() {
    return {
      'users_scrubbed': _userAliases.length,
      'devices_scrubbed': _deviceAliases.length,
      'user_mappings': _userAliases,
      'device_mappings': _deviceAliases,
    };
  }

  /// Clear all aliases (when starting a new session)
  void reset() {
    _userAliases.clear();
    _deviceAliases.clear();
    _userIdAliases.clear();
    _userCounter = 1;
    _deviceCounter = 1;
  }
}