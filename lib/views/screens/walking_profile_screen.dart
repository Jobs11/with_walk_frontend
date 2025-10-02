import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/dialogs/profile_change.dart';
import 'package:with_walk/views/screens/membership_update_screen.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final profileimage = await profileChange(
                      context,
                      title: '프로필수정',
                    );

                    if (profileimage != null) {
                      setState(() {});
                    }
                  },
                  child: Image.asset(
                    CurrentUser.instance.member!.mPaint ??
                        'assets/images/icons/user.png',
                    fit: BoxFit.cover,
                    width: 120.w,
                    height: 120.h,
                  ),
                ),

                Text(
                  '${CurrentUser.instance.member!.mNickname} 님',
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: current.fontThird,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                colorbtn(
                  "프로필 수정",
                  current.bg,
                  current.btn,
                  current.btn,
                  200,
                  36,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MembershipUpdateScreen(current: current),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  height: 400.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '고객지원',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('공지사항'),
                        SizedBox(height: 5.h),
                        settingrow('고객센터'),
                        SizedBox(height: 5.h),
                        settingrow('자주 묻는 질문(FAQ)'),
                        SizedBox(height: 5.h),
                        settingrow('문의하기 / 1:1 상담'),
                        SizedBox(height: 15.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '앱 정보',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('어플리케이션 정보'),
                        SizedBox(height: 5.h),
                        settingrow('버전 정보 & 업데이트 확인'),
                        SizedBox(height: 5.h),
                        settingrow('이용약관'),
                        SizedBox(height: 5.h),
                        settingrow('개인정보 처리방침'),
                        SizedBox(height: 15.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '기타',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('테마 설정'),
                        SizedBox(height: 5.h),
                        settingrow('알림 설정'),
                        SizedBox(height: 5.h),
                        settingrow('언어 설정'),
                        SizedBox(height: 5.h),
                        settingrow('실험실'),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row settingrow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: current.fontThird,
            fontWeight: FontWeight.bold,
          ),
        ),
        Image.asset(
          'assets/images/icons/setting_arrow.png',
          width: 15.w,
          height: 15.h,
        ),
      ],
    );
  }
}
