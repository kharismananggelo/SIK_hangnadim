import 'package:flutter/material.dart';
import '../widgets/sweet_alert_dialog.dart';
import 'loginpage.dart';
import '../services/auth_service.dart';
import '../utils/storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'John Doe';
  String userEmail = 'john.doe@hangnadim.com';
  String userPosition = 'Manager Operasional';
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _authService.getMe();
      setState(() {
        userName = user.name;
        userEmail = user.email;
        userPosition = user.role;
      });
    } catch (e) {
      // If loading fails, keep defaults and log the error
      print('Failed to load profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // ignore
    }
    await Storage.clearToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  void _showLogoutConfirmation() {
    SweetAlert.showWarning(
      context: context,
      title: 'Logout',
      message: 'Apakah Anda yakin ingin logout?',
      onConfirm: () {
        _logout();
      },
      confirmText: 'Ya, Logout',
      cancelText: 'Batal',
    );
  }

  void _showInfo(String title, String message) {
    SweetAlert.showInfo(context: context, title: title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userPosition,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showInfo(
                            'Edit Profile',
                            'Fitur edit profile akan segera datang!',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Edit Profile'),
                        ),
                      ],
                    ),
            ),

            SizedBox(height: 24),

            // Menu Utama
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.notifications_active,
                    title: 'Notifikasi',
                    subtitle: 'Kelola notifikasi aplikasi',
                    onTap: () => _showInfo(
                      'Notifikasi',
                      'Pengaturan notifikasi akan segera tersedia',
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.security,
                    title: 'Keamanan',
                    subtitle: 'Password dan keamanan akun',
                    onTap: () => _showInfo(
                      'Keamanan',
                      'Fitur keamanan akun sedang dalam pengembangan',
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.language,
                    title: 'Bahasa',
                    subtitle: 'Pilih bahasa aplikasi',
                    onTap: () =>
                        _showInfo('Bahasa', 'Bahasa Indonesia (Default)'),
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.help_center,
                    title: 'Bantuan & Support',
                    subtitle: 'Pusat bantuan dan FAQ',
                    onTap: () => _showInfo(
                      'Bantuan',
                      'Hubungi admin untuk bantuan lebih lanjut',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Menu Lainnya
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.history,
                    title: 'Riwayat Aktivitas',
                    subtitle: 'Lihat riwayat penggunaan',
                    onTap: () => _showInfo(
                      'Riwayat',
                      'Fitur riwayat akan segera tersedia',
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.share,
                    title: 'Bagikan Aplikasi',
                    subtitle: 'Bagikan ke kolega',
                    onTap: () => _showInfo(
                      'Berhasil',
                      'Link berhasil disalin ke clipboard',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout, color: Colors.red, size: 20),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  'Keluar dari aplikasi',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _showLogoutConfirmation,
              ),
            ),

            SizedBox(height: 20),

            // App Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'SIK Hangnadim Mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Versi 1.0.0 • Build 2024.01',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 Bandara Hang Nadim',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[900]),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue[700]),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }
}
