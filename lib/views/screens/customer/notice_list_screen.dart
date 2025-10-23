import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/notice.dart';
import 'package:with_walk/api/service/customer_service.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/screens/customer/notice_detail.screen.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  late ThemeColors current;
  List<Notice> noticeList = [];
  bool isLoading = true;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => isLoading = true);

    try {
      final notices = await CustomerService.getAllNotices(
        page: currentPage,
        size: 20,
      );

      if (mounted) {
        setState(() {
          noticeList = notices;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('공지사항 로드 실패: $e');
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
            '공지사항',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : noticeList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '공지사항이 없습니다',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadNotices,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: noticeList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final notice = noticeList[index];
                    return _buildNoticeCard(notice);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NoticeDetailScreen(noticeId: notice.noticeId!),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: notice.isImportant
              ? Border.all(color: current.accent, width: 2)
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
                // 중요 공지 배지
                if (notice.isImportant)
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
                if (notice.isImportant) SizedBox(width: 8.w),

                // 카테고리
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    notice.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Spacer(),

                // 조회수
                Row(
                  children: [
                    Icon(Icons.visibility, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      '${notice.viewCount}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 제목
            Text(
              notice.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8.h),

            // 내용 미리보기
            Text(
              notice.content,
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
                  ).format(DateTime.parse(notice.createdAt)),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
