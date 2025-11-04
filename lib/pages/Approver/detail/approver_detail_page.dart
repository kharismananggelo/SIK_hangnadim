import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../services/master_data_service.dart';
import '../../../widgets/sweet_alert_dialog.dart';
import '../../../widgets/smooth_signature_canvas.dart'; 

class ApproverDetailPage extends StatefulWidget {
  final dynamic item;

  ApproverDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _ApproverDetailPageState createState() => _ApproverDetailPageState();
}

class _ApproverDetailPageState extends State<ApproverDetailPage> {
  final _formKey = GlobalKey<FormState>();
  // 🔥 PERBAIKAN: Pindahkan signatureCanvasKey ke State class
  final GlobalKey<SmoothSignatureCanvasState> _signatureCanvasKey = GlobalKey<SmoothSignatureCanvasState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _positionController;
  late TextEditingController _levelController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isMounted = false;

  // 🔥 VARIABEL UNTUK SIGNATURE CANVAS YANG DIPERBAIKI
  bool _showSignatureCanvas = false;
  List<Offset> _points = [];
  ui.Image? _signatureImage;
  bool _hasSignatureChanges = false;

  // Focus nodes untuk keyboard handling
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();
  final FocusNode _levelFocusNode = FocusNode();

  // 🔥 VARIABEL UNTUK TRACK VALIDASI REAL-TIME
  bool _nameHasError = false;
  bool _emailHasError = false;
  bool _positionHasError = false;
  bool _levelHasError = false;
  String? _nameErrorText;
  String? _emailErrorText;
  String? _positionErrorText;
  String? _levelErrorText;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _nameController = TextEditingController(text: widget.item['user']?['name']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.item['user']?['email']?.toString() ?? '');
    _positionController = TextEditingController(text: widget.item['position']?.toString() ?? '');
    _levelController = TextEditingController(text: widget.item['level']?.toString() ?? '');

