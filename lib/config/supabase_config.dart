// This file contains your Supabase configuration
// This file is gitignored - keep your keys safe!

class SupabaseConfig {
  static const String url = 'https://unrzdubozarzulnlbdqe.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVucnpkdWJvemFyenVsbmxiZHFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjAyNTQsImV4cCI6MjA3MTk5NjI1NH0.z8NR5lLLvj5UlOOTpE3XLpgVpB_9_Vai821hAUWSoQk';
  
  // Optional: Add other configuration
  static const String storageUrl = 'https://unrzdubozarzulnlbdqe.supabase.co/storage/v1';
  
  // APNS Configuration (for notifications)
  static const String apnsKeyId = 'QS6T68AGAT'; // Your APNs key ID (works for both sandbox and production)
  static const String apnsTeamId = 'A72HB5582T'; // Your Apple Team ID
  static const String apnsBundleId = 'app.zagreus'; // Your app bundle ID
}