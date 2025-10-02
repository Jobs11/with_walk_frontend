import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/theme/colors.dart';

Widget colorbtn(
  String title,
  Color btncolor,
  Color fontcolor,
  Color borcolor,
  double ws,
  double hs,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: ws.w,
      height: hs.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: btncolor,
        border: Border.all(color: borcolor),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: fontcolor,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget inputdata(
  String title,
  TextEditingController controller,
  ThemeColors colors,
  double ws,
) {
  return Container(
    width: ws.w,
    height: 36.h,
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    decoration: BoxDecoration(
      color: colors.bg,
      border: Border.all(color: colors.accent),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        counterText: '',
        border: InputBorder.none, // 테두리 제거 (BoxDecoration에서 그림)
        hintText: title, // 플레이스홀더
        hintStyle: TextStyle(
          color: colors.fontPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextStyle(fontSize: 16.sp),
    ),
  );
}
