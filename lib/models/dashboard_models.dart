class DashboardData {
  final int totalRequests;
  final int? activeUsers;
  final int? errorCount;

  DashboardData({
    required this.totalRequests,
    this.activeUsers,
    this.errorCount,
  });

  /// 🔹 Getter tính successRate từ totalRequests và errorCount
  double get successRate {
    if (totalRequests == 0) return 0;
    final errors = errorCount ?? 0;
    final success = totalRequests - errors;
    return (success / totalRequests) * 100;
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    int _pickInt(List<String> keys) {
      for (final k in keys) {
        if (json[k] is num) return (json[k] as num).toInt();
      }
      return 0;
    }

    return DashboardData(
      totalRequests:
          _pickInt(['TotalRequests', 'totalRequests', 'requests', 'count']),
      activeUsers: (json['ActiveUsers'] ?? json['activeUsers']) is num
          ? ((json['ActiveUsers'] ?? json['activeUsers']) as num).toInt()
          : null,
      errorCount: (json['ErrorCount'] ?? json['errorCount']) is num
          ? ((json['ErrorCount'] ?? json['errorCount']) as num).toInt()
          : null,
    );
  }
}


class LoginAnalytics {
  final int totalLogins;
  final Map<String, int>? byHour; // nếu backend có

  LoginAnalytics({
    required this.totalLogins,
    this.byHour,
  });

  factory LoginAnalytics.fromJson(Map<String, dynamic> json) {
    int total = 0;
    if (json['TotalLogins'] is num) total = (json['TotalLogins'] as num).toInt();
    if (json['totalLogins'] is num) total = (json['totalLogins'] as num).toInt();
    if (json['logins'] is num) total = (json['logins'] as num).toInt();

    Map<String, int>? hourly;
    final raw = json['ByHour'] ?? json['byHour'];
    if (raw is Map) {
      hourly = raw.map((k, v) => MapEntry('$k', v is num ? v.toInt() : 0));
    }

    return LoginAnalytics(totalLogins: total, byHour: hourly);
  }
}

class TopApiUsage {
  final String controller;
  final String action;
  final String fullEndpoint;
  final int callCount;
  final double averageResponseTime;
  final int successCount;
  final int errorCount;
  final double successRate;

  TopApiUsage({
    required this.controller,
    required this.action,
    required this.fullEndpoint,
    required this.callCount,
    required this.averageResponseTime,
    required this.successCount,
    required this.errorCount,
    required this.successRate,
  });

  factory TopApiUsage.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;

    return TopApiUsage(
      controller: json['Controller']?.toString() ?? '',
      action: json['Action']?.toString() ?? '',
      fullEndpoint: json['FullEndpoint']?.toString() ?? '',
      callCount: toNum(json['CallCount']).toInt(),
      averageResponseTime: toNum(json['AverageResponseTime']).toDouble(),
      successCount: toNum(json['SuccessCount']).toInt(),
      errorCount: toNum(json['ErrorCount']).toInt(),
      successRate: toNum(json['SuccessRate']).toDouble(),
    );
  }
}


class RegistrationAnalytics {
  final int totalAccountRegistrations;
  final int successfulAccountRegistrations;
  final int totalAttempts; // hoặc tên thật API trả về

  RegistrationAnalytics({
    required this.totalAccountRegistrations,
    required this.successfulAccountRegistrations,
    required this.totalAttempts,
  });

  // 🔹 Alias để widget xài được totalDangKyAttempts
  int get totalDangKyAttempts => totalAttempts;

  factory RegistrationAnalytics.fromJson(Map<String, dynamic> j) {
    int toInt(v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return RegistrationAnalytics(
      totalAccountRegistrations:
          toInt(j['TotalAccountRegistrations'] ?? j['totalAccountRegistrations']),
      successfulAccountRegistrations:
          toInt(j['SuccessfulAccountRegistrations'] ?? j['successfulAccountRegistrations']),
      totalAttempts: toInt(j['TotalAttempts'] ?? j['totalAttempts']),
    );
  }
}


class BusinessMetrics {
  final int totalApiCalls;
  final int successCalls;
  final int failedCalls;

  BusinessMetrics({
    required this.totalApiCalls,
    required this.successCalls,
    required this.failedCalls,
  });

  /// 🔹 Tỷ lệ thành công (%), ví dụ 97.5
  double get successRate {
    if (totalApiCalls == 0) return 0;
    return (successCalls / totalApiCalls) * 100;
  }

  factory BusinessMetrics.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final total = _toInt(json['TotalApiCalls'] ?? json['totalApiCalls'] ?? json['apiCalls']);
    final success = _toInt(json['SuccessCalls'] ?? json['successCalls']);
    final failed = _toInt(json['FailedCalls'] ?? json['failedCalls']);

    return BusinessMetrics(
      totalApiCalls: total,
      successCalls: success,
      failedCalls: failed,
    );
  }
}

