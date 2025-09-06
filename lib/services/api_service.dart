import 'dart:convert';
import 'dart:developer';
import "package:http/http.dart" as http;
import '../models/dashboard_models.dart';

class ApiService {
  static const String baseUrl = 'https://api.app.honghunghospital.com.vn';

  // Common headers
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Helper method to make HTTP requests
  Future<dynamic> _makeRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('API Response [$endpoint]: ${data.toString()}');
        return data;
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to load data from $endpoint',
        );
      }
    } catch (e) {
      log('API Error [$endpoint]: $e');
      throw Exception('API Error: $e');
    }
  }

  // ✅ Public GET JSON
  Future<dynamic> getJson(String endpoint) async {
    return _makeRequest(endpoint);
  }

  // ✅ Public POST JSON
  Future<dynamic> postJson(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        log('API POST [$endpoint]: ${data.toString()}');
        return data;
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to POST $endpoint\n${response.body}',
        );
      }
    } catch (e) {
      log('API Error (POST) [$endpoint]: $e');
      throw Exception('API Error (POST): $e');
    }
  }

  // Helper to extract single object from response
  Map<String, dynamic> _extractSingleObject(
    dynamic data, [
    String? logContext,
  ]) {
    if (data is Map<String, dynamic>) {
      const possibleKeys = [
        'Data',
        'data',
        'Result',
        'result',
        'Response',
        'response',
        'Item',
        'item',
        'Object',
        'object',
        'Content',
        'content',
      ];
      for (final key in possibleKeys) {
        if (data.containsKey(key)) {
          final innerData = data[key];
          if (innerData is Map<String, dynamic>) {
            log('${logContext ?? "API"}: Extracted object from key "$key"');
            return innerData;
          }
        }
      }
      log('${logContext ?? "API"}: Using direct response (no wrapper found)');
      return data;
    }
    throw Exception(
      'Expected Map<String, dynamic> but got ${data.runtimeType}',
    );
  }

  // Helper to extract list from response
  List<dynamic> _extractList(dynamic data, [String? logContext]) {
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      const possibleKeys = [
        'Data',
        'data',
        'Items',
        'items',
        'Results',
        'results',
        'List',
        'list',
        'Array',
        'array',
        'Content',
        'content',
        'TopApis',
        'topApis',
        'Apis',
        'apis',
        'Endpoints',
        'endpoints',
        'Metrics',
        'metrics',
        'Analytics',
        'analytics',
      ];
      for (final key in possibleKeys) {
        if (data.containsKey(key) && data[key] is List) {
          final listData = data[key] as List;
          log('${logContext ?? "API"}: Found list with ${listData.length} items using key "$key"');
          return listData;
        }
      }
      for (final entry in data.entries) {
        if (entry.value is List) {
          final listData = entry.value as List;
          log('${logContext ?? "API"}: Found list with ${listData.length} items using fallback key "${entry.key}"');
          return listData;
        }
      }
    }
    log('${logContext ?? "API"}: No list found in response. Available keys: ${data is Map ? (data).keys.toList() : 'Not a Map'}');
    throw Exception('No valid list data found in API response');
  }

  // Helper to safely parse list items
  List<T> _parseListItems<T>(
    List<dynamic> listData,
    T Function(Map<String, dynamic>) fromJson, [
    String? logContext,
  ]) {
    return listData
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) {
          try {
            return fromJson(item as Map<String, dynamic>);
          } catch (e) {
            log('${logContext ?? "API"}: Error parsing item: $e, Item: $item');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<T>()
        .toList();
  }

  // Get Dashboard Data
  Future<DashboardData> getDashboardData() async {
    final data = await _makeRequest('/api/monitoring/dashboard');
    final responseData = _extractSingleObject(data, 'Dashboard');
    return DashboardData.fromJson(responseData);
  }

  // Get Login Analytics
  Future<LoginAnalytics> getLoginAnalytics([int hours = 24]) async {
    final data = await _makeRequest(
      '/api/monitoring/analytics/login?hours=$hours',
    );
    final responseData = _extractSingleObject(data, 'Login Analytics');
    return LoginAnalytics.fromJson(responseData);
  }

  // Get Top API Usage
  Future<List<TopApiUsage>> getTopApiUsage([
    int top = 20,
    int hours = 24,
  ]) async {
    final data = await _makeRequest(
      '/api/monitoring/analytics/top-apis?top=$top&hours=$hours',
    );
    if (data is List) {
      return _parseListItems(data, TopApiUsage.fromJson, 'Top API Usage');
    }
    if (data is Map<String, dynamic>) {
      final listData = _extractList(data, 'Top API Usage');
      return _parseListItems(listData, TopApiUsage.fromJson, 'Top API Usage');
    }
    throw Exception('Unexpected response type: ${data.runtimeType}');
  }

  // Get Registration Analytics
  Future<RegistrationAnalytics> getRegistrationAnalytics([
    int hours = 24,
  ]) async {
    final data = await _makeRequest(
      '/api/monitoring/analytics/registrations?hours=$hours',
    );
    final responseData = _extractSingleObject(data, 'Registration Analytics');
    return RegistrationAnalytics.fromJson(responseData);
  }

  // Get Business Metrics Summary
  Future<BusinessMetrics> getBusinessMetrics([int hours = 24]) async {
    final data = await _makeRequest(
      '/api/monitoring/analytics/business-summary?hours=$hours',
    );
    final responseData = _extractSingleObject(data, 'Business Metrics');
    return BusinessMetrics.fromJson(responseData);
  }

  // Generic method to get any list endpoint
  Future<List<T>> getListEndpoint<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, [
    String? logContext,
  ]) async {
    final data = await _makeRequest(endpoint);
    if (data is List) {
      return _parseListItems(data, fromJson, logContext);
    }
    if (data is Map<String, dynamic>) {
      final listData = _extractList(data, logContext);
      return _parseListItems(listData, fromJson, logContext);
    }
    throw Exception('Unexpected response type: ${data.runtimeType}');
  }

  // Generic method to get any single object endpoint
  Future<T> getSingleEndpoint<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, [
    String? logContext,
  ]) async {
    final data = await _makeRequest(endpoint);
    final responseData = _extractSingleObject(data, logContext);
    return fromJson(responseData);
  }
}
