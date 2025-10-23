import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/challenge.dart';
import 'package:with_walk/api/service/challenge_service.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';

class EditChallengeScreen extends StatefulWidget {
  final Challenge challenge;

  const EditChallengeScreen({super.key, required this.challenge});

  @override
  State<EditChallengeScreen> createState() => _EditChallengeScreenState();
}

class _EditChallengeScreenState extends State<EditChallengeScreen> {
  late ThemeColors current;

  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;
  late TextEditingController _rewardController;

  // 선택 값
  late String _selectedType;
  late String _selectedUnit;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedStatus;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;

    // 기존 챌린지 데이터로 초기화
    _titleController = TextEditingController(text: widget.challenge.cTitle);
    _descriptionController = TextEditingController(
      text: widget.challenge.cDescription,
    );
    _targetValueController = TextEditingController(
      text: widget.challenge.cTargetValue.toString(),
    );
    _rewardController = TextEditingController(text: widget.challenge.cReward);

    _selectedType = widget.challenge.cType;
    _selectedUnit = widget.challenge.cUnit;
    _startDate = widget.challenge.cStartDate;
    _endDate = widget.challenge.cEndDate;
    _selectedStatus = widget.challenge.cStatus;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "챌린지 수정",
            isBack: true,
            current: current,
          ),
        ),
        body: Stack(
          children: [
            // 배경
            Positioned.fill(
              child: Image.asset(
                "assets/images/bgs/background.png",
                fit: BoxFit.cover,
              ),
            ),

            // 메인 콘텐츠
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      _buildTextField(
                        controller: _titleController,
                        label: '챌린지 제목',
                        hint: '예: 11월 100km 걷기',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 설명
                      _buildTextField(
                        controller: _descriptionController,
                        label: '챌린지 설명',
                        hint: '예: 한 달 동안 총 100km를 걸어보세요!',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '설명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 챌린지 타입
                      _buildSectionTitle('챌린지 타입'),
                      SizedBox(height: 8.h),
                      _buildTypeSelector(),
                      SizedBox(height: 16.h),

                      // 목표값
                      _buildTextField(
                        controller: _targetValueController,
                        label: '목표값',
                        hint: '예: 100',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '목표값을 입력해주세요';
                          }
                          if (int.tryParse(value) == null) {
                            return '숫자만 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 단위
                      _buildSectionTitle('단위'),
                      SizedBox(height: 8.h),
                      _buildUnitSelector(),
                      SizedBox(height: 16.h),

                      // 시작일
                      _buildDateSelector(
                        label: '시작일',
                        date: _startDate,
                        onTap: () => _selectDate(context, true),
                      ),
                      SizedBox(height: 16.h),

                      // 종료일
                      _buildDateSelector(
                        label: '종료일',
                        date: _endDate,
                        onTap: () => _selectDate(context, false),
                      ),
                      SizedBox(height: 16.h),

                      // 보상
                      _buildTextField(
                        controller: _rewardController,
                        label: '보상 (이모지 + 텍스트)',
                        hint: '예: 🏆 골드 뱃지',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '보상을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 상태
                      _buildSectionTitle('챌린지 상태'),
                      SizedBox(height: 8.h),
                      _buildStatusSelector(),
                      SizedBox(height: 32.h),

                      // 수정 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: current.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: current.bg)
                              : Text(
                                  '수정 완료',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: current.bg,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: current.fontPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: current.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: current.accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: current.fontPrimary,
      ),
    );
  }

  // 타입 선택
  Widget _buildTypeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTypeButton('거리', 'distance')),
          Expanded(child: _buildTypeButton('빈도', 'frequency')),
          Expanded(child: _buildTypeButton('시간', 'duration')),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          if (value == 'distance') {
            _selectedUnit = 'km';
          } else if (value == 'frequency') {
            _selectedUnit = '일';
          } else {
            _selectedUnit = '시간';
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? current.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? current.bg : current.fontPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // 단위 선택
  Widget _buildUnitSelector() {
    List<String> units;
    if (_selectedType == 'distance') {
      units = ['km', 'm'];
    } else if (_selectedType == 'frequency') {
      units = ['일', '회'];
    } else {
      units = ['시간', '분'];
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: units
            .map(
              (unit) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUnit = unit;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedUnit == unit
                          ? current.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: _selectedUnit == unit
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedUnit == unit
                              ? current.bg
                              : current.fontPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // 상태 선택
  Widget _buildStatusSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: current.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatusButton('진행중', '진행중')),
          Expanded(child: _buildStatusButton('종료', '종료')),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? current.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? current.bg : current.fontPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // 날짜 선택
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: current.fontPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: current.bg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.year}년 ${date.month}월 ${date.day}일',
                  style: TextStyle(fontSize: 14.sp, color: current.fontPrimary),
                ),
                Icon(Icons.calendar_today, size: 20.sp, color: current.accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: current.accent)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 챌린지 수정
  Future<void> _updateChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedChallenge = Challenge(
        cNum: widget.challenge.cNum, // ✅ 기존 ID 유지
        cTitle: _titleController.text,
        cDescription: _descriptionController.text,
        cType: _selectedType,
        cTargetValue: int.parse(_targetValueController.text),
        cUnit: _selectedUnit,
        cStartDate: _startDate,
        cEndDate: _endDate,
        cReward: _rewardController.text,
        cStatus: _selectedStatus,
        cCreatedAt: widget.challenge.cCreatedAt,
        cUpdatedAt: DateTime.now(),
        participantCount: widget.challenge.participantCount,
        daysLeft: widget.challenge.daysLeft,
        isJoined: widget.challenge.isJoined,
        progress: widget.challenge.progress,
        currentValue: widget.challenge.currentValue,
      );

      final success = await ChallengeService.updateChallenge(updatedChallenge);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지가 수정되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true 반환하여 새로고침 트리거
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지 수정에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
