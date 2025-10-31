import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/api/service/post_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/screens/recommended_users_screen.dart'; // 👈 추가
import 'package:with_walk/views/widgets/create_post_bottom_sheet.dart';
import 'package:with_walk/views/widgets/post_card.dart';

class WalkingTalkScreen extends StatefulWidget {
  const WalkingTalkScreen({super.key});

  @override
  State<WalkingTalkScreen> createState() => _WalkingTalkScreenState();
}

class _WalkingTalkScreenState extends State<WalkingTalkScreen> {
  final current = ThemeManager().current;
  late Future<List<Post>> _postsFuture;
  int _selectedTabIndex = 0; // 0: 전체, 1: 인기, 2: 친구, 3: 추천

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    // 추천 탭이 아닐 때만 피드 로드
    if (_selectedTabIndex != 3) {
      setState(() {
        switch (_selectedTabIndex) {
          case 0: // 전체
            _postsFuture = PostService.getPostFeeds(
              userId: CurrentUser.instance.member!.mId,
            );
            break;
          case 1: // 인기
            _postsFuture = PostService.getPopularPostFeeds(
              userId: CurrentUser.instance.member!.mId,
            );
            break;
          case 2: // 친구
            _postsFuture = PostService.getPostFeeds(
              userId: CurrentUser.instance.member!.mId,
              style: 'friends',
            );
            break;
        }
      });
    }
  }

  Future<void> _showCreatePostDialog() async {
    final userId = CurrentUser.instance.member!.mId;

    // 사용자의 운동 기록 불러오기
    final records = await StreetService.getStreetAllList(userId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreatePostBottomSheet(
        userId: userId,
        records: records,
        onPostCreated: _loadPosts,
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
          titlename: "길건너 친구들",
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
          Column(
            children: [
              // 탭 버튼 영역
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                child: Row(
                  children: [
                    _buildTabButton('전체', 0),
                    _buildTabButton('인기', 1),
                    _buildTabButton('친구', 2),
                    _buildTabButton('추천', 3), // 👈 추가
                  ],
                ),
              ),

              // 피드 영역 or 추천 사용자 화면
              Expanded(
                child: _selectedTabIndex == 3
                    ? const RecommendedUsersScreen() // 👈 추천 탭일 때
                    : RefreshIndicator(
                        onRefresh: () async => _loadPosts(),
                        child: FutureBuilder<List<Post>>(
                          future: _postsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '피드를 불러올 수 없습니다',
                                  style: TextStyle(color: current.fontPrimary),
                                ),
                              );
                            }

                            final posts = snapshot.data ?? [];

                            if (posts.isEmpty) {
                              return Center(
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
                                      '첫 게시글을 작성해보세요!',
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
                              padding: EdgeInsets.all(16.w),
                              itemCount: posts.length,
                              itemBuilder: (ctx, i) => PostCard(
                                post: posts[i],
                                onLike: () async {
                                  final userId =
                                      CurrentUser.instance.member?.mId;
                                  if (userId != null && posts[i].pNum != null) {
                                    debugPrint(
                                      'Like: ${posts[i].pNum!}, id: $userId',
                                    );
                                    await PostService.toggleLike(
                                      posts[i].pNum!,
                                      userId,
                                    );
                                    _loadPosts();
                                  }
                                },
                                onCommentChanged: _loadPosts,
                                onPostDeleted: _loadPosts,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          _selectedTabIndex ==
              3 // 👈 추천 탭에선 숨김
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCreatePostDialog,
              backgroundColor: current.accent,
              icon: Icon(Icons.add, color: current.bg),
              label: Text('게시글 작성', style: TextStyle(color: current.bg)),
            ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _loadPosts();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? current.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? current.bg : current.fontPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
