import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/views/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final current = ThemeManager().current;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 페이드 인 애니메이션
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // 스케일 애니메이션 (살짝 커지는 효과)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // 애니메이션 시작
    _animationController.forward();

    // 3초 후 로그인 화면으로 이동
    Timer(const Duration(seconds: 5), () {
      openScreen(context, (context) => LoginScreen());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6db891), // 배경색 (로고 배경과 동일)
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 이미지
                    Image.asset(
                      'assets/images/icons/withwalk_intro.png',
                      width: 200.w,
                      height: 200.h,
                    ),
                    const SizedBox(height: 20),

                    // 로딩 인디케이터 (선택사항)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(current.bg),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
