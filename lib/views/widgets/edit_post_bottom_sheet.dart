import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/api/service/cloudinary_upload_service.dart';
import 'package:with_walk/api/service/post_service.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/api/model/member_nickname.dart';

import 'package:with_walk/functions/data.dart';

class EditPostBottomSheet extends StatefulWidget {
  final Post post;
  final VoidCallback onPostUpdated;

  const EditPostBottomSheet({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<EditPostBottomSheet> createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<EditPostBottomSheet> {
  late TextEditingController _contentController;
  String? _imageUrl;
  bool _isLoading = false;
  final _cloudinaryService = CloudinaryUploadService();

  // 태그 관련 추가
  List<MemberNickname> _searchResults = [];
  List<String> _taggedNicknames = [];
  bool _showTagSuggestions = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.pContent);
    _imageUrl = widget.post.pImage;
    _contentController.addListener(_onTextChanged);

    // 기존 게시글에서 태그된 닉네임 추출
    _extractTagsFromContent();
  }

  // 기존 텍스트에서 @닉네임 추출
  void _extractTagsFromContent() {
    final text = widget.post.pContent;
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(text);

    setState(() {
      _taggedNicknames = matches.map((m) => m.group(1)!).toSet().toList();
    });
  }

  // @ 입력 감지 및 검색
  void _onTextChanged() {
    final text = _contentController.text;
    final cursorPos = _contentController.selection.baseOffset;

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
    final text = _contentController.text;
    final cursorPos = _contentController.selection.baseOffset;
    final lastAtIndex = text.lastIndexOf('@', cursorPos - 1);

    if (lastAtIndex != -1) {
      final newText =
          '${text.substring(0, lastAtIndex)}@$nickname ${text.substring(cursorPos)}';

      _contentController.text = newText;
      _contentController.selection = TextSelection.fromPosition(
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

  Future<void> _pickAndUploadImage() async {
    final imageUrl = await _cloudinaryService.uploadImage(
      userId: widget.post.mId,
    );

    if (imageUrl != null && mounted) {
      setState(() => _imageUrl = imageUrl);
    }
  }

  Future<void> _updatePost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedPost = Post(
        pNum: widget.post.pNum,
        mId: widget.post.mId,
        rNum: widget.post.rNum,
        pContent: _contentController.text.trim(),
        pImage: _imageUrl,
        pDate: widget.post.pDate,
      );

      debugPrint("수정 json: ${jsonEncode(updatedPost.toJson())}");
      debugPrint("태그된 사용자: $_taggedNicknames");

      await PostService.updatePost(updatedPost);

      if (!mounted) return;

      Navigator.pop(context);
      widget.onPostUpdated();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      debugPrint("오류: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    super.dispose();
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                Text(
                  '게시글 수정',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontThird,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _updatePost,
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('완료', style: TextStyle(color: current.accent)),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 텍스트 입력
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: '내용을 입력하세요...\n@ 를 입력해 친구를 태그하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),

                      // 태그된 사용자 표시
                      if (_taggedNicknames.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _taggedNicknames.map((nickname) {
                            return Chip(
                              label: Text(
                                '@$nickname',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              deleteIcon: Icon(Icons.close, size: 16.sp),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () {
                                setState(() {
                                  _taggedNicknames.remove(nickname);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      SizedBox(height: 16.h),

                      // 사진 수정
                      Text(
                        '사진 수정',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: current.fontThird,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          height: 200.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _imageUrl != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.network(
                                        _imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: Row(
                                        children: [
                                          // 이미지 변경 버튼
                                          GestureDetector(
                                            onTap: _pickAndUploadImage,
                                            child: Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          // 이미지 삭제 버튼
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _imageUrl = null,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 48.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '사진 추가',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 닉네임 검색 결과 드롭다운
                if (_showTagSuggestions && _searchResults.isNotEmpty)
                  Positioned(
                    top: 120.h,
                    left: 16.w,
                    right: 16.w,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 200.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final nickname = _searchResults[index].mNickname;
                            return ListTile(
                              leading: Icon(
                                Icons.person,
                                color: current.accent,
                              ),
                              title: Text(
                                nickname,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () => _selectNickname(nickname),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
