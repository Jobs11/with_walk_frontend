import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithWalkAppbar extends StatelessWidget {
  final String titlename;
  final bool isBack;
  final Color isColored, fontColor;
  final VoidCallback? onMenuPressed;

  const WithWalkAppbar({
    super.key,
    required this.titlename,
    required this.isBack,
    required this.isColored,
    required this.fontColor,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isColored,
      centerTitle: true,
      automaticallyImplyLeading: isBack,

      title: Text(
        titlename,
        style: TextStyle(
          fontSize: 32.sp,
          color: fontColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
