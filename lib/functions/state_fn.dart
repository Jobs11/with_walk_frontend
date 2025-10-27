import 'package:flutter/material.dart';

String formatTime(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    // 1시간 이상
    return "$hours시간 $minutes분 $seconds초";
  } else if (minutes > 0) {
    // 1분 이상 1시간 미만
    return "$minutes분 $seconds초";
  } else {
    // 1분 미만
    return "$seconds초";
  }
}

void openScreen(BuildContext context, WidgetBuilder builder) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

String formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.toStringAsFixed(0)}m';
  }
  return '${(meters / 1000).toStringAsFixed(2)}km';
}

String formatStreetTime(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
