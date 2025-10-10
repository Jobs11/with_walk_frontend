// lib/api/service/naver_local_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:with_walk/api/model/place_result.dart';

/// ------------------------------
/// 네이버 지역 검색(키워드) + 지오코딩(주소→좌표)
/// ------------------------------
class NaverLocalService {
  NaverLocalService({
    required this.searchClientId,
    required this.searchClientSecret,
    required this.geocodeKeyId,
    required this.geocodeKey,
  });

  final String searchClientId;
  final String searchClientSecret;
  final String geocodeKeyId;
  final String geocodeKey;

  /// 키워드 장소 검색 (상호명 등)
  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('https://openapi.naver.com/v1/search/local.json')
        .replace(
          queryParameters: {
            'query': query,
            'display': '10',
            'start': '1',
            'sort': 'random',
          },
        );

    final headers = {
      'X-Naver-Client-Id': searchClientId,
      'X-Naver-Client-Secret': searchClientSecret,
    };

    http.Response res;
    try {
      res = await http.get(uri, headers: headers);
    } catch (e) {
      debugPrint('🚨 local search request error: $e');
      return [];
    }

    debugPrint('🔎 local search status=${res.statusCode}');
    debugPrint('🔎 local search body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (data.containsKey('errorCode')) {
      debugPrint(
        '🚨 local search API error: ${data['errorCode']} - ${data['errorMessage']}',
      );
      return [];
    }

    final items = (data['items'] as List? ?? []);
    return items.map<PlaceResult>((e) {
      final title = _stripTag(e['title'] as String? ?? '');
      final road = e['roadAddress'] as String? ?? '';
      final jibun = e['address'] as String? ?? '';
      return (title: title, roadAddr: road, jibunAddr: jibun);
    }).toList();
  }

  /// 주소 → 위경도 (WGS84)
  Future<NLatLng?> geocodeToLatLng(String address) async {
    if (address.trim().isEmpty) return null;
    final uri = Uri.https('maps.apigw.ntruss.com', '/map-geocode/v2/geocode', {
      'query': address,
    });

    final res = await http.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': geocodeKeyId,
        'X-NCP-APIGW-API-KEY': geocodeKey,
      },
    );

    debugPrint('🛰️ geocode status=${res.statusCode}');
    debugPrint('🛰️ geocode body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) return null;
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final addrs = (body['addresses'] as List? ?? []);
    if (addrs.isEmpty) return null;

    final first = addrs.first as Map<String, dynamic>;
    final x = double.tryParse(first['x']?.toString() ?? '');
    final y = double.tryParse(first['y']?.toString() ?? '');
    if (x == null || y == null) return null;

    return NLatLng(y, x);
  }

  String _stripTag(String s) => s.replaceAll(RegExp(r'<\/?b>'), '');

  /// ✅ 도로 경로(자동차) 요청: start~goal 사이의 도로를 따르는 폴리라인과 거리(m) 리턴
  Future<({List<NLatLng> path, int distanceM})?> fetchDrivingRoute({
    required NLatLng start,
    required NLatLng goal,
    String option = 'traoptimal',
    bool useV15 = false,
  }) async {
    final base = useV15
        ? 'https://maps.apigw.ntruss.com/map-direction-15/v1/driving'
        : 'https://maps.apigw.ntruss.com/map-direction/v1/driving';

    final uri = Uri.parse(
      '$base?start=${start.longitude},${start.latitude}'
      '&goal=${goal.longitude},${goal.latitude}'
      '&option=$option',
    );

    final res = await http.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': geocodeKeyId,
        'X-NCP-APIGW-API-KEY': geocodeKey,
      },
    );

    if (res.statusCode != 200) return null;

    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final routes = (json['route'] as Map?)?[option] as List?;
    if (routes == null || routes.isEmpty) return null;

    final first = routes.first as Map<String, dynamic>;
    final summary = (first['summary'] as Map?) ?? {};
    final pathRaw = (first['path'] as List?)?.cast<List>();
    if (pathRaw == null || pathRaw.length < 2) return null;

    final coords = <NLatLng>[];
    for (final p in pathRaw) {
      if (p.length >= 2) {
        final lng = (p[0] as num).toDouble();
        final lat = (p[1] as num).toDouble();
        coords.add(NLatLng(lat, lng));
      }
    }

    final distanceM = (summary['distance'] as num?)?.toInt() ?? 0;
    return (path: coords, distanceM: distanceM);
  }

  /// ✅ NEW: 여러 옵션 중 가장 짧은 거리 경로 선택
  Future<({List<NLatLng> path, int distanceM, String option})?>
  fetchShortestRoute({required NLatLng start, required NLatLng goal}) async {
    final options = ['trafast', 'traoptimal', 'tracomfort'];

    ({List<NLatLng> path, int distanceM, String option})? shortest;

    for (final opt in options) {
      debugPrint('🔍 경로 검색 중: $opt');

      final route = await fetchDrivingRoute(
        start: start,
        goal: goal,
        option: opt,
      );

      if (route != null) {
        debugPrint('  ↳ $opt: ${route.distanceM}m');

        if (shortest == null || route.distanceM < shortest.distanceM) {
          shortest = (
            path: route.path,
            distanceM: route.distanceM,
            option: opt,
          );
        }
      }
    }

    if (shortest != null) {
      debugPrint('✅ 최단 경로: ${shortest.option} (${shortest.distanceM}m)');
    }

    return shortest;
  }

  /// ✅ 좌표 → 주소(도로명 우선, 없으면 지번)
  Future<String?> reverseGeocodeToAddress(NLatLng p) async {
    final uri =
        Uri.https('maps.apigw.ntruss.com', '/map-reversegeocode/v2/gc', {
          'coords': '${p.longitude},${p.latitude}',
          'orders': 'roadaddr,addr',
          'output': 'json',
        });

    final res = await http.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': geocodeKeyId,
        'X-NCP-APIGW-API-KEY': geocodeKey,
      },
    );

    if (res.statusCode != 200) return null;

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? const [];
    if (results.isEmpty) return null;

    String? pretty;
    for (final r in results) {
      final name = r['name'] as String?;
      final region = (r['region'] as Map?)?['area3']?['name'] ?? '';
      final land = (r['land'] as Map?) ?? {};
      final road = land['name'] ?? '';
      final number = [
        land['number1'] ?? '',
        if ((land['number2'] ?? '').toString().isNotEmpty)
          '-${land['number2']}',
      ].join();
      if (name == 'roadaddr' && road.toString().isNotEmpty) {
        pretty = '$region $road $number'.trim();
        break;
      }
      if (name == 'addr') {
        final parcel = [
          land['number1'] ?? '',
          if ((land['number2'] ?? '').toString().isNotEmpty)
            '-${land['number2']}',
        ].join();
        final dong = region.toString();
        final ri = (r['region'] as Map?)?['area4']?['name'] ?? '';
        final area = [dong, if (ri.isNotEmpty) ri].join(' ');
        pretty = '$area $parcel'.trim();
      }
    }
    return pretty;
  }
}
