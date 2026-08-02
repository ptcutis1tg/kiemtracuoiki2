import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../services/session_service.dart';
import '../widgets/bottom_nav_dock.dart';
import 'chat_screen.dart';
import 'greeting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionService _sessionService = SessionService();
  late Mentor _selectedMentor;

  @override
  void initState() {
    super.initState();
    _selectedMentor = _sessionService.currentMentor ?? Mentor.defaultMentors.first;
  }

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

  void _onMentorSelected(Mentor mentor) async {
    setState(() {
      _selectedMentor = mentor;
    });
    await _sessionService.setMentor(mentor);
  }

  @override
  Widget build(BuildContext context) {
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
                  // Title
                  const Text(
                    'Discovery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Khám phá quân sư và ngành nghề phù hợp',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Phần 1: Chọn Quân Sư
                  const Text(
                    'Chọn Quân Sư AI',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Container bọc ListView của Quân sư
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B192A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Mentor.defaultMentors.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final mentor = Mentor.defaultMentors[index];
                        final isSelected = mentor.id == _selectedMentor.id;
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          onTap: () => _onMentorSelected(mentor),
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                                  : [],
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(mentor.imageAsset),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          title: Text(
                            mentor.name,
                            style: TextStyle(
                              color: isSelected ? Colors.cyanAccent : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            mentor.description,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Colors.cyanAccent)
                            : const Icon(Icons.circle_outlined, color: Colors.white24),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Phần 2: Top ngành nghề HOT 2026
                  const Text(
                    '🔥 Top Ngành Nghề HOT 2026',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCareerList([
                    {'title': 'Trí tuệ nhân tạo (AI)', 'desc': 'Kỹ sư AI, Machine Learning'},
                    {'title': 'Digital Marketing', 'desc': 'Content Creator, Chạy Ads, SEO'},
                    {'title': 'Phân tích Dữ liệu (Data)', 'desc': 'Data Analyst, Data Scientist'},
                  ]),

                  const SizedBox(height: 32),

                  // Phần 3: Top ngành nghề ổn định
                  const Text(
                    '🛡️ Top Ngành Nghề Ổn Định',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCareerList([
                    {'title': 'Y Khoa & Dược học', 'desc': 'Bác sĩ, Dược sĩ, Điều dưỡng'},
                    {'title': 'Sư Phạm', 'desc': 'Giáo viên, Giảng viên đại học'},
                    {'title': 'Kế toán - Kiểm toán', 'desc': 'Kế toán trưởng, Kiểm toán viên'},
                  ]),
                ],
              ),
            ),

            // Floating Bottom Navigation Dock
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavDock(
                activeIndex: 0,
                onHomeTap: () {},
                onNewChatTap: () => _navigateToChat(),
                onRecentChatTap: () => _navigateToRecentChat(),
                onExitTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const GreetingScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerList(List<Map<String, String>> careers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: careers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final career = careers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B192A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career['title']!,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      career['desc']!,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  foregroundColor: Colors.blueAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => _navigateToChat('Gợi ý cho mình về ngành ${career['title']}'),
                child: const Text('Hỏi ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          ),
        );
      },
    );
  }
}
