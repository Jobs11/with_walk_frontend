// lib/views/screens/walking_distance_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:with_walk/api/model/place_result.dart';
import 'package:with_walk/api/service/naver_local_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/widegt_fn.dart';

import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class WalkingDistanceScreen extends StatefulWidget {
  const WalkingDistanceScreen({super.key});
  @override
  State<WalkingDistanceScreen> createState() => _WalkingDistanceScreenState();
}

class _WalkingDistanceScreenState extends State<WalkingDistanceScreen> {
  late ThemeColors current;
  final startController = TextEditingController();
  final arriveController = TextEditingController();
  final _mapReady = Completer<NaverMapController>();
  bool _isMapReady = false;

  NaverMapController? _controller;
  final _seoul = const NLatLng(37.5665, 126.9780);

  // ✅ NEW: 출발/도착 상태 + 마커 + 선 + 거리
  NLatLng? _start;
  NLatLng? _goal;
  NMarker? _startMarker;
  NMarker? _goalMarker;
  NPolylineOverlay? _line; // flutter_naver_map 1.x 기준
  double? _distanceM;

  late final NaverLocalService _naver = NaverLocalService(
    searchClientId: NaverApi.naversearchclientid,
    searchClientSecret: NaverApi.naversearchclientsecret,
    geocodeKeyId: NaverApi.ncpgeocodekeyid,
    geocodeKey: NaverApi.ncpgeocodekey,
  );

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  void dispose() {
    startController.dispose();
    arriveController.dispose();
    super.dispose();
  }

  Future<void> _flyTo(NLatLng target, {double zoom = 16}) async {
    try {
      final c = _controller ?? await _mapReady.future;
      await c.updateCamera(
        NCameraUpdate.withParams(target: target, zoom: zoom),
      );
      debugPrint('✅ moved to ${target.latitude}, ${target.longitude}');
    } catch (e) {
      debugPrint('🚨 flyTo error: $e');
    }
  }

  // 컨트롤러 안전 접근 헬퍼(옵션)
  Future<NaverMapController?> _c() async {
    if (_controller != null) return _controller;
    if (_mapReady.isCompleted) return _mapReady.future;
    return null; // 아직 맵 준비 전
  }

  // ✅ 출발/도착 마킹 및 선/거리 갱신 (setMap → addOverlay/deleteOverlay)
  Future<void> _setStart(NLatLng p) async {
    debugPrint('🟢 setStart: ${p.latitude}, ${p.longitude}');
    _start = p;
    final c = await _c();
    if (c != null && _startMarker != null)
      await c.deleteOverlay(_startMarker!.info);
    _startMarker = NMarker(
      id: 'start',
      position: p,
      caption: const NOverlayCaption(text: '출발'),
      iconTintColor: Colors.green,
    );
    if (c != null) await c.addOverlay(_startMarker!);
    if (mounted) setState(() {});
  }

  Future<void> _setGoal(NLatLng p) async {
    debugPrint('🔴 setGoal: ${p.latitude}, ${p.longitude}');
    _goal = p;
    final c = await _c();
    if (c != null && _goalMarker != null)
      await c.deleteOverlay(_goalMarker!.info);
    _goalMarker = NMarker(
      id: 'goal',
      position: p,
      caption: const NOverlayCaption(text: '도착'),
      iconTintColor: Colors.redAccent,
    );
    if (c != null) await c.addOverlay(_goalMarker!);
    if (mounted) setState(() {});
  }

