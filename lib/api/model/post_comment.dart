class PostComment {
  final int? pcNum;
  final int pNum;
  final String mId;
  final String pcContent;
  final String pcDate;
  final String? authorName;
  final String? authorImage;

  // 좋아요 관련 필드 추가
  int likeCount;
  bool isLiked;
  bool isLikedByAuthor;

  PostComment({
    this.pcNum,
    required this.pNum,
    required this.mId,
    required this.pcContent,
    required this.pcDate,
    this.authorName,
    this.authorImage,
    this.likeCount = 0,
    this.isLiked = false,
    this.isLikedByAuthor = false,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    pcNum: (json['pcNum'] as num?)?.toInt(),
    pNum: (json['pnum'] as num).toInt(),
    mId: json['mid'] as String,
    pcContent: json['pcContent'] as String,
    pcDate: json['pcDate'] as String,
    authorName: json['authorName'] as String?,
    authorImage: json['authorImage'] as String?,
    likeCount: json['likeCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    isLikedByAuthor: json['isLikedByAuthor'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'pnum': pNum,
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

  PostComment copyWith({
    int? pcNum,
    int? pNum,
    String? mId,
    String? pcContent,
    String? pcDate,
    String? authorName,
    String? authorImage,
    bool? isLiked,
    int? likeCount,
    bool? isLikedByAuthor,
  }) {
    return PostComment(
      pcNum: pcNum ?? this.pcNum,
      pNum: pNum ?? this.pNum,
      mId: mId ?? this.mId,
      pcContent: pcContent ?? this.pcContent,
      pcDate: pcDate ?? this.pcDate,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      isLikedByAuthor: isLikedByAuthor ?? this.isLikedByAuthor,
    );
  }
}
