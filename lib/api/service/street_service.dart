import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/ranking_user.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/functions/data.dart';

class StreetService {
  static const String menual = "street";
  static const String registerStreet = "register";
  static const String getListStreet = "getlist";
  static const String getAllStreet = "getalllist";
  static const String deleteStreet = "delete";
  static const String getWeeklyTop3 = "ranking/weekly/top3";

  static Future<void> registerS(Street street) async {
    final url = Uri.parse("${Baseurl.b}$menual/$registerStreet");
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(street.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    // 디버깅에 도움되도록 응답 본문 포함
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Register failed: ${res.statusCode} ${res.body}");
    }
  }

  static Future<List<Street>> getStreetList(String id, String date) async {
    List<Street> streetInstances = [];
    final url = Uri.parse(
      '${Baseurl.b}$menual/$getListStreet',
    ).replace(queryParameters: {'mId': id, 'rDate': date});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> streets = jsonDecode(response.body);
      for (var street in streets) {
        streetInstances.add(Street.fromJson(street));
      }
      return streetInstances;
    }
    throw Error();
  }

  static Future<List<Street>> getStreetAllList(String id) async {
    List<Street> streetInstances = [];
    final url = Uri.parse(
      '${Baseurl.b}$menual/$getAllStreet',
    ).replace(queryParameters: {'mId': id});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> streets = jsonDecode(response.body);
      for (var street in streets) {
        streetInstances.add(Street.fromJson(street));
      }
      return streetInstances;
    }
    throw Error();
  }

  static Future<void> deleteS(int rNum) async {
    final url = Uri.parse(
      "${Baseurl.b}$menual/$deleteStreet",
    ).replace(queryParameters: {'rNum': rNum.toString()});

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      }, // JSON body 없어도 가능
    );

    if (res.statusCode != 200) {
      throw Exception("deleteStreet failed: ${res.statusCode} ${res.body}");
    }
  }

  static Future<List<RankingUser>> getTop3() async {
    List<RankingUser> rankingList = [];

    final url = Uri.parse('${Baseurl.b}$menual/$getWeeklyTop3');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> rankings = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      for (var ranking in rankings) {
        rankingList.add(RankingUser.fromJson(ranking));
      }

      return rankingList;
    }

    throw Exception('Failed to load ranking: ${response.statusCode}');
  }
}
