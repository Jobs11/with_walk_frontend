// lib/views/screens/walking_distance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:with_walk/api/service/naver_local_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/widgets/distance_widget.dart';
import 'package:with_walk/views/widgets/real_time_tracking_widget.dart';

class WalkingDistanceScreen extends StatefulWidget {
  const WalkingDistanceScreen({super.key});

  @override
  State<WalkingDistanceScreen> createState() => _WalkingDistanceScreenState();
}

class _WalkingDistanceScreenState extends State<WalkingDistanceScreen> {
  bool isWalk = false;

  Key _distanceKey = UniqueKey();
  Key _trackingKey = UniqueKey();

  // ✅ 출발지/도착지 정보 저장
  NLatLng? _startPoint;
  NLatLng? _goalPoint;
  String? _startAddress;
  String? _goalAddress;

  // ✅ NaverLocalService 인스턴스 생성
  late final NaverLocalService _naverService = NaverLocalService(
    searchClientId: NaverApi.naversearchclientid,
    searchClientSecret: NaverApi.naversearchclientsecret,
    geocodeKeyId: NaverApi.ncpgeocodekeyid,
    geocodeKey: NaverApi.ncpgeocodekey,
  );

  // ✅ DistanceWidget에서 전달받은 정보 저장
  void _onStartWalk({
    NLatLng? start,
    NLatLng? goal,
    String? startAddr,
    String? goalAddr,
  }) {
    setState(() {
      _startPoint = start;
      _goalPoint = goal;
      _startAddress = startAddr;
      _goalAddress = goalAddr;
      isWalk = true;
      _trackingKey = UniqueKey();
    });
  }

  // ✅ 실시간 추적 종료 시
  void _onStopTracking() {
    setState(() {
      isWalk = false;
      _distanceKey = UniqueKey();
      // 정보는 유지 (다시 보기 가능하도록)
    });
  }

  @override
  Widget build(BuildContext context) {
    return isWalk
        ? RealTimeTrackingWidget(
            key: _trackingKey,
            startPoint: _startPoint,
            goalPoint: _goalPoint,
            startAddress: _startAddress,
            goalAddress: _goalAddress,
            naverService: _naverService, // ✅ NaverService 전달
            onStop: _onStopTracking,
          )
        : DistanceWidget(key: _distanceKey, onStartWalk: _onStartWalk);
  }
}
