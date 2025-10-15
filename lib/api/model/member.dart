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
    mNum: (json['mnum'] as num?)?.toInt(), // JSON → Dart 매핑
    mId: json['mid'] as String,
    mPassword: json['mpassword'] as String,
    mName: json['mname'] as String,
    mNickname: json['mnickname'] as String,
    mEmail: json['memail'] as String,
    mProfileImage: json['mprofileImage'] as String?,
    mRole: json['mrole'] as String?,
  );

  Map<String, dynamic> toJson() => {
    // Dart → JSON 매핑
    'mid': mId,
    'mpassword': mPassword,
    'mname': mName,
    'mnickname': mNickname,
    'memail': mEmail,
    'mprofileImage': mProfileImage,
  };

  Map<String, dynamic> toJsonPaintOnly() => {
    'mid': mId,
    'mprofileImage': mProfileImage,
  };

  Map<String, dynamic> toJsonUpdate() => {
    // Dart → JSON 매핑
    'mname': mName,
    'mnickname': mNickname,
    'memail': mEmail,
    'mpassword': mPassword,
    'mid': mId,
  };
}
