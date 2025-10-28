import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/widgets/follower_dialog.dart';
import 'package:with_walk/views/widgets/following_dialog.dart';
import 'package:with_walk/views/widgets/smart_profile_image.dart';

class UserProfileBottomSheet extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userImage;

  const UserProfileBottomSheet({
    super.key,
    required this.userId,
    this.userName,
    this.userImage,
  });

  @override
  State<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> {
  late Future<List<Street>> _recordsFuture;

  // 통계 계산용 변수
  int totalRecords = 0;
  double totalDistance = 0.0;
  int totalTime = 0;
  double totalCalories = 0.0;

  // 팔로우 관련 변수
  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  bool isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _recordsFuture = StreetService.getStreetAllList(widget.userId);
    _loadStatistics();
    _loadFollowInfo();
  }

  Future<void> _loadStatistics() async {
    try {
      final records = await StreetService.getStreetAllList(widget.userId);

      if (mounted) {
        setState(() {
          totalRecords = records.length;
          totalDistance = records.fold(
            0.0,
            (sum, record) => sum + double.parse(record.rDistance.toString()),
          );
          totalTime = records.fold(
            0,
            (sum, record) => sum + int.parse(record.rTime),
          );
          totalCalories = records.fold(
            0.0,
            (sum, record) => sum + double.parse(record.rKcal.toString()),
          );
        });
      }
    } catch (e) {
      debugPrint('통계 로드 실패: $e');
    }
  }

  Future<void> _loadFollowInfo() async {
    try {
      final currentUserId = CurrentUser.instance.member?.mId;

      final followersCnt = await FriendService.getFollowerCount(
        widget.userId,
      ); // int
      final followingCnt = await FriendService.getFollowingCount(
        widget.userId,
      ); // int

      bool followStatus = false; // bool
      if (currentUserId != null && currentUserId != widget.userId) {
        followStatus = await FriendService.isFollowing(
          currentUserId,
          widget.userId,
        );
      }

      setState(() {
        followerCount = followersCnt; // int = int ✅
        followingCount = followingCnt; // int = int ✅
        isFollowing = followStatus; // bool = bool ✅
      });
    } catch (e) {
      debugPrint('팔로우 정보 로드 실패: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = CurrentUser.instance.member?.mId;
    if (currentUserId == null) return;

    setState(() => isLoadingFollow = true);

    try {
      if (isFollowing) {
        await FriendService.unfollowUser(currentUserId, widget.userId);
        if (mounted) {
          setState(() {
            isFollowing = false;
            followerCount--;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('팔로우를 취소했습니다')));
        }
      } else {
        await FriendService.followUser(currentUserId, widget.userId);
        if (mounted) {
          setState(() {
            isFollowing = true;
            followerCount++;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('팔로우했습니다')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingFollow = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ThemeManager().current;
    final isMyProfile = widget.userId == CurrentUser.instance.member?.mId;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMyProfile ? '내 프로필' : '사용자 프로필',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontThird,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // 프로필 이미지
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: current.accent, width: 3),
                    ),
                    child: ClipOval(
                      child: SmartProfileImage(
                        imageUrl:
                            widget.userImage ?? 'assets/images/icons/user.png',
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 사용자 이름
                  Text(
                    widget.userName ?? widget.userId,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: current.fontThird,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // 사용자 ID
                  Text(
                    '@${widget.userId}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 16.h),

                  // 팔로워/팔로잉 통계
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showFollowerDialog(context, widget.userId);
                        },
                        child: _buildFollowStat('팔로워', followerCount),
                      ),
                      SizedBox(width: 32.w),
                      GestureDetector(
                        onTap: () {
                          showFollowingDialog(context, widget.userId);
                        },
                        child: _buildFollowStat('팔로잉', followingCount),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // 팔로우 버튼 (다른 사람 프로필일 때만)
                  if (!isMyProfile)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: isLoadingFollow ? null : _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.grey[300]
                                : current.accent,
                            foregroundColor: isFollowing
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                          ),
                          child: isLoadingFollow
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isFollowing ? '팔로잉' : '팔로우',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // 통계 카드
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: current.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: current.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '운동 통계',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: current.fontThird,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.directions_walk,
                              label: '총 운동',
                              value: '$totalRecords회',
                              current: current,
                            ),
                            _buildStatItem(
                              icon: Icons.straighten,
                              label: '총 거리',
                              value: formatDistance(
                                double.parse(totalDistance.toStringAsFixed(1)),
                              ),
                              current: current,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.timer,
                              label: '총 시간',
                              value: formatTime(totalTime),
                              current: current,
                            ),
                            _buildStatItem(
                              icon: Icons.local_fire_department,
                              label: '총 칼로리',
                              value: '${totalCalories.toStringAsFixed(0)} kcal',
                              current: current,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 최근 운동 기록
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          '최근 운동 기록',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: current.fontThird,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 운동 기록 리스트
                  FutureBuilder<List<Street>>(
                    future: _recordsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: EdgeInsets.all(32.h),
                          child: Text(
                            '운동 기록을 불러올 수 없습니다',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final records = snapshot.data ?? [];

                      if (records.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(32.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_walk_outlined,
                                size: 48.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                '아직 운동 기록이 없습니다',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 최근 5개만 표시
                      final recentRecords = records.take(5).toList();

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: recentRecords.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final record = recentRecords[index];
                          return _buildRecordCard(record, current);
                        },
                      );
                    },
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStat(String label, int count) {
    final current = ThemeManager().current;
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeColors current,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32.sp, color: current.accent),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(Street record, ThemeColors current) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                DateFormat(
                  'yyyy.MM.dd',
                ).format(DateTime.parse(record.rDate.toString())),
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRecordStat('거리', formatDistance(record.rDistance)),
              _buildRecordStat('시간', formatTime(int.parse(record.rTime))),
              _buildRecordStat('칼로리', '${record.rKcal} kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
