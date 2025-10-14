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
import 'package:with_walk/functions/widegt_fn.dart';

import 'package:with_walk/theme/colors.dart';
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
  late ThemeColors current;
  final startController = TextEditingController();
  final arriveController = TextEditingController();

  // ✅ Completer를 late가 아닌 initState에서 생성
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
    _mapReady = Completer<NaverMapController>(); // ✅ 여기서 생성
  }

  @override
  void dispose() {
    startController.dispose();
    arriveController.dispose();
    super.dispose();
  }

  Future<void> _flyTo(NLatLng target, {double zoom = 16}) async {
    if (!mounted) return; // ✅ mounted 체크

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
    if (!mounted) return; // ✅ mounted 체크

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
    if (!mounted) return; // ✅ mounted 체크

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
    if (!mounted) return; // ✅ mounted 체크

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

    final route = await _naver.fetchShortestRoute(start: _start!, goal: _goal!);

    if (!mounted) return; // ✅ 비동기 작업 후 mounted 체크

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
    if (!mounted) return; // ✅ mounted 체크

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
    if (!mounted) return; // ✅ mounted 체크

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

      if (!mounted) return; // ✅ 비동기 작업 후 mounted 체크

      final currentLatLng = NLatLng(position.latitude, position.longitude);

      await _setStart(currentLatLng);

      final addr = await _naver.reverseGeocodeToAddress(currentLatLng);

      if (!mounted) return; // ✅ 비동기 작업 후 mounted 체크

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
                            if (!mounted) return; // ✅ mounted 체크

                            _controller = c;
                            if (!_mapReady.isCompleted) _mapReady.complete(c);
                            _isMapReady = true;
                            debugPrint('✅ NaverMap ready');
                          },
                          onMapTapped: (pt, latLng) async {
                            if (!mounted) return; // ✅ mounted 체크

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
                                  const SnackBar(
                                    content: Text('리셋 후 다시 지정하세요.'),
                                  ),
                                );
                              }
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

                            // ✅ 걷기 시작 버튼 추가
                            SizedBox(height: 8.h),
                            colorbtn(
                              '걷기 시작',
                              current.accent,
                              current.bg,
                              current.accent,
                              double.infinity,
                              36,
                              () {
                                if (_goal == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('도착지를 설정해주세요.'),
                                    ),
                                  );
                                } else {
                                  if (widget.onStartWalk != null) {
                                    // ✅ 출발지/도착지 정보와 주소를 함께 전달
                                    widget.onStartWalk!(
                                      start: _start,
                                      goal: _goal,
                                      startAddr: startController.text,
                                      goalAddr: arriveController.text,
                                    );
                                  }
                                }
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
    );
  }

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
            _addressInputField(title, controller),
          ],
        ),
      ],
    );
  }

  /// ✅ 주소 직접 입력 + 장소 검색 통합 필드
  Widget _addressInputField(String hint, TextEditingController ctrl) {
    return Container(
      width: 200.w,
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: current.bg,
        border: Border.all(color: current.accent),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TypeAheadField<dynamic>(
        hideOnEmpty: true,
        hideOnLoading: true,
        hideOnUnfocus: false, // ✅ 엔터키 입력을 위해 false
        hideOnSelect: true,
        debounceDuration: const Duration(milliseconds: 400),

        suggestionsCallback: (q) async {
          final query = q.trim();
          if (query.isEmpty || query.length < 2) return [];

          // ✅ 장소명 검색만 자동완성으로 제공
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

            // ✅ 엔터키 또는 검색 버튼 누르면 주소로 직접 검색
            onSubmitted: (value) async {
              final address = value.trim();
              if (address.isEmpty) return;

              FocusScope.of(context).unfocus();

              // ✅ 주소 → 좌표 변환
              final latLng = await _naver.geocodeToLatLng(address);

              if (!mounted) return;

              if (latLng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('해당 주소를 찾을 수 없습니다. 다시 입력해주세요.')),
                );
                return;
              }

              // ✅ 마커 표시
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
              hintText: hint,
              suffixIcon: IconButton(
                icon: Icon(Icons.search, size: 18.sp, color: current.accent),
                onPressed: () async {
                  // ✅ 검색 버튼 클릭 시에도 주소로 검색
                  final address = tController.text.trim();
                  if (address.isEmpty) return;

                  FocusScope.of(context).unfocus();

                  final latLng = await _naver.geocodeToLatLng(address);

                  if (!mounted) return;

                  if (latLng == null) {
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
                color: current.fontPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
          );
        },

        // ✅ 장소명 자동완성 결과 표시
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

        // ✅ 장소명 선택 시
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
