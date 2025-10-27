import 'package:flutter/material.dart';
import '../../services/master_data_service.dart';
import '../../widgets/sweet_alert_dialog.dart';
import '../../widgets/smooth_signature_canvas.dart';

class ApprovalDetailPage extends StatefulWidget {
  final dynamic item;

  const ApprovalDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _ApprovalDetailPageState createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();
  final _signatureKey = GlobalKey<SmoothSignatureCanvasState>();

  List<Offset> _signaturePoints = [];
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isMounted = false;

  final FocusNode _statusFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  final List<String> _statusOptions = ['waiting', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _statusController.text = widget.item['status']?.toString() ?? 'waiting';
    _notesController.text = widget.item['notes']?.toString() ?? '';
    
    // Load existing signature points if available
    if (widget.item['signature_points'] != null) {
      try {
        final List<dynamic> pointsData = widget.item['signature_points'];
        _signaturePoints = pointsData.map((point) {
          return Offset(
            (point['x'] ?? 0).toDouble(),
            (point['y'] ?? 0).toDouble(),
          );
        }).toList();
      } catch (e) {
        print('Error loading signature points: $e');
      }
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _statusController.dispose();
    _notesController.dispose();
    _statusFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (!_isMounted) return;
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveForm() async {
    FocusScope.of(context).unfocus();
    
    if (_statusController.text.isEmpty) {
      SweetAlert.showError(
        context: context,
        title: 'Data Tidak Valid',
        message: 'Status harus dipilih',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'status': _statusController.text,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'signature_points': _signaturePoints.map((point) => {
          'x': point.dx,
          'y': point.dy,
        }).toList(),
      };

      print('🔄 Data yang dikirim:');
      print('Status: ${data['status']}');
      print('Notes: ${data['notes']}');
      print('Signature Points: ${_signaturePoints.length}');
      print('ID: ${widget.item['id']}');

      await MasterDataService.updateData('approvals', widget.item['id'], data);
      
      if (!_isMounted) return;
      
      _showSimpleSuccessAlert('Data persetujuan berhasil diupdate');
      
    } catch (e) {
      if (!_isMounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      _handleApiError(e);
    }
  }

  void _handleApiError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan saat menyimpan data';
    String errorTitle = 'Gagal Update';

    if (error.toString().contains('422')) {
      errorTitle = 'Data Tidak Valid';
      errorMessage = 'Data yang dimasukkan tidak valid. Periksa kembali semua field';
    } else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan di server';
    } else if (error.toString().contains('timeout') || error.toString().contains('SocketException')) {
      errorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi';
    } else {
      errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi';
    }

    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  Future<void> _deleteData() async {
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
      
      _handleApiError(e);
    }
  }

  void _clearSignature() {
    _signatureKey.currentState?.clearCanvas();
    setState(() {
      _signaturePoints.clear();
    });
  }

  // Alert Methods
  void _showDetailedErrorAlert(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
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
                child: const Icon(
                  Icons.error_outline,
                  size: 30,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
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
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDelete ? Colors.red : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
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

  void _showSimpleSuccessAlert(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
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
                child: const Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Berhasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 4),
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

    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Tidak tersedia';
    
    String dateString = date.toString();
    
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'waiting':
      default:
        return Colors.orange;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 14,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayText(status),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'waiting':
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Persetujuan',
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
            const Padding(
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
              icon: const Icon(Icons.delete, color: Colors.red),
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
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
                // Approval Information
                _buildSectionHeader('Informasi Persetujuan'),
                _buildInfoCard('ID Persetujuan', widget.item['id']?.toString() ?? 'Tidak tersedia'),
                const SizedBox(height: 12),
                _buildInfoCard('Status', '', customWidget: _buildStatusBadge(widget.item['status']?.toString() ?? 'waiting')),
                const SizedBox(height: 12),
                _buildInfoCard('Catatan', widget.item['notes']?.toString() ?? 'Tidak ada catatan'),
                
                // Signature Section
                _buildSectionHeader('Tanda Tangan Digital'),
                _buildSignatureCard(),
                const SizedBox(height: 16),
                
                // Approver Information
                _buildSectionHeader('Informasi Approver'),
                _buildInfoCard('Nama Approver', widget.item['name']?.toString() ?? 'Tidak tersedia'),
                const SizedBox(height: 12),
                _buildInfoCard('Email', widget.item['email']?.toString() ?? 'Tidak tersedia'),
                const SizedBox(height: 12),
                _buildInfoCard('Posisi', widget.item['position']?.toString() ?? 'Tidak tersedia'),
                const SizedBox(height: 12),
                _buildInfoCard('Level', widget.item['level']?.toString() ?? 'Tidak tersedia'),
                
                // Work Permit Information
                _buildSectionHeader('Informasi Surat Izin Kerja'),
                if (widget.item['work_permit_letter'] != null) ...[
                  _buildInfoCard('Nomor Surat', widget.item['work_permit_letter']?['letter_number']?.toString() ?? 'Tidak tersedia'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Lokasi Kerja', widget.item['work_permit_letter']?['work_location']?.toString() ?? 'Tidak tersedia'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Deskripsi Pekerjaan', widget.item['work_permit_letter']?['description']?.toString() ?? 'Tidak tersedia'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Vendor', widget.item['work_permit_letter']?['vendor']?['legal_name']?.toString() ?? 'Tidak tersedia'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Tanggal Mulai', _formatDate(widget.item['work_permit_letter']?['started_at'])),
                  const SizedBox(height: 12),
                  _buildInfoCard('Tanggal Selesai', _formatDate(widget.item['work_permit_letter']?['ended_at'])),
                ],
                
                // Timestamps
                _buildSectionHeader('Informasi Waktu'),
                _buildInfoCard('Dibuat', _formatDate(widget.item['created_at'])),
                const SizedBox(height: 12),
                _buildInfoCard('Diupdate', _formatDate(widget.item['updated_at'])),
                const SizedBox(height: 20),
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
                _buildSectionHeader('Edit Persetujuan'),
                _buildDropdownField(
                  controller: _statusController,
                  label: 'Status',
                  options: _statusOptions,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _notesController,
                  label: 'Catatan',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Tanda Tangan Digital'),
                _buildSignatureCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildEditActionButtons(),
      ],
    );
  }

  Widget _buildSignatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tanda Tangan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_signaturePoints.isNotEmpty)
                Text(
                  '${_signaturePoints.length} points',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SmoothSignatureCanvas(
            key: _signatureKey,
            onPointsUpdate: (points) {
              setState(() {
                _signaturePoints = points;
              });
              print('Signature points updated: ${points.length}');
            },
            points: _signaturePoints,
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Hapus Tanda Tangan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Widget? customWidget}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          const SizedBox(height: 8),
          if (customWidget != null)
            customWidget
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[900],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                hintText: 'Masukkan $label',
              ),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: DropdownButtonFormField<String>(
              value: controller.text.isNotEmpty ? controller.text : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    _getStatusDisplayText(value),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.text = newValue;
                }
              },
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleEdit,
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('EDIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteData,
                icon: const Icon(Icons.delete, size: 20),
                label: const Text('HAPUS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('SIMPAN'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _toggleEdit,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
}