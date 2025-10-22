import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/services/master_data_service.dart';
import 'vendor_detail_page.dart';
import 'vendor_form_page.dart';

class VendorPage extends StatefulWidget {
  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          final legalName = item['legal_name']?.toString().toLowerCase() ?? '';
          final userName = item['user']?['name']?.toString().toLowerCase() ?? '';
          final email = item['user']?['email']?.toString().toLowerCase() ?? '';
          return legalName.contains(query.toLowerCase()) ||
                 userName.contains(query.toLowerCase()) ||
                 email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredData = _data;
    });
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _data = [];
        _filteredData = [];
        _searchController.clear();
        _isSearching = false;
      });

      print('🔄 Fetching vendors data');

      final data = await MasterDataService.fetchData('vendors');
      
      print('✅ Vendors data fetched successfully, length: ${data.length}');

      setState(() {
        _data = data;
        _filteredData = data;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error fetching vendors: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorFormPage(),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  void _navigateToDetail(int index, dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDetailPage(item: item),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Daftar Vendor',
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateForm,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
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
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      decoration: InputDecoration(
                        hintText: 'Cari vendor...',
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

            // Header Container
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
                    'Daftar Vendor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_isSearching ? _filteredData.length : _data.length} items',
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.blue),
                            SizedBox(height: 16),
                            Text(
                              'Memuat data vendor...',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : _buildSimpleList(),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.business_center_outlined, 
              size: 64, 
              color: Colors.grey[400]
            ),
            SizedBox(height: 16),
            Text(
              _isSearching ? 'Tidak ada vendor ditemukan' : 'Tidak ada vendor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _isSearching 
                ? 'Coba dengan kata kunci lain' 
                : 'Klik tombol + untuk menambah vendor',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: displayData.length,
      itemBuilder: (context, index) {
        final item = displayData[index];
        return _buildSimpleListItem(index, item);
      },
    );
  }

  Widget _buildSimpleListItem(int index, dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.business, size: 20, color: Colors.blue[700]),
        ),
        title: Text(
          item['legal_name']?.toString() ?? 'No Name',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.blue[900],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              item['user']?['name']?.toString() ?? 'No Contact',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              item['user']?['email']?.toString() ?? 'No Email',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue[700]),
        ),
        onTap: () => _navigateToDetail(index, item),
      ),
    );
  }
}