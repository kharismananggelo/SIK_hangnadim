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
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _unitNameController = TextEditingController();
  final _provisionTextBeforeController = TextEditingController();
  final _provisionTextAfterController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;

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
  }

  @override
  void dispose() {
    _typeController.dispose();
    _unitNameController.dispose();
    _provisionTextBeforeController.dispose();
    _provisionTextAfterController.dispose();
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
          'type': _typeController.text,
          'unit_name': _unitNameController.text,
          'provision_text_before': _provisionTextBeforeController.text,
          'provision_text_after': _provisionTextAfterController.text,
        };

        if (_isEdit) {
          await MasterDataService.updateData('work-types', widget.item['id'], data);
        } else {
          await MasterDataService.createData('work-types', data);
        }

        // ✅ GUNAKAN ALERT SUCCESS SEPERTI YANG DIMINTA
        _showSimpleSuccessAlert(
          _isEdit ? 'Tipe pekerjaan berhasil diperbarui' : 'Tipe pekerjaan berhasil ditambahkan'
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
      
      // ✅ GUNAKAN ALERT SUCCESS SEPERTI YANG DIMINTA
      _showSimpleSuccessAlert('Tipe pekerjaan berhasil dihapus');
      
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

  // ✅ ALERT SUCCESS SEPERTI YANG DIMINTA
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
                  
                  // Form Fields (TANPA tombol submit)
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
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Nama Unit Field
                          _buildTextField(
                            controller: _unitNameController,
                            label: 'Nama Unit',
                            hintText: 'Masukkan nama unit',
                            icon: Icons.business,
                            isRequired: true,
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

                          // 🔥 TAMBAHKIN SPASI UNTUK MEMBERI RUANG UNTUK TOMBOL
                          SizedBox(height: 80), // Spasi untuk tombol di bawah
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

      // 🔥 PINDAHKAN TOMBOL SUBMIT KE BOTTOM NAVIGATION DI SAFE AREA
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
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
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label wajib diisi';
                }
                return null;
              }
            : null,
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
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: true,
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}