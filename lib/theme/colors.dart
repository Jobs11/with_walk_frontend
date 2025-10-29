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
  Color get hash;
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
  @override
  Color get hash => const Color(0xFF3C8C5A);
}

// 다크 테마 (개선됨)
class AppColorsDark implements ThemeColors {
  @override
  Color get bg => const Color(0xFF121212); // 💡 순수 다크 배경
  @override
  Color get fontPrimary => const Color(0xFFE8E8E8); // 부드러운 흰색
  @override
  Color get fontSecondary => const Color(0xFFAAAAAA);
  @override
  Color get fontThird => const Color(0xFF7A8080);
  @override
  Color get border => const Color(0xFF2A2A2A);
  @override
  Color get btn => const Color(0xFF66BB6A); // 🌿 밝은 그린 (다크 배경에서 잘 보임)
  @override
  Color get btnBorder => const Color(0xFF4CAF50);
  @override
  Color get btnText => const Color(0xFF000000); // 💡 다크 배경에서는 버튼 텍스트를 검정으로
  @override
  Color get accent => const Color(0xFF26A69A); // 💎 차분한 틸 (민트보다 안정적)
  @override
  Color get pathStart => const Color(0xFF66BB6A); // 시작: 밝은 그린
  @override
  Color get pathEnd => const Color(0xFF42A5F5); // 끝: 밝은 블루
  @override
  Color get app => const Color(0xFF1A1A1A); // 앱 전체 틀
  @override
  Color get hash => const Color(0xFFA5D6A7);
}

// 다크 소프트 테마 (3번째 테마 - 눈의 피로 최소화)
class AppColorsDarkSoft implements ThemeColors {
  @override
  Color get bg => const Color(0xFF1E1E1E); // 💡 약간 밝은 다크
  @override
  Color get fontPrimary => const Color(0xFFDCDCDC);
  @override
  Color get fontSecondary => const Color(0xFF9E9E9E);
  @override
  Color get fontThird => const Color(0xFF6B7575);
  @override
  Color get border => const Color(0xFF333333);
  @override
  Color get btn => const Color(0xFF81C784); // 🌱 소프트 그린
  @override
  Color get btnBorder => const Color(0xFF66BB6A);
  @override
  Color get btnText => const Color(0xFF000000);
  @override
  Color get accent => const Color(0xFF4DB6AC); // 🌊 소프트 틸
  @override
  Color get pathStart => const Color(0xFF81C784);
  @override
  Color get pathEnd => const Color(0xFF64B5F6);
  @override
  Color get app => const Color(0xFF242424);
  @override
  Color get hash => const Color(0xFFA5D6A7);
}

// Map으로 관리 (3가지 테마)
Map<String, ThemeColors> themeMap = {
  "라이트": AppColors(),
  "다크": AppColorsDark(),
  "다크 소프트": AppColorsDarkSoft(),
};
