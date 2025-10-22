import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class LokasiPekerjaanFormPage extends StatefulWidget {
  final dynamic item;

  const LokasiPekerjaanFormPage({Key? key, this.item}) : super(key: key);

  @override
  _LokasiPekerjaanFormPageState createState() => _LokasiPekerjaanFormPageState();
}

class _LokasiPekerjaanFormPageState extends State<LokasiPekerjaanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      _locationController.text = widget.item['location'] ?? '';
      _descriptionController.text = widget.item['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Sembunyikan keyboard
      FocusScope.of(context).unfocus();
      
      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'location': _locationController.text,
          'description': _descriptionController.text,
        };

        if (_isEdit) {
          await MasterDataService.updateData('work-locations', widget.item['id'], data);
        } else {
          await MasterDataService.createData('work-locations', data);
        }

        // ✅ GUNAKAN SWEET ALERT UNTUK SUCCESS SEPERTI CONTOH
        _showSimpleSuccessAlert(
          _isEdit ? 'Lokasi pekerjaan berhasil diperbarui' : 'Lokasi pekerjaan berhasil ditambahkan'
        );
        
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        SweetAlert.showError(
          context: context,
          title: _isEdit ? 'Gagal Update' : 'Gagal Tambah Data',
          message: 'Terjadi kesalahan: $e',
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();
    
    // Konfirmasi delete dengan custom dialog
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
      
      // ✅ GUNAKAN SWEET ALERT UNTUK SUCCESS SEPERTI CONTOH
      _showSimpleSuccessAlert('Lokasi pekerjaan berhasil dihapus');
      
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

  // ✅ PERBAIKAN: Success Alert seperti di TembusanDetailPage
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
          _isEdit ? 'Edit Lokasi Pekerjaan' : 'Tambah Lokasi Pekerjaan',
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
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_on, color: Colors.green, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit ? 'Edit Lokasi Pekerjaan' : 'Tambah Lokasi Pekerjaan Baru',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Isi form berikut dengan data lokasi pekerjaan',
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
                            // Lokasi Field
                            _buildFormField(
                              label: 'Nama Lokasi *',
                              controller: _locationController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama lokasi wajib diisi';
                                }
                                return null;
                              },
                              hintText: 'Contoh: Geral FF. 01',
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Deskripsi Field
                            _buildTextAreaField(
                              label: 'Deskripsi Lokasi',
                              controller: _descriptionController,
                              hintText: 'Contoh: Dekat Gate A3',
                            ),
                            
                            SizedBox(height: 80), // Spacer untuk tombol
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

  Widget _buildFormField({
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
              maxLines: 3,
              decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : 'Masukkan $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}