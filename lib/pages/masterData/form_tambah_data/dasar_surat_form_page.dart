import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class DasarSuratFormPage extends StatefulWidget {
  final dynamic item;

  const DasarSuratFormPage({Key? key, this.item}) : super(key: key);

  @override
  _DasarSuratFormPageState createState() => _DasarSuratFormPageState();
}

class _DasarSuratFormPageState extends State<DasarSuratFormPage> {
  final _referenceController = TextEditingController();
  final _positionController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;

  // 🔥 VARIABEL UNTUK TRACK VALIDASI REAL-TIME
  bool _referenceHasError = false;
  bool _positionHasError = false;
  String? _referenceErrorText;
  String? _positionErrorText;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      _referenceController.text = widget.item['reference'] ?? '';
      _positionController.text = widget.item['position']?.toString() ?? '';
    }

    // 🔥 LISTENER UNTUK REAL-TIME VALIDATION
    _referenceController.addListener(_validateReferenceRealTime);
    _positionController.addListener(_validatePositionRealTime);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // 🔥 VALIDASI REAL-TIME UNTUK REFERENSI
  void _validateReferenceRealTime() {
    final error = _validateReference(_referenceController.text);
    setState(() {
      _referenceHasError = error != null;
      _referenceErrorText = error;
    });
  }

  // 🔥 VALIDASI REAL-TIME UNTUK POSISI
  void _validatePositionRealTime() {
    final error = _validatePosition(_positionController.text);
    setState(() {
      _positionHasError = error != null;
      _positionErrorText = error;
    });
  }

  // 🔥 VALIDATOR FUNCTIONS
  String? _validateReference(String? value) {
    if (value == null || value.isEmpty) {
      return 'Referensi dasar surat wajib diisi';
    }
    if (value.trim().isEmpty) {
      return 'Referensi dasar surat tidak boleh hanya spasi';
    }
    if (value.length < 3) {
      return 'Referensi minimal 3 karakter';
    }
    if (value.length > 500) {
      return 'Referensi maksimal 500 karakter';
    }
    return null;
  }

  String? _validatePosition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Posisi wajib diisi';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Posisi harus berupa angka';
    }
    final position = int.tryParse(value.trim()) ?? 0;
    if (position < 1) {
      return 'Posisi minimal 1';
    }
    if (position > 999) {
      return 'Posisi maksimal 999';
    }
    return null;
  }

  Future<void> _submitForm() async {
    // 🔥 SEMBUNYIKAN KEYBOARD DAN VALIDASI FORM
    FocusScope.of(context).unfocus();
    
    // 🔥 VALIDASI MANUAL TANPA FORM KEY
    final referenceError = _validateReference(_referenceController.text);
    final positionError = _validatePosition(_positionController.text);
    
    setState(() {
      _referenceHasError = referenceError != null;
      _positionHasError = positionError != null;
      _referenceErrorText = referenceError;
      _positionErrorText = positionError;
    });
    
    // 🔥 CEK JIKA ADA ERROR
    if (referenceError != null || positionError != null) {
      _showValidationErrorAlert();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'reference': _referenceController.text.trim(),
        'position': int.tryParse(_positionController.text.trim()) ?? 0,
      };

      if (_isEdit) {
        await MasterDataService.updateData('letter-fundamentals', widget.item['id'], data);
      } else {
        await MasterDataService.createData('letter-fundamentals', data);
      }

      // ✅ ALERT SUCCESS
      _showSimpleSuccessAlert(
        _isEdit ? 'Dasar surat berhasil diperbarui' : 'Dasar surat berhasil ditambahkan'
      );
      
    } catch (e) {
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
    String errorTitle = _isEdit ? 'Gagal Update' : 'Gagal Tambah Data';

    // Cek jika error adalah HTTP 422 (Validation Error)
    if (error.toString().contains('422')) {
      errorTitle = 'Data Tidak Valid';
      
      // 🔥 DETEKSI JENIS ERROR BERDASARKAN INPUT USER
      if (_referenceController.text.trim().isEmpty) {
        errorMessage = 'Referensi dasar surat wajib diisi';
      } else if (_referenceController.text.trim().length < 3) {
        errorMessage = 'Referensi dasar surat minimal 3 karakter';
      } else if (_positionController.text.trim().isEmpty) {
        errorMessage = 'Posisi wajib diisi';
      } else if (int.tryParse(_positionController.text.trim()) == null) {
        errorMessage = 'Posisi harus berupa angka';
      } else if (error.toString().contains('duplicate') || error.toString().contains('already exists')) {
        errorMessage = 'Data sudah ada dalam sistem. Referensi atau posisi mungkin sudah digunakan';
      } else {
        errorMessage = 'Data yang dimasukkan tidak valid. Periksa kembali referensi dan posisi';
      }
    } 
    // Handle error lainnya
    else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan di server';
    } else if (error.toString().contains('409')) {
      errorMessage = 'Data sudah ada dalam sistem. Referensi atau posisi mungkin sudah digunakan';
    } else if (error.toString().contains('timeout') || error.toString().contains('SocketException')) {
      errorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi';
    } else {
      errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi';
    }

    // 🔥 TAMPILKAN ALERT ERROR YANG LEBIH INFORMATIF
    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  Future<void> _deleteItem() async {
    FocusScope.of(context).unfocus();
    
    // ✅ GUNAKAN CUSTOM CONFIRMATION DIALOG SEPERTI FORM LAIN
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCleanConfirmationDialog(
        title: 'Hapus Data',
        message: 'Apakah Anda yakin ingin menghapus dasar surat "${widget.item['reference']}"?',
        confirmText: 'Hapus',
        isDelete: true,
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MasterDataService.deleteData('letter-fundamentals', widget.item['id']);
      
      // ✅ ALERT SUCCESS
      _showSimpleSuccessAlert('Dasar surat berhasil dihapus');
      
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

  // ✅ ALERT SUCCESS
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
    Navigator.of(context).pop();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Dasar Surat' : 'Tambah Dasar Surat',
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
          else if (_isEdit)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteItem,
              tooltip: 'Hapus',
            ),
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
              child: Column(
                children: [
                  // Header
                  Container(
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
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.description, color: Colors.purple, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEdit ? 'Edit Dasar Surat' : 'Tambah Dasar Surat Baru',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Isi form berikut dengan data dasar surat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Referensi Field
                          _buildTextAreaField(
                            controller: _referenceController,
                            label: 'Referensi Dasar Surat',
                            hintText: 'Contoh: Undang-Undang Republik Indonesia Nomor 1 Tahun 2009',
                            hasError: _referenceHasError,
                            errorText: _referenceErrorText,
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Posisi Field
                          _buildFormField(
                            controller: _positionController,
                            label: 'Posisi',
                            hintText: 'Contoh: 1, 2, 3 (harus angka)',
                            keyboardType: TextInputType.number,
                            hasError: _positionHasError,
                            errorText: _positionErrorText,
                          ),
                          
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isEdit ? Icons.save : Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Data'),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ BUILD FORM FIELD DENGAN VALIDASI YANG DIPERBAIKI
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required bool hasError,
    required String? errorText,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
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
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : 'Masukkan $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
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
    String hintText = '',
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
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : 'Masukkan $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                alignLabelWithHint: true,
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
}