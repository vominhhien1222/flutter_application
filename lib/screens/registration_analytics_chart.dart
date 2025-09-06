import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class RegistrationAnalyticsChart extends StatelessWidget {
  const RegistrationAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final hasData = provider.registrations != null;

        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.person_add, color: Color(0xFF9C27B0)),
                    const SizedBox(width: 12),
                    const Text(
                      'Phân tích đăng ký',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (provider.isLoading) // nếu có cờ isLoading khác, đổi ở đây
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                if (hasData) ...[
                  // ===== Summary stats (3 ô) =====
                  Row(
                    children: [
                      _buildStat(
                        'Tổng đăng ký',
                        (provider.registrations?.totalAccountRegistrations ?? 0)
                            .toString(),
                        const Color(0xFF9C27B0),
                      ),
                      const SizedBox(width: 24),
                      _buildStat(
                        'Đăng ký khám',
                        (provider.registrations?.totalDangKyAttempts ?? 0)
                            .toString(),
                        const Color(0xFF00BCD4),
                      ),
                      const SizedBox(width: 24),
                      _buildStat(
                        'Đăng ký TK',
                        (provider.registrations?.successfulAccountRegistrations ??
                                0)
                            .toString(),
                        const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== Pie Chart + Legend =====
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _buildPieChart(provider)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                'Đăng ký khám',
                                const Color(0xFF00BCD4),
                                provider.registrations?.totalDangKyAttempts ?? 0,
                              ),
                              const SizedBox(height: 12),
                              _buildLegendItem(
                                'Đăng ký tài khoản',
                                const Color(0xFFFF9800),
                                provider.registrations
                                        ?.totalAccountRegistrations ??
                                    0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!provider.isLoading) ...[
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

  // ===== Pie Chart =====
  Widget _buildPieChart(DashboardProvider provider) {
    final dangKyAttempts = provider.registrations?.totalDangKyAttempts ?? 0;
    final accountRegistrations =
        provider.registrations?.totalAccountRegistrations ?? 0;

    final total = dangKyAttempts + accountRegistrations;
    if (total == 0) {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            color: const Color(0xFF00BCD4),
            value: dangKyAttempts.toDouble(),
            title: '${(dangKyAttempts / total * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFFFF9800),
            value: accountRegistrations.toDouble(),
            title:
                '${(accountRegistrations / total * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Stat chip =====
  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ===== Legend item =====
  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
