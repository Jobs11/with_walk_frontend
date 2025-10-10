// lib/views/screens/walking_distance_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
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

  NLatLng? _start;
  NLatLng? _goal;
  NMarker? _startMarker;
  NMarker? _goalMarker;
  NPolylineOverlay? _line;
  double? _distanceM;

  // ✅ NEW: 현재 위치 로딩 상태
  bool _isLoadingLocation = false;

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

  Future<NaverMapController?> _c() async {
    if (_controller != null) return _controller;
    if (_mapReady.isCompleted) return _mapReady.future;
    return null;
  }

  Future<void> _setStart(NLatLng p) async {
    debugPrint('🟢 setStart: ${p.latitude}, ${p.longitude}');
    _start = p;
    final c = await _c();
    if (c != null && _startMarker != null) {
      await c.deleteOverlay(_startMarker!.info);
    }
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
    if (c != null && _goalMarker != null) {
      await c.deleteOverlay(_goalMarker!.info);
    }
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

    // ✅ 여러 옵션 중 최단 거리 경로 검색
    final route = await _naver.fetchShortestRoute(start: _start!, goal: _goal!);

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
      '✅ route ok: option=${route.option}, distance=$_distanceM m, pathLen=${route.path.length}',
    );
    if (mounted) setState(() {});
  }

  Future<void> _resetMarks() async {
    // ✅ 이미 모든 값이 null이면 스낵바 표시
    if (_start == null && _goal == null && _distanceM == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초기화할 데이터가 없습니다.')));
      return;
    }

    final c = await _c();

    _start = null;
    _goal = null;
    _distanceM = null;

    if (c != null) {
      if (_startMarker != null) {
        await c.deleteOverlay(_startMarker!.info);
        _startMarker = null;
      }
      if (_goalMarker != null) {
        await c.deleteOverlay(_goalMarker!.info);
        _goalMarker = null;
      }
      if (_line != null) {
        await c.deleteOverlay(_line!.info);
        _line = null;
      }
    }

    startController.text = '';
    arriveController.text = '';

    if (mounted) setState(() {});

    // ✅ 초기화 완료 알림
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초기화되었습니다.')));
    }
  }

  // ✅ NEW: 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // 1. 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('위치 서비스를 켜주세요.')));
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // 2. 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 권한이 영구 거부되었습니다. 설정에서 권한을 허용해주세요.'),
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // 3. 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = NLatLng(position.latitude, position.longitude);

      // 4. 출발지로 설정
      await _setStart(currentLatLng);

      // 5. 역지오코딩으로 주소 가져오기
      final addr = await _naver.reverseGeocodeToAddress(currentLatLng);
      if (addr != null && mounted) {
        setState(() => startController.text = addr);
      } else if (mounted) {
        setState(() => startController.text = '현재 위치');
      }

      // 6. 지도 이동
      await _flyTo(currentLatLng, zoom: 16);

      debugPrint('✅ 현재 위치: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('🚨 위치 가져오기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('위치를 가져올 수 없습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  String _fmtMeters(double m) => m >= 1000
      ? '${(m / 1000).toStringAsFixed(2)} km'
      : '${m.toStringAsFixed(0)} m';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ✅ 화면 어디든 터치하면 포커스 해제 (리스트 닫기)
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                          onMapTapped: (pt, latLng) async {
                            final focus = FocusScope.of(context);
                            if (focus.hasPrimaryFocus) focus.unfocus();

                            if (_start == null) {
                              await _setStart(latLng);
                              final addr = await _naver.reverseGeocodeToAddress(
                                latLng,
                              );
                              if (addr != null) {
                                setState(() => startController.text = addr);
                              }
                              await _flyTo(latLng);
                            } else if (_goal == null) {
                              await _setGoal(latLng);
                              final addr = await _naver.reverseGeocodeToAddress(
                                latLng,
                              );
                              if (addr != null) {
                                setState(() => arriveController.text = addr);
                              }
                              await _flyTo(latLng);
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
                            _inputRow(
                              '출발',
                              startController,
                              showLocationBtn: true,
                            ),
                            SizedBox(height: 8.h),
                            _inputRow('도착', arriveController),
                            SizedBox(height: 8.h),

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
                                      '경로 거리: ${_fmtMeters(_distanceM!)}',
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
            FloatingActionButton.extended(
              heroTag: 'reset',
              onPressed: _resetMarks,
              label: Text(
                '리셋',
                style: TextStyle(color: current.bg, fontSize: 16.sp),
              ),
              icon: Icon(Icons.refresh, color: current.bg),
              backgroundColor: current.accent,
            ),
          ],
        ),
      ),
    ); // ✅ GestureDetector 닫기
  }

  // ✅ UPDATED: showLocationBtn 파라미터 추가
  Row _inputRow(
    String title,
    TextEditingController controller, {
    bool showLocationBtn = false,
  }) {
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
        Row(
          children: [
            // ✅ NEW: 현재 위치 버튼 (출발에만 표시)
            if (showLocationBtn)
              GestureDetector(
                onTap: _isLoadingLocation ? null : _getCurrentLocation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  margin: EdgeInsets.only(right: 6.w),
                  decoration: BoxDecoration(
                    color: current.accent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _isLoadingLocation
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: current.bg,
                          ),
                        )
                      : Icon(Icons.my_location, color: current.bg, size: 18.sp),
                ),
              ),
            _autocompleteField(title, controller),
          ],
        ),
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
        hideOnUnfocus: true,
        hideOnSelect: true,
        debounceDuration: const Duration(milliseconds: 300), // ✅ 입력 후 300ms 대기
        suggestionsCallback: (q) async {
          final query = q.trim();
          if (query.isEmpty) return []; // ✅ 빈 문자열이면 빈 리스트 반환
          return await _naver.searchPlaces(query);
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
            onTap: () {
              // ✅ 탭했을 때 전체 선택 방지
              if (tController.selection.start == tController.selection.end) {
                tController.selection = TextSelection.fromPosition(
                  TextPosition(offset: tController.text.length),
                );
              }
            },
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
        onSelected: (item) async {
          // ✅ 1. 먼저 텍스트 업데이트 (setState 없이!)
          ctrl.text = item.title;

          // ✅ 2. 포커스 해제 (리스트 즉시 닫기)
          FocusScope.of(context).unfocus();

          final addr = item.roadAddr.isNotEmpty
              ? item.roadAddr
              : item.jibunAddr;
          final latLng = await _naver.geocodeToLatLng(addr);

          if (latLng == null) {
            debugPrint('❌ geocode null for "$addr"');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('주소 좌표를 찾지 못했습니다. 다른 키워드로 검색해보세요.'),
                ),
              );
            }
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
