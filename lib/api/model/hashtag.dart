class Hashtag {
  final int? hNum;
  final String hName;
  final int hCount;
  final String? createdAt;

  const Hashtag({
    this.hNum,
    required this.hName,
    required this.hCount,
    this.createdAt,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) => Hashtag(
    hNum: (json['hnum'] as num?)?.toInt(),
    hName: json['hname'] as String,
    hCount: (json['hcount'] as num).toInt(),
    createdAt: json['createdAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (hNum != null) 'hnum': hNum,
    'hname': hName,
    'hcount': hCount,
    if (createdAt != null) 'createdAt': createdAt,
  };

  // 해시태그를 # 포함해서 표시
  String get displayName => '#$hName';

  @override
  String toString() => 'Hashtag(hnum: $hNum, hname: $hName, hcount: $hCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hashtag &&
          runtimeType == other.runtimeType &&
          hNum == other.hNum &&
          hName == other.hName;

  @override
  int get hashCode => hNum.hashCode ^ hName.hashCode;
}
