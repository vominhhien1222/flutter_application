// lib/widgets/metrics_overview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/providers/dashboard_provider.dart';

class MetricsOverview extends StatelessWidget {
  const MetricsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final numFmt = NumberFormat.decimalPattern(); // 1,234,567

        // ----- Helpers an toàn kiểu dữ liệu -----
        String fmtInt(dynamic v) {
          if (v == null) return '---';
          if (v is num) return numFmt.format(v);
          if (v is String) {
            final parsed = num.tryParse(v);
            return parsed != null ? numFmt.format(parsed) : v;
          }
          return v.toString();
        }

        String fmtPercent(dynamic v) {
          if (v == null) return '---%';
          if (v is num) return '${v.toDouble().toStringAsFixed(1)}%';
          if (v is String) {
            final parsed = num.tryParse(v);
            return parsed != null
                ? '${parsed.toDouble().toStringAsFixed(1)}%'
                : (v.endsWith('%') ? v : '$v%');
          }
          return '$v%';
        }

        final dd = provider.dashboard;      // DashboardData?
        final bm = provider.business;       // BusinessMetrics?

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Total Requests (từ DashboardData)
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.api,
                  title: 'Tổng Requests',
                  value: fmtInt(dd?.totalRequests),
                  subtitle: 'API Calls',
                  color: const Color(0xFF00BCD4),
                  isLoading: provider.isLoading,
                ),
              ),

              const SizedBox(width: 16),

              // Success Rate (ưu tiên dashboard.successRate, fallback business.successRate nếu có)
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  title: 'Success Rate',
                  value: fmtPercent(dd?.successRate ?? bm?.successRate),
                  subtitle: 'Thành công',
                  color: const Color(0xFF4CAF50),
                  isLoading: provider.isLoading,
                ),
              ),

              const SizedBox(width: 16),

              // Login Count (từ LoginAnalytics)
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.login,
                  title: 'Đăng nhập',
                  value: fmtInt(provider.login?.totalLogins),
                  subtitle: 'Lượt đăng nhập',
                  color: const Color(0xFFFF9800),
                  isLoading: provider.isLoadingLogin,
                ),
              ),

              const SizedBox(width: 16),

              // Registration Count
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.person_add,
                  title: 'Đăng ký',
                  value: fmtInt(
                    provider.registrations?.totalAccountRegistrations,
                  ),
                  subtitle: 'Lượt đăng ký',
                  color: const Color(0xFF9C27B0),
                  // bạn chưa có cờ loading riêng cho registrations, tạm dùng isLoading chung
                  isLoading: provider.isLoading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isLoading,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
