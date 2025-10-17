import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/friendship.dart';
import 'package:with_walk/functions/data.dart';

class FriendService {
  static const String manual = "friend";
  static const String follow = "follow";
  static const String unfollow = "unfollow";
  static const String followers = "followers";
  static const String following = "following";
  static const String status = "status";

  // 팔로우 하기
  static Future<void> followUser(String fromUserId, String toUserId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$follow');

    final friendship = Friendship(
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: 'accepted', // 즉시 팔로우 (승인 필요 없음)
    );

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(friendship.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('팔로우 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 언팔로우 하기
  static Future<void> unfollowUser(String fromUserId, String toUserId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$unfollow').replace(
      queryParameters: {'from_user_id': fromUserId, 'to_user_id': toUserId},
    );

    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('언팔로우 실패: ${res.statusCode} ${res.body}');
    }
  }

  // 팔로워 수 조회
  static Future<int> getFollowerCount(String userId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$followers/$userId/count');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] as int;
    }
    throw Exception('팔로워 수 조회 실패: ${response.statusCode}');
  }

  // 팔로잉 수 조회
  static Future<int> getFollowingCount(String userId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$following/$userId/count');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] as int;
    }
    throw Exception('팔로잉 수 조회 실패: ${response.statusCode}');
  }

  // 팔로우 상태 확인
  static Future<bool> isFollowing(String fromUserId, String toUserId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$status').replace(
      queryParameters: {'from_user_id': fromUserId, 'to_user_id': toUserId},
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_following'] as bool;
    }
    throw Exception('팔로우 상태 확인 실패: ${response.statusCode}');
  }

  // 팔로워 목록 조회
  static Future<List<String>> getFollowers(String userId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$followers/$userId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    debugPrint('status: ${response.statusCode}');
    debugPrint('body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['fromUserId'] as String).toList();
    }
    throw Exception('팔로워 목록 조회 실패: ${response.statusCode}');
  }

  // 팔로잉 목록 조회
  static Future<List<String>> getFollowing(String userId) async {
    final url = Uri.parse('${Baseurl.b}$manual/$following/$userId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    debugPrint('status: ${response.statusCode}');
    debugPrint('body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['toUserId'] as String).toList();
    }
    throw Exception('팔로잉 목록 조회 실패: ${response.statusCode}');
  }
}
