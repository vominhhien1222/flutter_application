// lib/widgets/top_apis_table.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';

class TopApisTable extends StatefulWidget {
  final int top;    // số lượng API muốn lấy (top N)
  final int hours;  // khoảng thời gian (giờ) để thống kê

  const TopApisTable({
    super.key,
    this.top = 10,
    this.hours = 24,
  });

  @override
  State<TopApisTable> createState() => _TopApisTableState();
}

class _TopApisTableState extends State<TopApisTable> {
  @override
  void initState() {
    super.initState();
    // Tự load dữ liệu khi widget được tạo
    Future.microtask(() {
      final p = context.read<DashboardProvider>();
      p.loadTopApis(top: widget.top, hours: widget.hours);
    });
  }

  @override
  Widget build(BuildContext context) {
    final numFmt = NumberFormat.decimalPattern(); // 1,234

    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 420,
        child: Consumer<DashboardProvider>(
          builder: (context, p, _) {
            // ----- HEADER -----
            Widget header() {
              return Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Text(
                    'Top APIs (last ${widget.hours}h)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => p.loadTopApis(top: widget.top, hours: widget.hours),
                    icon: const Icon(Icons.refresh),
                  ),
                  if (p.isLoadingTopApis)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              );
            }

            // ----- BODY -----
            Widget body() {
              if (p.topApisError != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Lỗi tải Top APIs: ${p.topApisError}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              if (p.isLoadingTopApis && p.topApis.isEmpty) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (p.topApis.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Không có dữ liệu Top APIs.'),
                );
              }

              // Bảng cuộn ngang + dọc
              return Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 800),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowHeight: 44,
                          dataRowMinHeight: 44,
                          columns: const [
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('Endpoint')),
                            DataColumn(label: Text('Calls')),
                            DataColumn(label: Text('Avg (ms)')),
                            DataColumn(label: Text('Success')),
                            DataColumn(label: Text('Errors')),
                            DataColumn(label: Text('Success %')),
                          ],
                          rows: [
                            for (int i = 0; i < p.topApis.length; i++)
                              _row(numFmt: numFmt, index: i, ctx: context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                const SizedBox(height: 12),
                body(),
              ],
            );
          },
        ),
      ),
    );
  }

  DataRow _row({
    required NumberFormat numFmt,
    required int index,
    required BuildContext ctx,
  }) {
    final api = ctx.read<DashboardProvider>().topApis[index];

    // LƯU Ý: các thuộc tính dưới đây giả định model của bạn có tên:
    // fullEndpoint, controller, action, callCount, averageResponseTime,
    // successCount, errorCount, successRate.
    // Nếu trong `TopApiUsage` bạn đặt tên khác, đổi lại cho khớp.

    String calls = numFmt.format(api.callCount);
    String avg = api.averageResponseTime.toStringAsFixed(2);
    String success = numFmt.format(api.successCount);
    String errors = numFmt.format(api.errorCount);
    String rate = '${api.successRate.toStringAsFixed(1)}%';

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(api.fullEndpoint, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${api.controller}.${api.action}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        DataCell(Text(calls)),
        DataCell(Text(avg)),
        DataCell(Text(success)),
        DataCell(Text(errors)),
        DataCell(Text(rate)),
      ],
    );
  }
}
