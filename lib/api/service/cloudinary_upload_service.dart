// lib/api/service/cloudinary_upload_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryUploadService {
  // ✅ Cloudinary Dashboard에서 확인한 값으로 변경하세요!
  static const String cloudName = 'dvlvt2pms'; // 예: dxxxxx1234
  static const String uploadPreset = 'with_walk_upload'; // 위에서 만든 preset 이름

  final ImagePicker _picker = ImagePicker();

  /// 단일 이미지 업로드 (갤러리/카메라)
  Future<String?> uploadImage({
    required String userId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // 1. 이미지 선택
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('⚠️ 이미지 선택 취소');
        return null;
      }

      debugPrint('📤 이미지 업로드 시작...');

      // 2. Cloudinary API 요청
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      // 파일 추가
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      // 업로드 설정
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'with_walk/posts';
      request.fields['public_id'] =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // 3. 업로드 실행
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        final imageUrl = data['secure_url'] as String;

        debugPrint('✅ Cloudinary 업로드 성공!');
        debugPrint('📸 URL: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('🚨 업로드 실패: ${response.statusCode}');
        debugPrint('응답: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 업로드 에러: $e');
      return null;
    }
  }

  /// 여러 이미지 업로드 (피드용, 최대 5장)
  Future<List<String>> uploadMultipleImages({
    required String userId,
    int maxImages = 5,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        debugPrint('⚠️ 이미지 선택 취소');
        return [];
      }

      final selectedImages = images.take(maxImages).toList();
      List<String> urls = [];

      debugPrint('📤 ${selectedImages.length}장 업로드 시작...');

      for (var i = 0; i < selectedImages.length; i++) {
        final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        );

        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          await http.MultipartFile.fromPath('file', selectedImages[i].path),
        );

        request.fields['upload_preset'] = uploadPreset;
        request.fields['folder'] = 'with_walk/posts';
        request.fields['public_id'] =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i';

        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseData);
          urls.add(data['secure_url'] as String);
          debugPrint('✅ ${i + 1}/${selectedImages.length} 업로드 완료');
        } else {
          debugPrint('🚨 ${i + 1}번째 이미지 업로드 실패');
        }
      }

      return urls;
    } catch (e) {
      debugPrint('🚨 다중 업로드 실패: $e');
      return [];
    }
  }

  /// 프로필 사진 업로드 (정사각형)
  Future<String?> uploadProfileImage(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (image == null) return null;

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'with_walk/profiles';
      request.fields['public_id'] = userId;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return data['secure_url'] as String;
      }

      return null;
    } catch (e) {
      debugPrint('🚨 프로필 업로드 실패: $e');
      return null;
    }
  }

  /// 이미지 삭제 (Cloudinary는 무료 플랜에서 삭제 API 제한적)
  /// 대신 Dashboard에서 수동 삭제 권장
  Future<bool> deleteImage(String publicId) async {
    debugPrint('⚠️ Cloudinary 무료 플랜은 삭제 API 제한적');
    debugPrint('Dashboard에서 수동 삭제: https://cloudinary.com/console');
    return false;
  }
}