  Future<void> _makeRoadRoute() async {
    debugPrint('▶️ makeRoadRoute start: _start=$_start, _goal=$_goal');

    final c = await _c();
    if (_start == null || _goal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('출발지와 도착지를 먼저 선택하세요.')));
      return;
    }

    if (c != null && _line != null) {
      await c.deleteOverlay(_line!.info);
      _line = null;
    }

    final route = await _naver.fetchDrivingRoute(
      start: _start!,
      goal: _goal!,
      option: 'traoptimal',
    );

    if (route == null) {
      _distanceM = null;
      if (mounted) setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('경로를 찾을 수 없습니다.')));
      return;
    }

    _line = NPolylineOverlay(
      id: 'sg-road-line',
      coords: route.path,
      width: 6,
      color: Colors.blueAccent,
    );
    if (c != null) await c.addOverlay(_line!);

    _distanceM = route.distanceM.toDouble();
    debugPrint(
      '✅ route ok: distance=$_distanceM m, pathLen=${route.path.length}',
    );
    if (mounted) setState(() {});
  }

  Future<void> _resetMarks() async {
    final c = await _c();

    _start = null;
    _goal = null;
    _distanceM = null;

    if (c != null) {
      if (_startMarker != null) await c.deleteOverlay(_startMarker!.info);
      if (_goalMarker != null) await c.deleteOverlay(_goalMarker!.info);
      if (_line != null) await c.deleteOverlay(_line!.info);
    }

    _startMarker = null;
    _goalMarker = null;
    _line = null;

    if (mounted) setState(() {});
  }

  String _fmtMeters(double m) => m >= 1000
      ? '${(m / 1000).toStringAsFixed(2)} km'
      : '${m.toStringAsFixed(0)} m';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "발걸음",
          isBack: false,
          isColored: current.app,
          fontColor: current.fontThird,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bgs/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 580.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: 300.w,
                      height: 300.h,
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                            target: _seoul,
                            zoom: 14,
                          ),
                          contentPadding: EdgeInsets.zero,
                          mapType: NMapType.basic,
                          liteModeEnable: false,
                          indoorEnable: false,
                          logoClickEnable: false,
                          rotationGesturesEnable: true,
                          scrollGesturesEnable: true,
                          tiltGesturesEnable: true,
                          zoomGesturesEnable: true,
                        ),
                        onMapReady: (c) {
                          _controller = c;
                          if (!_mapReady.isCompleted) _mapReady.complete(c);
                          _isMapReady = true;
                          debugPrint('✅ NaverMap ready');
                        },
                        // ✅ NEW: 지도 탭으로도 지정하려면(선택)
                        onMapTapped: (pt, latLng) {
                          final focus = FocusScope.of(context);
                          if (focus.hasPrimaryFocus) {
                            // 키보드 열려 있으면 닫기
                            focus.unfocus();
                          }
                          if (_start == null) {
                            _setStart(latLng);
                            _flyTo(latLng);
                          } else if (_goal == null) {
                            _setGoal(latLng);
                            _flyTo(latLng);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('리셋 후 다시 지정하세요.')),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        children: [
                          _inputRow('출발', startController),
                          SizedBox(height: 8.h),
                          _inputRow('도착', arriveController),
                          SizedBox(height: 8.h),

                          // ✅ NEW: 거리 표시 (둘 다 지정됐을 때만)
                          if (_distanceM != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: current.bg,
                                border: Border.all(color: current.accent),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.route),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '직선 거리: ${_fmtMeters(_distanceM!)}',
                                    style: TextStyle(
                                      color: current.fontThird,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 8.h),
                          // 기존 버튼은 일단 유지(향후 도로 경로로 확장용)
                          colorbtn(
                            '길찾기',
                            current.bg,
                            current.fontThird,
                            current.accent,
                            double.infinity,
                            36,
                            () {
                              _makeRoadRoute();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ NEW: 리셋 버튼
          FloatingActionButton.extended(
            heroTag: 'reset',
            onPressed: _resetMarks,
            label: const Text('리셋'),
            icon: const Icon(Icons.refresh),
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'seoul',
            child: const Icon(Icons.location_city),
            onPressed: () => _flyTo(const NLatLng(37.5665, 126.9780), zoom: 16),
          ),
        ],
      ),
    );
  }

  Row _inputRow(String title, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: current.fontThird,
            fontWeight: FontWeight.bold,
          ),
        ),
        _autocompleteField(title, controller), // title로 출/도착 구분
      ],
    );
  }

  Widget _autocompleteField(String hint, TextEditingController ctrl) {
    return Container(
      width: 200.w,
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: current.bg,
        border: Border.all(color: current.accent),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TypeAheadField<PlaceResult>(
        hideOnEmpty: true,
        hideOnLoading: true,
        suggestionsCallback: (q) async {
          final query = q.trim();
          return await _naver.searchPlaces(query); // List<PlaceResult>
        },
        builder: (context, tController, focusNode) {
          if (tController.text != ctrl.text) {
            tController.value = ctrl.value;
          }
          return TextField(
            controller: tController,
            focusNode: focusNode,
            onChanged: (_) => ctrl.value = tController.value,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: current.fontPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          );
        },
        itemBuilder: (context, item) => ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            item.roadAddr.isNotEmpty ? item.roadAddr : item.jibunAddr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ✅ NEW: 선택 시 출발/도착 구분해서 마킹 + 직선/거리 갱신 + 카메라 이동
        onSelected: (item) async {
          setState(() => ctrl.text = item.title);
          FocusScope.of(context).unfocus();

          final addr = item.roadAddr.isNotEmpty
              ? item.roadAddr
              : item.jibunAddr;
          final latLng = await _naver.geocodeToLatLng(addr);

          if (latLng == null) {
            debugPrint('❌ geocode null for "$addr"');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('주소 좌표를 찾지 못했습니다. 다른 키워드로 검색해보세요.')),
            );
            return;
          }

          final isStart = hint.trim() == '출발';
          if (isStart) {
            await _setStart(latLng);
          } else {
            await _setGoal(latLng);
          }

          debugPrint('✅ current _start=$_start, _goal=$_goal');
          await _flyTo(latLng, zoom: 16);
        },
      ),
    );
  }
}
