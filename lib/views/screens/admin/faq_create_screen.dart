import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/faq.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/theme/colors.dart';

class FaqCreateScreen extends StatefulWidget {
  const FaqCreateScreen({super.key});

  @override
  State<FaqCreateScreen> createState() => _FaqCreateScreenState();
}

class _FaqCreateScreenState extends State<FaqCreateScreen> {
  late ThemeColors current;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _displayOrderController = TextEditingController(
    text: '0',
  );

  String selectedCategory = '계정';
  bool isActive = true;
  bool isLoading = false;

  final List<String> categories = ['계정', '결제', '이용방법', '오류 및 제안', '기타'];

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _createFaq() async {
    // 유효성 검사
    if (_questionController.text.trim().isEmpty) {
      _showSnackBar('질문을 입력해주세요');
      return;
    }

    if (_answerController.text.trim().isEmpty) {
      _showSnackBar('답변을 입력해주세요');
      return;
    }

    setState(() => isLoading = true);

    try {
      final faq = Faq(
        category: selectedCategory,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        viewCount: 0,
        displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
        isActive: isActive,
      );

      await CustomerService.createFaq(faq);

      if (mounted) {
        _showSnackBar('FAQ가 등록되었습니다');
        Navigator.pop(context, true); // 등록 성공 시 true 반환
      }
    } catch (e) {
      debugPrint('FAQ 등록 실패: $e');
      _showSnackBar('FAQ 등록에 실패했습니다');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: current.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: current.fontPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ 등록',
          style: TextStyle(
            color: current.fontPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(current.accent),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createFaq,
              child: Text(
                '등록',
                style: TextStyle(
                  color: current.accent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택
            _buildSectionTitle('카테고리'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: current.app,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: current.fontThird.withValues(alpha: 0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: current.fontPrimary),
                  style: TextStyle(color: current.fontPrimary, fontSize: 15.sp),
                  dropdownColor: current.app,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 질문 입력
            _buildSectionTitle('질문'),
            SizedBox(height: 12.h),
            TextField(
              controller: _questionController,
              maxLines: 2,
              maxLength: 500,
              style: TextStyle(color: current.fontPrimary, fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: '자주 묻는 질문을 입력하세요',
                hintStyle: TextStyle(color: current.fontThird),
                filled: true,
                fillColor: current.app,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: current.accent, width: 2),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 답변 입력
            _buildSectionTitle('답변'),
            SizedBox(height: 12.h),
            TextField(
              controller: _answerController,
              maxLines: 8,
              maxLength: 2000,
              style: TextStyle(color: current.fontPrimary, fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: '답변 내용을 입력하세요',
                hintStyle: TextStyle(color: current.fontThird),
                filled: true,
                fillColor: current.app,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: current.accent, width: 2),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 표시 순서
            _buildSectionTitle('표시 순서'),
            SizedBox(height: 12.h),
            TextField(
              controller: _displayOrderController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: current.fontPrimary, fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: current.fontThird),
                filled: true,
                fillColor: current.app,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: current.fontThird.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: current.accent, width: 2),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 활성화 여부
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: current.app,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: current.fontThird.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '활성화',
                    style: TextStyle(
                      color: current.fontPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeThumbColor: current.accent,
                    onChanged: (value) {
                      setState(() => isActive = value);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: current.fontPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
