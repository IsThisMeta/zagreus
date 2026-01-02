import 'package:zagreus/modules/sabnzbd/core/api/api.dart';
import 'package:intl/intl.dart';

class DownloadHistoryData {
  final Map<String, double> chartData;
  final double totalGB;

  DownloadHistoryData({
    required this.chartData,
    required this.totalGB,
  });
}

class DownloadHistoryFetcher {
  static Future<DownloadHistoryData> fetchSabnzbdDownloadStats({
    required SABnzbdAPI api,
    required int weeksLookBack,
  }) async {
    try {
      print('📊 Fetching SABnzbd statistics...');
      final stats = await api.getStatistics();
      
      print('📊 SABnzbd stats received:');
      print('   - Total servers: ${stats.servers.length}');
      for (var server in stats.servers) {
        print('   - Server: ${server.name}');
        print('     - Daily usage: ${server.dailyUsage}');
        print('     - Weekly usage: ${server.weeklyUsage}');
        print('     - Monthly usage: ${server.monthlyUsage}');
        print('     - Total usage: ${server.totalUsage}');
        print('     - Daily map: ${server.daily}');
        print('     - Daily entries: ${server.daily?.length ?? 0}');
      }
      
      final now = DateTime.now();
      final lookbackDate = now.subtract(Duration(days: weeksLookBack * 7));
      final dateFormat = DateFormat('yyyy-MM-dd'); // SABnzbd uses YYYY-MM-DD format!
      final displayFormat = DateFormat('E (yyyy-MM-dd)'); // e.g., "Mon (2024-11-16)"
      
      print('📊 Date range: ${dateFormat.format(lookbackDate)} to ${dateFormat.format(now)}');
      
      Map<String, double> aggregatedData = {};
      double totalBytes = 0;

      // Process each server's daily data
      for (var server in stats.servers) {
        if (server.daily != null && server.daily!.isNotEmpty) {
          print('📊 Processing server ${server.name} with ${server.daily!.length} daily entries');
          server.daily!.forEach((dateStr, bytes) {
            try {
              final date = dateFormat.parse(dateStr);
              
              // Only include dates within lookback window
              if (date.isAfter(lookbackDate) && date.isBefore(now.add(const Duration(days: 1)))) {
                final displayDate = displayFormat.format(date);
                final gb = bytes / 1073741824.0; // Convert bytes to GB
                
                print('   📅 $dateStr -> $displayDate: ${gb.toStringAsFixed(2)} GB');
                
                aggregatedData[displayDate] = (aggregatedData[displayDate] ?? 0) + gb;
                totalBytes += bytes;
              } else {
                print('   ⏭️ Skipping $dateStr (outside range)');
              }
            } catch (e) {
              print('   ❌ Error parsing date $dateStr: $e');
            }
          });
        } else {
          print('📊 Server ${server.name} has no daily data');
        }
      }

      print('📊 Aggregated ${aggregatedData.length} days of data, total: ${(totalBytes / 1073741824.0).toStringAsFixed(2)} GB');

      // Sort by date
      final sortedEntries = aggregatedData.entries.toList()
        ..sort((a, b) {
          try {
            final dateA = displayFormat.parse(a.key);
            final dateB = displayFormat.parse(b.key);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });

      final sortedData = Map<String, double>.fromEntries(sortedEntries);
      final totalGB = totalBytes / 1073741824.0;

      return DownloadHistoryData(
        chartData: sortedData,
        totalGB: totalGB,
      );
    } catch (e, stackTrace) {
      print('❌ Error in fetchSabnzbdDownloadStats: $e');
      print('❌ Stack trace: $stackTrace');
      return DownloadHistoryData(
        chartData: {},
        totalGB: 0,
      );
    }
  }

}
