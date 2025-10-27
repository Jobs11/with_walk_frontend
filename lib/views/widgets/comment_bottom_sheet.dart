import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/member_nickname.dart';
import 'package:with_walk/api/model/post_comment.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/api/service/post_comment_service.dart';
import 'package:with_walk/api/service/post_comment_like_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/widgets/smart_profile_image.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class CommentBottomSheet extends StatefulWidget {
  final String authorImage;
  final int pNum;
  final VoidCallback onCommentChanged;

  const CommentBottomSheet({
    super.key,
    required this.authorImage,
    required this.pNum,
    required this.onCommentChanged,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  late Future<List<PostComment>> _commentsFuture;
  bool _isSubmitting = false;

  // 태그 관련
  List<MemberNickname> _searchResults = [];
  final List<String> _taggedNicknames = [];
  bool _showTagSuggestions = false;

  // 대댓글 관련
  PostComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = PostCommentService.getCommentList(widget.pNum);
    });
  }

  // 답글 모드 시작
  void _startReply(PostComment comment) {
    setState(() {
      _replyingTo = comment;
      final nickname = comment.mNickname ?? comment.authorName ?? comment.mId;
      _commentController.text = '@$nickname ';
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentController.text.length),
      );
    });

    FocusScope.of(context).requestFocus(FocusNode());
  }

  // 답글 모드 취소
  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _commentController.clear();
    });
  }

  // @ 입력 감지 및 검색
  void _onTextChanged() {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;

    if (cursorPos <= 0) return;

    final beforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = beforeCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      final afterAt = beforeCursor.substring(lastAtIndex + 1);
      if (!afterAt.contains(' ') && !afterAt.contains('\n')) {
        setState(() => _showTagSuggestions = true);
        _searchNicknames(afterAt);
      } else {
        setState(() => _showTagSuggestions = false);
      }
    } else {
      setState(() => _showTagSuggestions = false);
    }
  }

  Future<void> _searchNicknames(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final results = await Memberservice.searchList(query);
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint('닉네임 검색 실패: $e');
    }
  }

  void _selectNickname(String nickname) {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;
    final lastAtIndex = text.lastIndexOf('@', cursorPos - 1);

    if (lastAtIndex != -1) {
      final newText =
          '${text.substring(0, lastAtIndex)}@$nickname ${text.substring(cursorPos)}';

      _commentController.text = newText;
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: lastAtIndex + nickname.length + 2),
      );

      setState(() {
        if (!_taggedNicknames.contains(nickname)) {
          _taggedNicknames.add(nickname);
        }
        _showTagSuggestions = false;
        _searchResults = [];
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글 내용을 입력해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 대댓글 작성
      if (_replyingTo != null && _replyingTo!.pcNum != null) {
        final reply = PostComment(
          pNum: widget.pNum,
          parentPcNum: _replyingTo!.pcNum,
          mId: CurrentUser.instance.member!.mId,
          pcContent: _commentController.text.trim(),
          pcDate: DateTime.now().toIso8601String(),
        );

        await PostCommentService.createComment(reply);

        if (!mounted) return;

        _commentController.clear();
        _taggedNicknames.clear();
        _cancelReply();
        _loadComments();
        widget.onCommentChanged();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('답글이 작성되었습니다')));
      }
      // 일반 댓글 작성
      else {
        final comment = PostComment(
          pNum: widget.pNum,
          parentPcNum: null,
          mId: CurrentUser.instance.member!.mId,
          pcContent: _commentController.text.trim(),
          pcDate: DateTime.now().toIso8601String(),
        );

        debugPrint("태그된 사용자: $_taggedNicknames");

        await PostCommentService.createComment(comment);

        if (!mounted) return;

        _commentController.clear();
        _taggedNicknames.clear();
        _loadComments();
        widget.onCommentChanged();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('댓글이 작성되었습니다')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(int pcNum) async {
    try {
      await PostCommentService.deleteComment(pcNum);

      if (!mounted) return;

      _loadComments();
      widget.onCommentChanged();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 삭제되었습니다')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  // 댓글 좋아요 토글
  Future<void> _toggleCommentLike(PostComment comment) async {
    if (comment.pcNum == null) return;

    final currentUserId = CurrentUser.instance.member?.mId;
    if (currentUserId == null) return;

    final originalIsLiked = comment.isLiked;
    final originalLikeCount = comment.likeCount;

    setState(() {
      comment.isLiked = !comment.isLiked;
      comment.likeCount += comment.isLiked ? 1 : -1;
    });

    try {
      final result = await PostCommentLikeService.toggleLike(
        comment.pcNum!,
        currentUserId,
      );

      if (mounted) {
        setState(() {
          comment.isLiked = result['isLiked'] ?? false;
          comment.likeCount = result['likeCount'] ?? 0;
          comment.isLikedByAuthor = result['isLikedByAuthor'] ?? false;
        });
      }

      debugPrint(
        '✅ 좋아요 업데이트: isLiked=${comment.isLiked}, '
        'likeCount=${comment.likeCount}, '
        'isLikedByAuthor=${comment.isLikedByAuthor}',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          comment.isLiked = originalIsLiked;
          comment.likeCount = originalLikeCount;
        });
      }
      debugPrint('❌ 좋아요 실패: $e');
    }
  }

  // ✅ 태그가 포함된 내용 렌더링
  Widget _buildContentWithTags(
    String content,
    ThemeColors current,
    double fontSize,
  ) {
    final currentUserNickname = CurrentUser.instance.member?.mNickname;
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return Text(
        content,
        style: TextStyle(fontSize: fontSize, color: current.fontThird),
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: TextStyle(fontSize: fontSize, color: current.fontThird),
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
                fontSize: fontSize,
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
          style: TextStyle(fontSize: fontSize, color: current.fontThird),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  // ✅ 태그된 사용자 프로필 보기
  void _showTaggedUserProfile(BuildContext context, String nickname) async {
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

  @override
  Widget build(BuildContext context) {
    final current = ThemeManager().current;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  '댓글',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 답글 작성 중 표시
          if (_replyingTo != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${_replyingTo!.mNickname ?? _replyingTo!.authorName ?? _replyingTo!.mId} 님에게 답글 작성 중',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _cancelReply,
                    icon: Icon(Icons.close, size: 18.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // 댓글 목록
          Expanded(
            child: FutureBuilder<List<PostComment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '댓글을 불러올 수 없습니다\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      '첫 댓글을 남겨보세요!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isMyComment =
                        comment.mId == CurrentUser.instance.member?.mId;

                    return Column(
                      children: [
                        // 부모 댓글
                        _buildCommentCard(
                          comment: comment,
                          isMyComment: isMyComment,
                          current: current,
                          isChild: false,
                        ),

                        // 대댓글 리스트 (들여쓰기)
                        ...comment.childComments.map((childComment) {
                          final isMyChild =
                              childComment.mId ==
                              CurrentUser.instance.member?.mId;
                          return Padding(
                            padding: EdgeInsets.only(left: 40.w),
                            child: _buildCommentCard(
                              comment: childComment,
                              isMyComment: isMyChild,
                              current: current,
                              isChild: true,
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 댓글 입력창
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: current.bg,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 태그된 사용자 표시
                  if (_taggedNicknames.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: _taggedNicknames.map((nickname) {
                          return Chip(
                            label: Text(
                              '@$nickname',
                              style: TextStyle(fontSize: 11.sp),
                            ),
                            deleteIcon: Icon(Icons.close, size: 14.sp),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            onDeleted: () {
                              setState(() {
                                _taggedNicknames.remove(nickname);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  // 닉네임 검색 결과
                  if (_showTagSuggestions && _searchResults.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      constraints: BoxConstraints(maxHeight: 150.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final nickname = _searchResults[index].mNickname;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.person,
                              color: current.accent,
                              size: 20.sp,
                            ),
                            title: Text(
                              nickname,
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            onTap: () => _selectNickname(nickname),
                          );
                        },
                      ),
                    ),

                  // 입력창
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: _replyingTo != null
                                ? '답글을 입력하세요...'
                                : '댓글을 입력하세요... (@ 로 태그)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _isSubmitting
                          ? SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              onPressed: _submitComment,
                              icon: Icon(
                                Icons.send,
                                color: current.accent,
                                size: 24.sp,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 카드 위젯
  Widget _buildCommentCard({
    required PostComment comment,
    required bool isMyComment,
    required ThemeColors current,
    required bool isChild,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isChild ? Colors.grey[50] : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => UserProfileBottomSheet(
                  userId: comment.mId,
                  userName: comment.authorName,
                  userImage: comment.authorImage,
                ),
              );
            },

            child: SmartProfileImage(
              imageUrl: comment.mProfileImage ?? comment.authorImage ?? '',
              width: isChild ? 32.w : 36.w,
              height: isChild ? 32.h : 36.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),

          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임
                Text(
                  comment.mNickname ?? comment.authorName ?? comment.mId,
                  style: TextStyle(
                    fontSize: isChild ? 13.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),

                // ✅ 태그가 적용된 내용
                _buildContentWithTags(
                  comment.pcContent,
                  current,
                  isChild ? 12.sp : 13.sp,
                ),
                SizedBox(height: 8.h),

                // 하단 액션바
                Row(
                  children: [
                    // 시간
                    Text(
                      DateFormat(
                        'MM.dd HH:mm',
                      ).format(DateTime.parse(comment.pcDate)),
                      style: TextStyle(
                        fontSize: isChild ? 10.sp : 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // 좋아요 버튼
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: isChild ? 14.sp : 16.sp,
                            color: comment.isLiked
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                          if (comment.likeCount > 0) ...[
                            SizedBox(width: 4.w),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                fontSize: isChild ? 11.sp : 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 답글 버튼 (부모 댓글만)
                    if (!isChild) ...[
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => _startReply(comment),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '답글',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 작성자가 좋아요한 경우 표시
                    if (comment.isLikedByAuthor && !isChild) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SmartProfileImage(
                              imageUrl: widget.authorImage,
                              width: 14.w,
                              height: 14.h,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.favorite,
                              size: 12.sp,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 삭제 버튼 (내 댓글만)
          if (isMyComment)
            IconButton(
              onPressed: () => _deleteComment(comment.pcNum!),
              icon: Icon(
                Icons.delete_outline,
                size: isChild ? 18.sp : 20.sp,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
