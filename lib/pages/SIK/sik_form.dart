import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class SIKFormPage extends StatefulWidget {
  @override
  _SIKFormPageState createState() => _SIKFormPageState();
}

class _SIKFormPageState extends State<SIKFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _externalPicNameController = TextEditingController();
  final TextEditingController _externalPicNumberController = TextEditingController();
  final TextEditingController _internalPicNameController = TextEditingController();
  final TextEditingController _internalPicNumberController = TextEditingController();
  final TextEditingController _pointingController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Variables
  int? _selectedVendorId;
  int? _selectedWorkTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<dynamic> _vendors = [];
  List<dynamic> _workTypes = [];
  
  bool _isLoading = false;
  bool _isMounted = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeData();
  }

  @override
  void dispose() {
    _isMounted = false;
    _descriptionController.dispose();
    _workLocationController.dispose();
    _externalPicNameController.dispose();
    _externalPicNumberController.dispose();
    _internalPicNameController.dispose();
    _internalPicNumberController.dispose();
    _pointingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final vendors = await MasterDataService.fetchData('vendors');
      final workTypes = await MasterDataService.fetchData('work-types');
      
      if (_isMounted) {
        setState(() {
          _vendors = vendors is List ? vendors : [];
          _workTypes = workTypes is List ? workTypes : [];
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('❌ Error initializing data: $e');
      if (_isMounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isMounted) return;
      
      if (_selectedVendorId == null) {
        SweetAlert.showError(
          context: context,
          title: 'Data Tidak Lengkap',
          message: 'Pilih vendor terlebih dahulu',
        );
        return;
      }

      if (_selectedWorkTypeId == null) {
        SweetAlert.showError(
          context: context,
          title: 'Data Tidak Lengkap',
          message: 'Pilih jenis pekerjaan terlebih dahulu',
        );
        return;
      }

      if (_startDate == null || _endDate == null) {
        SweetAlert.showError(
          context: context,
          title: 'Data Tidak Lengkap',
          message: 'Pilih tanggal mulai dan selesai terlebih dahulu',
        );
        return;
      }

      FocusScope.of(context).unfocus();
      
      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'vendor_id': _selectedVendorId,
          'work_type_id': _selectedWorkTypeId,
          'description': _descriptionController.text,
          'work_location': _workLocationController.text,
          'started_at': _startDate?.toIso8601String().split('T')[0],
          'ended_at': _endDate?.toIso8601String().split('T')[0],
          'external_pic_name': _externalPicNameController.text,
          'external_pic_number': _externalPicNumberController.text,
          'internal_pic_name': _internalPicNameController.text.isEmpty ? null : _internalPicNameController.text,
          'internal_pic_number': _internalPicNumberController.text.isEmpty ? null : _internalPicNumberController.text,
          'pointing': _pointingController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
        };

        await MasterDataService.createData('work-permit-letters', data);
        
        if (!_isMounted) return;
        
        _showSimpleSuccessAlert('Surat Izin Kerja berhasil dibuat');
        
      } catch (e) {
        if (!_isMounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        SweetAlert.showError(
          context: context,
          title: 'Gagal Membuat SIK',
          message: 'Terjadi kesalahan: $e',
        );
      }
    }
  }

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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Buat Surat Izin Kerja',
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _isInitializing
                  ? Center(child: CircularProgressIndicator(color: Colors.blue))
                  : _isLoading 
                      ? Center(child: CircularProgressIndicator(color: Colors.blue))
                      : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Vendor Selection
            // Vendor Selection - PERBAIKI
            _buildDropdownField(
              label: 'Vendor *',
              value: _selectedVendorId,
              items: _vendors.map((vendor) {
                return DropdownMenuItem<int>(
                  value: (vendor['id'] as num).toInt(), // Konversi explicit ke int
                  child: Text(vendor['legal_name']?.toString() ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVendorId = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih vendor terlebih dahulu';
                return null;
              },
            ),
            SizedBox(height: 16),

            // Work Type Selection - PERBAIKI
            _buildDropdownField(
              label: 'Jenis Pekerjaan *',
              value: _selectedWorkTypeId,
              items: _workTypes.map((workType) {
                return DropdownMenuItem<int>(
                  value: (workType['id'] as num).toInt(), // Konversi explicit ke int
                  child: Text(workType['type']?.toString() ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorkTypeId = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih jenis pekerjaan terlebih dahulu';
                return null;
              },
            ),

            // Description
            _buildFormField(
              label: 'Deskripsi Pekerjaan *',
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi pekerjaan harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Work Location
            _buildFormField(
              label: 'Lokasi Kerja *',
              controller: _workLocationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasi kerja harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Date Selection
            _buildDateField(
              label: 'Tanggal Mulai *',
              date: _startDate,
              onTap: _selectStartDate,
            ),
            SizedBox(height: 16),

            _buildDateField(
              label: 'Tanggal Selesai *',
              date: _endDate,
              onTap: _selectEndDate,
            ),
            SizedBox(height: 16),

            // External PIC
            _buildFormField(
              label: 'Nama PIC Eksternal *',
              controller: _externalPicNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama PIC eksternal harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            _buildFormField(
              label: 'No. HP PIC Eksternal *',
              controller: _externalPicNumberController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No. HP PIC eksternal harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Internal PIC (Optional)
            _buildFormField(
              label: 'Nama PIC Internal',
              controller: _internalPicNameController,
            ),
            SizedBox(height: 16),

            _buildFormField(
              label: 'No. HP PIC Internal',
              controller: _internalPicNumberController,
            ),
            SizedBox(height: 16),

            // Pointing
            _buildFormField(
              label: 'Dasar Penunjukan *',
              controller: _pointingController,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Dasar penunjukan harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Notes (Optional)
            _buildFormField(
              label: 'Catatan',
              controller: _notesController,
              maxLines: 3,
            ),

            SizedBox(height: 32),

            // Action Buttons
            Container(
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator, // Ubah menjadi optional
  bool obscureText = false,
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
            obscureText: obscureText,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            validator: validator, // Bisa null untuk field optional
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
    required String? Function(int?) validator,
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
            child: DropdownButtonFormField<int>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
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

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function onTap,
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
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                date != null 
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Pilih tanggal',
                style: TextStyle(
                  color: date != null ? Colors.blue[900] : Colors.grey[500],
                ),
              ),
              trailing: Icon(Icons.calendar_today, size: 20, color: Colors.blue[700]),
              onTap: () => onTap(),
            ),
          ),
        ],
      ),
    );
  }
}