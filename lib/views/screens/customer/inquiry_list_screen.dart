import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/inquiry.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/customer/inquiry_detail_screen.dart';

class InquiryListScreen extends StatefulWidget {
  final String userId;

  const InquiryListScreen({super.key, required this.userId});

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  final current = ThemeManager().current;
  List<Inquiry> inquiryList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadInquiries();
  }

  Future<void> _loadInquiries() async {
    setState(() => isLoading = true);

    try {
      final inquiries = await CustomerService.getUserInquiries(widget.userId);

      if (mounted) {
        setState(() {
          inquiryList = inquiries;
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
            '내 문의 내역',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : inquiryList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '문의 내역이 없습니다',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadInquiries,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: inquiryList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final inquiry = inquiryList[index];
                    return _buildInquiryCard(inquiry);
                  },
                ),
              ),
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
            builder: (context) => InquiryDetailScreen(
              inquiryId: inquiry.inquiryId!,
              onDeleted: _loadInquiries,
            ),
          ),
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
                // 상태 배지
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? current.accent.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
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

                if (isAnswered) ...[
                  Spacer(),
                  Icon(Icons.check_circle, size: 16.sp, color: current.accent),
                  SizedBox(width: 4.w),
                  Text(
                    '답변완료',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: current.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
