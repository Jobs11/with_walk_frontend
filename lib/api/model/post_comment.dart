class PostComment {
  final int? pcNum;
  final int pNum;
  final String mId;
  final String pcContent;
  final String pcDate;
  final String? authorName;
  final String? authorImage;

  const PostComment({
    this.pcNum,
    required this.pNum,
    required this.mId,
    required this.pcContent,
    required this.pcDate,
    this.authorName,
    this.authorImage,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    pcNum: (json['pcNum'] as num?)?.toInt(),
    pNum: (json['pnum'] as num).toInt(),
    mId: json['mid'] as String,
    pcContent: json['pcContent'] as String,
    pcDate: json['pcDate'] as String,
    authorName: json['authorName'] as String?,
    authorImage: json['authorImage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'pnum': pNum,
    'mid': mId,
    'pcContent': pcContent,
    'pcDate': pcDate,
  };
}