    // 🔥 LISTENER UNTUK REAL-TIME VALIDATION
    _nameController.addListener(_validateNameRealTime);
    _emailController.addListener(_validateEmailRealTime);
    _positionController.addListener(_validatePositionRealTime);
    _levelController.addListener(_validateLevelRealTime);
  }

  // 🔥 METHOD BARU UNTUK HANDLE UPDATE POINTS DARI CANVAS
  void _updateSignaturePoints(List<Offset> newPoints) {
    if (!_isMounted) return;
    
    // Batasi jumlah points untuk performance
    if (newPoints.length > 1500) {
      newPoints = newPoints.sublist(newPoints.length - 1200);
    }
    
    setState(() {
      _points = newPoints;
      _hasSignatureChanges = true;
    });
  }

  void _clearSignature() {
    if (!_isMounted) return;
    
    // 🔥 PERBAIKAN: Sekarang bisa akses _signatureCanvasKey karena sudah dipindahkan ke State
    _signatureCanvasKey.currentState?.clearCanvas();
    
    setState(() {
      _points.clear();
      _signatureImage = null;
      _hasSignatureChanges = true;
    });
    
    _updateSignaturePoints([]);
  }

  @override
  void dispose() {
    _isMounted = false;
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _levelController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _positionFocusNode.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  // 🔥 VALIDASI REAL-TIME
  void _validateNameRealTime() {
    final error = _validateName(_nameController.text);
    if (_isMounted) {
      setState(() {
        _nameHasError = error != null;
        _nameErrorText = error;
      });
    }
  }

  void _validateEmailRealTime() {
    final error = _validateEmail(_emailController.text);
    if (_isMounted) {
      setState(() {
        _emailHasError = error != null;
        _emailErrorText = error;
      });
    }
  }

  void _validatePositionRealTime() {
    final error = _validatePosition(_positionController.text);
    if (_isMounted) {
      setState(() {
        _positionHasError = error != null;
        _positionErrorText = error;
      });
    }
  }

  void _validateLevelRealTime() {
    final error = _validateLevel(_levelController.text);
    if (_isMounted) {
      setState(() {
        _levelHasError = error != null;
        _levelErrorText = error;
      });
    }
  }

  // 🔥 VALIDATOR FUNCTIONS
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama approver wajib diisi';
    }
    if (value.trim().isEmpty) {
      return 'Nama tidak boleh hanya spasi';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    
    final invalidChars = RegExp(r'[<>{}]');
    if (invalidChars.hasMatch(value)) {
      return 'Nama tidak boleh mengandung karakter <, >, {, }';
    }
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  String? _validatePosition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Posisi/jabatan wajib diisi';
    }
    if (value.trim().isEmpty) {
      return 'Posisi tidak boleh hanya spasi';
    }
    if (value.length < 2) {
      return 'Posisi minimal 2 karakter';
    }
    if (value.length > 100) {
      return 'Posisi maksimal 100 karakter';
    }
    
    final invalidChars = RegExp(r'[<>{}]');
    if (invalidChars.hasMatch(value)) {
      return 'Posisi tidak boleh mengandung karakter <, >, {, }';
    }
    
    return null;
  }

  String? _validateLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Level approval wajib diisi';
    }
    
    final level = int.tryParse(value);
    if (level == null) {
      return 'Level harus berupa angka';
    }
    if (level < 1) {
      return 'Level minimal 1';
    }
    if (level > 10) {
      return 'Level maksimal 10';
    }
    
    return null;
  }

  void _toggleEdit() {
    if (!_isMounted) return;
    
    if (_isEditing) {
      setState(() {
        _nameHasError = false;
        _emailHasError = false;
        _positionHasError = false;
        _levelHasError = false;
        _nameErrorText = null;
        _emailErrorText = null;
        _positionErrorText = null;
        _levelErrorText = null;
        _showSignatureCanvas = false;
        _points.clear();
        _hasSignatureChanges = false;
      });
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveForm() async {
    FocusScope.of(context).unfocus();
    
    final nameError = _validateName(_nameController.text);
    final emailError = _validateEmail(_emailController.text);
    final positionError = _validatePosition(_positionController.text);
    final levelError = _validateLevel(_levelController.text);
    
    setState(() {
      _nameHasError = nameError != null;
      _emailHasError = emailError != null;
      _positionHasError = positionError != null;
      _levelHasError = levelError != null;
      _nameErrorText = nameError;
      _emailErrorText = emailError;
      _positionErrorText = positionError;
      _levelErrorText = levelError;
    });
    
    if (nameError != null || emailError != null || positionError != null || levelError != null) {
      _showValidationErrorAlert();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'position': _positionController.text.trim(),
        'level': int.tryParse(_levelController.text) ?? 1,
      };

      print('🔄 Data yang dikirim ke API approvers:');
      print('Name: ${data['name']}');
      print('Email: ${data['email']}');
      print('Position: ${data['position']}');
      print('Level: ${data['level']}');
      print('ID: ${widget.item['id']}');

      await MasterDataService.updateData('approvers', widget.item['id'], data);
      
      if (!_isMounted) return;
      
      _showSimpleSuccessAlert('Data approver berhasil diupdate');
      
    } catch (e) {
      if (!_isMounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      _handleApiError(e);
    }
  }

  // 🔥 METHOD UNTUK MENANGANI ERROR DARI API
  void _handleApiError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan saat menyimpan data';
    String errorTitle = 'Gagal Update';

    if (error.toString().contains('422')) {
      errorTitle = 'Data Tidak Valid';
      
      if (_nameController.text.trim().isEmpty) {
        errorMessage = 'Nama approver wajib diisi';
      } else if (_nameController.text.trim().length < 2) {
        errorMessage = 'Nama minimal 2 karakter';
      } else if (_emailController.text.trim().isEmpty) {
        errorMessage = 'Email wajib diisi';
      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
        errorMessage = 'Format email tidak valid';
      } else if (_positionController.text.trim().isEmpty) {
        errorMessage = 'Posisi/jabatan wajib diisi';
      } else if (_levelController.text.isEmpty) {
        errorMessage = 'Level approval wajib diisi';
      } else if (int.tryParse(_levelController.text) == null) {
        errorMessage = 'Level harus berupa angka';
      } else if (error.toString().contains('duplicate') || error.toString().contains('already exists')) {
        errorMessage = 'Data sudah ada dalam sistem. Email mungkin sudah digunakan';
      } else {
        errorMessage = 'Data yang dimasukkan tidak valid. Periksa kembali semua field';
      }
    } 
    else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan di server';
    } else if (error.toString().contains('409')) {
      errorMessage = 'Data sudah ada dalam sistem. Email mungkin sudah digunakan';
    } else if (error.toString().contains('timeout') || error.toString().contains('SocketException')) {
      errorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi';
    } else {
      errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi';
    }

    _showDetailedErrorAlert(errorTitle, errorMessage);
  }

  // 🔥 SIGNATURE CANVAS METHODS YANG DIPERBAIKI
  void _openSignatureCanvas() {
    if (!_isEditing) return; // 🔥 HANYA AKTIF SAAT EDIT MODE
    
    setState(() {
      _showSignatureCanvas = true;
      _points.clear();
      _hasSignatureChanges = false;
    });
  }

  void _saveSignature() async {
    final validPoints = _points.where((point) => 
      point != Offset.infinite && 
      point.dx.isFinite && 
      point.dy.isFinite
    ).toList();

    if (validPoints.length < 10) {
      _showSignatureValidationAlert(
        'Tanda tangan terlalu pendek', 
        'Harap gambar tanda tangan yang lebih jelas dan lengkap. Minimal 10 titik.'
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final picture = _recordSignature();
      final image = await picture.toImage(400, 200);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();

      await MasterDataService.uploadSignature('approvers', widget.item['id'], uint8List);
      
      if (!_isMounted) return;
      
      setState(() {
        _showSignatureCanvas = false;
        _points.clear();
        _hasSignatureChanges = false;
      });
      
      _showSimpleSuccessAlert('Tanda tangan berhasil disimpan');
      
    } catch (e) {
      if (!_isMounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      _handleApiError(e);
    }
  }

  ui.Picture _recordSignature() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawRect(Rect.fromLTRB(0, 0, 400, 200), Paint()..color = Colors.white);

    _SimpleSignaturePainter(_points).paint(canvas, Size(400, 200));

    return recorder.endRecording();
  }

  void _closeSignatureCanvas() {
    if (_hasSignatureChanges) {
      _showUnsavedChangesAlert();
    } else {
      setState(() {
        _showSignatureCanvas = false;
        _points.clear();
      });
    }
  }

  Future<void> _deleteData() async {
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
      
      _handleApiError(e);
    }
  }

  // 🔥 ALERT METHODS
  void _showValidationErrorAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  size: 30,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Periksa Kembali Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Terdapat data yang tidak valid. Harap periksa form yang ditandai dengan warna merah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignatureValidationAlert(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.gesture,
                  size: 30,
                  color: Colors.orange,
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
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnsavedChangesAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  size: 30,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Perubahan Belum Disimpan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tanda tangan yang telah digambar belum disimpan. Yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _showSignatureCanvas = false;
                          _points.clear();
                          _hasSignatureChanges = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedErrorAlert(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 30,
                  color: Colors.red,
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
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Mengerti'),
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

  Widget _buildSignatureStatus() {
    final hasSignature = widget.item['signature'] != null;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasSignature ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasSignature ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasSignature ? Icons.assignment_turned_in : Icons.assignment_late,
            color: hasSignature ? Colors.green : Colors.orange,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSignature ? 'Tanda Tangan Tersedia' : 'Tanda Tangan Belum Diupload',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasSignature ? Colors.green : Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  hasSignature 
                    ? 'Approver sudah memiliki tanda tangan digital'
                    : 'Approver belum mengupload tanda tangan',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasSignature ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isEditing ? _openSignatureCanvas : null, // 🔥 HANYA AKTIF SAAT EDIT
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSignature ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(hasSignature ? 'Ganti TTD' : 'Upload TTD'),
          ),
        ],
      ),
    );
  }

  // 🔥 SIGNATURE CANVAS WIDGET YANG SUDAH DIPERBAIKI
  Widget _buildSignatureCanvas() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tanda Tangan Digital',
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
          // 🔥 PERBAIKAN: Tombol clear yang berfungsi dengan key yang sudah diperbaiki
          IconButton(
            icon: Icon(Icons.clear_all, color: Colors.red),
            onPressed: _clearSignature,
            tooltip: 'Hapus Tanda Tangan',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gambar tanda tangan Anda di area bawah. Gunakan satu jari untuk hasil terbaik.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              Expanded(
                child: SmoothSignatureCanvas(
                  key: _signatureCanvasKey, // 🔥 GUNAKAN KEY YANG SUDAH DIPERBAIKI
                  onPointsUpdate: _updateSignaturePoints, points: [],
                ),
              ),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _points.length > 10 ? 
                        Colors.green.withOpacity(0.1) : 
                        Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _points.length > 10 ? Icons.check_circle : Icons.info,
                      color: _points.length > 10 ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _points.length > 10 ? 
                      'Tanda tangan sudah cukup jelas' : 
                      'Gambar tanda tangan lebih jelas',
                      style: TextStyle(
                        color: _points.length > 10 ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _closeSignatureCanvas,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'BATAL',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _points.length > 10 ? _saveSignature : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _points.length > 10 ? 
                                      Colors.blue : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : Text(
                              'SIMPAN TTD',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSignatureCanvas) {
      return _buildSignatureCanvas();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Approver',
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
          else if (!_isEditing) ...[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue[700]),
              onPressed: _toggleEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
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
              child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.blue))
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
                _buildInfoCard('Nama Approver', widget.item['user']?['name']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard('Email', widget.item['user']?['email']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard('Posisi/Jabatan', widget.item['position']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard('Level Approval', widget.item['level']?.toString() ?? 'Tidak tersedia'),
                SizedBox(height: 12),
                _buildInfoCard(
                  'Status Default', 
                  widget.item['is_default_approver'] == 1 ? 'Ya' : 'Tidak',
                ),
                SizedBox(height: 12),
                _buildSignatureStatus(),
                SizedBox(height: 12),
                _buildInfoCard('Dibuat', _formatDate(widget.item['created_at'])),
                SizedBox(height: 12),
                _buildInfoCard('Diupdate', _formatDate(widget.item['updated_at'])),
                SizedBox(height: 20),
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
                _buildFormField(
                  controller: _nameController,
                  label: 'Nama Approver',
                  hasError: _nameHasError,
                  errorText: _nameErrorText,
                ),
                SizedBox(height: 16),
                _buildFormField(
                  controller: _emailController,
                  label: 'Email',
                  hasError: _emailHasError,
                  errorText: _emailErrorText,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                _buildFormField(
                  controller: _positionController,
                  label: 'Posisi/Jabatan',
                  hasError: _positionHasError,
                  errorText: _positionErrorText,
                ),
                SizedBox(height: 16),
                _buildFormField(
                  controller: _levelController,
                  label: 'Level Approval',
                  hasError: _levelHasError,
                  errorText: _levelErrorText,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                _buildSignatureStatus(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildEditActionButtons(),
      ],
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required bool hasError,
    required String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: hasError ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              label + ' *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: hasError ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasError ? Colors.red.withOpacity(0.02) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : Colors.blue.withOpacity(0.3),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
                hintText: 'Masukkan $label',
                errorText: errorText,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextStyle(
                color: hasError ? Colors.red : Colors.grey[800],
                fontSize: 14,
              ),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleEdit,
                icon: Icon(Icons.edit, size: 20),
                label: Text('EDIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteData,
                icon: Icon(Icons.delete, size: 20),
                label: Text('HAPUS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
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
                onPressed: _toggleEdit,
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
    );
  }
}

// PAINTER UNTUK RECORD SIGNATURE
class _SimpleSignaturePainter extends CustomPainter {
  final List<Offset> points;

  _SimpleSignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white
    );

    if (points.isEmpty) return;

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final currentPoint = points[i];
      final nextPoint = points[i + 1];

      if (currentPoint != Offset.infinite && 
          nextPoint != Offset.infinite &&
          currentPoint.dx.isFinite && 
          currentPoint.dy.isFinite &&
          nextPoint.dx.isFinite && 
          nextPoint.dy.isFinite) {
        
        canvas.drawLine(currentPoint, nextPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SimpleSignaturePainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}