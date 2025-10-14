import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/api/service/cloudinary_upload_service.dart';
import 'package:with_walk/api/service/post_service.dart';

import 'package:with_walk/theme/colors.dart';

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

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.pContent);
    _imageUrl = widget.post.pImage;
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
    _contentController.dispose();
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 텍스트 입력
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '내용을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

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
                                        onTap: () =>
                                            setState(() => _imageUrl = null),
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
          ),
        ],
      ),
    );
  }
}
