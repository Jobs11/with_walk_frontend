import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/faq.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/customer/feq_detail_screen.dart';

class FaqListScreen extends StatefulWidget {
  const FaqListScreen({super.key});

  @override
  State<FaqListScreen> createState() => _FaqListScreenState();
}

class _FaqListScreenState extends State<FaqListScreen> {
  final current = ThemeManager().current;
  List<Faq> faqList = [];
  bool isLoading = true;
  String selectedCategory = '전체';

  final List<String> categories = ['전체', '계정', '결제', '이용방법', '오류/제안', '기타'];

  @override
  void initState() {
    super.initState();

    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() => isLoading = true);

    try {
      final faqs = selectedCategory == '전체'
          ? await CustomerService.getAllFaqs()
          : await CustomerService.getFaqsByCategory(selectedCategory);

      if (mounted) {
        setState(() {
          faqList = faqs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('FAQ 로드 실패: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _selectCategory(String category) {
    setState(() => selectedCategory = category);
    _loadFaqs();
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
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'FAQ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // 카테고리 탭
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: categories
                      .map(
                        (category) => Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: GestureDetector(
                            onTap: () => _selectCategory(category),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: selectedCategory == category
                                    ? current.accent
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: selectedCategory == category
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            // FAQ 리스트
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : faqList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'FAQ가 없습니다',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: faqList.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final faq = faqList[index];
                        return _buildFaqCard(faq);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(Faq faq) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaqDetailScreen(faq: faq)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: current.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    faq.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: current.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey[400],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              faq.question,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              faq.answer,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
