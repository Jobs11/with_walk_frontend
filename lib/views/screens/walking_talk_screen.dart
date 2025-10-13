// lib/views/screens/walking_talk_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:with_walk/api/model/post.dart';

import 'package:with_walk/api/service/post_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';

import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/widgets/create_post_bottom_sheet.dart';
import 'package:with_walk/views/widgets/post_card.dart';

class WalkingTalkScreen extends StatefulWidget {
  const WalkingTalkScreen({super.key});

  @override
  State<WalkingTalkScreen> createState() => _WalkingTalkScreenState();
}

class _WalkingTalkScreenState extends State<WalkingTalkScreen> {
  late ThemeColors current;
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = PostService.getPostFeeds();
    });
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
          RefreshIndicator(
            onRefresh: () async => _loadPosts(),
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                      final userId = CurrentUser.instance.member?.mId;
                      if (userId != null && posts[i].pNum != null) {
                        debugPrint('Like: ${posts[i].pNum!}, id: $userId');
                        await PostService.toggleLike(posts[i].pNum!, userId);

                        _loadPosts();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: current.accent,
        icon: Icon(Icons.add, color: current.bg),
        label: Text('게시글 작성', style: TextStyle(color: current.bg)),
      ),
    );
  }
}
