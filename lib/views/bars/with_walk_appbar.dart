import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/theme/colors.dart';

class WithWalkAppbar extends StatelessWidget {
  final String titlename;
  final bool isBack;
  final VoidCallback? onMenuPressed;
  final bool isAdmin; // ✅ 생성자 매개변수로 추가
  final ThemeColors current; // ✅ 생성자 매개변수로 추가

  const WithWalkAppbar({
    super.key,
    required this.titlename,
    required this.isBack,
    this.onMenuPressed,
    this.isAdmin = false, // ✅ 기본값 false
    required this.current, // ✅ ThemeColors 추가
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 매개변수는 BuildContext만
    return AppBar(
      backgroundColor: current.app,
      centerTitle: true,
      automaticallyImplyLeading: isBack,

      title: Text(
        titlename,
        style: TextStyle(
          fontSize: 32.sp,
          color: current.fontThird,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        if (isAdmin)
          IconButton(
            icon: Icon(Icons.admin_panel_settings, color: current.accent),
            onPressed: onMenuPressed, // ✅ () 제거
          ),
      ],
    );
  }
}
