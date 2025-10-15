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

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/comment-writer/$pNum'),
        headers: {'Content-Type': 'application/json', 'user_id': currentUserId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        final comments = jsonList
            .map((json) => PostComment.fromJson(json))
            .toList();

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
