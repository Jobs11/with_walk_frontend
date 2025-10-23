import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:with_walk/api/model/member.dart';
import 'package:with_walk/api/model/member_profile.dart';
import 'package:with_walk/api/service/cloudinary_upload_service.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/login_screen.dart';

// ✅ userId 파라미터 추가
Future<String?> profileChange(
  BuildContext context, {
  required String title,
  String? userId, // 회원가입 시 임시 ID 전달
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: _ProfileChangeDialog(
        title: title,
        userId: userId, // ✅ 전달
      ),
    ),
  );
}

class _ProfileChangeDialog extends StatefulWidget {
  final String title;
  final String? userId; // ✅ 추가

  const _ProfileChangeDialog({required this.title, this.userId});

  @override
  State<_ProfileChangeDialog> createState() => __ProfileChangeDialogState();
}

class __ProfileChangeDialogState extends State<_ProfileChangeDialog> {
  final m = CurrentUser.instance.member;
  final CloudinaryUploadService _cloudinaryService = CloudinaryUploadService();
  bool _isUploading = false;

  Future<void> _update(String img) async {
    final member = MemberProfile(
      mId: widget.userId ?? m!.mId,
      mProfileImage: img,
    );

    try {
      await Memberservice.updateProfile(member);

      if (widget.title != '회원가입') {
        final mem = Member(
          mId: m!.mId,
          mPassword: m!.mPassword,
          mName: m!.mName,
          mNickname: m!.mNickname,
          mEmail: m!.mEmail,
          mProfileImage: img,
        );
        CurrentUser.instance.member = mem;
        debugPrint(const JsonEncoder.withIndent('  ').convert(mem.toJson()));
      }

      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "프로필 사진 변경 완료!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "프로필 사진 변경 실패!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
      debugPrint('에러: $e');
    }
  }

  // ✅ 갤러리에서 이미지 선택 및 업로드 (수정됨)
  Future<void> _uploadFromGallery() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      // ✅ userId 우선 사용, 없으면 로그인된 사용자 ID 사용
      final uploadUserId = widget.userId ?? m?.mId;

      if (uploadUserId == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다');
      }

      final imageUrl = await _cloudinaryService.uploadProfileImage(
        uploadUserId,
      );

      if (imageUrl != null) {
        await _update(imageUrl);
        debugPrint('$imageUrl 수정 완료');

        if (!mounted) return;
        Fluttertoast.showToast(
          msg: "프로필 사진 업로드 완료!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xAA4CAF50),
          textColor: Colors.white,
          fontSize: 16.0.sp,
        );

        if (!mounted) return;
        (widget.title == '회원가입')
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              )
            : Navigator.pop(context); // null 반환 (기본 이미지 사용)
      } else {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: "이미지 선택이 취소되었습니다",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xAA000000),
          textColor: Colors.white,
          fontSize: 16.0.sp,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "이미지 업로드 실패: $e",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
      debugPrint('업로드 에러: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFFFF8E7);

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/bgs/background.png"),
          fit: BoxFit.cover,
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
              '프로필 사진 선택',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: Colors.teal.shade900,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 16.h),

            // 갤러리 선택 버튼 추가
            _buildGalleryButton(),
            SizedBox(height: 12.h),

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
                      height: 400.h,
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
              ],
            ),

            // ✅ 회원가입일 때만 건너뛰기 버튼 표시
            if (widget.title == '회원가입') ...[
              SizedBox(height: 16.h),
              _buildSkipButton(),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ 건너뛰기 버튼
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      ),
      child: Text(
        '건너뛰기',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isUploading ? null : _uploadFromGallery,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isUploading) ...[
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '업로드 중...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '갤러리에서 선택하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector clickProfile(String img) {
    return GestureDetector(
      onTap: () {
        _update(img);

        (widget.title == '회원가입')
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              )
            : Navigator.pop(context); // null 반환 (기본 이미지 사용)
      },
      child: Image.asset(img, width: 100.w, height: 100.h),
    );
  }
}
