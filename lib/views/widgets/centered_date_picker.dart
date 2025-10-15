import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:with_walk/theme/colors.dart';

/// 오늘을 중심으로 ±3일을 보여주는 날짜 선택 위젯
class CenteredDatePicker extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final Map<DateTime, bool>? recordDates; // 기록이 있는 날짜들

  const CenteredDatePicker({super.key, this.onDateSelected, this.recordDates});

  @override
  State<CenteredDatePicker> createState() => _CenteredDatePickerState();
}

class _CenteredDatePickerState extends State<CenteredDatePicker> {
  late DateTime centerDate; // 중심 날짜 (처음엔 오늘)
  late DateTime selectedDate;
  late ThemeColors current;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
    final now = DateTime.now();
    centerDate = DateTime(now.year, now.month, now.day); // 시간 제거
    selectedDate = centerDate;
    _initializeLocale();
  }

  // ✅ 한국어 로케일 초기화
  Future<void> _initializeLocale() async {
    await initializeDateFormatting('ko_KR', null);
    if (mounted) {
      setState(() => _isLocaleInitialized = true);
    }
  }

  // 중심 날짜 기준 ±3일 날짜 목록 생성
  List<DateTime> _getSevenDates() {
    return List.generate(7, (index) {
      return centerDate.add(Duration(days: index - 3));
    });
  }

  // 중심 날짜 이동 (스크롤 효과)
  void _moveCenter(int days) {
    setState(() {
      centerDate = centerDate.add(Duration(days: days));
      selectedDate = centerDate;
    });
    widget.onDateSelected?.call(centerDate);
  }

  // 오늘 날짜인지 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 선택된 날짜인지 확인
  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  // 중심 날짜인지 확인
  bool _isCenter(DateTime date) {
    return date.year == centerDate.year &&
        date.month == centerDate.month &&
        date.day == centerDate.day;
  }

  // 기록이 있는지 확인
  bool _hasRecord(DateTime date) {
    if (widget.recordDates == null) return false;
    return widget.recordDates!.keys.any(
      (recordDate) =>
          recordDate.year == date.year &&
          recordDate.month == date.month &&
          recordDate.day == date.day,
    );
  }

  // ✅ 토요일인지 확인
  bool _isSaturday(DateTime date) {
    return date.weekday == DateTime.saturday;
  }

  // ✅ 일요일인지 확인
  bool _isSunday(DateTime date) {
    return date.weekday == DateTime.sunday;
  }

  // ✅ 요일별 색상 가져오기
  Color _getWeekdayColor(DateTime date, bool isCenter) {
    if (isCenter) return current.bg; // 중심 날짜는 배경색

    if (_isSaturday(date)) {
      return Colors.blue; // 토요일 파란색
    } else if (_isSunday(date)) {
      return Colors.red; // 일요일 빨간색
    }
    return current.fontThird; // 평일 기본 색상
  }

  // ✅ 요일 이름 가져오기 (한국어)
  String _getWeekdayName(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[date.weekday % 7];
  }

  // ✅ 날짜 포맷 (한국어)
  String _formatDate(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 로케일 초기화 전에는 로딩 표시
    if (!_isLocaleInitialized) {
      return Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(child: CircularProgressIndicator(color: current.accent)),
      );
    }

    final dates = _getSevenDates();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 6.w),
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
        children: [
          // 헤더 (현재 월/년)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy년 MM월').format(centerDate),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: current.fontThird,
                ),
              ),
              // 오늘로 돌아가기 버튼
              if (!_isToday(centerDate))
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final now = DateTime.now();
                      centerDate = DateTime(now.year, now.month, now.day);
                      selectedDate = centerDate;
                    });
                    widget.onDateSelected?.call(centerDate);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: current.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.today, size: 14.sp, color: current.accent),
                        SizedBox(width: 4.w),
                        Text(
                          '오늘',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: current.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // 날짜 버튼들 (← 이전 3일 | 오늘(중심) | 이후 3일 →)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 화살표 (이전으로)
              GestureDetector(
                onTap: () => _moveCenter(-1),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: current.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: current.accent,
                    size: 18.sp,
                  ),
                ),
              ),

              // 7개 날짜 버튼
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final date = dates[index];
                    final isToday = _isToday(date);
                    final isCenter = _isCenter(date);
                    final isSelected = _isSelected(date);
                    final hasRecord = _hasRecord(date);
                    // final isPast = index < 3; // 과거 날짜
                    // final isFuture = index > 3; // 미래 날짜

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                          centerDate = date; // 선택하면 중심도 이동
                        });
                        widget.onDateSelected?.call(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: isCenter ? 45.w : 35.w,
                        height: isCenter ? 70.h : 60.h,
                        decoration: BoxDecoration(
                          color: isCenter
                              ? current.accent
                              : isSelected
                              ? current.accent.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isToday && !isCenter
                                ? current.accent.withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 요일 (✅ 토요일/일요일 색상 적용)
                            Text(
                              _getWeekdayName(date),
                              style: TextStyle(
                                fontSize: isCenter ? 11.sp : 10.sp,
                                color: _getWeekdayColor(date, isCenter),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // 날짜 (✅ 토요일/일요일 색상 적용)
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: isCenter ? 20.sp : 16.sp,
                                color: _getWeekdayColor(date, isCenter),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // 기록 표시
                            Container(
                              width: isCenter ? 6.w : 5.w,
                              height: isCenter ? 6.h : 5.h,
                              decoration: BoxDecoration(
                                color: hasRecord
                                    ? (isCenter ? current.bg : Colors.green)
                                    : Colors.transparent, // 기록 없으면 투명
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 오른쪽 화살표 (다음으로)
              GestureDetector(
                onTap: () => _moveCenter(1),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: current.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: current.accent,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 날짜 표시
          Text(
            _formatDate(selectedDate),
            style: TextStyle(
              fontSize: 14.sp,
              color: current.fontThird,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
