class MemberNickname {
  final String mNickname;

  MemberNickname({required this.mNickname});

  factory MemberNickname.fromJson(Map<String, dynamic> json) {
    return MemberNickname(mNickname: json['m_nickname']);
  }
}
