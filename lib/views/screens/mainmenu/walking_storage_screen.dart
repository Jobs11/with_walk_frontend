import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:with_walk/api/model/street.dart';
import 'package:with_walk/api/model/weekly_goal.dart';
import 'package:with_walk/api/service/street_service.dart';
import 'package:with_walk/api/service/weekly_goal_service.dart';
import 'package:with_walk/functions/data.dart';
import 'package:with_walk/functions/state_fn.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/widgets/centered_date_picker.dart';

class WalkingStorageScreen extends StatefulWidget {
  const WalkingStorageScreen({super.key});

  @override
  State<WalkingStorageScreen> createState() => _WalkingStorageScreenState();
}

class _WalkingStorageScreenState extends State<WalkingStorageScreen> {
  final current = ThemeManager().current;
  DateTime selectedDate = DateTime.now();
  Map<DateTime, bool> recordDates = {};

  late Future<List<Street>> streets;
  WeeklyGoal? weeklyGoal; // 주간 목표
  double weeklyTotalKm = 0.0; // 이번 주 총 거리

  @override
  void initState() {
    super.initState();

    _loadRecordDates();
    _loadWeeklyGoal();
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

      final Set<DateTime> dateSet = {};

      for (var record in records) {
        if (record.rDate == null) continue;
        final date = DateTime.parse(record.rDate.toString());
        final normalized = DateTime(date.year, date.month, date.day);
        dateSet.add(normalized);
      }

      setState(() {
        recordDates = {for (var d in dateSet) d: true};
      });

      // 주간 총 거리 계산
      _calculateWeeklyTotal(records);
    } catch (e, st) {
      debugPrint('⚠️ _loadRecordDates() 오류: $e');
      debugPrint('$st');
    }
  }

  // 이번 주 총 거리 계산
  void _calculateWeeklyTotal(List<Street> records) {
    final monday = WeeklyGoalService.getCurrentMondayDate();
    final sunday = WeeklyGoalService.getCurrentSundayDate();

    double total = 0.0;
    for (var record in records) {
      if (record.rDate == null) continue;
      final date = DateTime.parse(record.rDate.toString());
      final normalized = DateTime(date.year, date.month, date.day);

      // 이번 주 범위 내인지 확인
      if ((normalized.isAfter(monday) || normalized.isAtSameMomentAs(monday)) &&
          (normalized.isBefore(sunday) ||
              normalized.isAtSameMomentAs(sunday))) {
        total += double.tryParse(record.rDistance.toString()) ?? 0.0;
      }
    }

    setState(() {
      weeklyTotalKm = total;
    });

    debugPrint('📊 이번 주 총 거리: $weeklyTotalKm');
  }

  // 주간 목표 불러오기
  Future<void> _loadWeeklyGoal() async {
    try {
      final goal = await WeeklyGoalService.getCurrentWeeklyGoal(
        CurrentUser.instance.member!.mId,
      );
      setState(() {
        weeklyGoal = goal;
      });
      debugPrint('🎯 주간 목표: ${goal.wgGoalKm} km');
    } catch (e) {
      debugPrint('⚠️ 주간 목표 조회 오류: $e');
    }
  }

  // 주간 목표 설정 다이얼로그
  Future<void> _showGoalDialog() async {
    final TextEditingController controller = TextEditingController(
      text: weeklyGoal?.wgGoalKm.toString() ?? '0',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '주간 목표 설정',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '목표 거리 (km)',
            hintText: '예: 20',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final goalKm = double.tryParse(controller.text) ?? 0.0;
              if (goalKm <= 0) {
                Fluttertoast.showToast(msg: '0보다 큰 값을 입력하세요');
                return;
              }

              try {
                await WeeklyGoalService.setWeeklyGoal(
                  CurrentUser.instance.member!.mId,
                  goalKm,
                );
                await _loadWeeklyGoal();
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                Fluttertoast.showToast(msg: '주간 목표가 설정되었습니다!');
              } catch (e) {
                Fluttertoast.showToast(msg: '목표 설정 실패: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: current.accent),
            child: Text('설정', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _update(int rNum) async {
    try {
      await StreetService.deleteS(rNum);
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "발자취 삭제 완료!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );

      // 삭제 후 주간 총 거리 다시 계산
      await _loadRecordDates();
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "발자취 삭제 실패!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xAA000000),
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
      debugPrint('발자취: $e');
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
          current: current,
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
                  // 🎯 주간 목표 위젯
                  _buildWeeklyGoalWidget(),

                  SizedBox(height: 20.h),

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

  // 🎯 주간 목표 위젯
  Widget _buildWeeklyGoalWidget() {
    final goalKm = weeklyGoal?.wgGoalKm ?? 0.0;
    final currentKm = weeklyTotalKm / 1000; // 👈 m를 km로 변환
    final progress = goalKm > 0 ? (currentKm / goalKm).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: _showGoalDialog,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [current.accent, current.accent.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: current.accent.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번 주 목표',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.edit, size: 20.sp, color: Colors.white70),
              ],
            ),
            SizedBox(height: 12.h),

            // 목표 거리
            Text(
              '목표: ${goalKm.toStringAsFixed(1)} km',
              style: TextStyle(fontSize: 14.sp, color: Colors.white70),
            ),
            SizedBox(height: 8.h),

            // 현재 거리
            Row(
              children: [
                Text(
                  currentKm.toStringAsFixed(1), // 👈 변환된 km 사용
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'km',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 프로그레스 바
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8.h,
              ),
            ),
            SizedBox(height: 8.h),

            // 남은 거리
            if (goalKm > 0)
              Text(
                currentKm >=
                        goalKm // 👈 변환된 km 사용
                    ? '🎉 목표 달성!'
                    : '남은 거리: ${(goalKm - currentKm).toStringAsFixed(1)} km', // 👈 변환된 km 사용
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
          ],
        ),
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

        return ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
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
              Expanded(
                child: Text(
                  '${DateFormat('MM. dd. HH:mm:ss').format(s.rStartTime)} - ${DateFormat('MM. dd. HH:mm:ss').format(s.rEndTime)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: current.fontThird,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20.sp),
                color: Colors.red.withValues(alpha: 0.7),
                onPressed: () {
                  _update(s.rNum!);
                  setState(() {
                    streets = StreetService.getStreetList(
                      CurrentUser.instance.member!.mId,
                      '${selectedDate.month}-${selectedDate.day}',
                    );
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn('거리', '${formatDistance(s.rDistance)} '),
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
