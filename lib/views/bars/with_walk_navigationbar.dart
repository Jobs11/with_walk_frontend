import 'package:flutter/material.dart';
import 'package:with_walk/theme/colors.dart';

class WithWalkNavigationbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeColors current;

  const WithWalkNavigationbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: current.btn,
      unselectedItemColor: current.fontThird,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk),
          label: '발걸음',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: '남긴 발자국'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '길건너 친구들'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '발자국 주인공'),
      ],
    );
  }
}
