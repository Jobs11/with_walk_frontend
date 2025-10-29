// lib/views/screens/friend_invite_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class FriendInviteScreen extends StatefulWidget {
  const FriendInviteScreen({super.key});

  @override
  State<FriendInviteScreen> createState() => _FriendInviteScreenState();
}

class _FriendInviteScreenState extends State<FriendInviteScreen> {
  final current = ThemeManager().current;

  // 더미 데이터
  final String myInviteCode = 'WALK2024XYZ';
  final List<Map<String, String>> invitedFriends = [
    {'name': '김철수', 'date': '2024.10.15'},
    {'name': '이영희', 'date': '2024.10.20'},
    {'name': '박민수', 'date': '2024.10.25'},
  ];

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: myInviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('초대 코드가 복사되었습니다!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: current.accent,
      ),
    );
  }

  void _shareInviteLink() {
    // TODO: Share 패키지 연동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('공유 기능은 준비 중입니다'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: current.fontSecondary,
      ),
    );
  }

  void _shareKakao() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('카카오톡 공유 준비 중'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.yellow[700],
      ),
    );
  }

  void _shareSMS() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('문자 메시지 공유 준비 중'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: current.bg,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "친구 초대",
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
                // 헤더 설명
                Text(
                  '친구를 초대하고 함께 걸어요!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '친구가 초대 코드로 가입하면 서로에게 보너스 포인트가 지급됩니다',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: current.fontSecondary,
                  ),
                ),
                SizedBox(height: 30.h),

                // 내 초대 코드 카드
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        current.accent,
                        current.accent.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: current.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '내 초대 코드',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        myInviteCode,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('복사'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: current.accent,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareInviteLink,
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('공유'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // 다른 방법으로 초대하기
                Text(
                  '다른 방법으로 초대하기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontPrimary,
                  ),
                ),
                SizedBox(height: 16.h),

                // 카카오톡 공유
                _buildInviteMethodCard(
                  icon: Icons.chat_bubble,
                  iconColor: Colors.yellow[700]!,
                  title: '카카오톡으로 초대',
                  subtitle: '카카오톡 메시지로 초대 링크 전송',
                  onTap: _shareKakao,
                ),

                SizedBox(height: 12.h),

                // 문자 메시지
                _buildInviteMethodCard(
                  icon: Icons.sms,
                  iconColor: Colors.green[600]!,
                  title: '문자 메시지로 초대',
                  subtitle: 'SMS로 초대 코드 전송',
                  onTap: _shareSMS,
                ),

                SizedBox(height: 12.h),

                // 링크 공유
                _buildInviteMethodCard(
                  icon: Icons.link,
                  iconColor: Colors.blue[600]!,
                  title: '링크 공유',
                  subtitle: '초대 링크를 다른 앱으로 공유',
                  onTap: _shareInviteLink,
                ),

                SizedBox(height: 30.h),

                // 초대한 친구 목록
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '초대한 친구',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: current.fontPrimary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: current.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${invitedFriends.length}명',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: current.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // 친구 목록
                if (invitedFriends.isEmpty)
                  Container(
                    padding: EdgeInsets.all(40.w),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 60.sp,
                          color: current.fontSecondary.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '아직 초대한 친구가 없어요',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: current.fontSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...invitedFriends.map(
                    (friend) => _buildFriendCard(
                      name: friend['name']!,
                      date: friend['date']!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviteMethodCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: current.fontSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: current.fontPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: current.fontSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: current.fontSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendCard({required String name, required String date}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: current.fontSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.w,
            backgroundColor: current.accent.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: current.accent, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: current.fontPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '가입일: $date',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: current.fontSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '가입완료',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
