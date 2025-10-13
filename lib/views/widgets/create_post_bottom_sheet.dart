import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/post.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/service/cloudinary_upload_service.dart';
import 'package:with_walk/api/service/post_service.dart';

import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/theme/colors.dart';

// ========== 게시글 작성 바텀시트 ==========
class CreatePostBottomSheet extends StatefulWidget {
  final String userId;
  final List<Street> records;
  final VoidCallback onPostCreated;

  const CreatePostBottomSheet({
    super.key,
    required this.userId,
    required this.records,
    required this.onPostCreated,
  });

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _contentController = TextEditingController();
  Street? _selectedRecord;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  final _cloudinaryService = CloudinaryUploadService();

  Future<void> _pickAndUploadImage() async {
    final imageUrl = await _cloudinaryService.uploadImage(
      userId: widget.userId,
    );

    if (imageUrl != null && mounted) {
      setState(() => _uploadedImageUrl = imageUrl);
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final post = Post(
        mId: widget.userId,
        rNum: _selectedRecord?.rNum?.toString(),
        pContent: _contentController.text.trim(),
        pImage: _uploadedImageUrl,
        pDate: DateTime.now().toIso8601String(),
      );

      await PostService.createPostWithImage(
        post: post,
        imageFile: null, // Cloudinary URL 사용하므로 null
      );

      if (!mounted) return;

      Navigator.pop(context);
      widget.onPostCreated();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 작성되었습니다!')));
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                Text(
                  '게시글 작성',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontThird,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _submitPost,
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
                      hintText: '오늘의 걷기 기록을 공유해보세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 운동 기록 선택
                  Text(
                    '운동 기록 선택 (선택사항)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: current.fontThird,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  if (widget.records.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '저장된 운동 기록이 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    SizedBox(
                      height: 150.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.records.length,
                        itemBuilder: (ctx, i) {
                          final record = widget.records[i];
                          final isSelected = _selectedRecord == record;

                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedRecord = isSelected ? null : record;
                            }),
                            child: Container(
                              width: 200.w,
                              margin: EdgeInsets.only(right: 12.w),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? current.accent.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: isSelected
                                      ? current.accent
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('yyyy.MM.dd').format(
                                      DateTime.parse(record.rDate.toString()),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: current.fontThird,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '거리: ${record.rDistance} km',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                      Text(
                                        '시간: ${formatTime(int.parse(record.rTime))}',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                      Text(
                                        '칼로리: ${record.rKcal} kcal',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // 사진 업로드
                  Text(
                    '사진 추가 (선택사항)',
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
                      child: _uploadedImageUrl != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(
                                    _uploadedImageUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _uploadedImageUrl = null,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
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
