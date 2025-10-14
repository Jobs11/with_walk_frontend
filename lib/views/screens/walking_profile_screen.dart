import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/dialogs/profile_change.dart';
import 'package:with_walk/views/screens/customer_center_screen.dart';
import 'package:with_walk/views/screens/login_screen.dart';
import 'package:with_walk/views/screens/membership_update_screen.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class WalkingProfileScreen extends StatefulWidget {
  const WalkingProfileScreen({super.key});

  @override
  State<WalkingProfileScreen> createState() => _WalkingProfileScreenState();
}

class _WalkingProfileScreenState extends State<WalkingProfileScreen> {
  late ThemeColors current;

  // 팔로우 정보
  int followerCount = 0;
  int followingCount = 0;

  // 간단한 통계
  int totalRecords = 0;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userId = CurrentUser.instance.member?.mId;
    if (userId == null) return;

    try {
      // 팔로우 정보 로드
      final followers = await FriendService.getFollowerCount(userId);
      final following = await FriendService.getFollowingCount(userId);

      // 운동 기록 로드
      final records = await StreetService.getStreetAllList(userId);
      final distance = records.fold(
        0.0,
        (sum, record) => sum + double.parse(record.rDistance.toString()),
      );

      if (mounted) {
        setState(() {
          followerCount = followers;
          followingCount = following;
          totalRecords = records.length;
          totalDistance = distance;
        });
      }
    } catch (e) {
      debugPrint('프로필 데이터 로드 실패: $e');
    }
  }

  // 상세 프로필 보기
  void _showDetailProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileBottomSheet(
        userId: CurrentUser.instance.member!.mId,
        userName: CurrentUser.instance.member!.mNickname,
        userImage: CurrentUser.instance.member!.mProfileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "발자국 주인공",
          isBack: false,
          isColored: current.app,
          fontColor: current.fontThird,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bgs/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // 프로필 이미지
                  GestureDetector(
                    onTap: () async {
                      final profileimage = await profileChange(
                        context,
                        title: '프로필수정',
                      );

                      if (profileimage != null) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: current.accent, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          CurrentUser.instance.member?.mProfileImage ??
                              'assets/images/icons/user.png',
                          fit: BoxFit.cover,
                          width: 100.w,
                          height: 100.h,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 이름
                  Text(
                    '${CurrentUser.instance.member?.mNickname ?? '손'}님',
                    style: TextStyle(
                      fontSize: 28.sp,
                      color: current.fontThird,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 팔로워/팔로잉 정보
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40.w),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: current.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: current.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('팔로워', followerCount),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey[300],
                        ),
                        _buildStatColumn('팔로잉', followingCount),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey[300],
                        ),
                        _buildStatColumn('운동', totalRecords),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 총 거리 정보
                  Text(
                    '총 ${totalDistance.toStringAsFixed(1)} km 걸었어요! 🚶',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontThird,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 버튼들
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // 상세 프로필 보기 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: ElevatedButton.icon(
                            onPressed: _showDetailProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: current.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(Icons.person, size: 20.sp),
                            label: Text(
                              '상세 프로필 보기',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // 프로필 수정 / 로그아웃
                        Row(
                          children: [
                            Expanded(
                              child: colorbtn(
                                "프로필 수정",
                                current.bg,
                                current.btn,
                                current.btn,
                                160,
                                36,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MembershipUpdateScreen(
                                            current: current,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: colorbtn(
                                "로그아웃",
                                current.btn,
                                current.bg,
                                current.bg,
                                160,
                                36,
                                () {
                                  openScreen(
                                    context,
                                    (context) => LoginScreen(),
                                  );
                                  CurrentUser.instance.member = null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 설정 메뉴들
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '고객지원',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('공지사항'),
                        SizedBox(height: 5.h),
                        GestureDetector(
                          onTap: () {
                            openScreen(
                              context,
                              (context) => CustomerCenterScreen(),
                            );
                          },
                          child: settingrow('고객센터'),
                        ),
                        SizedBox(height: 5.h),
                        settingrow('자주 묻는 질문(FAQ)'),
                        SizedBox(height: 5.h),
                        settingrow('문의하기 / 1:1 상담'),
                        SizedBox(height: 15.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '앱 정보',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('어플리케이션 정보'),
                        SizedBox(height: 5.h),
                        settingrow('버전 정보 & 업데이트 확인'),
                        SizedBox(height: 5.h),
                        settingrow('이용약관'),
                        SizedBox(height: 5.h),
                        settingrow('개인정보 처리방침'),
                        SizedBox(height: 15.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '기타',
                            style: TextStyle(
                              color: current.fontThird,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(color: current.fontThird),
                        ),
                        SizedBox(height: 10.h),
                        settingrow('테마 설정'),
                        SizedBox(height: 5.h),
                        settingrow('알림 설정'),
                        SizedBox(height: 5.h),
                        settingrow('언어 설정'),
                        SizedBox(height: 5.h),
                        settingrow('실험실'),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Row settingrow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: current.fontThird,
            fontWeight: FontWeight.bold,
          ),
        ),
        Image.asset(
          'assets/images/icons/setting_arrow.png',
          width: 15.w,
          height: 15.h,
        ),
      ],
    );
  }
}
