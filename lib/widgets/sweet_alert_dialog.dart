import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info, loading }

class SweetAlertDialog extends StatefulWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback? onConfirm;
  final String confirmText;
  final bool showCancelButton;
  final String cancelText;
  final VoidCallback? onCancel;
  final bool dismissible;

  const SweetAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    this.type = AlertType.info,
    this.onConfirm,
    this.confirmText = 'OK',
    this.showCancelButton = false,
    this.cancelText = 'Cancel',
    this.onCancel,
    this.dismissible = true,
  }) : super(key: key);

  @override
  _SweetAlertDialogState createState() => _SweetAlertDialogState();
}

class _SweetAlertDialogState extends State<SweetAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIcon() {
    final iconData = _getIconData();
    final color = _getIconColor();
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 40,
        color: color,
      ),
    );
  }

  IconData _getIconData() {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.loading:
        return Icons.hourglass_top;
      case AlertType.info:
      default:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.error:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.loading:
        return Colors.blue;
      case AlertType.info:
      default:
        return Colors.blue;
    }
  }

  void _handleConfirm() {
    _controller.reverse().then((_) {
      if (_isMounted) {
        Navigator.of(context).pop();
        widget.onConfirm?.call();
      }
    });
  }

  void _handleCancel() {
    _controller.reverse().then((_) {
      if (_isMounted) {
        Navigator.of(context).pop();
        widget.onCancel?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.dismissible) {
          _handleCancel();
        }
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan animasi
                _buildIcon(),
                
                SizedBox(height: 20),
                
                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 12),
                
                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    if (widget.showCancelButton) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleCancel,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Text(
                            widget.cancelText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getIconColor(),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          widget.confirmText,
                          style: TextStyle(
                            fontSize: 16,
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
        ),
      ),
    );
  }
}

// Helper function untuk show dialog
class SweetAlert {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    AlertType type = AlertType.info,
    VoidCallback? onConfirm,
    String confirmText = 'OK',
    bool showCancelButton = false,
    String cancelText = 'Cancel',
    VoidCallback? onCancel,
    bool dismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => SweetAlertDialog(
        title: title,
        message: message,
        type: type,
        onConfirm: onConfirm,
        confirmText: confirmText,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
        onCancel: onCancel,
        dismissible: dismissible,
      ),
    );
  }

  // Predefined methods untuk common alerts
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String confirmText = 'OK',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: AlertType.success,
      onConfirm: onConfirm,
      confirmText: confirmText,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String confirmText = 'OK',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: AlertType.error,
      onConfirm: onConfirm,
      confirmText: confirmText,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: AlertType.warning,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showCancelButton: true,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String confirmText = 'OK',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: AlertType.info,
      onConfirm: onConfirm,
      confirmText: confirmText,
    );
  }

  static void showLoading({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: AlertType.loading,
      dismissible: false,
    );
  }
}