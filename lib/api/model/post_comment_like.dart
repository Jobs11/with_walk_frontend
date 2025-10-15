// api/model/post_comment_like.dart
class PostCommentLike {
  final int? pclNum;
  final int pcNum;
  final String mId;
  final String? pclDate;

  PostCommentLike({
    this.pclNum,
    required this.pcNum,
    required this.mId,
    this.pclDate,
  });

  factory PostCommentLike.fromJson(Map<String, dynamic> json) {
    return PostCommentLike(
      pclNum: json['pcl_num'] as int?,
      pcNum: json['pc_num'] as int,
      mId: json['m_id'] as String,
      pclDate: json['pcl_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcl_num': pclNum,
      'pc_num': pcNum,
      'm_id': mId,
      'pcl_date': pclDate,
    };
  }
}
