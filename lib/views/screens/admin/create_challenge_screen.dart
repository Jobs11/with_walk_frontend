import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:with_walk/api/model/challenge.dart';
import 'package:with_walk/api/service/challenge_service.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/views/widgets/emoji_picker_bottom_sheet.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  late ThemeColors current;

  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _rewardController = TextEditingController();

  // 선택 값
  String _selectedType = 'distance';
  String _selectedUnit = 'km';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    current = themeMap["라이트"]!;
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(43.h),
        child: WithWalkAppbar(
          titlename: "챌린지 생성",
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
                    _buildRewardField(),
                    SizedBox(height: 32.h),

                    // 생성 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: current.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: current.bg)
                            : Text(
                                '챌린지 생성',
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

  // 보상 필드 (이모지 선택 포함)
  Widget _buildRewardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '보상 (이모지 + 텍스트)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: current.fontPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rewardController,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '보상을 입력해주세요';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '예: 🏆 골드 뱃지',
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
            ),
            SizedBox(width: 8.w),

            // 이모지 선택 버튼
            Container(
              height: 56.h,
              width: 56.w,
              decoration: BoxDecoration(
                color: current.accent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.emoji_emotions,
                  color: current.bg,
                  size: 24.sp,
                ),
                onPressed: _showEmojiPicker,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        Text(
          '이모지 버튼을 눌러 배지를 선택하거나 직접 입력하세요',
          style: TextStyle(fontSize: 11.sp, color: current.fontThird),
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
          // 타입에 따라 기본 단위 변경
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
      firstDate: DateTime.now(),
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
          // 시작일이 종료일보다 늦으면 종료일 조정
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 이모지 선택 바텀시트 표시
  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerBottomSheet(
        onEmojiSelected: (selectedEmoji) {
          setState(() {
            // 기존 텍스트 처리
            if (_rewardController.text.isEmpty) {
              _rewardController.text = selectedEmoji;
            } else {
              final currentText = _rewardController.text;
              // 이모지가 이미 포함되어 있으면 교체, 없으면 추가
              final emojiRegex = RegExp(
                r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
                unicode: true,
              );

              if (currentText.contains(emojiRegex)) {
                // 기존 이모지 제거하고 새 이모지로 교체
                final textOnly = currentText.replaceAll(emojiRegex, '').trim();
                _rewardController.text = textOnly.isEmpty
                    ? selectedEmoji
                    : '$selectedEmoji $textOnly';
              } else {
                _rewardController.text = '$selectedEmoji $currentText';
              }
            }
          });
        },
      ),
    );
  }

  // 챌린지 생성
  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final challenge = Challenge(
        cNum: 0,
        cTitle: _titleController.text,
        cDescription: _descriptionController.text,
        cType: _selectedType,
        cTargetValue: int.parse(_targetValueController.text),
        cUnit: _selectedUnit,
        cStartDate: _startDate,
        cEndDate: _endDate,
        cReward: _rewardController.text,
        cStatus: '진행중',
        participantCount: 0,
        daysLeft: 0,
        isJoined: false,
        progress: 0.0,
        currentValue: 0,
      );

      final success = await ChallengeService.createChallenge(challenge);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지가 생성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true 반환하여 새로고침 트리거
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지 생성에 실패했습니다'),
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
