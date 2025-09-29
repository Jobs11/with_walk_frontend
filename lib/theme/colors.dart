import 'package:flutter/material.dart';

// 공통 인터페이스
abstract class ThemeColors {
  Color get bg;
  Color get fontPrimary;
  Color get fontSecondary;
  Color get fontThird;
  Color get border;
  Color get btn;
  Color get btnBorder;
  Color get btnText;
  Color get accent;
  Color get pathStart;
  Color get pathEnd;
  Color get app;
}

// 라이트 테마
class AppColors implements ThemeColors {
  @override
  Color get bg => const Color(0xFFF9F9F9);
  @override
  Color get fontPrimary => const Color(0xFF212121);
  @override
  Color get fontSecondary => const Color(0xFF757575);
  @override
  Color get fontThird => const Color(0xFF465050);
  @override
  Color get border => const Color(0xFFDDDDDD);
  @override
  Color get btn => const Color(0xFF4CAF50);
  @override
  Color get btnBorder => const Color(0xFF388E3C);
  @override
  Color get btnText => const Color(0xFFFFFFFF);
  @override
  Color get accent => const Color(0xFF00C896);
  @override
  Color get pathStart => const Color(0xFF4CAF50);
  @override
  Color get pathEnd => const Color(0xFF2196F3);
  @override
  Color get app => const Color(0xFFeefaef);
}

// 다크 테마
class AppColorsDark implements ThemeColors {
  @override
  Color get bg => const Color(0xFF121212);
  @override
  Color get fontPrimary => const Color(0xFFE0E0E0);
  @override
  Color get fontSecondary => const Color(0xFF9E9E9E);
  @override
  Color get fontThird => const Color(0xFF465050);
  @override
  Color get border => const Color(0xFF333333);
  @override
  Color get btn => const Color(0xFF4CAF50);
  @override
  Color get btnBorder => const Color(0xFF2E7D32);
  @override
  Color get btnText => const Color(0xFFFFFFFF);
  @override
  Color get accent => const Color(0xFF00C896);
  @override
  Color get pathStart => const Color(0xFF81C784);
  @override
  Color get pathEnd => const Color(0xFF64B5F6);
  @override
  Color get app => const Color(0xFFeefaef);
}

// Map으로 관리
Map<String, ThemeColors> themeMap = {"라이트": AppColors(), "다크": AppColorsDark()};
