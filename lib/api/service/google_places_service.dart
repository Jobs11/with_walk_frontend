import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Google Places REST Service (Autocomplete + Details)
/// ─────────────────────────────────────────────────────────────────────────────
class GooglePlacesService {
  GooglePlacesService(this.apiKey);

  final String apiKey;
  String _sessionToken = const Uuid().v4();

  /// 자동완성: 입력어 → 후보(라벨+placeId)
  Future<List<({String placeId, String label})>> autocomplete({
    required String input,
    LatLng? biasCenter,
  }) async {
    if (input.trim().isEmpty) return [];
    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final body = {
      "input": input,
      "languageCode": "ko",
      "includedRegionCodes": ["KR"],
      if (biasCenter != null)
        "locationBias": {
          "circle": {
            "center": {
              "latitude": biasCenter.latitude,
              "longitude": biasCenter.longitude,
            },
            "radius": 30000.0, // 30km
          },
        },
      "sessionToken": _sessionToken,
    };

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final suggestions = (data['suggestions'] as List?) ?? [];

    return suggestions
        .map((e) {
          final p = e['placePrediction'];
          if (p == null) return null;
          final id = p['placeId'] as String?;
          final label = p['text']?['text'] as String?;
          if (id == null || label == null) return null;
          return (placeId: id, label: label);
        })
        .whereType<({String placeId, String label})>()
        .toList();
  }

  /// 상세조회: placeId → 좌표/표시명
  Future<({LatLng? latLng, String label})> fetchDetails(String placeId) async {
    final uri = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        'X-Goog-Session-Token': _sessionToken, // 같은 세션으로 마감
      },
    );

    // 다음 검색을 위한 세션 토큰 갱신
    _sessionToken = const Uuid().v4();

    if (res.statusCode != 200) return (latLng: null, label: '');
    final body = jsonDecode(res.body);
    final name =
        (body['displayName']?['text'] as String?) ??
        (body['formattedAddress'] as String? ?? '');
    final lat = (body['location']?['latitude'] as num?)?.toDouble();
    final lng = (body['location']?['longitude'] as num?)?.toDouble();
    final pos = (lat != null && lng != null) ? LatLng(lat, lng) : null;
    return (latLng: pos, label: name);
  }
}
