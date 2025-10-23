class Challenge {
  final int cNum;
  final String cTitle;
  final String cDescription;
  final String cType;
  final int cTargetValue;
  final String cUnit;
  final DateTime cStartDate;
  final DateTime cEndDate;
  final String cReward;
  final String cStatus;
  final DateTime? cCreatedAt;
  final DateTime? cUpdatedAt;

  // 추가 정보
  final int participantCount;
  final int daysLeft;
  final bool isJoined;
  final double progress;
  final int currentValue;

  Challenge({
    required this.cNum,
    required this.cTitle,
    required this.cDescription,
    required this.cType,
    required this.cTargetValue,
    required this.cUnit,
    required this.cStartDate,
    required this.cEndDate,
    required this.cReward,
    required this.cStatus,
    this.cCreatedAt,
    this.cUpdatedAt,
    required this.participantCount,
    required this.daysLeft,
    required this.isJoined,
    required this.progress,
    required this.currentValue,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      cNum: json['cnum'] ?? 0,
      cTitle: json['ctitle'] ?? '',
      cDescription: json['cdescription'] ?? '',
      cType: json['ctype'] ?? '',
      cTargetValue: json['ctargetValue'] ?? 0,
      cUnit: json['cunit'] ?? '',
      cStartDate: DateTime.parse(
        json['cstartDate'] ?? DateTime.now().toIso8601String(),
      ),
      cEndDate: DateTime.parse(
        json['cendDate'] ?? DateTime.now().toIso8601String(),
      ),
      cReward: json['creward'] ?? '',
      cStatus: json['cstatus'] ?? '',
      cCreatedAt: json['ccreatedAt'] != null
          ? DateTime.parse(json['ccreatedAt'])
          : null,
      cUpdatedAt: json['cupdatedAt'] != null
          ? DateTime.parse(json['cupdatedAt'])
          : null,
      participantCount: json['participantCount'] ?? 0,
      daysLeft: json['daysLeft'] ?? 0,
      isJoined: json['isJoined'] == 1 || json['isJoined'] == true,
      progress: (json['progress'] ?? 0.0).toDouble(),
      currentValue: json['currentValue'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnum': cNum,
      'ctitle': cTitle,
      'cdescription': cDescription,
      'ctype': cType,
      'ctargetValue': cTargetValue,
      'cunit': cUnit,
      'cstartDate': cStartDate.toIso8601String(),
      'c_encendDated_date': cEndDate.toIso8601String(),
      'creward': cReward,
      'cstatus': cStatus,
    };
  }
}
