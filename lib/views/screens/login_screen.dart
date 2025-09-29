import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/service/memberservice.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/mainhome_screen.dart';
import 'package:with_walk/views/screens/membership_screen.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ThemeColors current;
  bool isLogin = false;

  final passwordController = TextEditingController();
  final idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  Future<void> _login() async {
    final id = idController.text.trim();
    final password = passwordController.text.trim();

    try {
      final member = await Memberservice.login(id, password); // GET 요청

      // 로그인 성공 시 전역 상태나 Provider 등에 저장
      CurrentUser.instance.member = member;

      Fluttertoast.showToast(
        msg: "로그인 성공! ${member.mNickname}님 환영합니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );

      // 메인 페이지 이동
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainhomeScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "로그인 실패! $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "With Walk",
                    style: TextStyle(
                      fontSize: 48.sp,
                      color: current.fontThird,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "걸음을 기록하고, 함께 나누자",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontThird,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  SizedBox(height: 60.h),
                  (isLogin) ? yesLogin() : notLogin(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget notLogin() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isLogin = true;
            });
          },
          child: colorbtn('로그인', current.btn, current.btnText, current.btn),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MembershipScreen(current: current),
              ),
            );
          },
          child: colorbtn('회원가입', current.bg, current.btn, current.btnBorder),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget yesLogin() {
    return Column(
      children: [
        inputdata("ID", idController),
        SizedBox(height: 4.h),
        inputdata("PASSWORD", passwordController),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () {
            if (idController.text.isEmpty && passwordController.text.isEmpty) {
              Fluttertoast.showToast(
                msg: "처음 화면으로 돌아갑니다.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: const Color(0xAA000000),
                textColor: Colors.white,
                fontSize: 16.0.sp,
              );
              setState(() {
                isLogin = false;
              });
            } else if (idController.text.isNotEmpty &&
                passwordController.text.isNotEmpty) {
              _login();
            }
          },
          child: colorbtn('로그인', current.btn, current.btnText, current.btn),
        ),
      ],
    );
  }

  Widget colorbtn(
    String title,
    Color btncolor,
    Color fontcolor,
    Color borcolor,
  ) {
    return Container(
      width: 200.w,
      height: 36.h,
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
    );
  }

  Widget inputdata(String title, TextEditingController controller) {
    return Container(
      width: 200.w,
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: current.bg,
        border: Border.all(color: current.accent),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none, // 테두리 제거 (BoxDecoration에서 그림)
          hintText: title, // 플레이스홀더
          hintStyle: TextStyle(
            color: current.fontPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '값을 입력해주세요.';
          }
          return null; // 검증 통과
        },
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}
