import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TopApisList extends StatelessWidget {
  const TopApisList({super.key});

  @override
  Widget build(BuildContext context) {
    final numFmt = NumberFormat('#,###');

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- Header -----
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    const Text(
                      'Top APIs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (provider.isLoadingTopApis)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // ----- Danh sách hoặc thông báo -----
                if (provider.topApis.isNotEmpty) ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.topApis.length,
                      itemBuilder: (context, index) {
                        // ép dynamic để tránh lỗi nullability/kiểu khi format
                        final api = provider.topApis[index] as dynamic;
                        final rank = index + 1;

                        final endpoint = _s(api.fullEndpoint ?? api.endpoint);
                        final calls = numFmt.format(_n(api.callCount));
                        final avgMs =
                            '${_n(api.averageResponseTime).toStringAsFixed(0)}ms';
                        final success =
                            '${_n(api.successRate).toStringAsFixed(1)}%';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: rank <= 3
                                ? Border.all(
                                    color:
                                        _getRankColor(rank).withOpacity(0.3),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$rank',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      endpoint,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildApiStat(
                                    'Calls',
                                    calls,
                                    const Color(0xFF00BCD4),
                                  ),
                                  _buildApiStat(
                                    'Avg Time',
                                    avgMs,
                                    const Color(0xFFFF9800),
                                  ),
                                  _buildApiStat(
                                    'Success',
                                    success,
                                    const Color(0xFF4CAF50),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (!provider.isLoadingTopApis) ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Không có dữ liệu',
                        style: TextStyle(color: Colors.white60),
                      ),
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

  // ----- Helpers -----
  // Parse số an toàn từ int/double/String/null
  static num _n(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  // Parse chuỗi an toàn, fallback '---'
  static String _s(dynamic v) {
    if (v == null) return '---';
    final s = v.toString();
    return s.isEmpty ? '---' : s;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF666666);
    }
  }

  Widget _buildApiStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
