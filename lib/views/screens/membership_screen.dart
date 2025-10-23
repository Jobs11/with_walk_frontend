import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:with_walk/api/model/member.dart';

import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/functions/widegt_fn.dart';
import 'package:with_walk/views/bars/with_walk_appbar.dart';
import 'package:with_walk/theme/colors.dart';
import 'package:with_walk/views/dialogs/profile_change.dart';

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
  final lastemailController = TextEditingController();

  String? selectedValue;
  bool showDropdown = false; // 드롭다운 표시 여부
  bool isoverlap = false;
  Member? member;
  Member? memberNickname;
  String? error;
  bool isLoading = false;
  bool isNick = false;

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
      mEmail:
          '${emailController.text.trim()}@${lastemailController.text.trim()}',
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

  Future<void> loadNick(String nickname) async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await Memberservice.checkNick(nickname);
      setState(() {
        memberNickname = result;
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
            current: widget.current,
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
                  inputList("아이디", idController, (v) {}),
                  inputList("비밀번호", passwordController, (v) {}),
                  inputList("비밀번호 확인", conpasswordController, (v) {}),
                  inputList("이름", nameController, (v) {}),
                  inputList("닉네임", nicknameController, (v) async {
                    if (v.isNotEmpty) {
                      setState(() {
                        memberNickname = null; // ✅ 새 입력마다 이전 결과 초기화
                      });

                      await loadNick(v.trim()); // ✅ loadNick이 완료될 때까지 기다림
                      debugPrint(
                        'v: $v,   nickname: ${memberNickname?.mNickname}',
                      );

                      setState(() {
                        isNick = memberNickname != null ? false : true;
                      });
                    }
                  }),
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
                      if (isoverlap == true && isNick == true) {
                        if (idController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty &&
                            nameController.text.isNotEmpty &&
                            nicknameController.text.isNotEmpty &&
                            emailController.text.isNotEmpty &&
                            lastemailController.text.isNotEmpty) {
                          if (passwordController.text ==
                              conpasswordController.text) {
                            _register();
                            profileChange(
                              context,
                              title: '회원가입',
                              userId: idController.text.trim(), // ✅ 입력한 ID 전달
                            );
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
                          msg: "아이디 혹은 닉네임 중복 검사를 해주세요.",
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

  Widget inputList(
    String title,
    TextEditingController controller,
    void Function(String)? onChange,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: (title == '아이디' || title == '닉네임')
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
                      (title == '아이디')
                          ? colorbtn(
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
                                      toastLength: Toast
                                          .LENGTH_SHORT, // Toast.LENGTH_LONG 가능
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
                                      toastLength: Toast
                                          .LENGTH_SHORT, // Toast.LENGTH_LONG 가능
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
                                    toastLength: Toast
                                        .LENGTH_SHORT, // Toast.LENGTH_LONG 가능
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
                            )
                          : Text(
                              isNick ? '사용가능한 닉네임입니다.' : '중복된 닉네임입니다.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: widget.current.fontThird,
                                fontWeight: FontWeight.bold,
                              ),
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
          inputdata(
            title,
            controller,
            widget.current,
            double.infinity,
            onChange: onChange,
          ),
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
                width: 100.w,
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

                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              Text(
                '@',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: 100.w,
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: widget.current.bg,
                  border: Border.all(color: widget.current.accent),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextFormField(
                  controller: lastemailController,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none, // 테두리 제거 (BoxDecoration에서 그림)
                    hintText: "xxx.co.kr", // 플레이스홀더
                    hintStyle: TextStyle(
                      color: widget.current.fontPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              Container(
                width: 110.w,
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: widget.current.bg,
                  border: Border.all(color: widget.current.accent),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
                  child: DropdownButton<String>(
                    value: selectedValue,
                    hint: Text('선택'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    items:
                        [
                              '기본 값',
                              'gmail.com',
                              'naver.com',
                              'nate.com',
                              'daum.net',
                            ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),

                    onChanged: (value) {
                      setState(() {
                        if (value == "기본 값") {
                          selectedValue = null;
                          lastemailController.text = selectedValue ?? '';
                        } else {
                          selectedValue = value;
                          lastemailController.text = value!;
                        }
                        showDropdown = false; // 선택 후 목록 닫기
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
