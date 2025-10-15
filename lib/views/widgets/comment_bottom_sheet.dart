import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/member_nickname.dart';
import 'package:with_walk/api/model/post_comment.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/api/service/post_comment_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

class CommentBottomSheet extends StatefulWidget {
  final int pNum;
  final VoidCallback onCommentChanged;

  const CommentBottomSheet({
    super.key,
    required this.pNum,
    required this.onCommentChanged,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

// comment_bottom_sheet.dart 수정

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  late Future<List<PostComment>> _commentsFuture;
  bool _isSubmitting = false;

  // 태그 관련 추가
  List<MemberNickname> _searchResults = [];
  final List<String> _taggedNicknames = [];
  bool _showTagSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(_onTextChanged);
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = PostCommentService.getCommentList(widget.pNum);
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
      final comment = PostComment(
        pNum: widget.pNum,
        mId: CurrentUser.instance.member!.mId,
        pcContent: _commentController.text.trim(),
        pcDate: DateTime.now().toIso8601String(),
      );

      debugPrint("태그된 사용자: $_taggedNicknames");

      await PostCommentService.createComment(comment);

      if (!mounted) return;

      _commentController.clear();
      _taggedNicknames.clear(); // 태그 목록 초기화
      _loadComments();
      widget.onCommentChanged();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 작성되었습니다')));
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

  void _showUserProfile(BuildContext context, PostComment comment) {
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

  // 댓글 내용에서 태그 강조 표시
  Widget _buildCommentWithTags(String content, ThemeColors current) {
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

  // 태그된 사용자 프로필 표시
  Future<void> _showTaggedUserProfile(
    BuildContext context,
    String nickname,
  ) async {
    try {
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
  void dispose() {
    _commentController.removeListener(_onTextChanged);
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = themeMap["라이트"]!;

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
                      '댓글을 불러올 수 없습니다',
                      style: TextStyle(color: current.fontPrimary),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '첫 댓글을 남겨보세요!',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: current.fontPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => Divider(height: 24.h),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isMyComment =
                        comment.mId == CurrentUser.instance.member?.mId;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 프로필 이미지
                        GestureDetector(
                          onTap: () => _showUserProfile(context, comment),
                          child: Image.asset(
                            comment.authorImage ??
                                'assets/images/icons/user.png',
                            width: 40.w,
                            height: 40.h,
                          ),
                        ),
                        SizedBox(width: 12.w),

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
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: current.fontThird,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    DateFormat(
                                      'MM.dd HH:mm',
                                    ).format(DateTime.parse(comment.pcDate)),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              // 태그 강조 적용
                              _buildCommentWithTags(comment.pcContent, current),
                            ],
                          ),
                        ),

                        // 삭제 버튼 (내 댓글만)
                        if (isMyComment)
                          IconButton(
                            onPressed: () => _deleteComment(comment.pcNum!),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20.sp,
                              color: Colors.grey,
                            ),
                          ),
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
                        separatorBuilder: (_, __) => Divider(height: 1),
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
                            hintText: '댓글을 입력하세요... (@ 로 태그)',
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
}
