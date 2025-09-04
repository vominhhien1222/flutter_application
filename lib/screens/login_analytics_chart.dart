import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';

class LoginAnalyticsChart extends StatelessWidget {
  const LoginAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, color: Color(0xFF00BCD4)),
                    const SizedBox(width: 12),
                    const Text(
                      'Phân tích đăng nhập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (provider.isLoadingLogin)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // dùng provider.login (không phải loginAnalytics)
                if (provider.login != null) ...[
                  // Summary (hiện mỗi Total nếu model chỉ có totalLogins)
                  Row(
                    children: [
                      _buildStat(
                        'Tổng',
                        provider.login!.totalLogins.toString(),
                        const Color(0xFF00BCD4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chart từ byHour (map)
                  _buildChartFromByHour(provider.login!.byHour),
                ] else if (!provider.isLoadingLogin) ...[
                  const Center(
                    child: Text(
                      'Không có dữ liệu',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Vẽ chart từ Map<String,int>? byHour (ví dụ {"0":12,"1":5,...})
  Widget _buildChartFromByHour(Map<String, int>? byHour) {
    if (byHour == null || byHour.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text(
            'Chưa có dữ liệu theo giờ',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    // Chuẩn hoá 0..23 giờ để trục X đẹp và tránh thiếu key
    final hours = List<int>.generate(24, (i) => i);
    final values = hours.map((h) => (byHour['$h'] ?? 0).toDouble()).toList();

    final maxCount = values.fold<double>(0, (m, v) => v > m ? v : m);
    final chartMaxY = maxCount > 0 ? maxCount * 1.2 : 10.0;

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < hours.length; i++) {
      final count = values[i].isFinite ? values[i] : 0.0;
      barGroups.add(
        BarChartGroupData(
          x: hours[i],
          barRods: [
            BarChartRodData(
              toY: count,
              color: const Color(0xFF00BCD4),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: chartMaxY,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMaxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final hour = group.x.toInt();
                final count = rod.toY.toInt();
                return BarTooltipItem(
                  '$hour:00\n$count lượt',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${value.toInt()}h',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.white24, width: 1),
              left: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY / 5,
            getDrawingHorizontalLine: (value) {
              return const FlLine(color: Colors.white12, strokeWidth: 1);
            },
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
