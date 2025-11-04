import 'package:flutter/material.dart';
import '../../services/master_data_service.dart';
import '../../widgets/sweet_alert_dialog.dart';

class ApprovalFormPage extends StatefulWidget {
  final dynamic item;

  const ApprovalFormPage({Key? key, this.item}) : super(key: key);

  @override
  _ApprovalFormPageState createState() => _ApprovalFormPageState();
}

class _ApprovalFormPageState extends State<ApprovalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _workPermitLetterIdController = TextEditingController();
  final _approverIdController = TextEditingController();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  bool _isMounted = false;

  // Focus nodes untuk keyboard handling
  final FocusNode _workPermitLetterIdFocusNode = FocusNode();
  final FocusNode _approverIdFocusNode = FocusNode();
  final FocusNode _statusFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  // Status options
  final List<String> _statusOptions = ['waiting', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _isEdit = widget.item != null;
    if (_isEdit) {
      _workPermitLetterIdController.text = widget.item['work_permit_letter_id']?.toString() ?? '';
      _approverIdController.text = widget.item['approver_id']?.toString() ?? '';
      _statusController.text = widget.item['status']?.toString() ?? 'waiting';
      _notesController.text = widget.item['notes']?.toString() ?? '';
    } else {
      _statusController.text = 'waiting';
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _workPermitLetterIdController.dispose();
    _approverIdController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    _workPermitLetterIdFocusNode.dispose();
    _approverIdFocusNode.dispose();
    _statusFocusNode.dispose();
    _notesFocusNode.dispose();
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
          'work_permit_letter_id': int.tryParse(_workPermitLetterIdController.text) ?? 0,
          'approver_id': int.tryParse(_approverIdController.text) ?? 0,
          'status': _statusController.text,
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        };

        print('🔄 Data yang dikirim:');
        print('Work Permit Letter ID: ${data['work_permit_letter_id']}');
        print('Approver ID: ${data['approver_id']}');
        print('Status: ${data['status']}');
        print('Notes: ${data['notes']}');

        if (_isEdit) {
          await MasterDataService.updateData('approvals', widget.item['id'], data);
        } else {
          await MasterDataService.createData('approvals', data);
        }

        Navigator.pop(context, true);
        
        _showSimpleSuccessAlert(
          _isEdit ? 'Persetujuan berhasil diperbarui' : 'Persetujuan berhasil ditambahkan'
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
        message: 'Apakah Anda yakin ingin menghapus persetujuan ini?',
        confirmText: 'Hapus',
        isDelete: true,
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MasterDataService.deleteData('approvals', widget.item['id']);
      _showSimpleSuccessAlert('Persetujuan berhasil dihapus');
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
          _isEdit ? 'Edit Persetujuan' : 'Tambah Persetujuan',
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
                            child: Icon(Icons.assignment_turned_in, color: Colors.green, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit ? 'Edit Persetujuan' : 'Tambah Persetujuan Baru',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Isi form berikut dengan data persetujuan',
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
                            // Work Permit Letter ID Field
                            _buildFormField(
                              label: 'ID Surat Izin Kerja *',
                              controller: _workPermitLetterIdController,
                              focusNode: _workPermitLetterIdFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ID Surat Izin Kerja wajib diisi';
                                }
                                final id = int.tryParse(value);
                                if (id == null || id < 1) {
                                  return 'ID harus berupa angka positif';
                                }
                                return null;
                              },
                              hintText: 'Masukkan ID surat izin kerja',
                              keyboardType: TextInputType.number,
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Approver ID Field
                            _buildFormField(
                              label: 'ID Approver *',
                              controller: _approverIdController,
                              focusNode: _approverIdFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ID Approver wajib diisi';
                                }
                                final id = int.tryParse(value);
                                if (id == null || id < 1) {
                                  return 'ID harus berupa angka positif';
                                }
                                return null;
                              },
                              hintText: 'Masukkan ID approver',
                              keyboardType: TextInputType.number,
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Status Dropdown Field
                            _buildDropdownField(
                              label: 'Status *',
                              controller: _statusController,
                              focusNode: _statusFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Status wajib dipilih';
                                }
                                return null;
                              },
                              options: _statusOptions,
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Notes Field
                            _buildFormField(
                              label: 'Catatan',
                              controller: _notesController,
                              focusNode: _notesFocusNode,
                              validator: null, // Optional field
                              hintText: 'Masukkan catatan (opsional)',
                              maxLines: 3,
                            ),
                            
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    // Submit Button
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
              keyboardType: keyboardType,
              maxLines: maxLines,
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

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? Function(String?)? validator,
    required List<String> options,
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
            child: DropdownButtonFormField<String>(
              value: controller.text.isNotEmpty ? controller.text : null,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    _getStatusDisplayText(value),
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.text = newValue;
                }
              },
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}