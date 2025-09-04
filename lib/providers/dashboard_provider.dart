import 'package:flutter/foundation.dart';
import '../apis/api_service.dart';
import '../models/dashboard_models.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Loading / error
  bool _loading = false;              // loading chung khi loadAll
  bool _loadingLogin = false;         // loading riêng cho login analytics
  String? _error;

  // Data
  DashboardData? _dashboard;
  LoginAnalytics? _login;
  List<TopApiUsage> _topApis = [];
  RegistrationAnalytics? _registrations;
  BusinessMetrics? _business;

  // Getters
  bool get isLoading => _loading;
  bool get isLoadingLogin => _loadingLogin;
  String? get error => _error;

  DashboardData? get dashboard => _dashboard;
  LoginAnalytics? get login => _login;
  List<TopApiUsage> get topApis => _topApis;
  RegistrationAnalytics? get registrations => _registrations;
  BusinessMetrics? get business => _business;

  /// Load toàn bộ dữ liệu dashboard
  Future<void> loadAll({int hours = 24}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final d = await _api.getDashboardData();
      final l = await _api.getLoginAnalytics(hours);
      final t = await _api.getTopApiUsage(10, hours);
      final r = await _api.getRegistrationAnalytics(hours);
      final b = await _api.getBusinessMetrics(hours);

      _dashboard = d;
      _login = l;
      _topApis = t;
      _registrations = r;
      _business = b;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Chỉ load Login Analytics (phục vụ chart đăng nhập)
  Future<void> loadLoginAnalytics({int hours = 24}) async {
    _loadingLogin = true;
    _error = null;
    notifyListeners();

    try {
      final l = await _api.getLoginAnalytics(hours);
      _login = l;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingLogin = false;
      notifyListeners();
    }
  }

  Future<void> retry() => loadAll();

  /// (tuỳ chọn) xoá error để UI ẩn thông báo lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
