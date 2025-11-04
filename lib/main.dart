import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/splash.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';
import 'pages/approvals_page.dart';
import 'pages/signuppage.dart';
import 'pages/qr_scanner_page.dart';
import 'pages/profile_page.dart';
import 'widgets/bottomBar.dart';
import 'utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //inisialisasi permissions
  await initializePermissions();

  runApp(const MyApp());
}

Future<void> initializePermissions() async {
  try {
    await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();
    print("Permissions initialized successfully");
  } catch (e) {
    print("Error initializing permissions: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final token = await Storage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        //tampilkan splash screen saat menunggu hasil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final isLoggedIn = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SIK Hangnadim Mobile',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          home: isLoggedIn ? const MainNavigationWrapper() : const Login(),
          routes: {
            '/login': (context) => const Login(),
            '/signup': (context) => Daftar(),
            '/dashboard': (context) => const MainNavigationWrapper(),
            '/home': (context) => HomePage(),
            '/approvals': (context) => ApprovalsPage(),
          },
        );
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), QRScannerPage(), ProfilePage()];

  final List<BottomToolbarItem> _bottomToolbarItems = [
    BottomToolbarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    BottomToolbarItem(
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner,
      label: 'QR Scan',
    ),
    BottomToolbarItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: CustomBottomToolbar(
          currentIndex: _currentIndex,
          onTabChanged: _onTabChanged,
          items: _bottomToolbarItems,
        ),
      ),
    );
  }
}
