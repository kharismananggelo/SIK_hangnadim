import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class LokasiPekerjaanDetailPage extends StatefulWidget {
  final dynamic item;

  const LokasiPekerjaanDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _LokasiPekerjaanDetailPageState createState() => _LokasiPekerjaanDetailPageState();
}

class _LokasiPekerjaanDetailPageState extends State<LokasiPekerjaanDetailPage> {
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isMounted = false;

  // 🔥 VARIABEL UNTUK TRACK VALIDASI REAL-TIME
  bool _locationHasError = false;
  bool _descriptionHasError = false;
  String? _locationErrorText;
  String? _descriptionErrorText;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _locationController = TextEditingController(text: widget.item['location']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.item['description']?.toString() ?? '');

    // 🔥 LISTENER UNTUK REAL-TIME VALIDATION
    _locationController.addListener(_validateLocationRealTime);
    _descriptionController.addListener(_validateDescriptionRealTime);
  }

  @override
  void dispose() {
    _isMounted = false;
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 🔥 VALIDASI REAL-TIME UNTUK LOKASI
  void _validateLocationRealTime() {
    final error = _validateLocation(_locationController.text);
    if (_isMounted) {
      setState(() {
        _locationHasError = error != null;
        _locationErrorText = error;
      });
    }
  }

  // 🔥 VALIDASI REAL-TIME UNTUK DESKRIPSI
  void _validateDescriptionRealTime() {
    final error = _validateDescription(_descriptionController.text);
    if (_isMounted) {
      setState(() {
        _descriptionHasError = error != null;
        _descriptionErrorText = error;
      });
    }
  }

  // 🔥 VALIDATOR FUNCTIONS
  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lokasi kerja wajib diisi';
    }
    if (value.trim().isEmpty) {
      return 'Nama lokasi tidak boleh hanya spasi';
    }
    if (value.length < 2) {
      return 'Nama lokasi minimal 2 karakter';
    }
    if (value.length > 100) {
      return 'Nama lokasi maksimal 100 karakter';
    }
    
    // Validasi karakter khusus
    final invalidChars = RegExp(r'[<>{}]');
    if (invalidChars.hasMatch(value)) {
      return 'Nama lokasi tidak boleh mengandung karakter <, >, {, }';
    }
    
    return null;
  }

  String? _validateDescription(String? value) {
    // Description optional, jadi tidak wajib diisi
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.trim().isEmpty) {
      return 'Deskripsi tidak boleh hanya spasi';
    }
    
    if (value.length > 255) {
      return 'Deskripsi maksimal 255 karakter';
    }
    
    // Validasi karakter khusus
    final invalidChars = RegExp(r'[<>{}]');
    if (invalidChars.hasMatch(value)) {
      return 'Deskripsi tidak boleh mengandung karakter <, >, {, }';
    }
    
    return null;
  }

  void _toggleEdit() {
    if (!_isMounted) return;
    
    // 🔥 RESET ERROR STATE SAAT BATAL EDIT
    if (_isEditing) {
      setState(() {
        _locationHasError = false;
        _descriptionHasError = false;
        _locationErrorText = null;
        _descriptionErrorText = null;
      });
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveForm() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();
    
    // 🔥 VALIDASI MANUAL TANPA FORM KEY
    final locationError = _validateLocation(_locationController.text);
    final descriptionError = _validateDescription(_descriptionController.text);
    
    setState(() {
      _locationHasError = locationError != null;
      _descriptionHasError = descriptionError != null;
      _locationErrorText = locationError;
      _descriptionErrorText = descriptionError;
    });
    
    // 🔥 CEK JIKA ADA ERROR
    if (locationError != null || descriptionError != null) {
      _showValidationErrorAlert();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ PERBAIKAN: Trim data dan pastikan format benar
      final data = {
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      // ✅ DEBUG: Print data sebelum dikirim
      print('🔄 Data yang dikirim ke API work-locations:');
      print('Location: ${data['location']}');
      print('Description: ${data['description']}');
      print('ID: ${widget.item['id']}');

      await MasterDataService.updateData('work-locations', widget.item['id'], data);
      
      if (!_isMounted) return;
      
      _showSimpleSuccessAlert('Data lokasi pekerjaan berhasil diupdate');
      
    } catch (e) {
      if (e is http.Response) {
        final errorResponse = jsonDecode(e.body);
        final errors = errorResponse['errors'];
        print('🚨 Validation Errors:');
        
        if (errors is Map) {
          errors.forEach((field, errorMessages) {
            print('   📍 $field:');
            if (errorMessages is List) {
              errorMessages.forEach((error) => print('      - $error'));
            } else {
              print('      - $errorMessages');
            }
          });
        }
      }


      
      if (!_isMounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // 🔥 TANGANI ERROR DENGAN PESAN YANG USER-FRIENDLY
      _handleApiError(e);
    }
  }

  // 🔥 METHOD UNTUK MENANGANI ERROR DARI API
  void _handleApiError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan saat menyimpan data';
    String errorTitle = 'Gagal Update';

    // Cek jika error adalah HTTP 422 (Validation Error)
    if (error.toString().contains('422')) {
      errorTitle = 'Data Tidak Valid';

      print('error kontol');
      print(error);
      
      // 🔥 DETEKSI JENIS ERROR BERDASARKAN INPUT USER
      if (_locationController.text.trim().isEmpty) {
        errorMessage = 'Nama lokasi kerja wajib diisi';
      } else if (_locationController.text.trim().length < 2) {
        errorMessage = 'Nama lokasi minimal 2 karakter';
      } else if (_locationController.text.trim().length > 100) {
        errorMessage = 'Nama lokasi maksimal 100 karakter';
      } else if (_descriptionController.text.trim().length > 255) {
        errorMessage = 'Deskripsi maksimal 255 karakter';
      } else if (error.toString().contains('duplicate') || error.toString().contains('already exists')) {
        errorMessage = 'Data sudah ada dalam sistem. Nama lokasi mungkin sudah digunakan';
      } else {
        errorMessage = 'Data yang dimasukkan tidak valid. Periksa kembali nama lokasi dan deskripsi';
      }
    } 
    // Handle error lainnya
    else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan di server';
    } else if (error.toString().contains('409')) {
      errorMessage = 'Data sudah ada dalam sistem. Nama lokasi mungkin sudah digunakan';
    } else if (error.toString().contains('timeout') || error.toString().contains('SocketException')) {
      errorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi';
    } else {
      errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi';
    }

    // 🔥 TAMPILKAN ALERT ERROR YANG LEBIH INFORMATIF
    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  Future<void> _deleteData() async {
    FocusScope.of(context).unfocus();
    
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCleanConfirmationDialog(
        title: 'Hapus Data',
        message: 'Apakah Anda yakin ingin menghapus lokasi pekerjaan "${widget.item['location']}"?',
        confirmText: 'Hapus',
        isDelete: true,
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MasterDataService.deleteData('work-locations', widget.item['id']);
      _showSimpleSuccessAlert('Lokasi pekerjaan berhasil dihapus');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // 🔥 GUNAKAN ERROR HANDLER YANG SAMA UNTUK DELETE
      _handleApiError(e);
    }
  }

  // 🔥 ALERT UNTUK VALIDASI ERROR
  void _showValidationErrorAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 6),
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  size: 30,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Periksa Kembali Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Terdapat data yang tidak valid. Harap periksa form yang ditandai dengan warna merah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 ALERT ERROR DETAILED DENGAN INFORMASI LEBIH BAIK
  void _showDetailedErrorAlert(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 6),
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 30,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Confirmation Dialog
  Widget _buildCleanConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDelete = false,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 6),
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDelete ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDelete ? Icons.warning : Icons.info,
                size: 30,
                color: isDelete ? Colors.red : Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDelete ? Colors.red : Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Success Alert
  void _showSimpleSuccessAlert(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 6),
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Berhasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Tidak tersedia';
    
    String dateString = date.toString();
    
    if (dateString.contains('T')) {
      try {
        DateTime parsedDate = DateTime.parse(dateString);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return dateString;
      }
    }
    
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Lokasi Pekerjaan',
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
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.blue),
            )
          else if (!_isEditing) ...[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue[700]),
              onPressed: _toggleEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteData,
              tooltip: 'Hapus',
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.save, color: Colors.blue[700]),
              onPressed: _saveForm,
              tooltip: 'Simpan',
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[700]),
              onPressed: _toggleEdit,
              tooltip: 'Batal',
            ),
          ],
        ],
      ),
      body: SafeArea(
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
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.blue))
                  : _isEditing ? _buildEditForm() : _buildViewForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInfoCard('Lokasi', widget.item['location']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard(
                  'Deskripsi', 
                  widget.item['description']?.toString() ?? 'Tidak tersedia',
                  maxLines: 6,
                ),
                SizedBox(height: 12),
                _buildInfoCard('Dibuat', _formatDate(widget.item['created_at'])),
                SizedBox(height: 12),
                _buildInfoCard('Diupdate', _formatDate(widget.item['updated_at'])),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 FORM FIELD DENGAN VALIDASI YANG DIPERBAIKI
                _buildFormField(
                  controller: _locationController,
                  label: 'Lokasi',
                  hasError: _locationHasError,
                  errorText: _locationErrorText,
                ),
                SizedBox(height: 16),
                _buildTextAreaField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  hasError: _descriptionHasError,
                  errorText: _descriptionErrorText,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildEditActionButtons(),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, {int maxLines = 2}) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[900],
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ✅ BUILD FORM FIELD DENGAN VALIDASI YANG DIPERBAIKI
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required bool hasError,
    required String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: hasError ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label + ' *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: hasError ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasError ? Colors.red.withOpacity(0.02) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : Colors.blue.withOpacity(0.3),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                hintText: 'Masukkan $label',
                errorText: errorText,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextStyle(
                color: hasError ? Colors.red : Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ BUILD TEXT AREA FIELD DENGAN VALIDASI YANG DIPERBAIKI
  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required bool hasError,
    required String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: hasError ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: hasError ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasError ? Colors.red.withOpacity(0.02) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : Colors.blue.withOpacity(0.3),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                alignLabelWithHint: true,
                hintText: 'Masukkan $label',
                errorText: errorText,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextStyle(
                color: hasError ? Colors.red : Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleEdit,
                icon: Icon(Icons.edit, size: 20),
                label: Text('EDIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteData,
                icon: Icon(Icons.delete, size: 20),
                label: Text('HAPUS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditActionButtons() {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('SIMPAN'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _toggleEdit,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}