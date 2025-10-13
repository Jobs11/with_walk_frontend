// lib/api/model/post.dart
class Post {
  final int? pNum;
  final String mId;
  final String? rNum; // 연결된 운동 기록 번호
  final String pContent;
  final String? pImage; // 이미지 URL
  final String pDate;
  final int pLikes;

  // 추가 필드
  final String? authorName; // ✅ nullable
  final String? authorImage; // ✅ nullable
  final int likeCount;
  final int commentCount;
  final bool isLikedByUser;

  const Post({
    this.pNum,
    required this.mId,
    this.rNum,
    required this.pContent,
    this.pImage,
    required this.pDate,
    this.pLikes = 0,
    this.authorName,
    this.authorImage,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByUser = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    pNum: (json['pnum'] as num?)?.toInt(),
    mId: json['mid'] as String,
    rNum: json['rnum']?.toString(),
    pContent: json['pcontent'] as String,
    pImage: json['pimage'] as String?,
    pDate: json['pdate'] as String,
    pLikes: (json['plikes'] as num?)?.toInt() ?? 0,
    authorName: json['authorName'] as String?,
    authorImage: json['authorImage'] as String?,
    likeCount: json['likeCount'] as int,
    commentCount: json['commentCount'] as int,
    isLikedByUser: json['isLikedByUser'] as bool,
  );

  Map<String, dynamic> toJson() => {
    if (pNum != null) 'pnum': pNum,
    'mid': mId, // ✅ 수정됨
    if (rNum != null) 'rnum': rNum,
    'pcontent': pContent,
    if (pImage != null) 'pimage': pImage,
    'pdate': pDate,
    'plikes': pLikes,
  };
}
