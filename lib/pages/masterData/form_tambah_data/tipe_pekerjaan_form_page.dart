import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class TipePekerjaanFormPage extends StatefulWidget {
  final dynamic item;

  const TipePekerjaanFormPage({Key? key, this.item}) : super(key: key);

  @override
  _TipePekerjaanFormPageState createState() => _TipePekerjaanFormPageState();
}

class _TipePekerjaanFormPageState extends State<TipePekerjaanFormPage> {
  final _typeController = TextEditingController();
  final _unitNameController = TextEditingController();
  final _provisionTextBeforeController = TextEditingController();
  final _provisionTextAfterController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;

  // 🔥 VARIABEL UNTUK TRACK VALIDASI REAL-TIME
  bool _typeHasError = false;
  bool _unitNameHasError = false;
  String? _typeErrorText;
  String? _unitNameErrorText;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      _typeController.text = widget.item['type'] ?? '';
      _unitNameController.text = widget.item['unit_name'] ?? '';
      _provisionTextBeforeController.text = widget.item['provision_text_before'] ?? '';
      _provisionTextAfterController.text = widget.item['provision_text_after'] ?? '';
    }

    // 🔥 LISTENER UNTUK REAL-TIME VALIDATION
    _typeController.addListener(_validateTypeRealTime);
    _unitNameController.addListener(_validateUnitNameRealTime);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _unitNameController.dispose();
    _provisionTextBeforeController.dispose();
    _provisionTextAfterController.dispose();
    super.dispose();
  }

  // 🔥 VALIDASI REAL-TIME UNTUK TYPE
  void _validateTypeRealTime() {
    final error = _validateType(_typeController.text);
    setState(() {
      _typeHasError = error != null;
      _typeErrorText = error;
    });
  }

  // 🔥 VALIDASI REAL-TIME UNTUK UNIT NAME
  void _validateUnitNameRealTime() {
    final error = _validateUnitName(_unitNameController.text);
    setState(() {
      _unitNameHasError = error != null;
      _unitNameErrorText = error;
    });
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

  Future<void> _submitForm() async {
    // 🔥 SEMBUNYIKAN KEYBOARD DAN VALIDASI FORM
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
        'provision_text_before': _provisionTextBeforeController.text.trim(),
        'provision_text_after': _provisionTextAfterController.text.trim(),
      };

      if (_isEdit) {
        await MasterDataService.updateData('work-types', widget.item['id'], data);
      } else {
        await MasterDataService.createData('work-types', data);
      }

      _showSimpleSuccessAlert(
        _isEdit ? 'Tipe pekerjaan berhasil diperbarui' : 'Tipe pekerjaan berhasil ditambahkan'
      );
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _handleApiError(e);
    }
  }

  // 🔥 METHOD UNTUK MENANGANI ERROR DARI API
  void _handleApiError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan saat menyimpan data';
    String errorTitle = _isEdit ? 'Gagal Update' : 'Gagal Tambah Data';

    if (error.toString().contains('422')) {
      errorTitle = 'Data Tidak Valid';
      
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

    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  Future<void> _deleteItem() async {
    FocusScope.of(context).unfocus();
    
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
          _isEdit ? 'Edit Tipe Pekerjaan' : 'Tambah Tipe Pekerjaan',
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FDFF),
                Color(0xFFF5FBFF),
                Colors.white,
              ],
            ),
          ),
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
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.work, color: Colors.orange, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit Tipe Pekerjaan' : 'Tambah Tipe Pekerjaan Baru',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Isi form berikut dengan data tipe pekerjaan',
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
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Tipe Pekerjaan Field
                        _buildTextField(
                          controller: _typeController,
                          label: 'Tipe Pekerjaan',
                          hintText: 'Masukkan tipe pekerjaan',
                          icon: Icons.work_outline,
                          isRequired: true,
                          hasError: _typeHasError,
                          errorText: _typeErrorText,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Nama Unit Field
                        _buildTextField(
                          controller: _unitNameController,
                          label: 'Nama Unit',
                          hintText: 'Masukkan nama unit',
                          icon: Icons.business,
                          isRequired: true,
                          hasError: _unitNameHasError,
                          errorText: _unitNameErrorText,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Ketentuan Sebelum Field
                        _buildTextArea(
                          controller: _provisionTextBeforeController,
                          label: 'Ketentuan Sebelum Pekerjaan',
                          hintText: 'Masukkan ketentuan sebelum pekerjaan dimulai',
                          icon: Icons.assignment_turned_in,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Ketentuan Sesudah Field
                        _buildTextArea(
                          controller: _provisionTextAfterController,
                          label: 'Ketentuan Sesudah Pekerjaan',
                          hintText: 'Masukkan ketentuan setelah pekerjaan selesai',
                          icon: Icons.assignment_late,
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

      // Tombol Submit
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

  // ✅ BUILD TEXTFIELD YANG SUDAH DIPERBAIKI
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required bool hasError,
    required String? errorText,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: hasError ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: hintText,
          prefixIcon: Icon(
            icon, 
            color: hasError ? Colors.red : Colors.blue[700]
          ),
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: hasError ? Colors.red.withOpacity(0.02) : Colors.white,
          labelStyle: TextStyle(
            color: hasError ? Colors.red : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: hasError ? Colors.red.withOpacity(0.6) : Colors.grey[500],
          ),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(
          color: hasError ? Colors.red : Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: true,
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }
}