// api/service/post_comment_like_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:with_walk/functions/data.dart';

class PostCommentLikeService {
  static const String manual = "post";
  // 댓글 좋아요 토글 (좋아요/취소)
  static Future<Map<String, dynamic>> toggleLike(int pcNum, String mId) async {
    try {
      final response = await http.post(
        Uri.parse('${Baseurl.b}$manual/comment-like/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pc_num': pcNum, 'm_id': mId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('좋아요 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('좋아요 처리 중 오류 발생: $e');
    }
  }

  // 특정 댓글의 좋아요 개수 조회
  static Future<int> getLikeCount(int pcNum) async {
    try {
      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/comment-like/count/$pcNum'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('좋아요 개수 조회 실패');
      }
    } catch (e) {
      throw Exception('좋아요 개수 조회 중 오류: $e');
    }
  }

  // 사용자가 해당 댓글에 좋아요를 눌렀는지 확인
  static Future<bool> isLiked(int pcNum, String mId) async {
    try {
      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/comment-like/check/$pcNum/$mId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isLiked'] as bool;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 댓글별 좋아요 정보 일괄 조회 (최적화)
  static Future<Map<int, Map<String, dynamic>>> getBatchLikeInfo(
    List<int> pcNums,
    String mId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Baseurl.b}$manual/comment-like/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pc_nums': pcNums, 'm_id': mId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data.map(
          (key, value) =>
              MapEntry(int.parse(key), value as Map<String, dynamic>),
        );
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
