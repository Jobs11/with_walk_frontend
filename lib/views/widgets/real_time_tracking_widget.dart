// lib/views/widgets/real_time_tracking_widget.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class RealTimeTrackingWidget extends StatefulWidget {
  final VoidCallback? onStop;

  // ✅ 출발지/도착지 정보 추가
  final NLatLng? startPoint;
  final NLatLng? goalPoint;
  final String? startAddress;
  final String? goalAddress;

  // ✅ NaverLocalService 전달받기
  final dynamic naverService;

  const RealTimeTrackingWidget({
    super.key,
    this.onStop,
    this.startPoint,
    this.goalPoint,
    this.startAddress,
    this.goalAddress,
    this.naverService,
  });

  @override
  State<RealTimeTrackingWidget> createState() => _RealTimeTrackingWidgetState();
}

class _RealTimeTrackingWidgetState extends State<RealTimeTrackingWidget> {
  final current = ThemeManager().current;

  // 지도 관련
  NaverMapController? _controller;
  late Completer<NaverMapController> _mapReady;

  // GPS 추적 상태
  bool _isTracking = false;
  bool _isPaused = false;
  StreamSubscription<Position>? _positionStream;

  // 경로 데이터
  final List<NLatLng> _routePoints = [];
  NPolylineOverlay? _routeLine;
  NPolylineOverlay? _goalLine; // ✅ 현재위치 → 도착지 연결선
  NMarker? _currentMarker;
  NMarker? _goalMarker; // ✅ 도착지 마커

  // 운동 데이터
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  DateTime? _startTime;
  DateTime? _pauseTime;
  // ignore: unused_field
  int _pausedSeconds = 0;
  Timer? _timer;

  // 칼로리 계산용
  final double _userWeight = 70.0;

  // 실시간 속도
  double _currentSpeed = 0.0;

  double? _distanceToGoal; // ✅ 도착지까지 남은 거리
  int? _roadDistanceToGoal; // ✅ 도로 기준 남은 거리
  // ignore: unused_field
  DateTime? _lastRouteUpdate; // ✅ 마지막 경로 업데이트 시간

  // ✅ NaverLocalService 인스턴스
  dynamic _naver;

  @override
  void initState() {
    super.initState();

    _mapReady = Completer<NaverMapController>();
    _naver = widget.naverService; // ✅ NaverService 저장
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _positionStream?.cancel();
    _positionStream = null;
    super.dispose();
  }

  // ✅ 도착지 마커 표시 (맵 준비 후 호출)
  Future<void> _showGoalMarker() async {
    if (_controller == null || widget.goalPoint == null || !mounted) return;

    // 기존 마커 삭제
    if (_goalMarker != null) {
      try {
        await _controller!.deleteOverlay(_goalMarker!.info);
      } catch (e) {
        debugPrint('🚨 goalMarker 삭제 실패: $e');
      }
    }

    _goalMarker = NMarker(
      id: 'goal-marker',
      position: widget.goalPoint!,
      caption: NOverlayCaption(text: widget.goalAddress ?? '도착지'),
      iconTintColor: Colors.red,
    );

    await _controller!.addOverlay(_goalMarker!);
    debugPrint('✅ 도착지 마커 추가: ${widget.goalPoint}');
  }

