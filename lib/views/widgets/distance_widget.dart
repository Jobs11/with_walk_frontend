// lib/views/widgets/distance_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:with_walk/api/model/place_result.dart';
import 'package:with_walk/api/service/naver_local_service.dart';
import 'package:with_walk/functions/data.dart';

import 'package:with_walk/views/bars/with_walk_appbar.dart';

class DistanceWidget extends StatefulWidget {
  final void Function({
    NLatLng? start,
    NLatLng? goal,
    String? startAddr,
    String? goalAddr,
  })?
  onStartWalk;

  const DistanceWidget({super.key, this.onStartWalk});

  @override
  State<DistanceWidget> createState() => _DistanceWidgetState();
}

class _DistanceWidgetState extends State<DistanceWidget> {
  final current = ThemeManager().current;
  final startController = TextEditingController();
  final arriveController = TextEditingController();

  late Completer<NaverMapController> _mapReady;
  // ignore: unused_field
  bool _isMapReady = false;

  NaverMapController? _controller;
  final _seoul = const NLatLng(37.5665, 126.9780);

  NLatLng? _start;
  NLatLng? _goal;
  NMarker? _startMarker;
  NMarker? _goalMarker;
  NPolylineOverlay? _line;
  double? _distanceM;

  bool _isLoadingLocation = false;
  bool _isPanelExpanded = true; // 👈 패널 펼침/접기 상태

  late final NaverLocalService _naver = NaverLocalService(
    searchClientId: NaverApi.naversearchclientid,
    searchClientSecret: NaverApi.naversearchclientsecret,
    geocodeKeyId: NaverApi.ncpgeocodekeyid,
    geocodeKey: NaverApi.ncpgeocodekey,
  );

  @override
  void initState() {
    super.initState();
    _mapReady = Completer<NaverMapController>();
  }

  @override
  void dispose() {
    startController.dispose();
    arriveController.dispose();
    super.dispose();
  }

