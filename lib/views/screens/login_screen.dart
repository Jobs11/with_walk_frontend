import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/views/screens/mainhome_screen.dart';
import 'package:with_walk/views/screens/membership_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final current = ThemeManager().current;
  bool isLogin = false;

  final passwordController = TextEditingController();
  final idController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        msg: "아이디 혹은 패스워드가 틀렸습니다. ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
      debugPrint('why: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        colorbtn('로그인', current.btn, current.btnText, current.btn, 200, 36, () {
          setState(() {
            isLogin = true;
          });
        }),
        SizedBox(height: 10.h),
        colorbtn(
          '회원가입',
          current.bg,
          current.btn,
          current.btnBorder,
          200,
          36,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MembershipScreen(current: current),
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget yesLogin() {
    return Column(
      children: [
        inputdata("ID", idController, current, 200),
        SizedBox(height: 4.h),
        inputdata("PASSWORD", passwordController, current, 200),
        SizedBox(height: 12.h),
        colorbtn('로그인', current.btn, current.btnText, current.btn, 200, 36, () {
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
        }),
      ],
    );
  }
}
