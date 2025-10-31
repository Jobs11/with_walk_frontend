// lib/views/screens/recommended_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/member.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/member_service.dart'; // 전체 회원 조회용
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/widgets/smart_profile_image.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class RecommendedUsersScreen extends StatefulWidget {
  const RecommendedUsersScreen({super.key});

  @override
  State<RecommendedUsersScreen> createState() => _RecommendedUsersScreenState();
}

class _RecommendedUsersScreenState extends State<RecommendedUsersScreen> {
  final current = ThemeManager().current;
  List<Member> _recommendedUsers = [];
  bool _isLoading = true;
  final Set<String> _followingUsers = {};

  @override
  void initState() {
    super.initState();
    _loadRecommendedUsers();
  }

  Future<void> _loadRecommendedUsers() async {
    setState(() => _isLoading = true);

    try {
      final userId = CurrentUser.instance.member!.mId;

      // 1. 내가 팔로우하는 사람들
      final followingIds = await FriendService.getFollowing(userId);

      // 2. 전체 회원 목록 (MemberService에 있다고 가정)
      final allMembers = await Memberservice.getAllMembers();

      // 3. 필터링: 나 자신 + 이미 팔로우한 사람 제외
      final recommended = allMembers.where((member) {
        return member.mId != userId && !followingIds.contains(member.mId);
      }).toList();

      setState(() {
        _recommendedUsers = recommended;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('추천 사용자 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow(String targetUserId, bool isFollowing) async {
    final userId = CurrentUser.instance.member!.mId;

    try {
      if (isFollowing) {
        await FriendService.unfollowUser(userId, targetUserId);
        setState(() {
          _followingUsers.remove(targetUserId);
        });
      } else {
        await FriendService.followUser(userId, targetUserId);
        setState(() {
          _followingUsers.add(targetUserId);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFollowing ? '팔로우를 취소했습니다' : '팔로우했습니다'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  void _showUserProfile(Member user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UserProfileBottomSheet(
        userId: user.mId,
        userImage: user.mProfileImage,
        userName: user.mName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 사용자'),
        centerTitle: true,
        backgroundColor: current.bg,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              "assets/images/bgs/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // 추천 사용자 리스트
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recommendedUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '추천할 사용자가 없습니다',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: current.fontPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecommendedUsers,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _recommendedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _recommendedUsers[index];
                      final isFollowing = _followingUsers.contains(user.mId);

                      return _buildUserCard(user, isFollowing);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Member user, bool isFollowing) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: () => _showUserProfile(user),
            child: ClipOval(
              child: SmartProfileImage(
                imageUrl: user.mProfileImage ?? 'assets/images/icons/user.png',
                width: 56.w, // radius * 2
                height: 56.h, // radius * 2
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 사용자 정보
          Expanded(
            child: GestureDetector(
              onTap: () => _showUserProfile(user),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임
                  Text(
                    user.mNickname,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: current.fontPrimary,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // 이름
                  Text(
                    user.mName,
                    style: TextStyle(fontSize: 14.sp, color: current.fontThird),
                  ),
                ],
              ),
            ),
          ),

          // 팔로우 버튼
          ElevatedButton(
            onPressed: () => _toggleFollow(user.mId, isFollowing),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey : current.accent,
              foregroundColor: current.bg,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
            ),
            child: Text(
              isFollowing ? '팔로잉' : '팔로우',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
