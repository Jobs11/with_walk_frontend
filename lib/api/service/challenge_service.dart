import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/challenge.dart';
import 'package:with_walk/api/model/challenge_participant.dart';
import 'package:with_walk/api/model/badge.dart';
import 'package:with_walk/functions/data.dart';

class ChallengeService {
  static const String manual = "challenges";

  // 진행중인 챌린지 목록
  static Future<List<Challenge>> getActiveChallenges(String userId) async {
    try {
      debugPrint('📡 Fetching active challenges for user: $userId');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/active?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 active Response status: ${response.statusCode}');
      debugPrint('📥 active Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        debugPrint('✅ active Decoded response: $responseBody');

        List<dynamic> data = json.decode(responseBody);
        debugPrint('✅ active Parsed data count: ${data.length}');

        return data.map((json) => Challenge.fromJson(json)).toList();
      } else {
        debugPrint('❌ active Error status code: ${response.statusCode}');
        debugPrint('❌ active Error body: ${response.body}');
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ active Error loading challenges: $e');
      debugPrint('❌ active Stack trace: $stackTrace');
      throw Exception('Failed to load challenges: $e');
    }
  }

  // 챌린지 상세
  static Future<Challenge> getChallengeDetail(int cNum, String userId) async {
    try {
      debugPrint('📡 Fetching challenge detail: $cNum');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/$cNum?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 detail Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        return Challenge.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ detail Error loading challenge detail: $e');
      debugPrint('❌ detail Stack trace: $stackTrace');
      throw Exception('Failed to load challenge detail: $e');
    }
  }

  // 챌린지 참가
  static Future<bool> joinChallenge(int cNum, String userId) async {
    try {
      debugPrint('📡 Joining challenge: $cNum for user: $userId');

      final response = await http.post(
        Uri.parse('${Baseurl.b}$manual/$cNum/join?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 Join response status: ${response.statusCode}');
      debugPrint('📥 Join response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      debugPrint('❌ Join Error joining challenge: $e');
      debugPrint('❌ Join Stack trace: $stackTrace');
      return false;
    }
  }

  // 내 참가중인 챌린지
  static Future<List<ChallengeParticipant>> getMyActiveChallenges(
    String userId,
  ) async {
    try {
      debugPrint('📡 Fetching my active challenges for user: $userId');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/my/active?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 my Response status: ${response.statusCode}');
      debugPrint('📥 my Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        debugPrint('✅ my Decoded response: $responseBody');

        List<dynamic> data = json.decode(responseBody);
        debugPrint('✅ my Parsed data count: ${data.length}');

        return data.map((json) => ChallengeParticipant.fromJson(json)).toList();
      } else {
        debugPrint('❌ my Error status code: ${response.statusCode}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ my Error loading my active challenges: $e');
      debugPrint('❌ my Stack trace: $stackTrace');
      throw Exception('Failed to load my active challenges: $e');
    }
  }

  // 내 완료한 챌린지
  static Future<List<ChallengeParticipant>> getMyCompletedChallenges(
    String userId,
  ) async {
    try {
      debugPrint('📡 Fetching my completed challenges for user: $userId');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/my/completed?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 completed Response status: ${response.statusCode}');
      debugPrint('📥 completed Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        debugPrint('✅ completed Decoded response: $responseBody');

        // 빈 배열이면 빈 리스트 반환
        if (responseBody.trim() == '[]') {
          debugPrint('✅ completed No completed challenges found');
          return [];
        }

        List<dynamic> data = json.decode(responseBody);
        debugPrint('✅ completed Parsed data count: ${data.length}');

        return data.map((json) => ChallengeParticipant.fromJson(json)).toList();
      } else {
        debugPrint('❌ completed Error status code: ${response.statusCode}');
        debugPrint('❌ completed Error body: ${response.body}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ completed Error loading my completed challenges: $e');
      debugPrint('❌ completed Stack trace: $stackTrace');
      throw Exception('Failed to load my completed challenges: $e');
    }
  }

  // 내 뱃지 목록
  static Future<List<Badge>> getMyBadges(String userId) async {
    try {
      debugPrint('📡 Fetching my badges for user: $userId');

      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/my/badges?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 badges Response status: ${response.statusCode}');
      debugPrint('📥 badges Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);

        if (responseBody.trim() == '[]') {
          return [];
        }

        List<dynamic> data = json.decode(responseBody);
        return data.map((json) => Badge.fromJson(json)).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ badges Error loading badges: $e');
      debugPrint('❌ badges Stack trace: $stackTrace');
      throw Exception('Failed to load badges: $e');
    }
  }

  // 챌린지 생성
  static Future<bool> createChallenge(Challenge challenge) async {
    try {
      debugPrint('📡 Creating challenge: ${challenge.cTitle}');

      final response = await http.post(
        Uri.parse('${Baseurl.b}$manual/create'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(challenge.toJson()),
      );

      debugPrint('📥 Create response status: ${response.statusCode}');
      debugPrint('📥 Create response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Challenge created successfully');
        return true;
      } else {
        debugPrint('❌ Failed to create challenge: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating challenge: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // 챌린지 수정
  static Future<bool> updateChallenge(Challenge challenge) async {
    try {
      debugPrint('📡 Updating challenge: ${challenge.cNum}');

      final response = await http.put(
        Uri.parse('${Baseurl.b}$manual/${challenge.cNum}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(challenge.toJson()),
      );

      debugPrint('📥 Update response status: ${response.statusCode}');
      debugPrint('📥 Update response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Challenge updated successfully');
        return true;
      } else {
        debugPrint('❌ Failed to update challenge: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating challenge: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // 챌린지 삭제
  static Future<bool> deleteChallenge(int cNum) async {
    try {
      debugPrint('📡 Deleting challenge: $cNum');

      final response = await http.delete(
        Uri.parse('${Baseurl.b}$manual/$cNum'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 Delete response status: ${response.statusCode}');
      debugPrint('📥 Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Challenge deleted successfully');
        return true;
      } else {
        debugPrint('❌ Failed to delete challenge: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting challenge: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }
}
