class Street {
  final String mId;
  final int? rNum;
  final DateTime? rDate; // ✅ DateTime으로 변경 (nullable)
  final DateTime rStartTime; // ✅ DateTime으로 변경
  final DateTime rEndTime; // ✅ DateTime으로 변경
  final double rDistance; // ✅ double로 변경
  final String rTime;
  final double rSpeed; // ✅ double로 변경
  final int rKcal; // ✅ int로 변경

  const Street({
    required this.mId,
    this.rNum,
    this.rDate, // nullable (서버에서 자동 생성)
    required this.rStartTime,
    required this.rEndTime,
    required this.rDistance,
    required this.rTime,
    required this.rSpeed,
    required this.rKcal,
  });

  // ✅ JSON → Dart (서버에서 받을 때)
  factory Street.fromJson(Map<String, dynamic> json) => Street(
    mId: json['m_id'] as String,
    rNum: (json['r_num'] as num?)?.toInt(),
    rDate: json['r_date'] != null
        ? DateTime.parse(json['r_date'] as String)
        : null,
    rStartTime: DateTime.parse(json['r_start_time'] as String),
    rEndTime: DateTime.parse(json['r_end_time'] as String),
    rDistance: (json['r_distance'] as num).toDouble(),
    rTime: json['r_time'] as String,
    rSpeed: (json['r_speed'] as num).toDouble(),
    rKcal: (json['r_kcal'] as num).toInt(),
  );

  // ✅ Dart → JSON (서버로 보낼 때)
  Map<String, dynamic> toJson() => {
    'm_id': mId,
    // r_date는 서버에서 자동 생성되므로 전송하지 않음
    'r_start_time': rStartTime.toIso8601String(), // "2025-10-10T14:30:00"
    'r_end_time': rEndTime.toIso8601String(), // "2025-10-10T15:45:00"
    'r_distance': rDistance,
    'r_time': rTime,
    'r_speed': rSpeed,
    'r_kcal': rKcal,
  };
}
