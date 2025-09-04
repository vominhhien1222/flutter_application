import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // GỌI API KHI VÀO MÀN HÌNH
   Future.microtask(() {
    if (!mounted) return;
    context.read<DashboardProvider>().loadAll(hours: 24);
  });
}

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: vm.isLoading ? null : () => vm.loadAll(hours: 24), // 👈 GỌI LẠI
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Lỗi: ${vm.error}', textAlign: TextAlign.center),
                      ),
                      FilledButton(
                        onPressed: vm.retry,
                        child: const Text('Thử lại'),
                      )
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (vm.dashboard != null)
                      Card(
                        child: ListTile(
                          title: const Text('Tổng request'),
                          trailing: Text('${vm.dashboard!.totalRequests}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    // … các card khác (login, business, registrations, topApis)
                  ],
                ),
    );
  }
}
