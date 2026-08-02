import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Only for Sign up
  
  bool _isLoading = false;
  bool _isSignUpMode = false;
  
  @override
  void initState() {
    super.initState();
    // Rebuild when auth state changes
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu')),
      );
      return;
    }

    if (_isSignUpMode && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Họ Tên')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUpMode) {
        await _authService.signUpWithEmailPassword(email, password, name);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra email để xác thực (nếu yêu cầu).')),
        );
      } else {
        await _authService.signInWithEmailPassword(email, password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = _authService.isLoggedIn;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161426),
        title: Text(
          isLogged ? 'Hồ Sơ Của Bạn' : 'Đăng Nhập',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isLogged ? _buildProfileView() : _buildLoginView(),
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    final user = _authService.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'Người dùng';
    final email = user?.email ?? 'Chưa cập nhật email';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.purpleAccent]),
            boxShadow: [
              BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF161426),
            child: Icon(Icons.person, size: 50, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          fullName,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 48),
        
        // Cài đặt / Thông tin khác
        _buildProfileTile(Icons.history, 'Lịch sử tư vấn'),
        _buildProfileTile(Icons.settings, 'Cài đặt tài khoản'),
        _buildProfileTile(Icons.shield_outlined, 'Chính sách bảo mật'),
        
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () async {
            await _authService.signOut();
          },
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text('Đăng Xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B192A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
        onTap: () {},
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          _isSignUpMode ? 'Đăng Ký Tài Khoản' : 'Mừng Trở Lại! 👋',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUpMode ? 'Tạo tài khoản để lưu trữ lịch sử tư vấn.' : 'Đăng nhập để tiếp tục câu chuyện dang dở.',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 48),

        if (_isSignUpMode) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Họ và Tên',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
        ],

        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        
        const SizedBox(height: 48),

        _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
            : ElevatedButton(
                onPressed: _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.cyanAccent.withValues(alpha: 0.5),
                ),
                child: Text(
                  _isSignUpMode ? 'ĐĂNG KÝ' : 'ĐĂNG NHẬP',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isSignUpMode = !_isSignUpMode;
              });
            },
            child: Text(
              _isSignUpMode ? 'Đã có tài khoản? Đăng nhập ngay' : 'Chưa có tài khoản? Đăng ký',
              style: const TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1B192A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
      ),
    );
  }
}
