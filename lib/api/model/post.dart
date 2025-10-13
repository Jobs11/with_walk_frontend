// lib/api/model/post.dart
class Post {
  final int? pNum;
  final String mId;
  final String? rNum; // 연결된 운동 기록 번호
  final String pContent;
  final String? pImage; // 이미지 URL
  final String pDate;
  final int pLikes;
  final List<String>? likedBy; // 좋아요 누른 사용자 ID 목록

  const Post({
    this.pNum,
    required this.mId,
    this.rNum,
    required this.pContent,
    this.pImage,
    required this.pDate,
    this.pLikes = 0,
    this.likedBy,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    pNum: (json['p_num'] as num?)?.toInt(),
    mId: json['m_id'] as String,
    rNum: json['r_num']?.toString(),
    pContent: json['p_content'] as String,
    pImage: json['p_image'] as String?,
    pDate: json['p_date'] as String,
    pLikes: (json['p_likes'] as num?)?.toInt() ?? 0,
    likedBy: (json['liked_by'] as List?)?.cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    if (pNum != null) 'p_num': pNum,
    'm_id': mId,
    if (rNum != null) 'r_num': rNum,
    'p_content': pContent,
    if (pImage != null) 'p_image': pImage,
    'p_date': pDate,
    'p_likes': pLikes,
    if (likedBy != null) 'liked_by': likedBy,
  };
}
