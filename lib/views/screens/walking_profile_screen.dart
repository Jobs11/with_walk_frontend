import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class WalkingProfileScreen extends StatefulWidget {
  const WalkingProfileScreen({super.key});

  @override
  State<WalkingProfileScreen> createState() => _WalkingProfileScreenState();
}

class _WalkingProfileScreenState extends State<WalkingProfileScreen> {
  late ThemeColors current;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "발자국 주인공",
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
      ),
    );
  }
}
