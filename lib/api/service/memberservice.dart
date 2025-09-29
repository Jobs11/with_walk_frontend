import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/api/model/member.dart';

class Memberservice {
  static const String menual = "member";
  static const String registerUser = "register";
  static const String getUser = "getUser";
  static const String getUserdata = "getUserdata";
  static const String modifyUser = "modify";
  static const String deleteUser = "delete";
  static const String modifyProfile = "upprofile";

  static Future<void> registerMember(Member member) async {
    final url = Uri.parse("${Baseurl.b}$menual/$registerUser");
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(member.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    // 디버깅에 도움되도록 응답 본문 포함
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Register failed: ${res.statusCode} ${res.body}");
    }
  }

  static Future<Member> login(String id, String password) async {
    // GET 요청 → URL에 파라미터로 전달
    final url = Uri.parse(
      "${Baseurl.b}$menual/$getUser",
    ).replace(queryParameters: {'m_id': id, 'm_password': password});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Member.fromJson(json);
    }

    throw Exception('로그인 실패: ${response.statusCode}');
  }

  static Future<Member> userdata(String id) async {
    // GET 요청 → URL에 파라미터로 전달
    final url = Uri.parse(
      "${Baseurl.b}$menual/$getUserdata",
    ).replace(queryParameters: {'m_id': id});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Member.fromJson(json);
    }

    throw Exception('로그인 실패: ${response.statusCode}');
  }

  static Future<void> updateMember(Member member) async {
    final url = Uri.parse("${Baseurl.b}$menual/$modifyUser");
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(member.toJsonUpdate()),
        )
        .timeout(const Duration(seconds: 10));

    // 디버깅에 도움되도록 응답 본문 포함
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Register failed: ${res.statusCode} ${res.body}");
    }
  }

  static Future<void> updateProfile(Member member) async {
    final url = Uri.parse("${Baseurl.b}$menual/$modifyProfile");
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(member.toJsonPaintOnly()),
        )
        .timeout(const Duration(seconds: 10));

    // 디버깅에 도움되도록 응답 본문 포함
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Register failed: ${res.statusCode} ${res.body}");
    }
  }
}
