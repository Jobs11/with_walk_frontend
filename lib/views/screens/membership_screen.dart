import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:with_walk/api/model/member.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/dialogs/profile_change.dart';
import 'package:with_walk/views/screens/login_screen.dart';

class MembershipScreen extends StatefulWidget {
  final ThemeColors current;
  const MembershipScreen({required this.current, super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final conpasswordController = TextEditingController();
  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  String? selectedValue;
  bool showDropdown = false; // 드롭다운 표시 여부
  String? paint;
  bool isoverlap = false;
  Member? member;
  String? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _register() async {
    final member = Member(
      mId: idController.text.trim(),
      mPassword: passwordController.text.trim(),
      mName: nameController.text.trim(),
      mNickname: nicknameController.text.trim(),
      mEmail: '${emailController.text.trim()}@$selectedValue',
      mProfileImage: paint,
    );

    try {
      await Memberservice.registerMember(member); // 서버는 200/201만 주면 OK

      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "가입 완료!",
        toastLength: Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
        gravity: ToastGravity.BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
        backgroundColor: const Color(0xAA000000), // 반투명 검정
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );

      // 성공 시에만 페이지 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "가입 실패! $e",
        toastLength: Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
        gravity: ToastGravity.BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
        backgroundColor: const Color(0xAA000000), // 반투명 검정
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
      debugPrint("$e");
    } finally {}
  }

  Future<void> loadUser(String id) async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await Memberservice.userdata(id);
      setState(() {
        member = result;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(43.h),
          child: WithWalkAppbar(
            titlename: "회원가입",
            isBack: true,
            isColored: widget.current.app,
            fontColor: widget.current.fontThird,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final profileimage = await profileChange(
                        context,
                        title: '회원가입',
                      );

                      if (profileimage != null) {
                        setState(() {
                          paint = profileimage;
                        });
                      }
                    },
                    child: Image.asset(
                      paint ?? 'assets/images/icons/user.png',
                      fit: BoxFit.cover,
                      width: 120.w,
                      height: 120.h,
                    ),
                  ),
                  inputList("아이디", idController),
                  inputList("비밀번호", passwordController),
                  inputList("비밀번호 확인", conpasswordController),
                  inputList("이름", nameController),
                  inputList("닉네임", nicknameController),
                  emailInput(),

                  SizedBox(height: 24.h),
                  colorbtn(
                    "회원가입",
                    widget.current.bg,
                    widget.current.btn,
                    widget.current.btn,
                    200,
                    36,
                    () {
                      if (isoverlap == true) {
                        if (idController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty &&
                            nameController.text.isNotEmpty &&
                            nicknameController.text.isNotEmpty &&
                            emailController.text.isNotEmpty &&
                            selectedValue != null) {
                          if (passwordController.text ==
                              conpasswordController.text) {
                            _register();
                          } else {
                            Fluttertoast.showToast(
                              msg: "비밀번호가 서로 다릅니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: const Color(0xAA000000),
                              textColor: Colors.white,
                              fontSize: 16.0.sp,
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "정보를 다 입력해주시길 바랍니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color(0xAA000000),
                            textColor: Colors.white,
                            fontSize: 16.0.sp,
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "아이디 중복 검사를 해주세요.",
                          toastLength:
                              Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
                          gravity:
                              ToastGravity.BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
                          backgroundColor: const Color(0xAA000000), // 반투명 검정
                          textColor: Colors.white,
                          fontSize: 16.0.sp,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputList(String title, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: (title == '아이디')
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: widget.current.fontThird,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      colorbtn(
                        '중복 확인',
                        widget.current.accent,
                        widget.current.bg,
                        widget.current.accent,
                        80,
                        24,
                        () {
                          if (idController.text.isNotEmpty) {
                            loadUser(idController.text.trim());
                            if (member != null) {
                              Fluttertoast.showToast(
                                msg: "중복된 아이디입니다.",
                                toastLength:
                                    Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
                                gravity: ToastGravity
                                    .BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
                                backgroundColor: const Color(
                                  0xAA000000,
                                ), // 반투명 검정
                                textColor: Colors.white,
                                fontSize: 16.0.sp,
                              );
                              setState(() {
                                isoverlap = false;
                              });
                            } else {
                              Fluttertoast.showToast(
                                msg: "사용 가능한 아이디입니다.",
                                toastLength:
                                    Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
                                gravity: ToastGravity
                                    .BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
                                backgroundColor: const Color(
                                  0xAA000000,
                                ), // 반투명 검정
                                textColor: Colors.white,
                                fontSize: 16.0.sp,
                              );
                              setState(() {
                                isoverlap = true;
                              });
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: "아이디를 입력해주세요.",
                              toastLength:
                                  Toast.LENGTH_SHORT, // Toast.LENGTH_LONG 가능
                              gravity: ToastGravity
                                  .BOTTOM, // 위치 (TOP, CENTER, BOTTOM)
                              backgroundColor: const Color(
                                0xAA000000,
                              ), // 반투명 검정
                              textColor: Colors.white,
                              fontSize: 16.0.sp,
                            );
                          }
                        },
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: widget.current.fontThird,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(height: 4.h),
          inputdata(title, controller, widget.current, double.infinity),
        ],
      ),
    );
  }

  Widget emailInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              '이메일',
              style: TextStyle(
                fontSize: 16.sp,
                color: widget.current.fontThird,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150.w,
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: widget.current.bg,
                  border: Border.all(color: widget.current.accent),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none, // 테두리 제거 (BoxDecoration에서 그림)
                    hintText: "이메일", // 플레이스홀더
                    hintStyle: TextStyle(
                      color: widget.current.fontPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              Text(
                '@',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: 150.w,
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: widget.current.bg,
                  border: Border.all(color: widget.current.accent),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: DropdownButton<String>(
                        value: selectedValue,
                        hint: Text('선택하세요'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        items:
                            ['gmail.com', 'naver.com', 'nate.com', 'daum.net']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                            showDropdown = false; // 선택 후 목록 닫기
                          });
                        },
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
