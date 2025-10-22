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
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _positionController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      _referenceController.text = widget.item['reference'] ?? '';
      _positionController.text = widget.item['position']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
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

        // ✅ GUNAKAN ALERT SUCCESS SEPERTI FORM LAIN
        _showSimpleSuccessAlert(
          _isEdit ? 'Dasar surat berhasil diperbarui' : 'Dasar surat berhasil ditambahkan'
        );
        
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        // ✅ GUNAKAN SWEET ALERT UNTUK ERROR
        SweetAlert.showError(
          context: context,
          title: _isEdit ? 'Gagal Update' : 'Gagal Tambah Data',
          message: 'Terjadi kesalahan: $e',
        );
      }
    }
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
      
      // ✅ GUNAKAN ALERT SUCCESS SEPERTI FORM LAIN
      _showSimpleSuccessAlert('Dasar surat berhasil dihapus');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      SweetAlert.showError(
        context: context,
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
      );
    }
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

  // ✅ ALERT SUCCESS SEPERTI FORM LAIN
  void _showSimpleSuccessAlert(String message) async {
    // Tampilkan alert success
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

    // Tunggu 1 detik lalu tutup alert dan kembali ke halaman sebelumnya
    await Future.delayed(Duration(seconds: 1));
    
    // Tutup dialog alert
    Navigator.of(context).pop();
    
    // Kembali ke halaman sebelumnya
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
            child: Form(
              key: _formKey,
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
                              label: 'Referensi Dasar Surat *',
                              controller: _referenceController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Referensi dasar surat wajib diisi';
                                }
                                if (value.trim().isEmpty) {
                                  return 'Referensi dasar surat tidak boleh hanya spasi';
                                }
                                return null;
                              },
                              hintText: 'Contoh: Undang-Undang Republik Indonesia Nomor 1 Tahun 2009',
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Posisi Field
                            _buildFormField(
                              label: 'Posisi *',
                              controller: _positionController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Posisi wajib diisi';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Posisi harus berupa angka';
                                }
                                return null;
                              },
                              hintText: 'Contoh: 1, 2, 3 (harus angka)',
                              keyboardType: TextInputType.number,
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
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
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : 'Masukkan $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String hintText = '',
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
            child: TextFormField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : 'Masukkan $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                alignLabelWithHint: true,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}