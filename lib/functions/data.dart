import 'package:with_walk/api/model/member.dart';

class Baseurl {
  static String b = "http://192.168.0.121:8888/withwalk/";
}

class NaverApi {
  // 여기에 본인 키 채우기
  static const naversearchclientid = 'jbGQ2odFNTIh8fzCRIHv';
  static const naversearchclientsecret = 'Y1IbxJ5xiK';
  static const ncpgeocodekeyid = 'o2vkzbaydr';
  static const ncpgeocodekey = 'mbcYPean5m0WhP2hJDV4c6mdqVdnzHDHYFySkRck';
}

class CurrentUser {
  // 1) 프로그램 전체에서 딱 1개만 존재하는 instance
  static final CurrentUser instance = CurrentUser._internal();

  // 2) private 생성자 → 외부에서 new 불가
  CurrentUser._internal();

  // 3) 여기에 로그인한 유저 정보를 담음
  Member? member;
}
