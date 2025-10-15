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
    mId: json['mid'] as String,
    rNum: (json['rnum'] as num?)?.toInt(),
    rDate: json['rdate'] != null
        ? DateTime.parse(json['rdate'] as String)
        : null,
    rStartTime: DateTime.parse(json['rstartTime'] as String),
    rEndTime: DateTime.parse(json['rendTime'] as String),
    rDistance: (json['rdistance'] as num).toDouble(),
    rTime: json['rtime'] as String,
    rSpeed: (json['rspeed'] as num).toDouble(),
    rKcal: (json['rkcal'] as num).toInt(),
  );

  // ✅ Dart → JSON (서버로 보낼 때)
  Map<String, dynamic> toJson() => {
    'mid': mId,
    // r_date는 서버에서 자동 생성되므로 전송하지 않음
    'rstartTime': rStartTime.toIso8601String(), // "2025-10-10T14:30:00"
    'rendTime': rEndTime.toIso8601String(), // "2025-10-10T15:45:00"
    'rdistance': rDistance,
    'rtime': rTime,
    'rspeed': rSpeed,
    'rkcal': rKcal,
  };
}
