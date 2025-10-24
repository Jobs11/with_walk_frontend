import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/inquiry.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';

class InquiryDetailScreen extends StatefulWidget {
  final int inquiryId;
  final VoidCallback? onDeleted;

  const InquiryDetailScreen({
    super.key,
    required this.inquiryId,
    this.onDeleted,
  });

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  final current = ThemeManager().current;
  Inquiry? inquiry;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadInquiryDetail();
  }

  Future<void> _loadInquiryDetail() async {
    setState(() => isLoading = true);

    try {
      final data = await CustomerService.getInquiryDetail(widget.inquiryId);

      if (mounted) {
        setState(() {
          inquiry = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('문의 상세 로드 실패: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteInquiry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('문의 삭제'),
        content: Text('정말로 이 문의를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CustomerService.deleteInquiry(widget.inquiryId);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('문의가 삭제되었습니다')));

        widget.onDeleted?.call();
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '문의 상세',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (inquiry?.status == '답변대기')
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteInquiry,
              ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : inquiry == null
            ? Center(
                child: Text(
                  '문의를 불러올 수 없습니다',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상태 및 카테고리
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: inquiry!.status == '답변완료'
                                ? current.accent.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            inquiry!.status,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: inquiry!.status == '답변완료'
                                  ? current.accent
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            inquiry!.category,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // 제목
                    Text(
                      inquiry!.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 날짜
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat(
                            'yyyy.MM.dd HH:mm',
                          ).format(DateTime.parse(inquiry!.createdAt!)),
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    Divider(thickness: 1),

                    SizedBox(height: 20.h),

                    // 문의 내용
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        inquiry!.content,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black87,
                          height: 1.8,
                        ),
                      ),
                    ),

                    // 답변이 있는 경우
                    if (inquiry!.replyContent != null) ...[
                      SizedBox(height: 24.h),

                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: current.accent,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '관리자 답변',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: current.accent,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: current.accent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: current.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inquiry!.replyContent!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black87,
                                height: 1.8,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  DateFormat(
                                    'yyyy.MM.dd HH:mm',
                                  ).format(DateTime.parse(inquiry!.replyDate!)),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
      ),
    );
  }
}
