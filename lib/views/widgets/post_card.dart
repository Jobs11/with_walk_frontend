import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:with_walk/api/model/post.dart';

import 'package:with_walk/theme/colors.dart';

// ========== 게시글 카드 위젯 ==========
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({super.key, required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final current = themeMap["라이트"]!;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: current.accent,
                child: Text(
                  post.mId[0].toUpperCase(),
                  style: TextStyle(color: current.bg, fontSize: 16.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.mId,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: current.fontThird,
                    ),
                  ),
                  Text(
                    DateFormat(
                      'yyyy.MM.dd HH:mm',
                    ).format(DateTime.parse(post.pDate)),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 게시글 내용
          Text(
            post.pContent,
            style: TextStyle(fontSize: 14.sp, color: current.fontThird),
          ),

          // 이미지
          if (post.pImage != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                post.pImage!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200.h,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // 좋아요 버튼
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 20.sp, color: current.accent),
                    SizedBox(width: 4.w),
                    Text(
                      '${post.pLikes}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: current.fontThird,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
