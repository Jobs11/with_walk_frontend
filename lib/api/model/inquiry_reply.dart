// ========== inquiry_reply.dart ==========
class InquiryReply {
  final int? replyId;
  final int inquiryId;
  final String? adminId;
  final String content;
  final String? createdAt;

  const InquiryReply({
    this.replyId,
    required this.inquiryId,
    this.adminId,
    required this.content,
    this.createdAt,
  });

  factory InquiryReply.fromJson(Map<String, dynamic> json) => InquiryReply(
    replyId: (json['replyId'] as num?)?.toInt(),
    inquiryId: (json['inquiryId'] as num).toInt(),
    adminId: json['adminId'] as String?,
    content: json['content'] as String,
    createdAt: json['createdAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'inquiryId': inquiryId,
    'adminId': adminId,
    'content': content,
  };
}
