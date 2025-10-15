import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double ws, {
  void Function(String)? onChange, // ✅ 추가된 매개변수
}) {
  // 비밀번호 필드 여부 확인
  bool isPasswordField = title.contains('비밀번호');

  // 입력 필터 설정 (아이디 또는 비밀번호일 때 영문+숫자만)
  List<TextInputFormatter>? inputFormatters;
  if (title == '아이디' || isPasswordField) {
    inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    ];
  }

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
      obscureText: isPasswordField, // 비밀번호 필드일 때 *** 처리
      inputFormatters: inputFormatters, // 영문+숫자만 입력
      decoration: InputDecoration(
        counterText: '',
        border: InputBorder.none,
        hintText: title,
        hintStyle: TextStyle(
          color: colors.fontPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextStyle(fontSize: 16.sp),
      onChanged: onChange, // ✅ 외부 콜백 연결
    ),
  );
}
