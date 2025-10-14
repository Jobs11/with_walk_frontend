import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/inquiry.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/screens/customer/admin_inquiry_detail_screen.dart';

class AdminInquiryListScreen extends StatefulWidget {
  const AdminInquiryListScreen({super.key});

  @override
  State<AdminInquiryListScreen> createState() => _AdminInquiryListScreenState();
}

class _AdminInquiryListScreenState extends State<AdminInquiryListScreen> {
  late ThemeColors current;
  List<Inquiry> allInquiries = [];
  List<Inquiry> pendingInquiries = [];
  List<Inquiry> answeredInquiries = [];
  bool isLoading = true;
  int selectedTab = 0; // 0: 답변대기, 1: 답변완료, 2: 전체

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _loadAllInquiries();
  }

  Future<void> _loadAllInquiries() async {
    setState(() => isLoading = true);

    try {
      final inquiries = await CustomerService.getAllInquiries();

      if (mounted) {
        setState(() {
          allInquiries = inquiries;
          pendingInquiries = inquiries
              .where((i) => i.status == '답변대기')
              .toList();
          answeredInquiries = inquiries
              .where((i) => i.status == '답변완료')
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('문의 목록 로드 실패: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Inquiry> get displayInquiries {
    switch (selectedTab) {
      case 0:
        return pendingInquiries;
      case 1:
        return answeredInquiries;
      default:
        return allInquiries;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Icon(
              Icons.admin_panel_settings,
              color: current.accent,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '관리자 - 문의 관리',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 탭 메뉴
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('답변대기', 0, pendingInquiries.length),
                _buildTab('답변완료', 1, answeredInquiries.length),
                _buildTab('전체', 2, allInquiries.length),
              ],
            ),
          ),

          // 문의 리스트
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : displayInquiries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '문의가 없습니다',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAllInquiries,
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: displayInquiries.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final inquiry = displayInquiries[index];
                        return _buildInquiryCard(inquiry);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, int count) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? current.accent : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (isSelected)
            Container(
              width: 60.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: current.accent,
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    final isAnswered = inquiry.status == '답변완료';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminInquiryDetailScreen(
              inquiryId: inquiry.inquiryId!,
              onAnswered: _loadAllInquiries,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: !isAnswered
              ? Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
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
                // 상태 배지
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? current.accent.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    inquiry.status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isAnswered ? current.accent : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // 카테고리
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    inquiry.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Spacer(),

                // 사용자 ID
                Text(
                  inquiry.userId,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 제목
            Text(
              inquiry.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8.h),

            // 내용 미리보기
            Text(
              inquiry.content,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 12.h),

            // 날짜
            Row(
              children: [
                Icon(Icons.schedule, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  DateFormat(
                    'yyyy.MM.dd HH:mm',
                  ).format(DateTime.parse(inquiry.createdAt!)),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),

                Spacer(),

                if (!isAnswered)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '답변 필요',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