  Future<void> _flyTo(NLatLng target, {double zoom = 16}) async {
    if (!mounted) return;
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
    if (!mounted) return;
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
    if (!mounted) return;
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
    if (!mounted) return;
    debugPrint('▶️ makeRoadRoute start: _start=$_start, _goal=$_goal');

    final c = await _c();
    if (_start == null || _goal == null) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('출발지와 도착지를 먼저 선택하세요.')));
      return;
    }

    if (c != null && _line != null) {
      await c.deleteOverlay(_line!.info);
      _line = null;
    }

    // 👇 여기에 isWalking: true 추가!
    final route = await _naver.fetchShortestRoute(
      start: _start!,
      goal: _goal!,
      isWalking: true, // 👈 도보 경로 사용!
    );

    if (!mounted) return;

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
      color: Colors.green, // 👈 도보는 녹색으로 표시!
    );
    if (c != null) await c.addOverlay(_line!);

    _distanceM = route.distanceM.toDouble();
    debugPrint(
      '✅ route ok: option=${route.option}, distance=$_distanceM m, pathLen=${route.path.length}',
    );
    if (mounted) setState(() {});
  }

  Future<void> _resetMarks() async {
    if (!mounted) return;

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

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초기화되었습니다.')));
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isLoadingLocation = true);

    try {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final currentLatLng = NLatLng(position.latitude, position.longitude);

      await _setStart(currentLatLng);

      final addr = await _naver.reverseGeocodeToAddress(currentLatLng);

      if (!mounted) return;

      if (addr != null && mounted) {
        setState(() => startController.text = addr);
      } else if (mounted) {
        setState(() => startController.text = '현재 위치');
      }

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

  // 👉 예상 소요 시간 계산 (평균 보행 속도 4km/h 기준)
  String _estimateTime(double meters) {
    final hours = meters / 4000; // 4km/h
    final minutes = (hours * 60).round();
    if (minutes < 1) return '1분 미만';
    return '$minutes분';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "발걸음",
            isBack: false,
            current: current,
          ),
        ),
        body: Stack(
          children: [
            // 배경
            Positioned.fill(
              child: Image.asset(
                "assets/images/bgs/background.png",
                fit: BoxFit.cover,
              ),
            ),

            // 메인 컨텐츠
            Column(
              children: [
                // 🗺️ 지도 영역 (더 크게)
                SizedBox(
                  width: double.infinity,
                  height: _isPanelExpanded ? 400.h : 500.h,
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
                      if (!mounted) return;
                      _controller = c;
                      if (!_mapReady.isCompleted) _mapReady.complete(c);
                      _isMapReady = true;
                      debugPrint('✅ NaverMap ready');
                    },
                    onMapTapped: (pt, latLng) async {
                      if (!mounted) return;

                      final focus = FocusScope.of(context);
                      if (focus.hasPrimaryFocus) focus.unfocus();

                      if (_start == null) {
                        await _setStart(latLng);
                        final addr = await _naver.reverseGeocodeToAddress(
                          latLng,
                        );
                        if (addr != null && mounted) {
                          setState(() => startController.text = addr);
                        }
                        await _flyTo(latLng);
                      } else if (_goal == null) {
                        await _setGoal(latLng);
                        final addr = await _naver.reverseGeocodeToAddress(
                          latLng,
                        );
                        if (addr != null && mounted) {
                          setState(() => arriveController.text = addr);
                        }
                        await _flyTo(latLng);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('리셋 후 다시 지정하세요.')),
                          );
                        }
                      }
                    },
                  ),
                ),

                // 🎴 컨트롤 패널 (카드 스타일)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: current.bg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 패널 헤더 (접기/펴기)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPanelExpanded = !_isPanelExpanded;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isPanelExpanded
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up,
                                        color: current.fontSecondary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        _isPanelExpanded ? '경로 설정' : '경로 보기',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: current.fontThird,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 패널 내용
                          if (_isPanelExpanded)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                children: [
                                  // 출발지 카드
                                  _buildLocationCard(
                                    icon: Icons.my_location,
                                    iconColor: Colors.green,
                                    title: '출발지',
                                    controller: startController,
                                    hint: '출발',
                                    showLocationBtn: true,
                                  ),

                                  SizedBox(height: 12.h),

                                  // 도착지 카드
                                  _buildLocationCard(
                                    icon: Icons.location_on,
                                    iconColor: Colors.red,
                                    title: '도착지',
                                    controller: arriveController,
                                    hint: '도착',
                                    showLocationBtn: false,
                                  ),

                                  SizedBox(height: 16.h),

                                  // 경로 정보 카드
                                  if (_distanceM != null)
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            current.accent.withValues(
                                              alpha: 0.1,
                                            ),
                                            current.accent.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: current.accent.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildInfoColumn(
                                            icon: Icons.straighten,
                                            label: '예상 거리',
                                            value: _fmtMeters(_distanceM!),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40.h,
                                            color: current.accent.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          _buildInfoColumn(
                                            icon: Icons.access_time,
                                            label: '예상 시간',
                                            value: _estimateTime(_distanceM!),
                                          ),
                                        ],
                                      ),
                                    ),

                                  SizedBox(height: 20.h),

                                  // 버튼들
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _resetMarks,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('초기화'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: current.accent,
                                            side: BorderSide(
                                              color: current.accent,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _distanceM == null
                                              ? _makeRoadRoute
                                              : null,
                                          icon: const Icon(Icons.route),
                                          label: const Text('경로 보기'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: current.accent,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // 걷기 시작 버튼
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _goal == null
                                          ? null
                                          : () {
                                              if (widget.onStartWalk != null) {
                                                widget.onStartWalk!(
                                                  start: _start,
                                                  goal: _goal,
                                                  startAddr:
                                                      startController.text,
                                                  goalAddr:
                                                      arriveController.text,
                                                );
                                              }
                                            },
                                      icon: const Icon(
                                        Icons.directions_walk,
                                        size: 24,
                                      ),
                                      label: Text(
                                        '걷기 시작하기',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        disabledBackgroundColor: Colors.grey
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20.h),
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
          ],
        ),
      ),
    );
  }

  // 위치 카드 위젯
  Widget _buildLocationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required TextEditingController controller,
    required String hint,
    required bool showLocationBtn,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: current.fontSecondary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: current.fontThird,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (showLocationBtn)
                GestureDetector(
                  onTap: _isLoadingLocation ? null : _getCurrentLocation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: current.accent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: _isLoadingLocation
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '현재위치',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              Expanded(child: _addressInputField(hint, controller)),
            ],
          ),
        ],
      ),
    );
  }

  // 정보 컬럼 위젯
  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: current.accent, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: current.fontSecondary),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
      ],
    );
  }

  /// ✅ 주소 직접 입력 + 장소 검색 통합 필드
  Widget _addressInputField(String hint, TextEditingController ctrl) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: current.bg.withValues(alpha: 0.5),
        border: Border.all(color: current.fontSecondary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TypeAheadField<dynamic>(
        hideOnEmpty: true,
        hideOnLoading: true,
        hideOnUnfocus: true,
        hideOnSelect: true,
        debounceDuration: const Duration(milliseconds: 400),
        suggestionsCallback: (q) async {
          final query = q.trim();
          if (query.isEmpty || query.length < 2) return [];
          final places = await _naver.searchPlaces(query);
          return places;
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
            onSubmitted: (value) async {
              final address = value.trim();
              if (address.isEmpty) return;

              FocusScope.of(context).unfocus();

              final latLng = await _naver.geocodeToLatLng(address);

              if (!mounted) return;

              if (latLng == null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('해당 주소를 찾을 수 없습니다.')),
                );
                return;
              }

              final isStart = hint.trim() == '출발';
              if (isStart) {
                await _setStart(latLng);
                ctrl.text = address;
              } else {
                await _setGoal(latLng);
                ctrl.text = address;
              }

              await _flyTo(latLng, zoom: 16);

              if (mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ 위치가 설정되었습니다: $address')),
                );
              }
            },
            onTap: () {
              if (tController.selection.start == tController.selection.end) {
                tController.selection = TextSelection.fromPosition(
                  TextPosition(offset: tController.text.length),
                );
              }
            },
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: '주소 또는 장소명 입력',
              suffixIcon: IconButton(
                icon: Icon(Icons.search, size: 20.sp, color: current.accent),
                onPressed: () async {
                  final address = tController.text.trim();
                  if (address.isEmpty) return;

                  FocusScope.of(context).unfocus();

                  final latLng = await _naver.geocodeToLatLng(address);

                  if (!mounted) return;

                  if (latLng == null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('해당 주소를 찾을 수 없습니다.')),
                    );
                    return;
                  }

                  final isStart = hint.trim() == '출발';
                  if (isStart) {
                    await _setStart(latLng);
                    ctrl.text = address;
                  } else {
                    await _setGoal(latLng);
                    ctrl.text = address;
                  }

                  await _flyTo(latLng, zoom: 16);
                },
              ),
              hintStyle: TextStyle(
                color: current.fontSecondary.withValues(alpha: 0.6),
                fontSize: 13.sp,
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
          );
        },
        itemBuilder: (context, item) {
          if (item is! PlaceResult) return const SizedBox.shrink();

          return ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.store, color: current.accent, size: 20.sp),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.roadAddr.isNotEmpty ? item.roadAddr : item.jibunAddr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp),
            ),
          );
        },
        onSelected: (item) async {
          if (item is! PlaceResult) return;

          ctrl.text = item.title;
          FocusScope.of(context).unfocus();

          final addr = item.roadAddr.isNotEmpty
              ? item.roadAddr
              : item.jibunAddr;
          final latLng = await _naver.geocodeToLatLng(addr);

          if (!mounted) return;

          if (latLng == null) {
            debugPrint('❌ geocode null for "$addr"');
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('주소 좌표를 찾지 못했습니다.')));
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
