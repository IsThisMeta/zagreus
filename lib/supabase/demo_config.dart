import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';

class ZagDemoConfig {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetches the demo configuration from Supabase
  /// Returns null if demo is disabled or not found
  static Future<Map<String, dynamic>?> fetchDemoConfig() async {
    try {
      final response = await _client
          .from('demo_config_v2')
          .select()
          .eq('enabled', true)
          .single();

      return response;
    } catch (e) {
      // If table doesn't exist or no config found, return null
      print('Demo config not available: $e');
      return null;
    }
  }

  /// Checks if demo is enabled
  static Future<bool> isDemoEnabled() async {
    try {
      final response = await _client
          .from('demo_config_v2')
          .select('enabled')
          .single();

      return response['enabled'] ?? false;
    } catch (e) {
      // If table doesn't exist or no config found, demo is disabled
      return false;
    }
  }
}

/*
Supabase Table Structure:

CREATE TABLE demo_config_v2 (
  id SERIAL PRIMARY KEY,
  enabled BOOLEAN DEFAULT false,

  -- Lidarr
  lidarr_enabled BOOLEAN DEFAULT false,
  lidarr_host TEXT,
  lidarr_key TEXT,

  -- Readarr
  readarr_enabled BOOLEAN DEFAULT false,
  readarr_host TEXT,
  readarr_key TEXT,

  -- NZBGet
  nzbget_enabled BOOLEAN DEFAULT false,
  nzbget_host TEXT,
  nzbget_user TEXT,
  nzbget_pass TEXT,

  -- Radarr
  radarr_enabled BOOLEAN DEFAULT false,
  radarr_host TEXT,
  radarr_key TEXT,

  -- SABnzbd
  sabnzbd_enabled BOOLEAN DEFAULT false,
  sabnzbd_host TEXT,
  sabnzbd_key TEXT,

  -- Sonarr
  sonarr_enabled BOOLEAN DEFAULT false,
  sonarr_host TEXT,
  sonarr_key TEXT,

  -- Bazarr
  bazarr_enabled BOOLEAN DEFAULT false,
  bazarr_host TEXT,
  bazarr_key TEXT,

  -- Tautulli
  tautulli_enabled BOOLEAN DEFAULT false,
  tautulli_host TEXT,
  tautulli_key TEXT,

  -- Overseerr
  overseerr_enabled BOOLEAN DEFAULT false,
  overseerr_host TEXT,
  overseerr_key TEXT,

  -- Unraid
  unraid_enabled BOOLEAN DEFAULT true,
  unraid_host TEXT,
  unraid_key TEXT,

  -- External Module
  external_module_enabled BOOLEAN DEFAULT false,
  external_module_name TEXT,
  external_module_host TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default demo config (disabled by default)
INSERT INTO demo_config_v2 (
  enabled,
  lidarr_enabled, lidarr_host, lidarr_key,
  readarr_enabled, readarr_host, readarr_key,
  nzbget_enabled, nzbget_host, nzbget_user, nzbget_pass,
  radarr_enabled, radarr_host, radarr_key,
  sabnzbd_enabled, sabnzbd_host, sabnzbd_key,
  sonarr_enabled, sonarr_host, sonarr_key,
  bazarr_enabled, bazarr_host, bazarr_key,
  tautulli_enabled, tautulli_host, tautulli_key,
  overseerr_enabled, overseerr_host, overseerr_key,
  unraid_enabled, unraid_host, unraid_key,
  external_module_enabled, external_module_name, external_module_host
) VALUES (
  false, -- Demo disabled by default
  true, 'http://lidarr.scarletmacaw.box.ca', '415636849060457686c7ad0287b600dd',
  true, 'http://readarr.scarletmacaw.box.ca/', '112fd9870c02429c8721884d0e22d82b',
  true, 'http://thebe.whatbox.ca:15245', 'isthismeta', '5EpM3IGHEuOg239QLjeM',
  true, 'https://radarr4k.scarletmacaw.box.ca', '6970ae751f2846ef96ab23cc684c9d74',
  true, 'https://sabnzbd.scarletmacaw.box.ca', '27843cf64c724b88a1eac3bcd6f3cab7',
  true, 'https://sonarr4k.scarletmacaw.box.ca', 'a6b51eea58c14fb185c75e7ab89e05e7',
  true, 'https://bazarr.scarletmacaw.box.ca/', 'kxcuxqehuepune11zgyaf6d64ad0bh1b',
  true, 'http://thebe.whatbox.ca:23786', 'ca72097372814a73ba603364f76cc99e',
  true, 'http://thebe.whatbox.ca:12301/', 'MTcxNjUzMzQyOTU5OTdjZjZlNDI1LWQwY2ItNGRlOS1iYTBlLTdlNjZlN2Y5NzJiYw==',
  true, 'https://tower.zagreus.app/', '4f881bebb9da6a41431cfa5b194b36fa12094a87b5164886542ddfa2e235066c',
  true, 'Test', 'https://zagreus.app'
);

-- To enable demo: UPDATE demo_config_v2 SET enabled = true WHERE id = 1;
-- To disable demo: UPDATE demo_config_v2 SET enabled = false WHERE id = 1;

-- Update Radarr 4K API key:
-- UPDATE demo_config_v2 SET radarr_key = '6970ae751f2846ef96ab23cc684c9d74' WHERE id = 1;
*/
