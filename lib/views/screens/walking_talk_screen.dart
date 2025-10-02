import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class WalkingTalkScreen extends StatefulWidget {
  const WalkingTalkScreen({super.key});

  @override
  State<WalkingTalkScreen> createState() => _WalkingTalkScreenState();
}

class _WalkingTalkScreenState extends State<WalkingTalkScreen> {
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
          titlename: "길건너 친구들",
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
