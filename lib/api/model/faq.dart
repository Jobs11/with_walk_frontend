// ========== faq.dart ==========
class Faq {
  final int? faqId;
  final String category;
  final String question;
  final String answer;
  final int viewCount;
  final int displayOrder;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const Faq({
    this.faqId,
    required this.category,
    required this.question,
    required this.answer,
    required this.viewCount,
    required this.displayOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    faqId: (json['faqId'] as num?)?.toInt(),
    category: json['category'] as String,
    question: json['question'] as String,
    answer: json['answer'] as String,
    viewCount: (json['viewCount'] as num).toInt(),
    displayOrder: (json['displayOrder'] as num).toInt(),
    isActive: json['isActive'] as bool,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'category': category,
    'question': question,
    'answer': answer,
    'displayOrder': displayOrder,
    'isActive': isActive,
  };
}
