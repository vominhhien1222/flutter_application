// lib/providers/dashboard_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/models/dashboard_models.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ----- Loading / Error -----
  bool _loading = false;            // loading chung khi loadAll
  bool _loadingLogin = false;       // loading riêng cho login analytics
  bool _loadingTopApis = false;     // loading riêng cho Top APIs

  String? _error;                   // lỗi chung
  String? _topApisError;            // lỗi riêng cho Top APIs

  // ----- Data -----
  DashboardData? _dashboard;
  LoginAnalytics? _login;
  List<TopApiUsage> _topApis = [];
  RegistrationAnalytics? _registrations;
  BusinessMetrics? _business;

  // ----- Getters -----
  bool get isLoading => _loading;
  bool get isLoadingLogin => _loadingLogin;
  bool get isLoadingTopApis => _loadingTopApis;

  String? get error => _error;
  String? get topApisError => _topApisError;

  DashboardData? get dashboard => _dashboard;
  LoginAnalytics? get login => _login;
  List<TopApiUsage> get topApis => _topApis;
  RegistrationAnalytics? get registrations => _registrations;
  BusinessMetrics? get business => _business;

  // ----- Actions -----

  /// Load toàn bộ dữ liệu dashboard
  Future<void> loadAll({int hours = 24}) async {
    _loading = true;
    _error = null;
    _topApisError = null; // reset lỗi top APIs khi loadAll
    notifyListeners();

    try {
      final d = await _api.getDashboardData();
      final l = await _api.getLoginAnalytics(hours);
      final t = await _api.getTopApiUsage(10, hours);
      final r = await _api.getRegistrationAnalytics(hours);
      final b = await _api.getBusinessMetrics(hours);

      // (tuỳ chọn) sort giảm dần CallCount cho chắc
      t.sort((a, b) => b.callCount.compareTo(a.callCount));

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
      _login = await _api.getLoginAnalytics(hours);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingLogin = false;
      notifyListeners();
    }
  }

  /// Chỉ load Top APIs (để widget dùng isLoadingTopApis + topApisError)
  Future<void> loadTopApis({int top = 5, int hours = 24}) async {
    _loadingTopApis = true;
    _topApisError = null;
    notifyListeners();

    try {
      final list = await _api.getTopApiUsage(top, hours);
      list.sort((a, b) => b.callCount.compareTo(a.callCount)); // sort giảm dần
      _topApis = list;
    } catch (e) {
      _topApisError = e.toString();
      _topApis = [];
    } finally {
      _loadingTopApis = false;
      notifyListeners();
    }
  }

  Future<void> retry() => loadAll();

  void clearError() {
    _error = null;
    _topApisError = null;
    notifyListeners();
  }
}
