class MemberProfile {
  final String mId;
  final String mProfileImage;

  MemberProfile({required this.mId, required this.mProfileImage});

  Map<String, dynamic> toJsonPaintOnly() => {
    'mid': mId,
    'mprofileImage': mProfileImage,
  };
}
