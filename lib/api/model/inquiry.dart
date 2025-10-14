// ========== inquiry.dart ==========
class Inquiry {
  final int? inquiryId;
  final String userId;
  final String category;
  final String title;
  final String content;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? replyContent;
  final String? replyDate;

  const Inquiry({
    this.inquiryId,
    required this.userId,
    required this.category,
    required this.title,
    required this.content,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.replyContent,
    this.replyDate,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) => Inquiry(
    inquiryId: (json['inquiryId'] as num?)?.toInt(),
    userId: json['userId'] as String,
    category: json['category'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    status: json['status'] as String,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
    replyContent: json['replyContent'] as String?,
    replyDate: json['replyDate'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'category': category,
    'title': title,
    'content': content,
    'status': status,
  };
}
