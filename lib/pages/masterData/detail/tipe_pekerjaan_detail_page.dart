import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class TipePekerjaanDetailPage extends StatefulWidget {
  final dynamic item;

  const TipePekerjaanDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _TipePekerjaanDetailPageState createState() => _TipePekerjaanDetailPageState();
}

class _TipePekerjaanDetailPageState extends State<TipePekerjaanDetailPage> {
  late TextEditingController _typeController;
  late TextEditingController _unitNameController;
  late TextEditingController _provisionBeforeController;
  late TextEditingController _provisionAfterController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isMounted = false;

  // 🔥 VARIABEL UNTUK TRACK VALIDASI REAL-TIME
  bool _typeHasError = false;
  bool _unitNameHasError = false;
  String? _typeErrorText;
  String? _unitNameErrorText;

  // Focus nodes untuk keyboard handling
  final FocusNode _typeFocusNode = FocusNode();
  final FocusNode _unitNameFocusNode = FocusNode();
  final FocusNode _provisionBeforeFocusNode = FocusNode();
  final FocusNode _provisionAfterFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _typeController = TextEditingController(text: widget.item['type']?.toString() ?? '');
    _unitNameController = TextEditingController(text: widget.item['unit_name']?.toString() ?? '');
    _provisionBeforeController = TextEditingController(text: widget.item['provision_text_before']?.toString() ?? '');
    _provisionAfterController = TextEditingController(text: widget.item['provision_text_after']?.toString() ?? '');

