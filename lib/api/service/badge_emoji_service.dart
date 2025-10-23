import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:with_walk/api/model/badge_emoji.dart';

class BadgeEmojiService {
  static BadgeEmojiData? _data;

  // JSON 파일 로드
  static Future<BadgeEmojiData> loadBadgeEmojis() async {
    if (_data != null) return _data!;

    final String jsonString = await rootBundle.loadString(
      'assets/data/badge_emojis.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _data = BadgeEmojiData.fromJson(jsonData);
    return _data!;
  }

  // 카테고리별 배지 가져오기
  static Future<List<BadgeEmoji>> getBadgesByCategory(String category) async {
    final data = await loadBadgeEmojis();
    return data.categories[category]?.badges ?? [];
  }

  // 빠른 선택 이모지 가져오기
  static Future<List<String>> getQuickPicks(String type) async {
    final data = await loadBadgeEmojis();
    return data.quickPicks[type] ?? [];
  }

  // 모든 이모지 가져오기
  static Future<List<String>> getAllEmojis() async {
    final data = await loadBadgeEmojis();
    final List<String> allEmojis = [];

    data.categories.forEach((key, category) {
      allEmojis.addAll(category.badges.map((badge) => badge.emoji));
    });

    return allEmojis.toSet().toList(); // 중복 제거
  }

  // 레벨별 배지 가져오기
  static Future<BadgeEmoji?> getBadgeByLevel(String category, int level) async {
    final badges = await getBadgesByCategory(category);
    try {
      return badges.firstWhere((badge) => badge.level == level);
    } catch (e) {
      return null;
    }
  }
}
