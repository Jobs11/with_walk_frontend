import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class WalkingDistanceScreen extends StatefulWidget {
  const WalkingDistanceScreen({super.key});

  @override
  State<WalkingDistanceScreen> createState() => _WalkingDistanceScreenState();
}

class _WalkingDistanceScreenState extends State<WalkingDistanceScreen> {
  late ThemeColors current;

  GoogleMapController? _map;
  bool _locOn = false;

  static const _seoul = CameraPosition(
    target: LatLng(37.5665, 126.9780), // 서울 시청
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _initLocation();
  }

  Future<void> _initLocation() async {
    final ok = await _ensurePermission();
    if (!mounted) return;
    setState(() => _locOn = ok);

    if (ok) {
      final p = await Geolocator.getCurrentPosition();
      _map?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 16),
      );
    }
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 400, // 원하는 높이(px)
                    child: GoogleMap(
                      initialCameraPosition: _seoul,
                      onMapCreated: (c) => _map = c,
                      myLocationEnabled: _locOn,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.my_location),
          onPressed: () async {
            final ok = await _ensurePermission();
            if (!ok) return;
            final p = await Geolocator.getCurrentPosition();
            _map?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 16),
            );
          },
        ),
      ),
    );
  }
}
