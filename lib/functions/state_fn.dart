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
