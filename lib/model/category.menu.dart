import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../pages/vendors_page.dart';
import '../pages/masterData/index.dart';
import '../pages/Approver/index.dart'; // Sesuaikan path dengan struktur folder Anda


class CategoriModel {
  final String name;
  final String iconPath;
  final Color boxColor;
  final VoidCallback? onTap;

  CategoriModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    this.onTap,
  });

  // Method dengan navigation termasuk menu API
  static List<CategoriModel> getCategoriesWithNavigation(BuildContext context) {
    List<CategoriModel> categories = [];

    // ===== MENU UTAMA =====
    categories.add(
      CategoriModel(
        name: 'Masterdata',
        iconPath: 'assets/images/masterData.png',
        boxColor: Color(0xFFE3F2FD),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MasterDataPage()),
          );
      },      ),
    );

    categories.add(
      CategoriModel(
        name: 'Approver',
        iconPath: 'assets/images/approver.png',
        boxColor: Color(0xFFE8F5E8),
        onTap: () => _navigateToApprover(context),
      ),
    );

    categories.add(
      CategoriModel(
        name: 'Persetujuan',
        iconPath: 'assets/images/Persetujuan.png',
        boxColor: Color(0xFFFFF3E0),
        onTap: () => _navigateToPersetujuan(context), // METHOD INI PERLU DIBUAT
      ),
    );

    categories.add(
      CategoriModel(
        name: 'SIK',
        iconPath: 'assets/images/SIK.png',
        boxColor: Color(0xFFF3E5F5),
        onTap: () => _navigateToSIK(context), // METHOD INI PERLU DIBUAT
      ),
    );

    categories.add(
      CategoriModel(
        name: 'Vendor',
        iconPath: 'assets/images/vendor.png',
        boxColor: Color(0xFFE0F2F1),
        onTap: () => _navigateToVendor(context),
      ),
    );

    categories.add(
      CategoriModel(
        name: 'Manajemen User',
        iconPath: 'assets/images/manajemen_user.png',
        boxColor: Color(0xFFFFEBEE),
        onTap: () => _navigateToManajemenUser(context),
      ),
    );

    // ===== MENU API (OPSIONAL) =====
    // Jika ingin menambahkan menu API, hapus komentar di bawah ini:
    /*
    categories.add(
      CategoriModel(
        name: 'Work Types',
        iconPath: 'assets/icons/work.png',
        boxColor: Color(0xFFE1BEE7),
        onTap: () => _navigateToWorkTypes(context),
      ),
    );

    categories.add(
      CategoriModel(
        name: 'Work Locations',
        iconPath: 'assets/icons/location.png',
        boxColor: Color(0xFFC8E6C9),
        onTap: () => _navigateToWorkLocations(context),
      ),
    );
    */

    return categories;
  }

  // ===== NAVIGATION HANDLERS UNTUK SEMUA MENU =====

  // 1. Masterdata
  static void _navigateToMasterData(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
         builder: (context) => MasterDataPage(),
      ),
    );
  }

  // 2. Approver
  // 2. Approver - Navigate to ApproverIndexPage
static void _navigateToApprover(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ApproverIndexPage(), // Arahkan ke halaman index approver yang sudah ada
    ),
  );
}

  // 3. Persetujuan - METHOD YANG DIBUTUHKAN
  static void _navigateToPersetujuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: CustomAppBar(
            title: 'Persetujuan',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.approval, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Halaman Persetujuan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Manajemen persetujuan dokumen'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4. SIK - METHOD YANG DIBUTUHKAN
  static void _navigateToSIK(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: CustomAppBar(
            title: 'SIK',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 64, color: Colors.purple),
                SizedBox(height: 16),
                Text(
                  'Halaman SIK',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Sistem Informasi Korespondensi'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Vendor
  static void _navigateToVendor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: CustomAppBar(
            title: 'Vendor',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Halaman Vendor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Manajemen vendor dan supplier'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Manajemen User
  static void _navigateToManajemenUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: CustomAppBar(
            title: 'Manajemen User',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.manage_accounts, size: 64, color: Colors.teal),
                SizedBox(height: 16),
                Text(
                  'Halaman Manajemen User',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Manajemen pengguna sistem'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== METHOD UNTUK MENU API (OPSIONAL) =====
  
  // static void _navigateToWorkTypes(BuildContext context) {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => WorkTypesPage()));
  // }

  // static void _navigateToWorkLocations(BuildContext context) {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => WorkLocationsPage()));
  // }

  // static void _navigateToApprovalsAPI(BuildContext context) {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovalsPage()));
  // }

  // static void _navigateToVendorsAPI(BuildContext context) {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => VendorsPage()));
  // }
}