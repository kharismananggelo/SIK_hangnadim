import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class ApproverFormPage extends StatefulWidget {
  final dynamic item;

  const ApproverFormPage({Key? key, this.item}) : super(key: key);

  @override
  _ApproverFormPageState createState() => _ApproverFormPageState();
}

class _ApproverFormPageState extends State<ApproverFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _positionController = TextEditingController();
  final _levelController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  bool _isMounted = false;

  // Focus nodes untuk keyboard handling
  final FocusNode _userIdFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();
  final FocusNode _levelFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _isEdit = widget.item != null;
    if (_isEdit) {
      _userIdController.text = widget.item['user_id']?.toString() ?? '';
      _positionController.text = widget.item['position']?.toString() ?? '';
      _levelController.text = widget.item['level']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _userIdController.dispose();
    _positionController.dispose();
    _levelController.dispose();
    _userIdFocusNode.dispose();
    _positionFocusNode.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isMounted) return;
      
      FocusScope.of(context).unfocus();
      
      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'user_id': int.tryParse(_userIdController.text) ?? 0,
          'position': _positionController.text,
          'level': int.tryParse(_levelController.text) ?? 1,
        };

        if (_isEdit) {
          await MasterDataService.updateData('approvers', widget.item['id'], data);
        } else {
          await MasterDataService.createData('approvers', data);
        }

        Navigator.pop(context, true);
        
        _showSimpleSuccessAlert(
          _isEdit ? 'Approver berhasil diperbarui' : 'Approver berhasil ditambahkan'
        );
        
      } catch (e) {
        if (!_isMounted) return;
        
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
    FocusScope.of(context).unfocus();
    
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCleanConfirmationDialog(
        title: 'Hapus Data',
        message: 'Apakah Anda yakin ingin menghapus approver "${widget.item['user']?['name']}"?',
        confirmText: 'Hapus',
        isDelete: true,
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MasterDataService.deleteData('approvers', widget.item['id']);
      _showSimpleSuccessAlert('Approver berhasil dihapus');
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
          _isEdit ? 'Edit Approver' : 'Tambah Approver',
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
                            child: Icon(Icons.person, color: Colors.orange, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit ? 'Edit Approver' : 'Tambah Approver Baru',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Isi form berikut dengan data approver',
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
                            // User ID Field
                            _buildFormField(
                              label: 'User ID *',
                              controller: _userIdController,
                              focusNode: _userIdFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'User ID wajib diisi';
                                }
                                final userId = int.tryParse(value);
                                if (userId == null || userId < 1) {
                                  return 'User ID harus berupa angka positif';
                                }
                                return null;
                              },
                              hintText: 'Masukkan ID user',
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Posisi Field
                            _buildFormField(
                              label: 'Posisi/Jabatan *',
                              controller: _positionController,
                              focusNode: _positionFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Posisi/jabatan wajib diisi';
                                }
                                return null;
                              },
                              hintText: 'Contoh: Ketua Tim, Manager, dll',
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Level Field
                            _buildFormField(
                              label: 'Level Approval *',
                              controller: _levelController,
                              focusNode: _levelFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Level approval wajib diisi';
                                }
                                final level = int.tryParse(value);
                                if (level == null || level < 1) {
                                  return 'Level harus berupa angka positif';
                                }
                                return null;
                              },
                              hintText: 'Contoh: 1, 2, 3, dll',
                            ),
                            
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    // Submit Button - dalam SafeArea
                    Container(
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
                  ],
                ),
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
    required FocusNode focusNode,
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
              focusNode: focusNode,
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
}