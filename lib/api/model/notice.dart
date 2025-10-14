// ========== notice.dart ==========
class Notice {
  final int? noticeId;
  final String title;
  final String content;
  final String category;
  final bool isImportant;
  final int viewCount;
  final String createdAt;
  final String? updatedAt;

  const Notice({
    this.noticeId,
    required this.title,
    required this.content,
    required this.category,
    required this.isImportant,
    required this.viewCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    noticeId: (json['noticeId'] as num?)?.toInt(),
    title: json['title'] as String,
    content: json['content'] as String,
    category: json['category'] as String,
    isImportant: json['isImportant'] as bool,
    viewCount: (json['viewCount'] as num).toInt(),
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'category': category,
    'isImportant': isImportant,
  };
}
