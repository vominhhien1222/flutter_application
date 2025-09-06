class TopApiItem {
  final String controller;
  final String action;
  final String fullEndpoint;
  final int callCount;
  final double averageResponseTime;
  final int successCount;
  final int errorCount;
  final double successRate;

  TopApiItem({
    required this.controller,
    required this.action,
    required this.fullEndpoint,
    required this.callCount,
    required this.averageResponseTime,
    required this.successCount,
    required this.errorCount,
    required this.successRate,
  });

  factory TopApiItem.fromJson(Map<String, dynamic> json) {
    // API của bạn trả về Data:[ { ... } ]
    num toNum(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;

    return TopApiItem(
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
