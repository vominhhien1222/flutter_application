class DashboardData {
  final int totalRequests;
  final int? activeUsers;
  final int? errorCount;

  DashboardData({
    required this.totalRequests,
    this.activeUsers,
    this.errorCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // chống case: TotalRequests / totalRequests / requests
    int _pickInt(List<String> keys) {
      for (final k in keys) {
        if (json[k] is num) return (json[k] as num).toInt();
      }
      return 0;
    }

    return DashboardData(
      totalRequests: _pickInt(['TotalRequests', 'totalRequests', 'requests', 'count']),
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
  final String? endpoint;
  final String? method;
  final int? count;

  TopApiUsage({
    this.endpoint,
    this.method,
    this.count,
  });

  factory TopApiUsage.fromJson(Map<String, dynamic> json) {
    String? ep = json['endpoint'] ?? json['Endpoint'] ?? json['path'] ?? json['Path'];
    String? m = json['method'] ?? json['Method'] ?? json['httpMethod'];
    int? c;
    final rawCount = json['count'] ?? json['Count'] ?? json['calls'] ?? json['Calls'];
    if (rawCount is num) c = rawCount.toInt();

    return TopApiUsage(endpoint: ep, method: m, count: c);
  }
}

class RegistrationAnalytics {
  final int totalAccountRegistrations;

  RegistrationAnalytics({required this.totalAccountRegistrations});

  factory RegistrationAnalytics.fromJson(Map<String, dynamic> json) {
    int total = 0;
    final keys = [
      'TotalRegistrations',
      'totalRegistrations',
      'registrations',
      'TotalAccountRegistrations',
      'totalAccountRegistrations'
    ];
    for (final k in keys) {
      if (json[k] is num) {
        total = (json[k] as num).toInt();
        break;
      }
    }
    return RegistrationAnalytics(totalAccountRegistrations: total);
  }
}

class BusinessMetrics {
  final int totalApiCalls;
  final int? successCalls;
  final int? failedCalls;

  BusinessMetrics({
    required this.totalApiCalls,
    this.successCalls,
    this.failedCalls,
  });

  factory BusinessMetrics.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => v is num ? v.toInt() : 0;

    return BusinessMetrics(
      totalApiCalls: _toInt(json['TotalApiCalls'] ?? json['totalApiCalls'] ?? json['apiCalls']),
      successCalls: (json['SuccessCalls'] ?? json['successCalls']) is num
          ? (json['SuccessCalls'] ?? json['successCalls'] as num).toInt()
          : null,
      failedCalls: (json['FailedCalls'] ?? json['failedCalls']) is num
          ? (json['FailedCalls'] ?? json['failedCalls'] as num).toInt()
          : null,
    );
  }
}
