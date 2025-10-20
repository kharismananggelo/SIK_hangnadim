import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/splash.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';
import 'pages/approvals_page.dart';
import 'pages/vendors_page.dart';
import 'pages/signuppage.dart';
import 'pages/qr_scanner_page.dart';
import 'pages/profile_page.dart';
import 'widgets/bottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi permissions
  await initializePermissions();
  
  runApp(MyApp());
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SIK Hangnadim Mobile',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Poppins',
            ),
            home: Login(), // ✅ Login sebagai halaman awal
            routes: {
              '/login': (context) => Login(),
              '/home': (context) => HomePage(), // ✅ Tambah route untuk HomePage
              '/signup': (context) => Signup(),
              '/approvals': (context) => ApprovalsPage(),
              '/vendors': (context) => VendorsPage(),
              '/dashboard': (context) => MainNavigationWrapper(),
            },
          );
        }
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

  final List<Widget> _pages = [
    HomePage(), // ✅ HomePage langsung digunakan di sini
    QRScannerPage(),
    ProfilePage(),
  ];

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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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