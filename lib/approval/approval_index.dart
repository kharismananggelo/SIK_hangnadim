import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'approval_detail.dart';
import 'approval_form.dart';
import '../../services/master_data_service.dart';

class ApprovalIndexPage extends StatefulWidget {
  @override
  _ApprovalIndexPageState createState() => _ApprovalIndexPageState();
}

class _ApprovalIndexPageState extends State<ApprovalIndexPage> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  //pagination variables
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  int _perPage = 10;

  @override
  void initState() {
    super.initState();
    print('🚀 ApprovalIndexPage initialized');
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
          if (item is! Map) return false;

          final workPermitLetter = item['work_permit_letter'] as Map?;

          final letterNumber =
              workPermitLetter?['letter_number']?.toString().toLowerCase() ??
              '';
          final vendorName =
              workPermitLetter?['vendor']?['legal_name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          final workLocation =
              workPermitLetter?['work_location']?.toString().toLowerCase() ??
              '';
          final description =
              workPermitLetter?['description']?.toString().toLowerCase() ?? '';
          final status = item['status']?.toString().toLowerCase() ?? '';

          final searchText =
              '$letterNumber $vendorName $workLocation $description $status';
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

  Future<void> _fetchData({int page = 1}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 Fetching approvals data... page: $page');

      final response = await http.get(
        Uri.parse('https://sik.luckyabdillah.com/api/v1/approvals?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Raw response type: ${data.runtimeType}');

        List<dynamic> items = [];

        if (data is Map<String, dynamic>) {
          print('🔑 Response keys: ${data.keys}');

          if (data.containsKey('data')) {
            final responseData = data['data'];
            print('📋 Response data type: ${responseData.runtimeType}');

            if (responseData is Map<String, dynamic>) {
              print('🔑 Data keys: ${responseData.keys}');

              if (responseData.containsKey('data') &&
                  responseData['data'] is List) {
                items = responseData['data'];

                _currentPage = _convertToInt(responseData['current_page']) ?? 1;
                _lastPage = _convertToInt(responseData['last_page']) ?? 1;
                _total = _convertToInt(responseData['total']) ?? items.length;
                _perPage = _convertToInt(responseData['per_page']) ?? 10;

                print('✅ Using nested data structure');
              }
            } else if (responseData is List<dynamic>) {
              items = responseData;

              _currentPage = _convertToInt(data['current_page']) ?? 1;
              _lastPage = _convertToInt(data['last_page']) ?? 1;
              _total = _convertToInt(data['total']) ?? items.length;
              _perPage = _convertToInt(data['per_page']) ?? 10;

              print('✅ Using direct list structure');
            }
          }
        } else if (data is List<dynamic>) {
          items = data;
          _currentPage = 1;
          _lastPage = 1;
          _total = items.length;
          _perPage = items.length;
          print('✅ Using simple list structure');
        } else {
          print('⚠️ Unexpected response type: ${data.runtimeType}');
          items = [];
        }

        print('✅ Approvals data processed successfully');
        print('📊 Page: $_currentPage/$_lastPage');
        print('📊 Total: $_total items');
        print('📊 Current items: ${items.length}');

        // Debug print untuk memastikan data yang benar
        if (items.isNotEmpty && items[0] is Map) {
          final firstItem = items[0] as Map;
          print('🔍 First approval item structure:');
          print('   - Approval ID: ${firstItem['id']}');
          print('   - Status: ${firstItem['status']}');
          print('   - Approver Name: ${firstItem['name']}');
          if (firstItem.containsKey('work_permit_letter')) {
            final letter = firstItem['work_permit_letter'] as Map;
            print('   - Work Permit Letter:');
            print('     * Letter Number: ${letter['letter_number']}');
            print('     * Vendor: ${letter['vendor']?['legal_name']}');
            print('     * Work Location: ${letter['work_location']}');
          } else {
            print('   - No work_permit_letter data');
          }
        }

        List<dynamic> validData = items.where((item) => item is Map).toList();

        print('✅ Valid approvals data: ${validData.length} items');

        if (mounted) {
          setState(() {
            _data = validData;
            _filteredData = validData;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load approvals: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching approvals: $e');
      print('📋 Error type: ${e.runtimeType}');

      String errorMessage = 'Gagal memuat data persetujuan. ';
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

  int? _convertToInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else if (value is double) {
      return value.toInt();
    } else {
      print(
        '⚠️ Cannot parse value to int: $value (type: ${value.runtimeType})',
      );
      return null;
    }
  }

  void _navigateToCreateForm() {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApprovalFormPage()),
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
      MaterialPageRoute(builder: (context) => ApprovalDetailPage(item: item)),
    ).then((refresh) {
      if (refresh == true) {
        _fetchData();
      }
    });
  }

  // Method helper khusus untuk data approvals
  String _getItemTitle(dynamic item) {
    if (item is Map) {
      final workPermitLetter = item['work_permit_letter'] as Map?;
      if (workPermitLetter != null) {
        return workPermitLetter['letter_number']?.toString() ??
            'No Letter Number';
      }
      return 'Approval ID: ${item['id']}';
    }
    return 'Invalid Data';
  }

  String _getItemSubtitle(dynamic item) {
    if (item is Map) {
      final workPermitLetter = item['work_permit_letter'] as Map?;
      if (workPermitLetter != null) {
        final vendorName =
            workPermitLetter['vendor']?['legal_name']?.toString() ??
            'No Vendor';
        final workLocation =
            workPermitLetter['work_location']?.toString() ?? 'No Location';
        return '$vendorName - $workLocation';
      }
      return 'No Work Permit Data';
    }
    return '';
  }

  String _getWorkDescription(dynamic item) {
    if (item is Map) {
      final workPermitLetter = item['work_permit_letter'] as Map?;
      if (workPermitLetter != null) {
        return workPermitLetter['description']?.toString() ?? 'No Description';
      }
      return 'No Description';
    }
    return '';
  }

  String _getDateRange(dynamic item) {
    if (item is Map) {
      final workPermitLetter = item['work_permit_letter'] as Map?;
      if (workPermitLetter != null) {
        final startDate = workPermitLetter['started_at']?.toString() ?? '';
        final endDate = workPermitLetter['ended_at']?.toString() ?? '';
        if (startDate.isNotEmpty && endDate.isNotEmpty) {
          return '$startDate s/d $endDate';
        }
      }
      return 'No Date Range';
    }
    return '';
  }

  String _getApproverInfo(dynamic item) {
    if (item is Map) {
      final name = item['name']?.toString() ?? '';
      final position = item['position']?.toString() ?? '';
      if (name.isNotEmpty) {
        return position.isNotEmpty ? '$name ($position)' : name;
      }
      return 'No Approver Info';
    }
    return '';
  }

  Widget _buildStatusIndicator(dynamic item) {
    if (item is! Map) return Container();

    final status = item['status']?.toString() ?? 'waiting';
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Disetujui';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Ditolak';
        statusIcon = Icons.cancel;
        break;
      case 'verified':
        statusColor = Colors.blue;
        statusText = 'Terverifikasi';
        statusIcon = Icons.verified;
        break;
      case 'waiting':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Pending';
        statusIcon = Icons.pending;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_lastPage <= 1) return SizedBox();

    return Container(
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
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () => _fetchData(page: _currentPage - 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16),
                SizedBox(width: 4),
                Text('Sebelumnya'),
              ],
            ),
          ),
          Text(
            'Halaman $_currentPage dari $_lastPage',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage < _lastPage
                ? () => _fetchData(page: _currentPage + 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selanjutnya'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
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
          'Persetujuan Surat Izin Kerja',
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
            onPressed: () => _fetchData(page: _currentPage),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateForm,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _searchFocusNode.unfocus();
          },
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
                            hintText:
                                'Cari nomor surat, vendor, lokasi kerja, atau status...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_isSearching)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          onPressed: _clearSearch,
                        ),
                    ],
                  ),
                ),

                // Header
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
                        'Daftar Persetujuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_isSearching ? _filteredData.length : _total} item',
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

                // Content
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
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? _buildLoadingWidget()
                        : _errorMessage.isNotEmpty
                        ? _buildErrorWidget()
                        : _buildContentWithPagination(),
                  ),
                ),
              ],
            ),
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
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Memuat data persetujuan...',
            style: TextStyle(color: Colors.grey[600]),
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
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_errorMessage, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchData(page: _currentPage),
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWithPagination() {
    return Column(
      children: [
        Expanded(child: _buildSimpleList()),
        if (_lastPage > 1) ...[
          SizedBox(height: 16),
          _buildPaginationControls(),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSimpleList() {
    final displayData = _isSearching ? _filteredData : _data;

    if (displayData.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchData(page: _currentPage),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            _isSearching
                ? 'Tidak ada hasil ditemukan'
                : 'Belum ada data persetujuan',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Coba dengan kata kunci yang berbeda'
                : 'Tambahkan persetujuan baru dengan tombol + di bawah',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedListItem(int index, dynamic item) {
    if (item is! Map) {
      return Card(
        color: Colors.white, // 🔥 TAMBAHKAN INI
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(Icons.error, color: Colors.red),
          title: Text('Data tidak valid'),
        ),
      );
    }

    final subtitle = _getItemSubtitle(item);
    final workDescription = _getWorkDescription(item);
    final dateRange = _getDateRange(item);
    final approverInfo = _getApproverInfo(item);

    return Card(
      color: Colors.white, // 🔥 TAMBAHKAN INI - BACKGROUND PUTIH
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2, // 🔥 OPSIONAL: TAMBAH ELEVATION UNTUK SHADOW
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(Icons.assignment_turned_in, color: Colors.green[700]),
        ),
        title: Text(
          _getItemTitle(item),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (approverInfo.isNotEmpty && approverInfo != 'No Approver Info')
              Text('Approver: $approverInfo', style: TextStyle(fontSize: 12)),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: TextStyle(fontSize: 12)),
            if (dateRange.isNotEmpty && dateRange != 'No Date Range')
              Text(
                dateRange,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            if (workDescription.isNotEmpty &&
                workDescription != 'No Description')
              Text(
                workDescription,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIndicator(item),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[700]),
          ],
        ),
        onTap: () => _navigateToDetail(index, item),
      ),
    );
  }
}
