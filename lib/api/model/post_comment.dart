class PostComment {
  final int? pcNum;
  final int pNum;
  final int? parentPcNum; // ✅ 추가: 부모 댓글 ID (NULL이면 일반 댓글)
  final String mId;
  final String pcContent;
  final String pcDate;
  final String? authorName;
  final String? authorImage;
  final String? mNickname; // ✅ 추가: 닉네임 (답글 UI용)
  final String? mProfileImage; // ✅ 추가: 프로필 이미지

  // 좋아요 관련 필드
  int likeCount;
  bool isLiked;
  bool isLikedByAuthor;

  // ✅ 추가: 대댓글 리스트
  List<PostComment> childComments;

  PostComment({
    this.pcNum,
    required this.pNum,
    this.parentPcNum, // ✅ 추가
    required this.mId,
    required this.pcContent,
    required this.pcDate,
    this.authorName,
    this.authorImage,
    this.mNickname, // ✅ 추가
    this.mProfileImage, // ✅ 추가
    this.likeCount = 0,
    this.isLiked = false,
    this.isLikedByAuthor = false,
    this.childComments = const [], // ✅ 추가
  });

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    pcNum: (json['pcNum'] as num?)?.toInt(),
    pNum: (json['pnum'] as num).toInt(),
    parentPcNum: (json['parentPcNum'] as num?)?.toInt(), // ✅ 추가
    mId: json['mid'] as String,
    pcContent: json['pcContent'] as String,
    pcDate: json['pcDate'] as String,
    authorName: json['authorName'] as String?,
    authorImage: json['authorImage'] as String?,
    mNickname: json['mNickname'] as String?, // ✅ 추가
    mProfileImage: json['mProfileImage'] as String?, // ✅ 추가
    likeCount: json['likeCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    isLikedByAuthor: json['isLikedByAuthor'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'pnum': pNum,
    'parentPcNum': parentPcNum, // ✅ 추가
    'mid': mId,
    'pcContent': pcContent,
    'pcDate': pcDate,
    'likeCount': likeCount,
    'isLiked': isLiked,
    'isLikedByAuthor': isLikedByAuthor,
  };

  // 좋아요 토글
  void toggleLike() {
    if (isLiked) {
      likeCount = (likeCount - 1).clamp(0, double.infinity).toInt();
    } else {
      likeCount++;
    }
    isLiked = !isLiked;
  }

  // ✅ 추가: 일반 댓글인지 확인
  bool get isParentComment => parentPcNum == null;

  // ✅ 추가: 대댓글인지 확인
  bool get isChildComment => parentPcNum != null;

  PostComment copyWith({
    int? pcNum,
    int? pNum,
    int? parentPcNum, // ✅ 추가
    String? mId,
    String? pcContent,
    String? pcDate,
    String? authorName,
    String? authorImage,
    String? mNickname, // ✅ 추가
    String? mProfileImage, // ✅ 추가
    bool? isLiked,
    int? likeCount,
    bool? isLikedByAuthor,
    List<PostComment>? childComments, // ✅ 추가
  }) {
    return PostComment(
      pcNum: pcNum ?? this.pcNum,
      pNum: pNum ?? this.pNum,
      parentPcNum: parentPcNum ?? this.parentPcNum, // ✅ 추가
      mId: mId ?? this.mId,
      pcContent: pcContent ?? this.pcContent,
      pcDate: pcDate ?? this.pcDate,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      mNickname: mNickname ?? this.mNickname, // ✅ 추가
      mProfileImage: mProfileImage ?? this.mProfileImage, // ✅ 추가
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      isLikedByAuthor: isLikedByAuthor ?? this.isLikedByAuthor,
      childComments: childComments ?? this.childComments, // ✅ 추가
    );
  }
}
