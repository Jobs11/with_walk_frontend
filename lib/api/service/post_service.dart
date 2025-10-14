import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/functions/data.dart';

class PostService {
  static const String manual = "post";
  static const String feeds = "feeds";
  static const String create = "create";
  static const String like = "like";
  static const String update = "update";
  static const String delete = "delete";

  // 피드 목록 조회
  static Future<List<Post>> getPostFeeds() async {
    List<Post> postInstances = [];
    final url = Uri.parse('${Baseurl.b}$manual/$feeds');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> posts = jsonDecode(utf8.decode(response.bodyBytes));
      for (var post in posts) {
        postInstances.add(Post.fromJson(post));
      }
      return postInstances;
    }
    throw Exception('피드를 불러올 수 없습니다: ${response.statusCode}');
  }

  // 게시글 작성
  static Future<void> createPostWithImage({
    required Post post,
    File? imageFile,
  }) async {
    final url = Uri.parse('${Baseurl.b}$manual/$create');

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('게시글 작성 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 게시글 수정
  static Future<void> updatePost(Post post) async {
    final url = Uri.parse('${Baseurl.b}$manual/$update/${post.pNum}');

    final res = await http
        .put(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('게시글 수정 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 게시글 삭제
  static Future<void> deletePost(int pNum) async {
    final url = Uri.parse('${Baseurl.b}$manual/$pNum');

    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('게시글 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 좋아요 토글
  static Future<void> toggleLike(int pNum, String userId) async {
    final url = Uri.parse(
      '${Baseurl.b}$manual/$like',
    ).replace(queryParameters: {'p_num': pNum.toString(), 'user_id': userId});

    final res = await http.post(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('좋아요 처리 실패: ${res.statusCode} ${res.body}');
    }
  }
}
