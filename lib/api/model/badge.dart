class Badge {
  final int mbNum;
  final String mId;
  final int cNum;
  final String mbBadgeName;
  final DateTime mbEarnedDate;

  // 추가 정보
  final String? cTitle;
  final String? cDescription;

  Badge({
    required this.mbNum,
    required this.mId,
    required this.cNum,
    required this.mbBadgeName,
    required this.mbEarnedDate,
    this.cTitle,
    this.cDescription,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      mbNum: json['mbNum'] ?? 0,
      mId: json['mid'] ?? '',
      cNum: json['cnum'] ?? 0,
      mbBadgeName: json['mbBadgeName'] ?? '',
      mbEarnedDate: DateTime.parse(
        json['mbEarnedDate'] ?? DateTime.now().toIso8601String(),
      ),
      cTitle: json['ctitle'],
      cDescription: json['cdescription'],
    );
  }
}
