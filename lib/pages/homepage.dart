// home_page.dart (modifikasi)
import 'package:flutter/material.dart';
import 'package:sik_hangnadim_mobile/model/category.menu.dart';
import 'masterData/index.dart';
import '../pages/qr_scanner_page.dart';
import '../model/work_permit_service.dart';
import '../model/work_permit_letter.dart';
import '../widgets/statistic_chart.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<CategoriModel> categories = [];
  List<WorkPermitLetter> workPermits = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWorkPermits();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //refresh ketika app kembali dari background
      _loadWorkPermits();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadWorkPermits() async {
    try {
      final response = await WorkPermitService.fetchWorkPermits();
      if (mounted) {
        setState(() {
          workPermits = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat data SIK';
          isLoading = false;
        });
      }
    }
  }

  void _getCategoriesWithNavigation(BuildContext context) {
    final newCategories = CategoriModel.getCategoriesWithNavigation(context);

    if (newCategories.length != categories.length) {
      setState(() {
        categories = newCategories;
      });
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName akan segera hadir!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      _getCategoriesWithNavigation(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.blue, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'kharisman!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
            onPressed: () => _showComingSoonSnackbar(context, 'Notifikasi'),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
            onPressed: () => _showComingSoonSnackbar(context, 'Pengaturan'),
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
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //header dengan logo
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo-hangnadim.png',
                      width: 160,
                      height: 80,
                    ),

                    SizedBox(height: 8),
                    Text(
                      'Kelola semua aktivitas izin Anda di satu tempat',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              //statistics Chart
              if (!isLoading && errorMessage.isEmpty)
                StatisticsChart(
                  workPermits: workPermits,
                  onRefresh: _loadWorkPermits,
                )
              else if (isLoading)
                _buildLoadingChart()
              else
                _buildErrorChart(),

              //grid Menu Container
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //quick access section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih menu untuk mengelola aktivitas Anda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //grid Menu
                    _buildGridMenu(),

                    SizedBox(height: 20),
                  ],
                ),
              ),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat statistik SIK...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorChart() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 16),
            Text(errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWorkPermits,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenu() {
    if (categories.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 16),
              Text('Memuat menu...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: categories.map((category) {
          return _buildCategoryItem(category);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(CategoriModel category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: category.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: category.boxColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: category.boxColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: category.boxColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(child: _buildCategoryIcon(category)),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CategoriModel category) {
    try {
      return Image.asset(
        category.iconPath,
        width: 25,
        height: 25,
        errorBuilder: (context, error, stackTrace) {
          return _getFallbackIcon(category.name);
        },
      );
    } catch (e) {
      return _getFallbackIcon(category.name);
    }
  }

  Widget _getFallbackIcon(String categoryName) {
    IconData iconData;
    Color color = Colors.blue;

    switch (categoryName) {
      case 'Masterdata':
        iconData = Icons.storage;
        color = Colors.blue;
        break;
      case 'Approver':
        iconData = Icons.people_alt;
        color = Colors.green;
        break;
      case 'Persetujuan':
        iconData = Icons.assignment_turned_in;
        color = Colors.orange;
        break;
      case 'SIK':
        iconData = Icons.description;
        color = Colors.purple;
        break;
      case 'Vendor':
        iconData = Icons.business_center;
        color = Colors.red;
        break;
      case 'Manajemen User':
        iconData = Icons.manage_accounts;
        color = Colors.teal;
        break;
      case 'Work Types':
        iconData = Icons.work_outline;
        color = Colors.indigo;
        break;
      case 'Work Locations':
        iconData = Icons.location_on;
        color = Colors.green;
        break;
      case 'Approvals API':
        iconData = Icons.verified;
        color = Colors.orange;
        break;
      case 'Vendors API':
        iconData = Icons.business;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.apps;
        color = Colors.grey;
    }

    return Icon(iconData, size: 25, color: color);
  }
}
