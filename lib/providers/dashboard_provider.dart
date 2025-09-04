import 'package:flutter/foundation.dart';
import '../apis/api_service.dart';
import '../models/dashboard_models.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  String? _error;

  DashboardData? _dashboard;
  LoginAnalytics? _login;
  List<TopApiUsage> _topApis = [];
  RegistrationAnalytics? _registrations;
  BusinessMetrics? _business;

  bool get isLoading => _loading;
  String? get error => _error;

  DashboardData? get dashboard => _dashboard;
  LoginAnalytics? get login => _login;
  List<TopApiUsage> get topApis => _topApis;
  RegistrationAnalytics? get registrations => _registrations;
  BusinessMetrics? get business => _business;

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

  Future<void> retry() => loadAll();
}
