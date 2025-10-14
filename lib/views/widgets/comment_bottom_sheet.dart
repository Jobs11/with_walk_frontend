import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/post_comment.dart';
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

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  late Future<List<PostComment>> _commentsFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = PostCommentService.getCommentList(widget.pNum);
    });
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

      await PostCommentService.createComment(comment);

      if (!mounted) return;

      _commentController.clear();
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

  // 사용자 프로필 표시
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

  @override
  void dispose() {
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
                              Text(
                                comment.pcContent,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: current.fontThird,
                                ),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
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
            ),
          ),
        ],
      ),
    );
  }
}
