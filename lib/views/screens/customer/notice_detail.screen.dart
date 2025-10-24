import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/notice.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/views/screens/admin/edit_notice_screen.dart';

class NoticeDetailScreen extends StatefulWidget {
  final int noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  final current = ThemeManager().current;
  Notice? notice;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNoticeDetail();
  }

  Future<void> _loadNoticeDetail() async {
    setState(() => isLoading = true);

    try {
      final data = await CustomerService.getNoticeDetail(widget.noticeId);

      if (mounted) {
        setState(() {
          notice = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('공지사항 상세 로드 실패: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            '공지사항',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // ✅ 관리자만 수정/삭제 버튼 표시
            if (isAdmin && notice != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editNotice();
                  } else if (value == 'delete') {
                    _deleteNotice();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20.sp, color: Colors.blue),
                        SizedBox(width: 8.w),
                        Text('수정'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : notice == null
            ? Center(
                child: Text(
                  '공지사항을 불러올 수 없습니다',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 및 중요 배지
                    Row(
                      children: [
                        if (notice!.isImportant)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: current.accent,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '중요',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (notice!.isImportant) SizedBox(width: 8.w),
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
                            notice!.category,
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
                      notice!.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 날짜 및 조회수
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat(
                            'yyyy.MM.dd HH:mm',
                          ).format(DateTime.parse(notice!.createdAt)),
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.visibility, size: 16.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '조회 ${notice!.viewCount}',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    Divider(thickness: 1),

                    SizedBox(height: 20.h),

                    // 내용
                    Text(
                      notice!.content,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        height: 1.8,
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
      ),
    );
  }

  // ✅ 공지사항 수정
  Future<void> _editNotice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoticeScreen(notice: notice!),
      ),
    );

    // 수정 완료 후 새로고침
    if (result == true) {
      _loadNoticeDetail();
    }
  }

  // ✅ 공지사항 삭제
  Future<void> _deleteNotice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지사항 삭제'),
        content: Text('${notice!.title}\n\n이 공지사항을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 삭제 API 호출
      await CustomerService.deleteNotice(widget.noticeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공지사항이 삭제되었습니다'),
          backgroundColor: Colors.green,
        ),
      );

      // 목록 화면으로 돌아가기 (새로고침 트리거)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
