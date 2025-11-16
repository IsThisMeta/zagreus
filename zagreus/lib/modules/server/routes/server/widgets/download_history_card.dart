import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:fl_chart/fl_chart.dart';

class DownloadHistoryCard extends StatelessWidget {
  final Map<String, double> chartData;
  final double totalGB;
  final String periodLabel;

  const DownloadHistoryCard({
    Key? key,
    required this.chartData,
    required this.totalGB,
    required this.periodLabel,
  }) : super(key: key);

  Color _sectionIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.light ? Colors.black54 : Colors.white70;
  }

  String _formatSize(double gb) {
    if (gb < 0.01) return '0 GB';
    if (gb < 1) return '${(gb * 1024).toStringAsFixed(0)} MB';
    if (gb < 1000) return '${gb.toStringAsFixed(1)} GB';
    return '${(gb / 1024).toStringAsFixed(2)} TB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    
    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // More compact padding
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isLightTheme ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18, // Slightly smaller icon
                color: _sectionIconColor(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Download History',
                  style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontSize: 15, // Slightly smaller
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Tighter spacing
          Text(
            '${_formatSize(totalGB)} in last $periodLabel',
            style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
              fontSize: 16, // Slightly smaller
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12), // Tighter spacing
          if (chartData.isNotEmpty)
            _buildChart(context)
          else
            SizedBox(
              height: 100, // Smaller empty state
              child: Center(
                child: Text(
                  'No download history available',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final entries = chartData.entries.toList();
    
    if (entries.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text('No data')));
    }

    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: 140, // More compact height
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.cardColor.withOpacity(0.9),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = entries[groupIndex];
                return BarTooltipItem(
                  '${entry.key}\n',
                  TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // Smaller
                  ),
                  children: [
                    TextSpan(
                      text: _formatSize(entry.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 10, // Smaller
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20, // Less space
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < entries.length) {
                    final date = entries[value.toInt()].key;
                    // Extract just the day letter (M, T, W, etc.)
                    final dayLetter = date.split(' ').isNotEmpty ? date.split(' ')[0][0] : '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        dayLetter,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          fontSize: 9, // Smaller
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36, // Less space
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('');
                  return Text(
                    _formatSize(value),
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontSize: 9, // Smaller
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? maxValue / 3 : 1, // Fewer grid lines
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: (isLightTheme ? Colors.black12 : Colors.white12),
                strokeWidth: 0.5, // Thinner lines
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  color: ZagColours.orange,
                  width: 12, // Thinner bars for 2 weeks
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
