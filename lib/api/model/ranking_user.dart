class RankingUser {
  final String mId;
  final String mName;
  final double totalDistance;
  final int rank;

  const RankingUser({
    required this.mId,
    required this.mName,
    required this.totalDistance,
    required this.rank,
  });

  // ✅ JSON → Dart (서버에서 받을 때)
  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      mId: json['mid'] as String,
      mName: json['mname'] as String,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );
  }

  // ✅ Dart → JSON (필요시)
  Map<String, dynamic> toJson() {
    return {
      'mid': mId,
      'mname': mName,
      'totalDistance': totalDistance,
      'rank': rank,
    };
  }
}
