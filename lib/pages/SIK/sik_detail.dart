import 'package:flutter/material.dart';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';

class SIKDetailPage extends StatefulWidget {
  final dynamic item;

  const SIKDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _SIKDetailPageState createState() => _SIKDetailPageState();
}

class _SIKDetailPageState extends State<SIKDetailPage> {
  bool _isLoading = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.orange;
      case 'verified':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Diajukan';
      case 'verified':
        return 'Terverifikasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Tidak tersedia';
    
    String dateString = date.toString();
    
    if (dateString.contains('T')) {
      try {
        DateTime parsedDate = DateTime.parse(dateString);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        return dateString;
      }
    }
    
    return dateString;
  }

  Widget _buildStatusBadge() {
    final status = widget.item['status']?.toString() ?? 'submitted';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $statusText',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getStatusDescription(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'submitted':
        return Icons.pending_actions;
      case 'verified':
        return Icons.verified;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'submitted':
        return 'Surat Izin Kerja telah diajukan dan menunggu verifikasi';
      case 'verified':
        return 'Surat Izin Kerja telah diverifikasi dan menunggu persetujuan';
      case 'approved':
        return 'Surat Izin Kerja telah disetujui dan dapat dilaksanakan';
      case 'rejected':
        return 'Surat Izin Kerja ditolak, silakan periksa catatan';
      default:
        return 'Status tidak diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Surat Izin Kerja',
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _buildViewForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildViewForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Badge
          _buildStatusBadge(),
          SizedBox(height: 16),

          // Informasi Umum
          _buildSectionHeader('Informasi Umum'),
          _buildInfoCard('Nomor Surat', widget.item['letter_number']?.toString() ?? 'Belum ada nomor'),
          SizedBox(height: 12),
          _buildInfoCard('Deskripsi Pekerjaan', widget.item['description']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('Lokasi Kerja', widget.item['work_location']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('Vendor', widget.item['vendor']?['legal_name']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('Jenis Pekerjaan', widget.item['work_type']?['type']?.toString() ?? 'Tidak tersedia'),

          SizedBox(height: 20),

          // Timeline
          _buildSectionHeader('Timeline Pekerjaan'),
          _buildInfoCard('Tanggal Mulai', _formatDate(widget.item['started_at'])),
          SizedBox(height: 12),
          _buildInfoCard('Tanggal Selesai', _formatDate(widget.item['ended_at'])),

          SizedBox(height: 20),

          // PIC
          _buildSectionHeader('Penanggung Jawab'),
          _buildInfoCard('PIC Eksternal', widget.item['external_pic_name']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('No. HP PIC Eksternal', widget.item['external_pic_number']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('PIC Internal', widget.item['internal_pic_name']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('No. HP PIC Internal', widget.item['internal_pic_number']?.toString() ?? 'Tidak tersedia'),

          SizedBox(height: 20),

          // Dokumen & Catatan
          _buildSectionHeader('Dokumen & Catatan'),
          _buildInfoCard('Dasar Penunjukan', widget.item['pointing']?.toString() ?? 'Tidak tersedia'),
          SizedBox(height: 12),
          _buildInfoCard('Catatan', widget.item['notes']?.toString() ?? 'Tidak ada catatan'),

          SizedBox(height: 20),

          // Metadata
          _buildSectionHeader('Metadata'),
          _buildInfoCard('Dibuat', _formatDate(widget.item['created_at'])),
          SizedBox(height: 12),
          _buildInfoCard('Diupdate', _formatDate(widget.item['updated_at'])),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildInfoCard(String label, String value, {int maxLines = 2}) {
    return Container(
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
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[900],
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}