    // 🔥 LISTENER UNTUK REAL-TIME VALIDATION
    _typeController.addListener(_validateTypeRealTime);
    _unitNameController.addListener(_validateUnitNameRealTime);
  }

  @override
  void dispose() {
    _isMounted = false;
    _typeController.dispose();
    _unitNameController.dispose();
    _provisionBeforeController.dispose();
    _provisionAfterController.dispose();
    _typeFocusNode.dispose();
    _unitNameFocusNode.dispose();
    _provisionBeforeFocusNode.dispose();
    _provisionAfterFocusNode.dispose();
    super.dispose();
  }

  // 🔥 VALIDASI REAL-TIME UNTUK TYPE
  void _validateTypeRealTime() {
    final error = _validateType(_typeController.text);
    if (_isMounted) {
      setState(() {
        _typeHasError = error != null;
        _typeErrorText = error;
      });
    }
  }

  // 🔥 VALIDASI REAL-TIME UNTUK UNIT NAME
  void _validateUnitNameRealTime() {
    final error = _validateUnitName(_unitNameController.text);
    if (_isMounted) {
      setState(() {
        _unitNameHasError = error != null;
        _unitNameErrorText = error;
      });
    }
  }

  // 🔥 VALIDATOR FUNCTIONS
  String? _validateType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tipe pekerjaan wajib diisi';
    }
    if (value.length < 3) {
      return 'Tipe pekerjaan minimal 3 karakter';
    }
    if (value.length > 100) {
      return 'Tipe pekerjaan maksimal 100 karakter';
    }
    return null;
  }

  String? _validateUnitName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama unit wajib diisi';
    }
    if (value.length < 2) {
      return 'Nama unit minimal 2 karakter';
    }
    if (value.length > 50) {
      return 'Nama unit maksimal 50 karakter';
    }
    return null;
  }

  void _toggleEdit() {
    if (!_isMounted) return;
    
    // 🔥 RESET ERROR STATE SAAT BATAL EDIT
    if (_isEditing) {
      setState(() {
        _typeHasError = false;
        _unitNameHasError = false;
        _typeErrorText = null;
        _unitNameErrorText = null;
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
    final typeError = _validateType(_typeController.text);
    final unitError = _validateUnitName(_unitNameController.text);
    
    setState(() {
      _typeHasError = typeError != null;
      _unitNameHasError = unitError != null;
      _typeErrorText = typeError;
      _unitNameErrorText = unitError;
    });
    
    // 🔥 CEK JIKA ADA ERROR
    if (typeError != null || unitError != null) {
      _showValidationErrorAlert();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'type': _typeController.text.trim(),
        'unit_name': _unitNameController.text.trim(),
        'provision_text_before': _provisionBeforeController.text.trim(),
        'provision_text_after': _provisionAfterController.text.trim(),
      };

      await MasterDataService.updateData('work-types', widget.item['id'], data);
      
      if (!_isMounted) return;
      
      // Tampilkan success alert auto close
      _showSimpleSuccessAlert('Data tipe pekerjaan berhasil diupdate');
      
    } catch (e) {
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
      
      // 🔥 DETEKSI JENIS ERROR BERDASARKAN INPUT USER
      if (_typeController.text.trim().isEmpty) {
        errorMessage = 'Tipe pekerjaan wajib diisi';
      } else if (_typeController.text.trim().length < 3) {
        errorMessage = 'Tipe pekerjaan minimal 3 karakter';
      } else if (_unitNameController.text.trim().isEmpty) {
        errorMessage = 'Nama unit wajib diisi';
      } else if (_unitNameController.text.trim().length < 2) {
        errorMessage = 'Nama unit minimal 2 karakter';
      } else if (error.toString().contains('duplicate') || error.toString().contains('already exists')) {
        errorMessage = 'Data sudah ada dalam sistem. Tipe pekerjaan atau nama unit mungkin sudah digunakan';
      } else {
        errorMessage = 'Data yang dimasukkan tidak valid. Periksa kembali tipe pekerjaan dan nama unit';
      }
    } 
    // Handle error lainnya
    else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan di server';
    } else if (error.toString().contains('409')) {
      errorMessage = 'Data sudah ada dalam sistem. Tipe pekerjaan atau nama unit mungkin sudah digunakan';
    } else if (error.toString().contains('timeout') || error.toString().contains('SocketException')) {
      errorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi';
    } else {
      errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi';
    }

    // 🔥 TAMPILKAN ALERT ERROR YANG LEBIH INFORMATIF
    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  Future<void> _deleteData() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();
    
    // Konfirmasi delete dengan custom dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCleanConfirmationDialog(
        title: 'Hapus Data',
        message: 'Apakah Anda yakin ingin menghapus tipe pekerjaan "${widget.item['type']}"?',
        confirmText: 'Hapus',
        isDelete: true,
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MasterDataService.deleteData('work-types', widget.item['id']);
      _showSimpleSuccessAlert('Tipe pekerjaan berhasil dihapus');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Tipe Pekerjaan',
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
        child: SafeArea(
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
                _buildInfoCard('Tipe Pekerjaan', widget.item['type']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard('Nama Unit', widget.item['unit_name']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard(
                  'Ketentuan Sebelum Pekerjaan', 
                  widget.item['provision_text_before']?.toString() ?? 'Tidak tersedia',
                  maxLines: 6,
                ),
                SizedBox(height: 12),
                _buildInfoCard(
                  'Ketentuan Sesudah Pekerjaan', 
                  widget.item['provision_text_after']?.toString() ?? 'Tidak tersedia',
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
                  label: 'Tipe Pekerjaan',
                  controller: _typeController,
                  focusNode: _typeFocusNode,
                  hasError: _typeHasError,
                  errorText: _typeErrorText,
                ),
                SizedBox(height: 16),
                _buildFormField(
                  label: 'Nama Unit',
                  controller: _unitNameController,
                  focusNode: _unitNameFocusNode,
                  hasError: _unitNameHasError,
                  errorText: _unitNameErrorText,
                ),
                SizedBox(height: 16),
                _buildTextAreaField(
                  label: 'Ketentuan Sebelum Pekerjaan',
                  controller: _provisionBeforeController,
                  focusNode: _provisionBeforeFocusNode,
                ),
                SizedBox(height: 16),
                _buildTextAreaField(
                  label: 'Ketentuan Sesudah Pekerjaan',
                  controller: _provisionAfterController,
                  focusNode: _provisionAfterFocusNode,
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
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
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
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                hintText: 'Masukkan $label',
                hintStyle: TextStyle(
                  color: hasError ? Colors.red.withOpacity(0.6) : Colors.grey[500],
                ),
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

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                alignLabelWithHint: true,
                hintText: 'Masukkan $label',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
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

  String _formatDate(dynamic date) {
    if (date == null) return 'Tidak tersedia';
    
    String dateString = date.toString();
    
    // Handle format dari API: "2025-07-05T21:18:48.000000Z"
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
}