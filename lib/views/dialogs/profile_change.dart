import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<String?> profileChange(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: _ProfileChangeDialog(),
    ),
  );
}

class _ProfileChangeDialog extends StatefulWidget {
  const _ProfileChangeDialog();

  @override
  State<_ProfileChangeDialog> createState() => __ProfileChangeDialogState();
}

class __ProfileChangeDialogState extends State<_ProfileChangeDialog> {
  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFFFF8E7);

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/bgs/background.png"), // 배경 이미지 경로
          fit: BoxFit.cover, // 화면 꽉 채우기
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 타이틀
            Text(
              '프로필 사진 목록',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: Colors.teal.shade900,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 16.h),

            // 본문 카드
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 12.h),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
                    child: SizedBox(
                      height: 480.h,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                clickProfile('assets/images/foots/cat.png'),
                                SizedBox(width: 20.w),

                                clickProfile('assets/images/foots/dog.png'),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                clickProfile('assets/images/foots/bear.png'),
                                SizedBox(width: 20.w),

                                clickProfile('assets/images/foots/rabbit.png'),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                clickProfile('assets/images/foots/raccoon.png'),
                                SizedBox(width: 20.w),

                                clickProfile('assets/images/foots/hamster.png'),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                clickProfile('assets/images/foots/penguin.png'),

                                SizedBox(width: 20.w),
                                clickProfile('assets/images/foots/duck.png'),
                              ],
                            ),

                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 오른쪽 상단 타이머 칩(고정 텍스트)
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector clickProfile(String img) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, img);
      },
      child: Image.asset(img, width: 100.w, height: 100.h),
    );
  }
}