  // ========== GPS 추적 시작 ==========
  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('위치 서비스를 켜주세요');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('위치 권한이 거부되었습니다');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('설정에서 위치 권한을 허용해주세요');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isTracking = true;
      _isPaused = false;
      _startTime = DateTime.now();
      _routePoints.clear();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _pausedSeconds = 0;
    });

    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isPaused) {
        setState(() => _elapsedSeconds++);
      }
    });

    // GPS 스트림 시작
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) async {
          // ✅ async 추가
          if (!mounted || _isPaused) return;

          final newPoint = NLatLng(position.latitude, position.longitude);
          _currentSpeed = position.speed;

          // ✅ 도착지까지 남은 거리 계산 (직선)
          if (widget.goalPoint != null) {
            _distanceToGoal = _calculateDistance(newPoint, widget.goalPoint!);

            debugPrint('📍 현재: ${newPoint.latitude}, ${newPoint.longitude}');
            debugPrint(
              '🎯 목표: ${widget.goalPoint!.latitude}, ${widget.goalPoint!.longitude}',
            );
            debugPrint('🔍 _naver null? ${_naver == null}');

            // ✅ 현재 위치 → 도착지 도로 경로선 업데이트
            await _updateGoalLine(newPoint); // ✅ await 추가!
          }

          if (_routePoints.isNotEmpty) {
            final lastPoint = _routePoints.last;
            final distance = _calculateDistance(lastPoint, newPoint);

            if (distance > 3) {
              if (mounted) {
                setState(() {
                  _totalDistance += distance;
                  _routePoints.add(newPoint);
                });
              }

              _updateRouteLine();
              _updateCurrentMarker(newPoint);
              _moveCameraToPosition(newPoint);
            }
          } else {
            if (mounted) {
              setState(() => _routePoints.add(newPoint));
            }
            _updateCurrentMarker(newPoint);
            _moveCameraToPosition(newPoint);
          }
        });
  }

  // ========== 일시정지 ==========
  void _pauseTracking() {
    if (!mounted) return;
    setState(() {
      _isPaused = true;
      _pauseTime = DateTime.now();
    });
  }

  // ========== 재개 ==========
  void _resumeTracking() {
    if (_pauseTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseTime!).inSeconds;
      _pausedSeconds += pauseDuration;
    }

    if (!mounted) return;
    setState(() {
      _isPaused = false;
      _pauseTime = null;
    });
  }

  // ========== 추적 종료 ==========
  Future<void> _stopTracking() async {
    _timer?.cancel();
    _timer = null;

    await _positionStream?.cancel();
    _positionStream = null;

    if (!mounted) return;

    setState(() {
      _isTracking = false;
      _isPaused = false;
    });

    _showSaveDialog();
    // if (_routePoints.length > 1) {
    //   _showSaveDialog();
    // } else {
    //   if (widget.onStop != null) {
    //     widget.onStop!();
    //   }
    // }
  }

  // ========== 경로 선 업데이트 ==========
  Future<void> _updateRouteLine() async {
    if (_controller == null || _routePoints.length < 2 || !mounted) return;

    if (_routeLine != null) {
      await _controller!.deleteOverlay(_routeLine!.info);
    }

    _routeLine = NPolylineOverlay(
      id: 'tracking-route',
      coords: _routePoints,
      width: 8,
      color: Colors.blueAccent,
    );

    await _controller!.addOverlay(_routeLine!);
  }

  // ✅ 현재 위치 → 도착지 도로 경로선 업데이트
  Future<void> _updateGoalLine(NLatLng currentPosition) async {
    if (_controller == null || widget.goalPoint == null || !mounted) return;
    if (_naver == null) return;

    // 기존 선 삭제
    if (_goalLine != null) {
      try {
        await _controller!.deleteOverlay(_goalLine!.info);
      } catch (e) {
        debugPrint('🚨 goalLine 삭제 실패: $e');
      }
    }

    // ✅ 네이버 Direction API로 도로 경로 가져오기
    try {
      final route = await _naver.fetchShortestRoute(
        start: currentPosition,
        goal: widget.goalPoint!,
      );

      if (route == null || !mounted) return;

      // ✅ 도로 기준 남은 거리 저장
      _roadDistanceToGoal = route.distanceM;

      // 도로를 따라가는 점선 생성
      _goalLine = NPolylineOverlay(
        id: 'goal-line',
        coords: route.path,
        width: 4,
        color: Colors.orange.withValues(alpha: 0.7),
        pattern: [10, 5], // ✅ 점선 패턴
      );

      await _controller!.addOverlay(_goalLine!);

      if (mounted) setState(() {}); // ✅ 도로 거리 UI 업데이트

      debugPrint('✅ 도로 경로 업데이트: ${route.distanceM}m');
    } catch (e) {
      debugPrint('🚨 도로 경로 가져오기 실패: $e');
    }
  }

  // ========== 현재 위치 마커 업데이트 ==========
  Future<void> _updateCurrentMarker(NLatLng position) async {
    if (_controller == null || !mounted) return;

    if (_currentMarker != null) {
      await _controller!.deleteOverlay(_currentMarker!.info);
    }

    _currentMarker = NMarker(
      id: 'current-position',
      position: position,
      iconTintColor: Colors.blue,
      size: const Size(32, 32),
    );

    await _controller!.addOverlay(_currentMarker!);
  }

  // ========== 카메라 이동 ==========
  Future<void> _moveCameraToPosition(NLatLng position) async {
    if (_controller == null || !mounted) return;

    await _controller!.updateCamera(
      NCameraUpdate.withParams(target: position, zoom: 17),
    );
  }

  // ========== 두 지점 간 거리 계산 ==========
  double _calculateDistance(NLatLng start, NLatLng end) {
    const earthRadius = 6371000.0;

    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLat = (end.latitude - start.latitude) * pi / 180;
    final dLng = (end.longitude - start.longitude) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // ========== 칼로리 계산 ==========
  int get _calories {
    if (_elapsedSeconds == 0) return 0;
    final hours = _elapsedSeconds / 3600;
    final avgSpeed = _totalDistance / _elapsedSeconds;

    double met = 3.5;
    if (avgSpeed > 2.0) met = 7.0;

    return (met * _userWeight * hours).round();
  }

  // ========== 평균 속도 계산 ==========
  double get _avgSpeed {
    if (_elapsedSeconds == 0) return 0.0;
    return _totalDistance / _elapsedSeconds;
  }

  // ========== 포맷 함수들 ==========
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(2)}km';
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatSpeed(double mps) {
    final kmh = mps * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  String _formatPace(double mps) {
    if (mps == 0) return '--:--';
    final minPerKm = 1000 / (mps * 60);
    final min = minPerKm.floor();
    final sec = ((minPerKm - min) * 60).round();
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')} /km';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ========== 저장 다이얼로그 ==========
  void _showSaveDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('운동 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('거리: ${_formatDistance(_totalDistance)}'),
            Text('시간: ${_formatTime(_elapsedSeconds)}'),
            Text('칼로리: $_calories kcal'),
            Text('평균 속도: ${_formatSpeed(_avgSpeed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetAll();
              if (widget.onStop != null) {
                widget.onStop!();
              }
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveActivity();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // ========== 활동 저장 ==========
  Future<void> _saveActivity() async {
    if (_startTime == null) {
      _showSnackBar('운동 시작 시간을 찾을 수 없습니다.');
      return;
    }

    final endTime = DateTime.now();

    // ✅ Street 객체 생성 (수정된 모델 사용)
    final street = Street(
      mId: CurrentUser.instance.member!.mId,
      rStartTime: _startTime!, // DateTime 그대로 전달
      rEndTime: endTime, // DateTime 그대로 전달
      rDistance: _totalDistance, // double (미터)
      rTime: _elapsedSeconds.toString(), // String (초)
      rSpeed: _avgSpeed, // double (m/s)
      rKcal: _calories, // int
    );

    try {
      await StreetService.registerS(street);

      if (!mounted) return;

      _showSnackBar('활동이 저장되었습니다!');
      await _resetAll();

      if (widget.onStop != null) {
        widget.onStop!();
      }
    } catch (e) {
      debugPrint('🚨 활동 저장 실패: $e');

      if (!mounted) return;

      _showSnackBar('저장에 실패했습니다: $e');
    }
  }

  // ========== 전체 초기화 ==========
  Future<void> _resetAll() async {
    if (_controller != null && mounted) {
      if (_routeLine != null) {
        await _controller!.deleteOverlay(_routeLine!.info);
      }
      if (_goalLine != null) {
        await _controller!.deleteOverlay(_goalLine!.info);
      }
      if (_currentMarker != null) {
        await _controller!.deleteOverlay(_currentMarker!.info);
      }
      if (_goalMarker != null) {
        await _controller!.deleteOverlay(_goalMarker!.info);
      }
    }

    if (!mounted) return;

    setState(() {
      _routePoints.clear();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _pausedSeconds = 0;
      _startTime = null;
      _pauseTime = null;
      _currentSpeed = 0.0;
      _routeLine = null;
      _goalLine = null;
      _currentMarker = null;
      _goalMarker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "실시간 추적",
          isBack: true,
          current: current,
        ),
      ),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: widget.goalPoint ?? const NLatLng(37.5665, 126.9780),
                zoom: 15,
              ),
              mapType: NMapType.basic,
              locationButtonEnable: true,
            ),
            onMapReady: (controller) async {
              if (!mounted) return;

              _controller = controller;
              if (!_mapReady.isCompleted) _mapReady.complete(controller);

              debugPrint('✅ NaverMap ready');

              // ✅ 맵이 준비된 후 도착지 마커 표시
              if (widget.goalPoint != null) {
                await _showGoalMarker();
              }
            },
          ),

          Positioned(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: current.accent,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ✅ 도착지 정보가 있으면 표시
                  if (widget.goalAddress != null)
                    Text(
                      '목표: ${widget.goalAddress}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_roadDistanceToGoal != null)
                    Text(
                      '도로 기준 남은 거리: ${_formatDistance(_roadDistanceToGoal!.toDouble())}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_distanceToGoal != null && _roadDistanceToGoal == null)
                    Text(
                      '직선 거리: ${_formatDistance(_distanceToGoal!)}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.orange),
                    ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('거리', _formatDistance(_totalDistance)),
                      _statItem('속도', _formatSpeed(_currentSpeed)),
                      _statItem('칼로리', '$_calories kcal'),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '페이스: ${_formatPace(_currentSpeed)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isTracking)
                  _controlButton(
                    icon: Icons.play_arrow,
                    label: '시작',
                    color: Colors.green,
                    onTap: _startTracking,
                  ),

                if (_isTracking && !_isPaused)
                  _controlButton(
                    icon: Icons.pause,
                    label: '일시정지',
                    color: Colors.orange,
                    onTap: _pauseTracking,
                  ),

                if (_isTracking && _isPaused)
                  _controlButton(
                    icon: Icons.play_arrow,
                    label: '재개',
                    color: Colors.blue,
                    onTap: _resumeTracking,
                  ),

                if (_isTracking) SizedBox(width: 16.w),

                if (_isTracking)
                  _controlButton(
                    icon: Icons.stop,
                    label: '종료',
                    color: Colors.red,
                    onTap: _stopTracking,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
