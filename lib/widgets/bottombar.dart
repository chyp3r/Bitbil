import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(1),
            icon: Icon(
              Icons.camera_alt_outlined,
              color: currentIndex == 1 ? Colors.black : Colors.grey,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => onTap(0),
            icon: Icon(
              Icons.home_outlined,
              color: currentIndex == 0 ? Colors.black : Colors.grey,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => onTap(2),
            icon: Icon(
              Icons.chat_outlined,
              color: currentIndex == 2 ? Colors.black : Colors.grey,
              size: 28,
            ),
          ),
          
        ],
      ),
    );
  }
}
