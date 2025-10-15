import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/api/model/post_comment.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/api/service/post_comment_service.dart';
import 'package:with_walk/api/service/post_service.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/widgets/comment_bottom_sheet.dart';
import 'package:with_walk/views/widgets/edit_post_bottom_sheet.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback? onCommentChanged;
  final VoidCallback? onPostDeleted;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onCommentChanged,
    this.onPostDeleted,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  List<PostComment> _previewComments = [];
  bool _isLoadingComments = false;
  Street? _streetRecord;

  @override
  void initState() {
    super.initState();
    // 댓글이 있으면 미리보기 로드
    if (widget.post.commentCount > 0) {
      _loadPreviewComments();
    }
  }

  // 운동 기록 로드
  Future<Street?> _loadStreetRecord() async {
    if (_streetRecord != null) return _streetRecord;

    if (widget.post.rNum == null) return null;

    try {
      final allRecords = await StreetService.getStreetAllList(widget.post.mId);

      // rNum으로 해당 운동 기록 찾기
      _streetRecord = allRecords.firstWhere(
        (record) => record.rNum.toString() == widget.post.rNum,
        orElse: () => throw Exception('Record not found'),
      );

      return _streetRecord;
    } catch (e) {
      debugPrint('운동 기록 로드 실패: $e');
      return null;
    }
  }

  Future<void> _loadPreviewComments() async {
    if (_isLoadingComments) return;

    setState(() => _isLoadingComments = true);

    try {
      final comments = await PostCommentService.getCommentList(
        widget.post.pNum!,
      );
      if (mounted) {
        setState(() {
          // 최신 3개만 미리보기
          _previewComments = comments.take(3).toList();
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  void _showAllComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommentBottomSheet(
        pNum: widget.post.pNum!,
        onCommentChanged: () {
          widget.onCommentChanged?.call();
          _loadPreviewComments(); // 미리보기도 새로고침
        },
      ),
    );
  }

  // 게시글 작성자 프로필 표시
  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileBottomSheet(
        userId: widget.post.mId,
        userName: widget.post.authorName,
        userImage: widget.post.authorImage,
      ),
    );
  }

  // 댓글 작성자 프로필 표시
  void _showCommentUserProfile(BuildContext context, PostComment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileBottomSheet(
        userId: comment.mId,
        userName: comment.authorName,
        userImage: comment.authorImage,
      ),
    );
  }

  // 게시글 옵션 메뉴 표시
  void _showPostOptions(BuildContext context) {
    final current = themeMap["라이트"]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // 수정 버튼
              ListTile(
                leading: Icon(Icons.edit, color: current.fontThird),
                title: Text(
                  '게시글 수정',
                  style: TextStyle(fontSize: 16.sp, color: current.fontThird),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditPost(context);
                },
              ),

              Divider(height: 1, color: Colors.grey[300]),

              // 삭제 버튼
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  '게시글 삭제',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context);
                },
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  // 게시글 수정
  void _showEditPost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditPostBottomSheet(
        post: widget.post,
        onPostUpdated: () {
          widget.onCommentChanged?.call(); // 게시글 목록 새로고침
        },
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePost();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 태그된 사용자 프로필 표시
  Future<void> _showTaggedUserProfile(
    BuildContext context,
    String nickname,
  ) async {
    try {
      // 닉네임으로 사용자 정보 조회 (MemberService에 메서드 필요)
      final member = await Memberservice.checkNick(nickname);

      if (!mounted) return;

      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => UserProfileBottomSheet(
          userId: member.mId,
          userName: member.mNickname,
          userImage: member.mProfileImage,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('사용자 정보를 불러올 수 없습니다')));
      debugPrint('프로필 로드 실패: $e');
    }
  }

  // 게시글 삭제 실행
  Future<void> _deletePost() async {
    try {
      await PostService.deletePost(widget.post.pNum!);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다')));

      widget.onPostDeleted?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = themeMap["라이트"]!;
    final commentCount = widget.post.commentCount;
    final isMyPost = widget.post.mId == CurrentUser.instance.member?.mId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보 + 옵션 버튼
          Row(
            children: [
              GestureDetector(
                onTap: () => _showUserProfile(context),
                child: Image.asset(
                  widget.post.authorImage ?? 'assets/images/icons/user.png',
                  width: 40.w,
                  height: 40.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName ?? widget.post.mId,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: current.fontThird,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'yyyy.MM.dd HH:mm',
                      ).format(DateTime.parse(widget.post.pDate)),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // 내 게시글일 때만 옵션 버튼 표시
              if (isMyPost)
                IconButton(
                  onPressed: () => _showPostOptions(context),
                  icon: Icon(
                    Icons.more_vert,
                    color: current.fontPrimary,
                    size: 24.sp,
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // 게시글 내용
          _buildContentWithTags(widget.post.pContent, current),

          // 운동 기록 정보 (r_num이 있을 때)
          if (widget.post.rNum != null) ...[
            SizedBox(height: 12.h),
            FutureBuilder<Street?>(
              future: _loadStreetRecord(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final record = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: current.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: current.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _recordStatItem(
                          icon: Icons.straighten,
                          label: '거리',
                          value: '${record.rDistance} km',
                          current: current,
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey[300],
                        ),
                        _recordStatItem(
                          icon: Icons.timer,
                          label: '시간',
                          value: formatTime(int.parse(record.rTime)),
                          current: current,
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: Colors.grey[300],
                        ),
                        _recordStatItem(
                          icon: Icons.local_fire_department,
                          label: '칼로리',
                          value: '${record.rKcal} kcal',
                          current: current,
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox.shrink();
              },
            ),
          ],

          // 이미지
          if (widget.post.pImage != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                widget.post.pImage!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200.h,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // 좋아요 & 댓글 버튼
          Row(
            children: [
              // 좋아요 버튼
              GestureDetector(
                onTap: widget.onLike,
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 20.sp, color: current.accent),
                    SizedBox(width: 4.w),
                    Text(
                      '${widget.post.pLikes}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: current.fontThird,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 24.w),

              // 댓글 버튼
              GestureDetector(
                onTap: () => _showAllComments(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 20.sp,
                      color: current.fontPrimary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$commentCount',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: current.fontThird,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 댓글 미리보기 영역
          if (commentCount > 0) ...[
            SizedBox(height: 12.h),

            // 로딩 중
            if (_isLoadingComments)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            // 댓글 미리보기 (최대 3개)
            else if (_previewComments.isNotEmpty) ...[
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 8.h),

              // 댓글 리스트
              ..._previewComments.map(
                (comment) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 작은 프로필 이미지
                      GestureDetector(
                        onTap: () => _showCommentUserProfile(context, comment),
                        child: Image.asset(
                          comment.authorImage ?? 'assets/images/icons/user.png',
                          width: 24.w,
                          height: 24.h,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 댓글 내용
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.authorName ?? comment.mId,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: current.fontThird,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _getTimeAgo(comment.pcDate),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            _buildCommentPreviewWithTags(
                              comment.pcContent,
                              current,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "댓글 n개 모두 보기" 버튼
              if (commentCount > 3)
                GestureDetector(
                  onTap: () => _showAllComments(context),
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '댓글 $commentCount개 모두 보기',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  // 게시글 내용에서 @닉네임 태그를 감지하고 스타일링
  Widget _buildContentWithTags(String content, ThemeColors current) {
    final currentUserNickname = CurrentUser.instance.member?.mNickname;
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return Text(
        content,
        style: TextStyle(fontSize: 14.sp, color: current.fontThird),
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: TextStyle(fontSize: 14.sp, color: current.fontThird),
          ),
        );
      }

      final taggedNickname = match.group(1)!;
      final isCurrentUser = taggedNickname == currentUserNickname;

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => _showTaggedUserProfile(context, taggedNickname),
            child: Text(
              '@$taggedNickname',
              style: TextStyle(
                fontSize: 14.sp,
                color: isCurrentUser ? Colors.red : current.accent,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                backgroundColor: isCurrentUser
                    ? Colors.red.withValues(alpha: 0.1)
                    : null,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: TextStyle(fontSize: 14.sp, color: current.fontThird),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  // 댓글 미리보기에서 @닉네임 태그를 감지하고 스타일링
  Widget _buildCommentPreviewWithTags(String content, ThemeColors current) {
    final currentUserNickname = CurrentUser.instance.member?.mNickname;
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return Text(
        content,
        style: TextStyle(fontSize: 13.sp, color: current.fontThird),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: TextStyle(fontSize: 13.sp, color: current.fontThird),
          ),
        );
      }

      final taggedNickname = match.group(1)!;
      final isCurrentUser = taggedNickname == currentUserNickname;

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => _showTaggedUserProfile(context, taggedNickname),
            child: Text(
              '@$taggedNickname',
              style: TextStyle(
                fontSize: 13.sp,
                color: isCurrentUser ? Colors.red : current.accent,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                backgroundColor: isCurrentUser
                    ? Colors.red.withValues(alpha: 0.1)
                    : null,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: TextStyle(fontSize: 13.sp, color: current.fontThird),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 상대 시간 표시 (예: 5분 전, 2시간 전)
  String _getTimeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM.dd').format(date);
    }
  }

  // 운동 기록 통계 아이템
  Widget _recordStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeColors current,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18.sp, color: current.accent),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: current.fontThird,
          ),
        ),
      ],
    );
  }
}
