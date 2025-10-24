import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/badge_emoji.dart';
import 'package:with_walk/api/service/badge_emoji_service.dart';

import 'package:with_walk/functions/data.dart';

class EmojiPickerBottomSheet extends StatefulWidget {
  final Function(String) onEmojiSelected;

  const EmojiPickerBottomSheet({super.key, required this.onEmojiSelected});

  @override
  State<EmojiPickerBottomSheet> createState() => _EmojiPickerBottomSheetState();
}

class _EmojiPickerBottomSheetState extends State<EmojiPickerBottomSheet>
    with SingleTickerProviderStateMixin {
  final current = ThemeManager().current;
  late TabController _tabController;

  final List<Map<String, String>> _categories = [
    {'name': '자주 사용', 'key': 'common'},
    {'name': '거리', 'key': 'distance'},
    {'name': '연속', 'key': 'streak'},
    {'name': '속도', 'key': 'speed'},
    {'name': '계절', 'key': 'seasonal'},
    {'name': '장소', 'key': 'location'},
    {'name': '시간대', 'key': 'timeOfDay'},
    {'name': '메달', 'key': 'medal'},
    {'name': '특별', 'key': 'special'},
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // 제목
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '배지 이모지 선택',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: current.fontPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 탭바
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: current.accent,
            unselectedLabelColor: current.fontSecondary,
            indicatorColor: current.accent,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
            tabs: _categories.map((cat) => Tab(text: cat['name'])).toList(),
          ),

          // 탭뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildEmojiGrid(category['key']!);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(String categoryKey) {
    return FutureBuilder<dynamic>(
      future: _loadEmojis(categoryKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '이모지를 불러올 수 없습니다',
              style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              '이모지가 없습니다',
              style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
            ),
          );
        }

        final data = snapshot.data;

        // 자주 사용 (quickPicks)
        if (data is List<String>) {
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _buildSimpleEmojiButton(data[index]);
            },
          );
        }

        // 카테고리 배지 (BadgeEmoji 리스트)
        if (data is List<BadgeEmoji>) {
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.9,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final badge = data[index];
              return _buildBadgeEmojiButton(badge);
            },
          );
        }

        return Center(
          child: Text(
            '데이터 형식 오류',
            style: TextStyle(fontSize: 14.sp, color: current.fontSecondary),
          ),
        );
      },
    );
  }

  // 간단한 이모지 버튼 (자주 사용)
  Widget _buildSimpleEmojiButton(String emoji) {
    return GestureDetector(
      onTap: () {
        widget.onEmojiSelected(emoji);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: 36.sp)),
        ),
      ),
    );
  }

  // 배지 이모지 버튼 (카테고리별)
  Widget _buildBadgeEmojiButton(BadgeEmoji badge) {
    return GestureDetector(
      onTap: () {
        widget.onEmojiSelected('${badge.emoji} ${badge.name}');
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 4.h),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 11.sp,
                color: current.fontPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _loadEmojis(String categoryKey) async {
    try {
      // "자주 사용"인 경우 quickPicks에서 가져오기
      if (categoryKey == 'common') {
        return await BadgeEmojiService.getQuickPicks('common');
      }

      // 나머지는 카테고리별 배지에서 가져오기
      return await BadgeEmojiService.getBadgesByCategory(categoryKey);
    } catch (e) {
      debugPrint('Error loading emojis for $categoryKey: $e');
      rethrow;
    }
  }
}
