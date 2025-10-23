import 'package:flutter/material.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_navigationbar.dart';
import 'package:with_walk/views/screens/mainmenu/walking_distance_screen.dart';
import 'package:with_walk/views/screens/mainmenu/walking_event_screen.dart';
import 'package:with_walk/views/screens/mainmenu/walking_profile_screen.dart';
import 'package:with_walk/views/screens/mainmenu/walking_storage_screen.dart';
import 'package:with_walk/views/screens/mainmenu/walking_talk_screen.dart';

class MainhomeScreen extends StatefulWidget {
  const MainhomeScreen({super.key});

  @override
  State<MainhomeScreen> createState() => _MainhomeScreenState();
}

class _MainhomeScreenState extends State<MainhomeScreen> {
  late ThemeColors current;
  int _index = 0;

  final List<Widget> _pages = const [
    WalkingDistanceScreen(),
    WalkingStorageScreen(),
    WalkingTalkScreen(),
    WalkingEventScreen(),
    WalkingProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _pages[_index], // ✅ 전환 애니 없음, 상태 유지
        bottomNavigationBar: WithWalkNavigationbar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          current: current,
        ),
      ),
    );
  }
}
