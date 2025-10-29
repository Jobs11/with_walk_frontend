class PostHashtag {
  final int? phNum;
  final int pNum;
  final int hNum;

  const PostHashtag({this.phNum, required this.pNum, required this.hNum});

  factory PostHashtag.fromJson(Map<String, dynamic> json) => PostHashtag(
    phNum: (json['phNum'] as num?)?.toInt(),
    pNum: (json['pnum'] as num).toInt(),
    hNum: (json['hnum'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    if (phNum != null) 'phNum': phNum,
    'pnum': pNum,
    'hnum': hNum,
  };

  @override
  String toString() => 'PostHashtag(phNum: $phNum, pnum: $pNum, hnum: $hNum)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostHashtag &&
          runtimeType == other.runtimeType &&
          phNum == other.phNum &&
          pNum == other.pNum &&
          hNum == other.hNum;

  @override
  int get hashCode => phNum.hashCode ^ pNum.hashCode ^ hNum.hashCode;
}
