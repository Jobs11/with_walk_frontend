import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 인스턴스 생성 후 init() 호출
  await FlutterNaverMap().init(
    clientId: 'o2vkzbaydr', // NCP 콘솔 → Mobile Dynamic Map Client ID
    onAuthFailed: (e) {
      debugPrint("네이버 지도 인증 실패: $e");
    },
  );

  // ✅ Firebase 초기화
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 세로 모드만 허용
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 세로 위
    DeviceOrientation.portraitDown, // 세로 아래
  ]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 780),
      child: MaterialApp(home: LoginScreen()),
    );
  }
}
