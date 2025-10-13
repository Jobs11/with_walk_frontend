import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/widgets/centered_date_picker.dart';

class WalkingStorageScreen extends StatefulWidget {
  const WalkingStorageScreen({super.key});

  @override
  State<WalkingStorageScreen> createState() => _WalkingStorageScreenState();
}

class _WalkingStorageScreenState extends State<WalkingStorageScreen> {
  late ThemeColors current;
  DateTime selectedDate = DateTime.now();
  Map<DateTime, bool> recordDates = {};

  late Future<List<Street>> streets;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    _loadRecordDates();
    streets = StreetService.getStreetList(
      CurrentUser.instance.member!.mId,
      '${selectedDate.month}-${selectedDate.day}',
    );
  }

  Future<void> _loadRecordDates() async {
    try {
      final records = await StreetService.getStreetAllList(
        CurrentUser.instance.member!.mId,
      );

      // ✅ 중복 없는 날짜 집합
      final Set<DateTime> dateSet = {};

      for (var record in records) {
        if (record.rDate == null) continue;

        final date = DateTime.parse(record.rDate.toString());

        // 시, 분, 초 제거 → 하루 단위로 통일
        final normalized = DateTime(date.year, date.month, date.day);

        // Set은 중복 자동 제거됨
        dateSet.add(normalized);
      }

      // ✅ Map으로 변환 (캘린더에서 true/false로 쓰기 위함)
      setState(() {
        recordDates = {for (var d in dateSet) d: true};
      });

      debugPrint("📅 기록 날짜 ${recordDates.keys}");
    } catch (e, st) {
      debugPrint('⚠️ _loadRecordDates() 오류: $e');
      debugPrint('$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "남긴 발자국",
          isBack: false,
          isColored: current.app,
          fontColor: current.fontThird,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bgs/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // 날짜 선택기
                  CenteredDatePicker(
                    recordDates: recordDates,
                    onDateSelected: (date) {
                      setState(() => selectedDate = date);
                      streets = StreetService.getStreetList(
                        CurrentUser.instance.member!.mId,
                        '${selectedDate.month}-${selectedDate.day}',
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  // 선택된 날짜의 운동 기록
                  SizedBox(
                    width: double.infinity,
                    height: 300.h,
                    child: _buildDayRecords(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRecords() {
    return FutureBuilder<List<Street>>(
      future: streets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_walk_outlined,
                  size: 60.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '오류가 발생해서 운동 기록을 불러올 수 없습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? const <Street>[];
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_walk_outlined,
                  size: 60.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '이 날의 운동 기록이 없습니다',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // ✅ 해결: Column 대신 ListView.builder 직접 사용
        return ListView.builder(
          itemCount: items.length + 1, // 제목용 +1
          itemBuilder: (context, index) {
            // 첫 번째 아이템은 제목
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  '운동 기록 (${items.length})',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontThird,
                  ),
                ),
              );
            }

            // 나머지는 카드
            return _buildRecordCard(items[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildRecordCard(Street s) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          Row(
            children: [
              Icon(Icons.access_time, size: 16.sp, color: current.accent),
              SizedBox(width: 8.w),
              Text(
                '${DateFormat('MM. dd. HH:mm:ss').format(s.rStartTime)} - ${DateFormat('MM. dd. HH:mm:ss').format(s.rEndTime)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: current.fontThird,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn('거리', '${s.rDistance} km'),
              _statColumn('시간', formatTime(int.parse(s.rTime))),
              _statColumn('칼로리', '${s.rKcal} kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: current.fontPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: current.accent,
          ),
        ),
      ],
    );
  }
}
