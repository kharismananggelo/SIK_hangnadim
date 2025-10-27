import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail/approver_detail_page.dart';
import '../../services/master_data_service.dart';
import 'form_penambahan_data/approver_form_page.dart';

class ApproverIndexPage extends StatefulWidget {
  @override
  _ApproverIndexPageState createState() => _ApproverIndexPageState();
}

class _ApproverIndexPageState extends State<ApproverIndexPage> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('🚀 ApproverIndexPage initialized');
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          // Safe access dengan null checking
          if (item is! Map) return false;
          
          final userName = item['user']?['name']?.toString().toLowerCase() ?? '';
          final position = item['position']?.toString().toLowerCase() ?? '';
          final level = item['level']?.toString().toLowerCase() ?? '';
          final searchText = '$userName $position $level';
          return searchText.contains(query.toLowerCase());
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
    _searchFocusNode.unfocus();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 Fetching approvers data...');

      final data = await MasterDataService.fetchData('approvers');
      
      print('📊 Raw data type: ${data.runtimeType}');
      print('📊 Raw data length: ${data.length}');
      
      // Debug: print struktur data
      if (data.isNotEmpty) {
        print('🔍 First item preview:');
        if (data[0] is Map) {
          final firstItem = data[0] as Map;
          print('   - ID: ${firstItem['id']}');
          print('   - User: ${firstItem['user']}');
          print('   - Position: ${firstItem['position']}');
          print('   - Level: ${firstItem['level']}');
          print('   - Signature: ${firstItem['signature']}');
        } else {
          print('   - Item type: ${data[0].runtimeType}');
        }
      }

      // Validasi data
      List<dynamic> validData = [];
      for (var item in data) {
        if (item is Map) {
          validData.add(item);
        }
      }

      print('✅ Valid approvers data: ${validData.length} items');

      if (mounted) {
        setState(() {
          _data = validData;
          _filteredData = validData;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('❌ Error fetching approvers: $e');
      print('📋 Error type: ${e.runtimeType}');
      
      String errorMessage = 'Gagal memuat data approver. ';
      if (e.toString().contains('Timeout')) {
        errorMessage += 'Timeout: Periksa koneksi internet Anda.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage += 'Format data tidak valid.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage += 'Tidak dapat terhubung ke server.';
      } else {
        errorMessage += 'Error: $e';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCreateForm() {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApproverFormPage()),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  void _navigateToDetail(int index, dynamic item) {
    if (item is! Map) {
      print('❌ Cannot navigate to detail - invalid item data');
      return;
    }
    
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproverDetailPage(item: item),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  String _getItemTitle(dynamic item) {
    if (item is Map) {
      return item['user']?['name']?.toString() ?? 'No Name';
    }
    return 'Invalid Data';
  }

  String _getItemSubtitle(dynamic item) {
    if (item is Map) {
      final position = item['position']?.toString() ?? '';
      final level = item['level']?.toString() ?? '';
      final isDefault = item['is_default_approver'] == 1 ? ' (Default)' : '';
      return '$position - Level $level$isDefault';
    }
    return '';
  }

  Widget _buildSignatureIndicator(dynamic item) {
    if (item is! Map) {
      return Container(); // Return empty container for invalid data
    }
    
    final hasSignature = item['signature'] != null && 
                        item['signature'].toString().isNotEmpty &&
                        item['signature'].toString() != 'null';
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasSignature ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasSignature ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSignature ? Icons.assignment_turned_in : Icons.assignment_late,
            size: 12,
            color: hasSignature ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            hasSignature ? 'TTD Ada' : 'TTD Kosong',
            style: TextStyle(
              fontSize: 10,
              color: hasSignature ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Daftar Approver',
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
      body: GestureDetector(
        onTap: () {
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
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Cari nama approver, posisi, atau level...',
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
                      'Daftar Approver',
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
    return FloatingActionButton(
      onPressed: _navigateToCreateForm,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.add, size: 24),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ],
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
            'Memuat data approver...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sedang mengambil data daftar approver',
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
                    _isSearching ? Icons.search_off : Icons.person_off_outlined, 
                    size: 48, 
                    color: Colors.grey[400]
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _isSearching ? 'Tidak ada hasil ditemukan' : 'Belum ada data approver',
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
                    : 'Tambahkan approver baru dengan tombol + di bawah',
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
                        Text('Tambah Approver'),
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
    // Safe check untuk item data
    if (item is! Map) {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Data tidak valid',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.orange[700],
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
                SizedBox(width: 8),
                _buildSignatureIndicator(item),
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
}