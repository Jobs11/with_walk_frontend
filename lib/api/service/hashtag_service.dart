import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/hashtag.dart';
import 'package:with_walk/functions/data.dart';

class HashtagService {
  static const String manual = "hashtags";

  // ========================================
  // 게시글 해시태그 관리
  // ========================================

  /// 게시글에 해시태그 추가
  /// hashtags: ["여행", "서울", "걷기"] (# 없이 전달)
  static Future<void> addHashtagsToPost(int pNum, List<String> hashtags) async {
    if (hashtags.isEmpty) return;

    final url = Uri.parse('${Baseurl.b}$manual/post/$pNum');

    // # 제거 후 전달
    final cleanHashtags = hashtags
        .map((tag) => tag.trim().replaceAll('#', ''))
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (cleanHashtags.isEmpty) return;

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(cleanHashtags),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('해시태그 추가 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 게시글의 해시태그 수정
  static Future<void> updatePostHashtags(
    int pNum,
    List<String> hashtags,
  ) async {
    final url = Uri.parse('${Baseurl.b}$manual/post/$pNum');

    // # 제거 후 전달
    final cleanHashtags = hashtags
        .map((tag) => tag.trim().replaceAll('#', ''))
        .where((tag) => tag.isNotEmpty)
        .toList();

    final res = await http
        .put(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(cleanHashtags),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('해시태그 수정 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 게시글의 해시태그 삭제
  static Future<void> removeHashtagsFromPost(int pNum) async {
    final url = Uri.parse('${Baseurl.b}$manual/post/$pNum');

    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('해시태그 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 게시글의 해시태그 목록 조회
  static Future<List<Hashtag>> getPostHashtags(int pNum) async {
    List<Hashtag> hashtags = [];
    final url = Uri.parse('${Baseurl.b}$manual/post/$pNum');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var hashtag in data) {
        hashtags.add(Hashtag.fromJson(hashtag));
      }
      return hashtags;
    }
    throw Exception('해시태그 조회 실패: ${response.statusCode}');
  }

  // ========================================
  // 해시태그 검색/조회
  // ========================================

  /// 해시태그로 게시글 번호 목록 조회
  static Future<List<int>> getPostNumsByHashtag(String hashtagName) async {
    // # 제거
    final cleanName = hashtagName.trim().replaceAll('#', '');

    final url = Uri.parse(
      '${Baseurl.b}$manual/posts',
    ).replace(queryParameters: {'hashtag': cleanName});

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> postNums = data['post_nums'];
      // ignore: avoid_types_as_parameter_names
      return postNums.map((num) => num as int).toList();
    }
    throw Exception('게시글 조회 실패: ${response.statusCode}');
  }

  /// 인기 해시태그 조회 (상위 N개)
  static Future<List<Hashtag>> getTopHashtags({int limit = 10}) async {
    List<Hashtag> hashtags = [];
    final url = Uri.parse(
      '${Baseurl.b}$manual/top',
    ).replace(queryParameters: {'limit': limit.toString()});

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var hashtag in data) {
        hashtags.add(Hashtag.fromJson(hashtag));
      }
      return hashtags;
    }
    throw Exception('인기 해시태그 조회 실패: ${response.statusCode}');
  }

  /// 해시태그 검색
  static Future<List<Hashtag>> searchHashtags(String keyword) async {
    List<Hashtag> hashtags = [];
    // # 제거
    final cleanKeyword = keyword.trim().replaceAll('#', '');

    final url = Uri.parse(
      '${Baseurl.b}$manual/search',
    ).replace(queryParameters: {'keyword': cleanKeyword});

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var hashtag in data) {
        hashtags.add(Hashtag.fromJson(hashtag));
      }
      return hashtags;
    }
    throw Exception('해시태그 검색 실패: ${response.statusCode}');
  }

  // ========================================
  // 유틸리티 함수
  // ========================================

  /// 텍스트에서 해시태그 추출
  /// 예: "오늘 #서울 #여행 재미있었다!" -> ["서울", "여행"]
  static List<String> extractHashtagsFromText(String text) {
    final RegExp hashtagRegex = RegExp(r'#([가-힣a-zA-Z0-9_]+)');
    final matches = hashtagRegex.allMatches(text);

    return matches
        .map((match) => match.group(1)!)
        .where((tag) => tag.isNotEmpty)
        .toSet() // 중복 제거
        .toList();
  }

  /// 해시태그를 문자열로 변환
  /// 예: ["서울", "여행"] -> "#서울 #여행"
  static String hashtagsToString(List<String> hashtags) {
    return hashtags.map((tag) => '#${tag.replaceAll('#', '')}').join(' ');
  }

  /// 해시태그 문자열을 리스트로 변환
  /// 예: "#서울 #여행 #걷기" -> ["서울", "여행", "걷기"]
  static List<String> stringToHashtags(String hashtagString) {
    return hashtagString
        .split(' ')
        .map((tag) => tag.trim().replaceAll('#', ''))
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// 해시태그 유효성 검사
  /// - 1~50자
  /// - 한글, 영문, 숫자, _ 만 허용
  static bool isValidHashtag(String hashtag) {
    final cleanTag = hashtag.replaceAll('#', '').trim();
    if (cleanTag.isEmpty || cleanTag.length > 50) {
      return false;
    }
    final RegExp validRegex = RegExp(r'^[가-힣a-zA-Z0-9_]+$');
    return validRegex.hasMatch(cleanTag);
  }
}
