import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/inquiry.dart';
import 'package:with_walk/api/model/inquiry_reply.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/theme/colors.dart';

class AdminInquiryDetailScreen extends StatefulWidget {
  final int inquiryId;
  final VoidCallback? onAnswered;

  const AdminInquiryDetailScreen({
    super.key,
    required this.inquiryId,
    this.onAnswered,
  });

  @override
  State<AdminInquiryDetailScreen> createState() =>
      _AdminInquiryDetailScreenState();
}

class _AdminInquiryDetailScreenState extends State<AdminInquiryDetailScreen> {
  late ThemeColors current;
  final _replyController = TextEditingController();

  Inquiry? inquiry;
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
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

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답변 내용을 입력해주세요')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final reply = InquiryReply(
        inquiryId: widget.inquiryId,
        adminId: CurrentUser.instance.member!.mId,
        content: _replyController.text.trim(),
      );

      await CustomerService.replyToInquiry(reply);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답변이 등록되었습니다')));

      widget.onAnswered?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답변 등록 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '문의 상세 (관리자)',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 문의자 정보
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: current.accent,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '문의자',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    inquiry!.userId,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

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
                            Icon(
                              Icons.schedule,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat(
                                'yyyy.MM.dd HH:mm',
                              ).format(DateTime.parse(inquiry!.createdAt!)),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        Divider(thickness: 1),

                        SizedBox(height: 20.h),

                        // 문의 내용
                        Text(
                          '문의 내용',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12.h),
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

                        // 기존 답변 표시
                        if (inquiry!.replyContent != null) ...[
                          SizedBox(height: 24.h),

                          Text(
                            '등록된 답변',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
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
                                      DateFormat('yyyy.MM.dd HH:mm').format(
                                        DateTime.parse(inquiry!.replyDate!),
                                      ),
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

                // 답변 입력창 (답변대기 상태일 때만)
                if (inquiry!.status == '답변대기')
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '답변 작성',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: _replyController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: '답변 내용을 입력하세요',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.all(12.w),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitReply,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: current.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: isSubmitting
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '답변 등록',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
