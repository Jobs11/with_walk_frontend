class Member {
  final int? mNum; // Dart 규칙: lowerCamelCase
  final String mId;
  final String mPassword;
  final String mName;
  final String mNickname;
  final String mEmail;
  final String? mProfileImage;
  final String? mRole;

  const Member({
    this.mNum,
    required this.mName,
    required this.mNickname,
    required this.mEmail,
    required this.mId,
    required this.mPassword,
    this.mProfileImage,
    this.mRole,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    mNum: (json['m_num'] as num?)?.toInt(), // JSON → Dart 매핑
    mId: json['m_id'] as String,
    mPassword: json['m_password'] as String,
    mName: json['m_name'] as String,
    mNickname: json['m_nickname'] as String,
    mEmail: json['m_email'] as String,
    mProfileImage: json['m_profile_image'] as String?,
    mRole: json['m_role'] as String?,
  );

  Map<String, dynamic> toJson() => {
    // Dart → JSON 매핑
    'm_id': mId,
    'm_password': mPassword,
    'm_name': mName,
    'm_nickname': mNickname,
    'm_email': mEmail,
    'm_profile_image': mProfileImage,
  };

  Map<String, dynamic> toJsonPaintOnly() => {
    'm_id': mId,
    'm_profile_image': mProfileImage,
  };

  Map<String, dynamic> toJsonUpdate() => {
    // Dart → JSON 매핑
    'm_name': mName,
    'm_nickname': mNickname,
    'm_email': mEmail,
    'm_password': mPassword,
    'm_id': mId,
  };
}
