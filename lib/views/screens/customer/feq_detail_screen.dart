import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/faq.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/admin/faq_edit_screen.dart';

class FaqDetailScreen extends StatelessWidget {
  final Faq faq;

  const FaqDetailScreen({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    final current = ThemeManager().current;
    final isAdmin = CurrentUser.instance.member?.mRole == 'ADMIN';

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
            'FAQ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 태그
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: current.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  faq.category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: current.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // 질문
              Text(
                'Q. ${faq.question}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20.h),

              // 답변
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: current.accent,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '답변',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: current.accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // 도움이 되었나요?
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '이 답변이 도움이 되었나요?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('피드백 감사합니다!')),
                            );
                          },
                          icon: Icon(Icons.thumb_up_outlined, size: 18.sp),
                          label: Text('도움됨'),
                        ),
                        SizedBox(width: 12.w),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('피드백 감사합니다!')),
                            );
                          },
                          icon: Icon(Icons.thumb_down_outlined, size: 18.sp),
                          label: Text('도움안됨'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 관리자 전용 - 수정/삭제 버튼
              if (isAdmin) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: current.accent.withValues(alpha: 0.1),
                    border: Border.all(
                      color: current.accent.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: current.accent,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '관리자 메뉴',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: current.accent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FaqEditScreen(faq: faq),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    // 수정 완료 후 화면 새로고침 또는 뒤로가기
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context, true);
                                  }
                                });
                              },
                              icon: Icon(Icons.edit, size: 18.sp),
                              label: Text('수정'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: current.bg,
                                foregroundColor: current.btn,
                                side: BorderSide(color: current.btn),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                // 삭제 확인 다이얼로그
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: current.bg,
                                    title: Text(
                                      'FAQ 삭제',
                                      style: TextStyle(
                                        color: current.fontPrimary,
                                      ),
                                    ),
                                    content: Text(
                                      '이 FAQ를 삭제하시겠습니까?',
                                      style: TextStyle(
                                        color: current.fontSecondary,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            color: current.fontThird,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  try {
                                    await CustomerService.deleteFaq(faq.faqId!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('FAQ가 삭제되었습니다')),
                                      );
                                      Navigator.pop(context, true); // 삭제 후 뒤로가기
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('삭제 실패: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: Icon(Icons.delete_outline, size: 18.sp),
                              label: Text('삭제'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: current.bg,
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
