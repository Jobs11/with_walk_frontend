import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/dialogs/profile_change.dart';
import 'package:with_walk/views/screens/customer/faq_list_screen.dart';
import 'package:with_walk/views/screens/customer/inquiry_create_screen.dart';
import 'package:with_walk/views/screens/customer/notice_list_screen.dart';
import 'package:with_walk/views/screens/customer_center_screen.dart';
import 'package:with_walk/views/screens/login_screen.dart';
import 'package:with_walk/views/screens/membership_update_screen.dart';
import 'package:with_walk/views/widgets/follower_dialog.dart';
import 'package:with_walk/views/widgets/following_dialog.dart';
import 'package:with_walk/views/widgets/smart_profile_image.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class WalkingProfileScreen extends StatefulWidget {
  const WalkingProfileScreen({super.key});

  @override
  State<WalkingProfileScreen> createState() => _WalkingProfileScreenState();
}

class _WalkingProfileScreenState extends State<WalkingProfileScreen> {
  final current = ThemeManager().current;

  // 팔로우 정보
  int followerCount = 0;
  int followingCount = 0;

  // 간단한 통계
  int totalRecords = 0;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();

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
          current: current,
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
                        child: SmartProfileImage(
                          imageUrl:
                              CurrentUser.instance.member?.mProfileImage ??
                              'assets/images/icons/user.png',
                          width: 120.w,
                          height: 120.h,
                          fit: BoxFit.cover,
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
                        GestureDetector(
                          onTap: () {
                            showFollowerDialog(
                              context,
                              CurrentUser.instance.member!.mId,
                            );
                          },
                          child: _buildStatColumn('팔로워', followerCount),
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey[300],
                        ),
                        GestureDetector(
                          onTap: () {
                            showFollowingDialog(
                              context,
                              CurrentUser.instance.member!.mId,
                            );
                          },
                          child: _buildStatColumn('팔로잉', followingCount),
                        ),
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
                    '총 ${formatDistance(double.parse(totalDistance.toStringAsFixed(1)))} 걸었어요! 🚶',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontThird,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 버튼들
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      children: [
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

                  SizedBox(height: 24.h),

                  // ✅ 카드형 설정 메뉴들
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // 고객지원 섹션
                        _buildMenuSection(
                          title: '고객지원',
                          items: [
                            _MenuItemData(
                              icon: Icons.campaign_rounded,
                              title: '공지사항',
                              onTap: () {
                                openScreen(
                                  context,
                                  (context) => NoticeListScreen(),
                                );
                              },
                            ),
                            _MenuItemData(
                              icon: Icons.support_agent_rounded,
                              title: '고객센터',
                              onTap: () {
                                openScreen(
                                  context,
                                  (context) => CustomerCenterScreen(),
                                );
                              },
                            ),
                            _MenuItemData(
                              icon: Icons.help_outline_rounded,
                              title: '자주 묻는 질문(FAQ)',
                              onTap: () {
                                openScreen(
                                  context,
                                  (context) => FaqListScreen(),
                                );
                              },
                            ),
                            _MenuItemData(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: '문의하기 / 1:1 상담',
                              onTap: () {
                                openScreen(
                                  context,
                                  (context) => InquiryCreateScreen(),
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // 앱 정보 섹션
                        _buildMenuSection(
                          title: '앱 정보',
                          items: [
                            _MenuItemData(
                              icon: Icons.info_outline_rounded,
                              title: '어플리케이션 정보',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.system_update_rounded,
                              title: '버전 정보 & 업데이트 확인',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.description_outlined,
                              title: '이용약관',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.privacy_tip_outlined,
                              title: '개인정보 처리방침',
                              onTap: () {},
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // 기타 섹션
                        _buildMenuSection(
                          title: '기타',
                          items: [
                            _MenuItemData(
                              icon: Icons.palette_outlined,
                              title: '테마 설정',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.notifications_outlined,
                              title: '알림 설정',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.language_rounded,
                              title: '언어 설정',
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.science_outlined,
                              title: '실험실',
                              onTap: () {},
                            ),
                          ],
                        ),

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

  // ✅ 메뉴 섹션 빌더
  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Text(
              title,
              style: TextStyle(
                color: current.fontThird,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 구분선
          Divider(height: 1, color: Colors.grey[300]),

          // 메뉴 아이템들
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                _buildMenuItem(
                  icon: item.icon,
                  title: item.title,
                  onTap: item.onTap,
                ),
                if (!isLast)
                  Divider(height: 1, indent: 60.w, color: Colors.grey[200]),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ✅ 메뉴 아이템 빌더
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: current.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 22.sp, color: current.accent),
              ),

              SizedBox(width: 16.w),

              // 제목
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: current.fontThird,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right_rounded,
                size: 24.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
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
}

// ✅ 메뉴 아이템 데이터 클래스
class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItemData({required this.icon, required this.title, required this.onTap});
}
