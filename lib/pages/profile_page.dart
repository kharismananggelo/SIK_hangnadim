import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/sweet_alert_dialog.dart';
import 'loginpage.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'John Doe';
  String userEmail = 'john.doe@hangnadim.com';
  String userPosition = 'Manager Operasional';

  void _showEditProfile() {
    SweetAlert.showSuccess(
      context: context,
      title: 'Edit Profile',
      message: 'Fitur edit profile akan segera datang!',
    );
  }

  void _showNotifications() {
    SweetAlert.showInfo(
      context: context,
      title: 'Notifikasi',
      message: 'Pengaturan notifikasi akan segera tersedia',
    );
  }

  void _showSecurity() {
    SweetAlert.showWarning(
      context: context,
      title: 'Keamanan',
      message: 'Fitur keamanan akun sedang dalam pengembangan',
    );
  }

  void _showHelp() {
    SweetAlert.showInfo(
      context: context,
      title: 'Bantuan',
      message: 'Hubungi admin untuk bantuan lebih lanjut',
    );
  }

  void _showAbout() {
    SweetAlert.showInfo(
      context: context,
      title: 'Tentang Aplikasi',
      message: 'SIK Hangnadim Mobile\nVersi 1.0.0\n© 2024 Hangnadim Airport',
    );
  }

  void _showLogoutConfirmation() {
    SweetAlert.showWarning(
      context: context,
      title: 'Logout',
      message: 'Apakah Anda yakin ingin logout?',
      onConfirm: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (route) => false,
        );
      },
      confirmText: 'Ya, Logout',
      cancelText: 'Batal',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // INI YANG PERLU DITAMBAHKAN
        surfaceTintColor: Colors.white, // INI JUGA
        iconTheme: IconThemeData(color: Colors.blue[900]),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue[700]),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FDFF),
              Color(0xFFF5FBFF),
              Color(0xFFF2F9FF),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(), // INI UNTUK SMOOTH SCROLL
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
                child: Column(
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
                      onPressed: _showEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                      onTap: _showNotifications,
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.security,
                      title: 'Keamanan',
                      subtitle: 'Password dan keamanan akun',
                      onTap: _showSecurity,
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.language,
                      title: 'Bahasa',
                      subtitle: 'Pilih bahasa aplikasi',
                      onTap: () {
                        SweetAlert.showInfo(
                          context: context,
                          title: 'Bahasa',
                          message: 'Bahasa Indonesia (Default)',
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.help_center,
                      title: 'Bantuan & Support',
                      subtitle: 'Pusat bantuan dan FAQ',
                      onTap: _showHelp,
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
                      onTap: () {
                        SweetAlert.showInfo(
                          context: context,
                          title: 'Riwayat',
                          message: 'Fitur riwayat akan segera tersedia',
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.share,
                      title: 'Bagikan Aplikasi',
                      subtitle: 'Bagikan ke kolega',
                      onTap: () {
                        SweetAlert.showSuccess(
                          context: context,
                          title: 'Berhasil',
                          message: 'Link berhasil disalin ke clipboard',
                        );
                      },
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '© 2024 Bandara Hang Nadim',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // TAMBAHKAN EXTRA SPACE BIAR BISA SCROLL LEBIH JAUH
              SizedBox(height: 100),
            ],
          ),
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
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.blue[900],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
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