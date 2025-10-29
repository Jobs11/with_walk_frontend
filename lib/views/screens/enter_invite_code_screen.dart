// lib/views/screens/enter_invite_code_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';

import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/screens/login_screen.dart';

class EnterInviteCodeScreen extends StatefulWidget {
  const EnterInviteCodeScreen({super.key});

  @override
  State<EnterInviteCodeScreen> createState() => _EnterInviteCodeScreenState();
}

class _EnterInviteCodeScreenState extends State<EnterInviteCodeScreen> {
  final current = ThemeManager().current;

  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // 초대 코드 검증 및 적용
  Future<void> _applyInviteCode() async {
    final code = _codeController.text.trim().toUpperCase();

    // 입력 검증
    if (code.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        Navigator.of(context).pop(); // 화면 닫기
        openScreen(context, (context) => LoginScreen());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('초대 코드는 발자국 주인공 화면에서 등록하실 수 있습니다.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green[600],
          ),
        );
      });
      return;
    }

    if (code.length < 6) {
      setState(() {
        _errorMessage = '초대 코드는 최소 6자 이상이어야 합니다';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 백엔드 API 호출
      // final result = await FriendService.applyInviteCode(code);

      // 임시 시뮬레이션 (2초 대기)
      await Future.delayed(const Duration(seconds: 2));

      // 임시: 특정 코드만 성공으로 처리
      if (code == 'WALK2024XYZ' || code == 'TEST1234') {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          Navigator.of(context).pop(); // 화면 닫기
          openScreen(context, (context) => LoginScreen());
        });

        // 성공 다이얼로그 표시
        _showSuccessDialog();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '유효하지 않은 초대 코드입니다';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  // 성공 다이얼로그
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 80.sp),
            SizedBox(height: 20.h),
            Text(
              '초대 코드 적용 완료!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: current.fontPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '보너스 포인트가 지급되었습니다',
              style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 화면 닫기
                  openScreen(context, (context) => LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: current.accent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 클립보드에서 붙여넣기
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _codeController.text = clipboardData.text!.trim().toUpperCase();
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: current.bg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "초대 코드 입력",
          isBack: true,
          current: current,
          isAdmin: false,
          onMenuPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),

              // 아이콘
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: current.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    size: 50.sp,
                    color: current.accent,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // 안내 문구
              Text(
                '친구의 초대 코드를 입력하세요',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: current.fontPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                '초대 코드를 입력하면 서로에게\n보너스 포인트가 지급됩니다',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: current.fontSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // 초대 코드 입력란
              Container(
                decoration: BoxDecoration(
                  color: current.bg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _errorMessage != null
                        ? Colors.red
                        : current.fontSecondary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: current.fontPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(20),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) => TextEditingValue(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      ),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: '초대 코드 입력',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontSecondary.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    suffixIcon: _codeController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: current.fontSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _codeController.clear();
                                _errorMessage = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
              ),

              // 에러 메시지
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16.sp, color: Colors.red),
                      SizedBox(width: 6.w),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 13.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              // 붙여넣기 버튼
              TextButton.icon(
                onPressed: _pasteFromClipboard,
                icon: Icon(
                  Icons.content_paste,
                  size: 18.sp,
                  color: current.accent,
                ),
                label: Text(
                  '클립보드에서 붙여넣기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: current.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // 적용 버튼
              SizedBox(
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading || _isSuccess ? null : _applyInviteCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.accent,
                    disabledBackgroundColor: current.fontSecondary.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          '초대 코드 적용하기',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 30.h),

              // 추가 안내
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: current.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: current.accent,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '초대 코드 입력 시 주의사항',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: current.fontPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '• 초대 코드는 1회만 입력 가능합니다\n'
                            '• 자신의 초대 코드는 입력할 수 없습니다\n'
                            '• 보너스 포인트는 즉시 지급됩니다',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: current.fontSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
