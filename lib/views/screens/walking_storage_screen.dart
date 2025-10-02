import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class WalkingStorageScreen extends StatefulWidget {
  const WalkingStorageScreen({super.key});

  @override
  State<WalkingStorageScreen> createState() => _WalkingStorageScreenState();
}

class _WalkingStorageScreenState extends State<WalkingStorageScreen> {
  late ThemeColors current;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "남긴 발자국",
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
          Center(child: Column()),
        ],
      ),
    );
  }
}
