import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail/tembusan_detail_page.dart';
import 'detail/tipe_pekerjaan_detail_page.dart';
import 'detail/lokasi_pekerjaan_detail_page.dart';
import 'detail/dasar_surat_detail_page.dart';
import '../../services/master_data_service.dart';
import 'form_tambah_data/tembusan_form_page.dart';
import 'form_tambah_data/tipe_pekerjaan_form_page.dart';
import 'form_tambah_data/lokasi_pekerjaan_form_page.dart';
import 'form_tambah_data/dasar_surat_form_page.dart';

class MasterDataPage extends StatefulWidget {
  @override
  _MasterDataPageState createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage> {
  int _selectedMenuIndex = 0;
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // 🔥 TAMBAHKAN FOCUS NODE UNTUK SEARCH
  final FocusNode _searchFocusNode = FocusNode();

  final Map<int, String> _apiEndpoints = {
    0: 'copies',
    1: 'work-types', 
    2: 'work-locations',
    3: 'letter-fundamentals',
  };

  final Map<int, String> _pageTitles = {
    0: 'Daftar Tembusan',
    1: 'Daftar Tipe Pekerjaan',
    2: 'Daftar Lokasi Pekerjaan',
    3: 'Daftar Dasar Surat',
  };

  final Map<int, String> _itemTitles = {
    0: 'name',
    1: 'type',
    2: 'location', 
    3: 'reference',
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // 🔥 DISPOSE FOCUS NODE
    super.dispose();
  }

  void _onSearchChanged() {
    _filterData(_searchController.text);
  }

  void _filterData(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredData = _data;
      } else {
        _filteredData = _data.where((item) {
          final searchText = _getSearchableText(item).toLowerCase();
          return searchText.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getSearchableText(dynamic item) {
    String searchText = _getItemTitle(item);
    
    switch (_selectedMenuIndex) {
      case 0: // Tembusan
        searchText += ' ${item['description'] ?? ''}';
        break;
      case 1: // Tipe Pekerjaan  
        searchText += ' ${item['category'] ?? ''} ${item['description'] ?? ''}';
        break;
      case 2: // Lokasi Pekerjaan
        searchText += ' ${item['address'] ?? ''} ${item['city'] ?? ''}';
        break;
      case 3: // Dasar Surat
        searchText += ' ${item['description'] ?? ''} ${item['category'] ?? ''}';
        break;
    }
    return searchText;
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredData = _data;
    });
    // 🔥 SEMBUNYIKAN KEYBOARD SAAT CLEAR SEARCH
    _searchFocusNode.unfocus();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 Fetching from: ${_apiEndpoints[_selectedMenuIndex]}');

      final data = await MasterDataService.fetchData(_apiEndpoints[_selectedMenuIndex]!);
      
      print('✅ Data fetched successfully, length: ${data.length}');

      if (mounted) {
        setState(() {
          _data = data;
          _filteredData = data;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda.';
          _isLoading = false;
        });
      }
    }
  }

  void _onMenuTap(int index) {
    if (_selectedMenuIndex == index) return;
    
    // 🔥 SEMBUNYIKAN KEYBOARD SAAT GANTI MENU
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    setState(() {
      _selectedMenuIndex = index;
      _searchController.clear();
      _isSearching = false;
    });
    _fetchData();
  }

  void _navigateToCreateForm() {
    // 🔥 SEMBUNYIKAN KEYBOARD SEBELUM NAVIGASI
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    Widget formPage;
    
    switch (_selectedMenuIndex) {
      case 0: // Tembusan
        formPage = TembusanFormPage();
        break;
      case 1: // Tipe Pekerjaan
        formPage = TipePekerjaanFormPage();
        break;
      case 2: // Lokasi Pekerjaan
        formPage = LokasiPekerjaanFormPage();
        break;
      case 3: // Dasar Surat
        formPage = DasarSuratFormPage();
        break;
      default:
        formPage = TembusanFormPage();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formPage),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  void _navigateToDetail(int index, dynamic item) {
    // 🔥 SEMBUNYIKAN KEYBOARD SEBELUM NAVIGASI
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _getDetailPage(item),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  Widget _getDetailPage(dynamic item) {
    switch (_selectedMenuIndex) {
      case 0: // Tembusan
        return TembusanDetailPage(item: item);
      case 1: // Tipe Pekerjaan
        return TipePekerjaanDetailPage(item: item);
      case 2: // Lokasi Pekerjaan
        return LokasiPekerjaanDetailPage(item: item);
      case 3: // Dasar Surat
        return DasarSuratDetailPage(item: item);
      default:
        return TembusanDetailPage(item: item);
    }
  }

  String _getItemTitle(dynamic item) {
    final fieldName = _itemTitles[_selectedMenuIndex];
    return item[fieldName]?.toString() ?? 'No Data';
  }

  String _getItemSubtitle(dynamic item) {
    switch (_selectedMenuIndex) {
      case 0: // Tembusan
        return item['description']?.toString() ?? '';
      case 1: // Tipe Pekerjaan
        return item['category']?.toString() ?? '';
      case 2: // Lokasi Pekerjaan
        return item['address']?.toString() ?? '';
      case 3: // Dasar Surat
        return item['description']?.toString() ?? '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Master Data',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.blue[900]),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue[700]),
            onPressed: _fetchData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      floatingActionButton: _buildEnhancedFAB(),
      // 🔥 TAMBAHKAN GESTURE DETECTOR DI ROOT BODY
      body: GestureDetector(
        onTap: () {
          // SEMBUNYIKAN KEYBOARD KETIKA TAP DI AREA KOSONG
          FocusScope.of(context).unfocus();
          _searchFocusNode.unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
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
          child: Column(
            children: [
              // Menu Horizontal
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 8, right: 8, top: 14, bottom: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuCard(
                        icon: Icons.copy,
                        label: 'Tembusan',
                        isActive: _selectedMenuIndex == 0,
                        onTap: () => _onMenuTap(0),
                      ),
                      SizedBox(width: 6),
                      _buildMenuCard(
                        icon: Icons.work,
                        label: 'Tipe Pekerjaan',
                        isActive: _selectedMenuIndex == 1,
                        onTap: () => _onMenuTap(1),
                      ),
                      SizedBox(width: 6),
                      _buildMenuCard(
                        icon: Icons.location_on,
                        label: 'Lokasi',
                        isActive: _selectedMenuIndex == 2,
                        onTap: () => _onMenuTap(2),
                      ),
                      SizedBox(width: 6),
                      _buildMenuCard(
                        icon: Icons.description,
                        label: 'Dasar Surat',
                        isActive: _selectedMenuIndex == 3,
                        onTap: () => _onMenuTap(3),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[500], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode, // 🔥 GUNAKAN FOCUS NODE
                        decoration: InputDecoration(
                          hintText: 'Cari ${_pageTitles[_selectedMenuIndex]!.toLowerCase()}...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    if (_isSearching)
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[500]),
                        onPressed: _clearSearch,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 36),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Header Container dengan shadow
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _pageTitles[_selectedMenuIndex]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_isSearching ? _filteredData.length : _data.length} item',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Content List
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, -2),
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: _isLoading
                      ? _buildLoadingWidget()
                      : _errorMessage.isNotEmpty
                          ? _buildErrorWidget()
                          : _buildSimpleList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue, // 🔥 GUNAKAN WARNA SOLID BUKAN GRADIENT
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976D2).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToCreateForm,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, size: 18, color: Colors.white),
        ),
        label: Text(
          'Tambah Data',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sedang mengambil data ${_pageTitles[_selectedMenuIndex]!.toLowerCase()}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 40, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text('Coba Lagi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleList() {
    final displayData = _isSearching ? _filteredData : _data;
    
    if (displayData.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: displayData.length,
        itemBuilder: (context, index) {
          final item = displayData[index];
          return _buildEnhancedListItem(index, item);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSearching ? Icons.search_off : Icons.inbox_outlined, 
                    size: 48, 
                    color: Colors.grey[400]
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _isSearching ? 'Tidak ada hasil ditemukan' : 'Belum ada data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _isSearching 
                    ? 'Coba dengan kata kunci yang berbeda' 
                    : 'Tambahkan data baru dengan tombol + di bawah',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (!_isSearching)
                  ElevatedButton(
                    onPressed: _navigateToCreateForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Tambah Data'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedListItem(int index, dynamic item) {
    final subtitle = _getItemSubtitle(item);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(index, item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMenuIcon(),
                    size: 20,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getItemTitle(item),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.blue[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMenuIcon() {
    switch (_selectedMenuIndex) {
      case 0: return Icons.copy;
      case 1: return Icons.work;
      case 2: return Icons.location_on;
      case 3: return Icons.description;
      default: return Icons.category;
    }
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required bool isActive,
    required Function onTap,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 90,
      height: 80,
      child: Material(
        color: isActive ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 4 : 2,
        shadowColor: Colors.black.withOpacity(isActive ? 0.2 : 0.1),
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : Colors.blue[700],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.blue[900],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}