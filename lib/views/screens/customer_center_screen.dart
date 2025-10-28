import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/faq.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/admin/admin_inquiry_list_screen.dart';
import 'package:with_walk/views/screens/customer/faq_list_screen.dart';
import 'package:with_walk/views/screens/customer/feq_detail_screen.dart';
import 'package:with_walk/views/screens/customer/inquiry_create_screen.dart';
import 'package:with_walk/views/screens/customer/inquiry_list_screen.dart';
import 'package:with_walk/views/screens/customer/notice_list_screen.dart';

class CustomerCenterScreen extends StatefulWidget {
  const CustomerCenterScreen({super.key});

  @override
  State<CustomerCenterScreen> createState() => _CustomerCenterScreenState();
}

class _CustomerCenterScreenState extends State<CustomerCenterScreen> {
  final current = ThemeManager().current;
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = '전체';
  List<Faq> faqList = [];
  bool isLoading = true;

  final List<String> categories = ['전체', '계정', '결제', '이용방법', '오류 및 제안', '기타'];

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

  Future<void> _searchFaqs(String keyword) async {
    if (keyword.trim().isEmpty) {
      _loadFaqs();
      return;
    }

    setState(() => isLoading = true);

    try {
      final faqs = await CustomerService.searchFaqs(keyword);

      if (mounted) {
        setState(() {
          faqList = faqs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('FAQ 검색 실패: $e');
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = CurrentUser.instance.member?.mRole == 'ADMIN';

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Icon(Icons.headset_mic, color: current.accent, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                '고객센터',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // 관리자 버튼 추가
          actions: [
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.admin_panel_settings, color: current.accent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminInquiryListScreen(),
                    ),
                  );
                },
              ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // 검색창
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchFaqs,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력해주세요',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              _loadFaqs();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),

              // 탭 메뉴
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    children: categories
                        .map(
                          (category) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: GestureDetector(
                              onTap: () => _selectCategory(category),
                              child: _buildTab(
                                category,
                                selectedCategory == category,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // 빠른 메뉴
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '빠른 메뉴',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoticeListScreen(),
                              ),
                            );
                          },
                          child: _buildQuickMenu(
                            Icons.notifications_outlined,
                            '공지사항',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaqListScreen(),
                              ),
                            );
                          },
                          child: _buildQuickMenu(Icons.help_outline, 'FAQ'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InquiryCreateScreen(),
                              ),
                            );
                          },
                          child: _buildQuickMenu(Icons.mail_outline, '문의하기'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // 자주 묻는 질문
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '자주 묻는 질문',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaqListScreen(),
                              ),
                            );
                          },
                          child: Text(
                            '전체보기',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: current.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // FAQ 로딩 또는 리스트
                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (faqList.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: faqList
                            .take(3)
                            .map(
                              (faq) => Column(
                                children: [
                                  _buildFaqItem(faq),
                                  if (faqList.indexOf(faq) < 2)
                                    Divider(height: 24.h),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // 내 문의 내역 버튼
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InquiryListScreen(
                            userId: CurrentUser.instance.member!.mId,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: current.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.message,
                      color: current.accent,
                      size: 20.sp,
                    ),
                    label: Text(
                      '내 문의 내역',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: current.accent,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // 1:1 문의 작성 버튼
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InquiryCreateScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: current.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      '1:1 문의하기',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        if (isSelected)
          Container(
            width: 40.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: current.accent,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickMenu(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: current.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: current.accent, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildFaqItem(Faq faq) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaqDetailScreen(faq: faq)),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.question,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  faq.answer,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
