import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/notice.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/theme/colors.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  late ThemeColors current;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = '일반';
  bool _isImportant = false;
  bool _isLoading = false;

  final List<String> _categories = ['일반', '이벤트', '업데이트', '점검', '안내'];

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '공지사항 작성',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: Text(
                '등록',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _isLoading ? Colors.grey : current.accent,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 선택
                _buildSectionTitle('카테고리'),
                SizedBox(height: 8.h),
                _buildCategorySelector(),

                SizedBox(height: 24.h),

                // 중요 공지 토글
                _buildImportantToggle(),

                SizedBox(height: 24.h),

                // 제목 입력
                _buildSectionTitle('제목'),
                SizedBox(height: 8.h),
                _buildTitleField(),

                SizedBox(height: 24.h),

                // 내용 입력
                _buildSectionTitle('내용'),
                SizedBox(height: 8.h),
                _buildContentField(),

                SizedBox(height: 32.h),

                // 미리보기 섹션
                _buildPreviewSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: current.accent),
          style: TextStyle(fontSize: 15.sp, color: Colors.black87),
          items: _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildImportantToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isImportant ? current.accent : Colors.grey[300]!,
          width: _isImportant ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.priority_high,
            color: _isImportant ? current.accent : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '중요 공지',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '공지사항 목록 상단에 강조 표시됩니다',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isImportant,
            activeThumbColor: current.accent,
            onChanged: (value) {
              setState(() {
                _isImportant = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: '공지사항 제목을 입력하세요',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
        style: TextStyle(fontSize: 15.sp),
        maxLength: 100,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '제목을 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          hintText: '공지사항 내용을 입력하세요',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
        style: TextStyle(fontSize: 15.sp, height: 1.5),
        maxLines: 15,
        minLines: 10,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '내용을 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '미리보기',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: _isImportant
                ? Border.all(color: current.accent, width: 2)
                : Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 배지
              Row(
                children: [
                  if (_isImportant)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: current.accent,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '중요',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_isImportant) SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // 제목
              Text(
                _titleController.text.isEmpty
                    ? '제목이 여기에 표시됩니다'
                    : _titleController.text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _titleController.text.isEmpty
                      ? Colors.grey[400]
                      : Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),

              // 내용
              Text(
                _contentController.text.isEmpty
                    ? '내용이 여기에 표시됩니다'
                    : _contentController.text,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _contentController.text.isEmpty
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ 실제 API 연동
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Notice 객체 생성
      final notice = Notice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isImportant: _isImportant,
        viewCount: 0,
        createdAt: DateTime.now().toIso8601String(),
      );

      // API 호출
      await CustomerService.createNotice(notice);

      if (!mounted) return;

      // 성공
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공지사항이 등록되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 화면 닫기 (새로고침 트리거)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('등록 실패: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
