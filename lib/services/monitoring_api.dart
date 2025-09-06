// lib/services/monitoring_apis.dart
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../models/top_api_item.dart';

class MonitoringApis {
  final ApiService _api;
  MonitoringApis({ApiService? api}) : _api = api ?? ApiService();

  /// Dashboard snapshot
  Future<DashboardData?> fetchDashboard() async {
    try {
      final res = await _api.getJson('/api/monitoring/dashboard');
      if (res is Map<String, dynamic> && res['Data'] != null) {
        return DashboardData.fromJson(res['Data']);
      }
      // Một số API có thể trả thẳng object thay vì bọc Data
      if (res is Map<String, dynamic>) {
        return DashboardData.fromJson(res);
      }
      return null;
    } catch (e) {
      // Không throw để UI không vỡ — có thể log hoặc show snackbar ở UI
      return null;
    }
  }

  /// Top APIs (trả về TopApiItem) — mặc định lấy top=5 trong 24h
  Future<List<TopApiItem>> fetchTopApis({int top = 5, int hours = 24}) async {
    try {
      final res = await _api.getJson(
        '/api/monitoring/analytics/top-apis?top=$top&hours=$hours',
      );

      // Chuẩn hoá: nhận {Data:[...]} hoặc [...]
      final List raw = (res is Map<String, dynamic>)
          ? (res['Data'] as List? ?? [])
          : (res as List? ?? []);

      final items = raw
          .whereType<Map<String, dynamic>>()
          .map((e) => TopApiItem.fromJson(e))
          .toList();

      // Sắp xếp giảm dần theo CallCount cho chắc
      items.sort((a, b) => b.callCount.compareTo(a.callCount));
      return items;
    } catch (e) {
      // Lỗi parse/format — trả list rỗng để UI tự hiển thị "Không có dữ liệu"
      return <TopApiItem>[];
    }
  }

  /// Login analytics
  Future<LoginAnalytics?> fetchLoginAnalytics({int hours = 24}) async {
    try {
      final res =
          await _api.getJson('/api/monitoring/analytics/login?hours=$hours');
      if (res is Map<String, dynamic> && res['Data'] != null) {
        return LoginAnalytics.fromJson(res['Data']);
      }
      if (res is Map<String, dynamic>) {
        return LoginAnalytics.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Registration analytics
  Future<RegistrationAnalytics?> fetchRegistrations({int hours = 24}) async {
    try {
      final res = await _api
          .getJson('/api/monitoring/analytics/registrations?hours=$hours');
      if (res is Map<String, dynamic> && res['Data'] != null) {
        return RegistrationAnalytics.fromJson(res['Data']);
      }
      if (res is Map<String, dynamic>) {
        return RegistrationAnalytics.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Business summary
  Future<BusinessMetrics?> fetchBusinessSummary({int hours = 24}) async {
    try {
      final res = await _api
          .getJson('/api/monitoring/analytics/business-summary?hours=$hours');
      if (res is Map<String, dynamic> && res['Data'] != null) {
        return BusinessMetrics.fromJson(res['Data']);
      }
      if (res is Map<String, dynamic>) {
        return BusinessMetrics.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
