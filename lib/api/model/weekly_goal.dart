class WeeklyGoal {
  final int? wgNum;
  final String mId;
  final double wgGoalKm;
  final DateTime wgStartDate;
  final DateTime? wgCreatedAt;
  final DateTime? wgUpdatedAt;

  WeeklyGoal({
    this.wgNum,
    required this.mId,
    required this.wgGoalKm,
    required this.wgStartDate,
    this.wgCreatedAt,
    this.wgUpdatedAt,
  });

  // JSON → WeeklyGoal
  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      wgNum: json['wgNum'],
      mId: json['mId'] ?? '',
      wgGoalKm: (json['wgGoalKm'] ?? 0).toDouble(),
      wgStartDate: json['wgStartDate'] != null
          ? DateTime.parse(json['wgStartDate'])
          : DateTime.now(),
      wgCreatedAt: json['wgCreatedAt'] != null
          ? DateTime.parse(json['wgCreatedAt'])
          : null,
      wgUpdatedAt: json['wgUpdatedAt'] != null
          ? DateTime.parse(json['wgUpdatedAt'])
          : null,
    );
  }

  // WeeklyGoal → JSON
  Map<String, dynamic> toJson() {
    return {
      'wgNum': wgNum,
      'mId': mId,
      'wgGoalKm': wgGoalKm,
      'wgStartDate': wgStartDate.toIso8601String().split('T')[0], // yyyy-MM-dd
      'wgCreatedAt': wgCreatedAt?.toIso8601String(),
      'wgUpdatedAt': wgUpdatedAt?.toIso8601String(),
    };
  }
}
