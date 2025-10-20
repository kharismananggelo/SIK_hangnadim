import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';

class TembusanFormPage extends StatefulWidget {
  final dynamic item;

  const TembusanFormPage({Key? key, this.item}) : super(key: key);

  @override
  State<TembusanFormPage> createState() => _TembusanFormPageState();
}

class _TembusanFormPageState extends State<TembusanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _sendEmail = false;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      _nameController.text = widget.item['name'] ?? '';
      _emailController.text = widget.item['email'] ?? '';
      _sendEmail = widget.item['send_email'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'name': _nameController.text,
          'email': _emailController.text,
          'send_email': _sendEmail,
        };

        if (_isEdit) {
          await MasterDataService.updateData('copies', widget.item['id'], data);
        } else {
          await MasterDataService.createData('copies', data);
        }

        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Tembusan berhasil diperbarui' : 'Tembusan berhasil ditambahkan'),
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

  Future<void> _deleteItem() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Data'),
        content: Text('Apakah Anda yakin ingin menghapus tembusan ini?'),
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
        final success = await MasterDataService.deleteData('copies', widget.item['id']);
        
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tembusan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Gagal menghapus data');
        }
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text(
        _isEdit ? 'Edit Tembusan' : 'Tambah Tembusan',
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
    body: SafeArea( // 🔥 TAMBAHKIN SafeArea DI SINI
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
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.copy, color: Colors.blue, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit Tembusan' : 'Tambah Tembusan Baru',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Isi form berikut dengan data tembusan',
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
                        // Nama Tembusan Field
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nama Tembusan',
                          hintText: 'Masukkan nama tembusan',
                          icon: Icons.person,
                          isRequired: true,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Masukkan alamat email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Send Email Checkbox
                        Container(
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
                          child: CheckboxListTile(
                            title: Text(
                              'Kirim Email Otomatis',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            subtitle: Text(
                              'Email akan dikirim secara otomatis ketika surat dibuat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            value: _sendEmail,
                            onChanged: (value) {
                              setState(() {
                                _sendEmail = value!;
                              });
                            },
                            secondary: Icon(
                              Icons.send,
                              color: _sendEmail ? Colors.green : Colors.grey[400],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
                if (keyboardType == TextInputType.emailAddress && 
                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              }
            : null,
      ),
    );
  }
}