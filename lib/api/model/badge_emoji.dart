class BadgeEmoji {
  final int? level;
  final String emoji;
  final String name;
  final String description;
  final String? season;

  BadgeEmoji({
    this.level,
    required this.emoji,
    required this.name,
    required this.description,
    this.season,
  });

  factory BadgeEmoji.fromJson(Map<String, dynamic> json) {
    return BadgeEmoji(
      level: json['level'],
      emoji: json['emoji'],
      name: json['name'],
      description: json['description'],
      season: json['season'],
    );
  }
}

class BadgeCategory {
  final String name;
  final List<BadgeEmoji> badges;

  BadgeCategory({required this.name, required this.badges});

  factory BadgeCategory.fromJson(Map<String, dynamic> json) {
    return BadgeCategory(
      name: json['name'],
      badges: (json['badges'] as List)
          .map((badge) => BadgeEmoji.fromJson(badge))
          .toList(),
    );
  }
}

class BadgeEmojiData {
  final Map<String, BadgeCategory> categories;
  final Map<String, List<String>> quickPicks;

  BadgeEmojiData({required this.categories, required this.quickPicks});

  factory BadgeEmojiData.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as Map<String, dynamic>;
    final categories = <String, BadgeCategory>{};

    categoriesJson.forEach((key, value) {
      categories[key] = BadgeCategory.fromJson(value);
    });

    final quickPicksJson = json['quickPicks'] as Map<String, dynamic>;
    final quickPicks = <String, List<String>>{};

    quickPicksJson.forEach((key, value) {
      quickPicks[key] = List<String>.from(value);
    });

    return BadgeEmojiData(categories: categories, quickPicks: quickPicks);
  }
}
