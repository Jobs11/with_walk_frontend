import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/post_comment.dart';
import 'package:with_walk/functions/data.dart';

class PostCommentService {
  static const String manual = "post";
  static const String getComments = "comments";
  static const String addComment = "comment";
  static const String delComment = "comment";

  // 댓글 목록 조회
  static Future<List<PostComment>> getCommentList(int pNum) async {
    try {
      final currentUserId = CurrentUser.instance.member?.mId ?? '';

      debugPrint('📤 API 요청 시작');
      debugPrint('   - URL: ${Baseurl.b}$manual/comment-writer/$pNum');
      debugPrint('   - user_id: $currentUserId');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/comment-writer/$pNum'),
        headers: {'Content-Type': 'application/json', 'user_id': currentUserId},
      );

      print('📥 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // 🔍 백엔드 응답 원본 확인
        debugPrint('📦 백엔드 응답 원본:');
        debugPrint(response.body);

        debugPrint('\n🔍 각 댓글 데이터:');
        for (var json in jsonList) {
          debugPrint('─────────────────────────────');
          debugPrint('  pc_num: ${json['pcNum']}');
          debugPrint('  pc_content: ${json['pcContent']}');
          debugPrint('  author_name: ${json['authorName']}');
          debugPrint('  is_liked: ${json['isLiked']}');
          debugPrint('  like_count: ${json['likeCount']}');
          debugPrint(
            '  is_liked_by_author: ${json['is_liked_by_author']}',
          ); // 👈 핵심!
          debugPrint('  타입: ${json['is_liked_by_author'].runtimeType}');
        }
        debugPrint('─────────────────────────────\n');

        final comments = jsonList
            .map((json) => PostComment.fromJson(json))
            .toList();

        debugPrint('✅ 파싱된 댓글 객체:');
        for (var comment in comments) {
          debugPrint(
            '  댓글 ${comment.pcNum}: isLikedByAuthor=${comment.isLikedByAuthor}',
          );
        }

        return comments;
      } else {
        throw Exception('댓글 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 에러 발생: $e');
      throw Exception('댓글 목록 조회 중 오류 발생: $e');
    }
  }

  // 댓글 작성
  static Future<void> createComment(PostComment comment) async {
    final url = Uri.parse('${Baseurl.b}$manual/$addComment');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(comment.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('댓글 작성 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 댓글 삭제
  static Future<void> deleteComment(int pcNum) async {
    final url = Uri.parse('${Baseurl.b}$manual/$delComment/$pcNum');
    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('댓글 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }
}
