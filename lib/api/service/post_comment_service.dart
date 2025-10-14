import 'dart:convert';
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
    List<PostComment> commentInstances = [];
    final url = Uri.parse('${Baseurl.b}$manual/$getComments/$pNum');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> comments = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      for (var comment in comments) {
        commentInstances.add(PostComment.fromJson(comment));
      }
      return commentInstances;
    }
    throw Exception('댓글 목록을 불러올 수 없습니다: ${response.statusCode}');
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
