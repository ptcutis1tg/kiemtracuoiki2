import 'package:flutter/material.dart';

class BottomNavDock extends StatelessWidget {
  final int activeIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onNewChatTap;
  final VoidCallback onRecentChatTap;

  const BottomNavDock({
    super.key,
    required this.activeIndex,
    required this.onHomeTap,
    required this.onNewChatTap,
    required this.onRecentChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 48, right: 48),
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C2A),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home Icon (now Discovery)
          IconButton(
            icon: Icon(
              Icons.explore_rounded,
              color: activeIndex == 0 ? Colors.white : Colors.white38,
              size: 26,
            ),
            onPressed: onHomeTap,
          ),

          // Glowing Neon Center '+' Button
          GestureDetector(
            onTap: onNewChatTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFC6FF00), // Lime Neon
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC6FF00).withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),

          // Messages / Recent Chat Icon
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: activeIndex == 2 ? Colors.white : Colors.white38,
              size: 24,
            ),
            onPressed: onRecentChatTap,
          ),
        ],
      ),
    );
  }
}
