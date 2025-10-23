import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Asset과 Network URL을 자동으로 구분하여 표시하는 프로필 이미지 위젯
class SmartProfileImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;

  const SmartProfileImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/foots/cat.png', // 기본 이미지
  });

  @override
  Widget build(BuildContext context) {
    // URL이 http:// 또는 https://로 시작하면 Network 이미지
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) {
          // 에러 시 fallback Asset 이미지 표시
          return Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }

    // 그 외에는 Asset 이미지
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Asset 로드 실패 시 fallback 이미지
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}

/// CircleAvatar용 SmartProfileImage
class SmartProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final String fallbackAsset;

  const SmartProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 50,
    this.fallbackAsset = 'assets/images/foots/cat.png',
  });

  @override
  Widget build(BuildContext context) {
    // Network URL인 경우
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (context, url, error) {
              return Image.asset(
                fallbackAsset,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      );
    }

    // Asset 이미지인 경우
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: AssetImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // 에러 시 로그 출력
        debugPrint('프로필 이미지 로드 실패: $exception');
      },
    );
  }
}
