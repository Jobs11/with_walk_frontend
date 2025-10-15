import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/weekly_goal.dart';
import 'package:with_walk/functions/data.dart';

class WeeklyGoalService {
  static const String manual = "goal";

  // 현재 주간 목표 조회
  static Future<WeeklyGoal> getCurrentWeeklyGoal(String mId) async {
    try {
      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/weekly/$mId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return WeeklyGoal.fromJson(data);
      } else {
        throw Exception('주간 목표 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주간 목표 조회 오류: $e');
    }
  }

  // 주간 목표 설정/수정
  static Future<void> setWeeklyGoal(String mId, double goalKm) async {
    try {
      final response = await http.post(
        Uri.parse('${Baseurl.b}$manual/weekly'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'mId': mId, 'goalKm': goalKm}),
      );

      if (response.statusCode != 200) {
        throw Exception('주간 목표 설정 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주간 목표 설정 오류: $e');
    }
  }

  // 주간 목표 삭제
  static Future<void> deleteWeeklyGoal(String mId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Baseurl.b}$manual/weekly/$mId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode != 200) {
        throw Exception('주간 목표 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주간 목표 삭제 오류: $e');
    }
  }

  // 주간 목표 히스토리 조회
  static Future<List<WeeklyGoal>> getAllWeeklyGoals(String mId) async {
    try {
      final response = await http.get(
        Uri.parse('${Baseurl.b}$manual/weekly/history/$mId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => WeeklyGoal.fromJson(json)).toList();
      } else {
        throw Exception('히스토리 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('히스토리 조회 오류: $e');
    }
  }

  // 이번 주 월요일 날짜 계산 (프론트에서도 사용)
  static DateTime getCurrentMondayDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysToSubtract = today.weekday - DateTime.monday;
    return today.subtract(Duration(days: daysToSubtract));
  }

  // 이번 주 일요일 날짜 계산
  static DateTime getCurrentSundayDate() {
    final monday = getCurrentMondayDate();
    return monday.add(const Duration(days: 6));
  }
}
