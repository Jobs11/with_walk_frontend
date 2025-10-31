import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/challenge.dart';
import 'package:with_walk/api/model/challenge_participant.dart';
import 'package:with_walk/api/model/ranking_user.dart';
import 'package:with_walk/api/service/challenge_service.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/screens/admin/create_challenge_screen.dart';
import 'package:with_walk/views/screens/admin/edit_challenge_screen.dart';
import 'package:with_walk/views/screens/friend_invite_screen.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class WalkingEventScreen extends StatefulWidget {
  const WalkingEventScreen({super.key});

  @override
  State<WalkingEventScreen> createState() => _WalkingEventScreenState();
}

class _WalkingEventScreenState extends State<WalkingEventScreen>
    with SingleTickerProviderStateMixin {
  final current = ThemeManager().current;
  late TabController _tabController;

  late Future<List<Challenge>> _activeChallengesFuture;
  late Future<List<ChallengeParticipant>> _myCompletedChallengesFuture;
  late Future<List<RankingUser>> _rankingFuture;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    isAdmin = CurrentUser.instance.member?.mRole == 'ADMIN';
    _loadData();
  }

  void _loadData() {
    final userId = CurrentUser.instance.member?.mId ?? '';
    setState(() {
      _activeChallengesFuture = ChallengeService.getActiveChallenges(userId);
      _myCompletedChallengesFuture = ChallengeService.getMyCompletedChallenges(
        userId,
      );
      _rankingFuture = StreetService.getTop3();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showUserProfile(BuildContext context, String userId) async {
    final user = await Memberservice.userdata(userId);

    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileBottomSheet(
        userId: userId,
        userName: user.mName,
        userImage: user.mProfileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "도전의 발자국",
            isBack: false,
            current: current,
            isAdmin: isAdmin, // ✅ 관리자 여부 전달
            onMenuPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateChallengeScreen(),
                ),
              );

              if (result == true) {
                _loadData();
              }
            },
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
            Column(
              children: [
                // 탭 바
                Container(
                  margin: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: current.bg.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: current.accent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab, // 👈 이거 추가!
                    labelColor: current.bg,
                    unselectedLabelColor: current.fontPrimary,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: '진행중인 도전'),
                      Tab(text: '내 도전 기록'),
                    ],
                  ),
                ),

                // 탭 뷰
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildActiveChallenges(), _buildMyChallenges()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 진행중인 도전
  Widget _buildActiveChallenges() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: FutureBuilder<List<Challenge>>(
        future: _activeChallengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    '챌린지를 불러올 수 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final challenges = snapshot.data ?? [];

          if (challenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '진행중인 챌린지가 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: challenges.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildTop3RankingCard(),
                );
              }
              final challenge = challenges[index - 1];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildChallengeCard(challenge),
              );
            },
          );
        },
      ),
    );
  }

  // 내 도전 기록
  Widget _buildMyChallenges() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: FutureBuilder<List<ChallengeParticipant>>(
        future: _myCompletedChallengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    '완료 기록을 불러올 수 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final completedChallenges = snapshot.data ?? [];

          if (completedChallenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '완료한 챌린지가 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: current.fontPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '챌린지에 참가하고 목표를 달성해보세요!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: current.fontSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: completedChallenges.length,
            itemBuilder: (context, index) {
              final participant = completedChallenges[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildCompletedChallengeCard(participant),
              );
            },
          );
        },
      ),
    );
  }

  // 챌린지 카드
  Widget _buildChallengeCard(Challenge challenge) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg.withValues(alpha: 0.95),
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
          // 제목 & 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.cTitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: current.fontPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      challenge.cDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: current.fontSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ 관리자: 수정/삭제 버튼
              if (isAdmin) ...[
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.sp, color: Colors.blue),
                      onPressed: () => _editChallenge(challenge),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20.sp, color: Colors.red),
                      onPressed: () => _deleteChallenge(challenge),
                    ),
                  ],
                ),
              ]
              // ✅ 일반 사용자: 참가하기 버튼
              else if (!challenge.isJoined) ...[
                ElevatedButton(
                  onPressed: () => _joinChallenge(challenge.cNum),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.accent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    '참가하기',
                    style: TextStyle(fontSize: 12.sp, color: current.bg),
                  ),
                ),
              ],
            ],
          ),

          if (challenge.isJoined && !isAdmin) ...[
            SizedBox(height: 16.h),
            // 진행률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.currentValue}${challenge.cUnit}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: current.accent,
                  ),
                ),
                Text(
                  '${challenge.cTargetValue}${challenge.cUnit}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: current.fontSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(current.accent),
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ],

          SizedBox(height: 12.h),
          // 정보
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16.sp, color: current.fontThird),
              SizedBox(width: 4.w),
              Text(
                'D-${challenge.daysLeft}',
                style: TextStyle(fontSize: 12.sp, color: current.fontThird),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.people_outline, size: 16.sp, color: current.fontThird),
              SizedBox(width: 4.w),
              Text(
                '${challenge.participantCount}명 참여중',
                style: TextStyle(fontSize: 12.sp, color: current.fontThird),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // 보상
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: current.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '보상: ${challenge.cReward}',
              style: TextStyle(
                fontSize: 12.sp,
                color: current.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 완료된 챌린지 카드 (기존 코드 유지)
  Widget _buildCompletedChallengeCard(ChallengeParticipant participant) {
    final completedDate = participant.cpCompletedDate != null
        ? '${participant.cpCompletedDate!.year}.${participant.cpCompletedDate!.month.toString().padLeft(2, '0')}.${participant.cpCompletedDate!.day.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.cReward ?? '🏆',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.cTitle ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '완료: $completedDate',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: current.fontSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              participant.cpStatus == '완료' ? '달성' : participant.cpStatus,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 챌린지 수정
  Future<void> _editChallenge(Challenge challenge) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditChallengeScreen(challenge: challenge),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  // ✅ 챌린지 삭제
  Future<void> _deleteChallenge(Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('챌린지 삭제'),
        content: Text('${challenge.cTitle}을(를) 삭제하시겠습니까?\n참가자 데이터도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ChallengeService.deleteChallenge(challenge.cNum);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지가 삭제되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지 삭제에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 챌린지 참가
  Future<void> _joinChallenge(int cNum) async {
    final userId = CurrentUser.instance.member?.mId;
    if (userId == null) return;

    try {
      final success = await ChallengeService.joinChallenge(cNum, userId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지 참가 완료!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('이미 참가중인 챌린지입니다'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('참가 실패: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ TOP 3 랭킹 카드 (실제 데이터)
  Widget _buildTop3RankingCard() {
    return FutureBuilder<List<RankingUser>>(
      future: _rankingFuture,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: current.bg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // 에러 발생
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: current.bg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                '랭킹을 불러올 수 없습니다',
                style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
              ),
            ),
          );
        }

        final rankings = snapshot.data ?? [];

        // 데이터가 없을 때
        if (rankings.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: current.bg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                '이번 주 기록이 없습니다',
                style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
              ),
            ),
          );
        }

        // 랭킹 데이터 표시
        final emojis = ['🥇', '🥈', '🥉'];

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                current.accent.withValues(alpha: 0.15),
                current.accent.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: current.accent.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: current.accent.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: current.accent,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '이번 주 TOP 3',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: current.fontPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: current.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '실시간',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: current.accent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // 랭킹 리스트
              ...rankings.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                final isFirst = index == 0;
                final emoji = index < emojis.length ? emojis[index] : '🏅';

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: GestureDetector(
                    onTap: () {
                      _showUserProfile(context, user.mName);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? current.accent.withValues(alpha: 0.1)
                            : current.bg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16.r),
                        border: isFirst
                            ? Border.all(
                                color: current.accent.withValues(alpha: 0.3),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          // 메달
                          Text(emoji, style: TextStyle(fontSize: 32.sp)),
                          SizedBox(width: 16.w),

                          // 이름
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.mName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: current.fontPrimary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${user.rank}위',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: current.fontSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 거리
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatDistance(
                                  double.parse(
                                    user.totalDistance.toStringAsFixed(1),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: current.accent,
                                ),
                              ),
                              Text(
                                '이번 주',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: current.fontThird,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // 👇 친구 초대 배너 추가
              SizedBox(height: 8.h),
              _buildInviteBanner(),
            ],
          ),
        );
      },
    );
  }

  // 👇 친구 초대 배너 위젯
  Widget _buildInviteBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendInviteScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              current.accent.withValues(alpha: 0.8),
              current.accent.withValues(alpha: 0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: current.accent.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '친구 초대하고 함께 도전하기!',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '초대하면 서로 보너스 포인트 지급',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
