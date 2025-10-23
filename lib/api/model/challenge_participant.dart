class ChallengeParticipant {
  final int cpNum;
  final int cNum;
  final String mId;
  final DateTime cpJoinDate;
  final String cpStatus;
  final DateTime? cpCompletedDate;
  final int cpCurrentValue;

  // 추가 정보
  final String? cTitle;
  final String? cReward;
  final int? cTargetValue;
  final String? cUnit;

  ChallengeParticipant({
    required this.cpNum,
    required this.cNum,
    required this.mId,
    required this.cpJoinDate,
    required this.cpStatus,
    this.cpCompletedDate,
    required this.cpCurrentValue,
    this.cTitle,
    this.cReward,
    this.cTargetValue,
    this.cUnit,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      cpNum: json['cpNum'] ?? 0,
      cNum: json['cnum'] ?? 0,
      mId: json['mid'] ?? '',
      cpJoinDate: DateTime.parse(
        json['cpJoinDate'] ?? DateTime.now().toIso8601String(),
      ),
      cpStatus: json['cpStatus'] ?? '',
      cpCompletedDate: json['cpCompletedDate'] != null
          ? DateTime.parse(json['cpCompletedDate'])
          : null,
      cpCurrentValue: json['cpCurrentValue'] ?? 0,
      cTitle: json['ctitle'],
      cReward: json['creward'],
      cTargetValue: json['ctargetValue'],
      cUnit: json['cunit'],
    );
  }

  // 진행률 계산
  double get progress {
    if (cTargetValue == null || cTargetValue == 0) return 0.0;
    return (cpCurrentValue / cTargetValue!).clamp(0.0, 1.0);
  }
}
