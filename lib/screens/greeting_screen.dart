import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../services/session_service.dart';
import '../widgets/bottom_nav_dock.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({super.key});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  final SessionService _sessionService = SessionService();

  void _navigateToChat([String? customPrompt]) {
    final session = _sessionService.createNewSession(
      customPrompt != null && customPrompt.length > 25
          ? '${customPrompt.substring(0, 25)}...'
          : customPrompt ?? 'Trò chuyện hướng nghiệp mới',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(session: session),
      ),
    ).then((_) => setState(() {}));
  }

  void _navigateToRecentChat() {
    final session = _sessionService.currentOrLatestSession;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(session: session)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final recentSessions = _sessionService.recentSessions;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C1D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào bạn 👋',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI Hướng nghiệp có thể giúp gì cho bạn?',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Cards Section
                  Row(
                    children: [
                      // Glowing Blue AI Card (Left)
                      Expanded(
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A1B54), Color(0xFF18153A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFF6C5CE7),
                                child: Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                              ),
                              const Text(
                                'Tư vấn chọn ngành & khối thi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () => _navigateToChat(),
                                child: const Text("Let's Talk", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right Column Cards
                      Expanded(
                        child: Column(
                          children: [
                            // Start new chat card
                            _buildSmallActionCard(
                              title: 'Bắt đầu chat mới',
                              icon: Icons.chat_bubble_outline_rounded,
                              onTap: () => _navigateToChat(),
                            ),
                            const SizedBox(height: 12),
                            // Search by topic card
                            _buildSmallActionCard(
                              title: 'Gợi ý ngành HOT 2026',
                              icon: Icons.explore_outlined,
                              onTap: () => _navigateToChat('Gợi ý cho mình các ngành học HOT nhất năm 2026 kèm khối thi'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Searches Title
                  const Text(
                    'Các cuộc trò chuyện gần đây',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5 Recent Chat Items
                  if (recentSessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Chưa có cuộc trò chuyện nào. Hãy nhấn nút + bên dưới để bắt đầu!',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentSessions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = recentSessions[index];
                        return _buildRecentChatTile(s);
                      },
                    ),
                ],
              ),
            ),

            // Floating Bottom Navigation Dock
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavDock(
                activeIndex: 1, // Let's use 1 for Greeting Screen
                onHomeTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                onNewChatTap: () => _navigateToChat(),
                onRecentChatTap: () => _navigateToRecentChat(),
                onExitTap: () {}, // Already on Greeting Screen
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1B192A),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 84,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(16),
          ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRecentChatTile(ChatSession session) {
    return Material(
      color: const Color(0xFF1B192A),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(session: session)),
          ).then((_) => setState(() {}));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            borderRadius: BorderRadius.circular(14),
          ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, color: Colors.cyanAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                session.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              session.formattedTime,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
          ],
        ),
      ),
      ),
    );
  }
}
