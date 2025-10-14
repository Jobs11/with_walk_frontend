class Friendship {
  final int? fNum;
  final String fromUserId;
  final String toUserId;
  final String status; // pending, accepted, rejected
  final String? createdAt;
  final String? updatedAt;

  const Friendship({
    this.fNum,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) => Friendship(
    fNum: (json['fnum'] as num?)?.toInt(),
    fromUserId: json['fromUserId'] as String,
    toUserId: json['toUserId'] as String,
    status: json['status'] as String,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'status': status,
  };
}
