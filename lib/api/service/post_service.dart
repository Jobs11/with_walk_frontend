// lib/api/service/post_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/functions/data.dart';

class PostService {
  static const String menu = "post";
  static const String createPost = "create";
  static const String getFeeds = "feeds";
  static const String likePost = "like";
  static const String uploadImage = "upload";

  /// 게시글 작성
  static Future<void> createPostWithImage({
    required Post post,
    File? imageFile,
  }) async {
    final url = Uri.parse("${Baseurl.b}$menu/$createPost");

    if (imageFile != null) {
      // 멀티파트 요청 (이미지 포함)
      var request = http.MultipartRequest('POST', url);
      request.fields['mid'] = post.mId;
      if (post.rNum != null) request.fields['rnum'] = post.rNum!;
      request.fields['pcontent'] = post.pContent;
      request.fields['pdate'] = post.pDate;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Post creation failed: ${response.statusCode}");
      }
    } else {
      // JSON 요청 (이미지 없음)
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode(post.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception("Post creation failed: ${res.statusCode} ${res.body}");
      }
    }
  }

  /// 피드 목록 가져오기 (전체 또는 친구)
  static Future<List<Post>> getPostFeeds({String? userId}) async {
    final url = Uri.parse(
      "${Baseurl.b}$menu/$getFeeds",
    ).replace(queryParameters: userId != null ? {'user_id': userId} : null);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> posts = jsonDecode(response.body);
      return posts.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception("Failed to load feeds");
  }

  /// 좋아요 토글
  static Future<void> toggleLike(int postNum, String userId) async {
    final url = Uri.parse("${Baseurl.b}$menu/$likePost");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'p_num': postNum.toString(), 'user_id': userId},
    );

    if (res.statusCode != 200) {
      throw Exception("Like toggle failed: ${res.statusCode}");
    }
  }
}
