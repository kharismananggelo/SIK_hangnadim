import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/services/master_data_service.dart';
import 'sik_detail.dart';
import 'sik_form.dart';

class SIKPage extends StatefulWidget {
  @override
  _SIKPageState createState() => _SIKPageState();
}

class _SIKPageState extends State<SIKPage> {
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
          final letterNumber = item['letter_number']?.toString().toLowerCase() ?? '';
          final description = item['description']?.toString().toLowerCase() ?? '';
          final vendorName = item['vendor']?['legal_name']?.toString().toLowerCase() ?? '';
          final workLocation = item['work_location']?.toString().toLowerCase() ?? '';
          return letterNumber.contains(query.toLowerCase()) ||
                 description.contains(query.toLowerCase()) ||
                 vendorName.contains(query.toLowerCase()) ||
                 workLocation.contains(query.toLowerCase());
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

      print('🔄 Fetching SIK data');

      // Service sudah mengembalikan List<dynamic> langsung
      final sikData = await MasterDataService.fetchData('work-permit-letters');

      print('✅ SIK data fetched successfully, length: ${sikData.length}');

      setState(() {
        _data = sikData;
        _filteredData = _data;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error fetching SIK: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SIKFormPage(),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  void _navigateToDetail(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SIKDetailPage(item: item),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.orange;
      case 'verified':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Diajukan';
      case 'verified':
        return 'Terverifikasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Surat Izin Kerja (SIK)',
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
                        hintText: 'Cari SIK...',
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
                    'Daftar Surat Izin Kerja',
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
                              'Memuat data SIK...',
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
              _isSearching ? Icons.search_off : Icons.assignment_outlined, 
              size: 64, 
              color: Colors.grey[400]
            ),
            SizedBox(height: 16),
            Text(
              _isSearching ? 'Tidak ada SIK ditemukan' : 'Tidak ada Surat Izin Kerja',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _isSearching 
                ? 'Coba dengan kata kunci lain' 
                : 'Klik tombol + untuk membuat SIK baru',
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
        return _buildSimpleListItem(item);
      },
    );
  }

  Widget _buildSimpleListItem(dynamic item) {
    final status = item['status']?.toString() ?? 'submitted';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
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
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.assignment, size: 20, color: statusColor),
        ),
        title: Text(
          item['letter_number']?.toString() ?? 'No Number',
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
              item['description']?.toString() ?? 'No Description',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['vendor']?['legal_name']?.toString() ?? 'No Vendor',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
        onTap: () => _navigateToDetail(item),
      ),
    );
  }
}