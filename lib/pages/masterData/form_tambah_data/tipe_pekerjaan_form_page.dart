import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/master_data_service.dart';

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

        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Tipe pekerjaan berhasil diperbarui' : 'Tipe pekerjaan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        actions: [
          if (_isEdit)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteItem,
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
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
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

  Future<void> _deleteItem() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Data'),
        content: Text('Apakah Anda yakin ingin menghapus tipe pekerjaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MasterDataService.deleteData('work-types', widget.item['id']);
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tipe pekerjaan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}