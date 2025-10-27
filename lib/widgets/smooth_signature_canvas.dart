import 'package:flutter/material.dart';

class SmoothSignatureCanvas extends StatefulWidget {
  final ValueChanged<List<Offset>> onPointsUpdate;
  final List<Offset> points;

  const SmoothSignatureCanvas({
    Key? key,
    required this.onPointsUpdate,
    required this.points,
  }) : super(key: key);

  @override
  SmoothSignatureCanvasState createState() => SmoothSignatureCanvasState();
}

class SmoothSignatureCanvasState extends State<SmoothSignatureCanvas> {
  List<Offset> _points = [];
  bool _isDrawing = false;
  
  void clearCanvas() {
    setState(() {
      _points.clear();
    });
    widget.onPointsUpdate([]);
  }

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.points);
  }

  void _handlePanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // Validasi titik dalam bounds
    if (_isValidPoint(localPosition, box.size)) {
      setState(() {
        _isDrawing = true;
        _points.add(localPosition);
      });
      widget.onPointsUpdate(List.from(_points));
      print('🟢 START: ${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)}');
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // Validasi titik dalam bounds
    if (_isValidPoint(localPosition, box.size)) {
      setState(() {
        _points.add(localPosition);
      });
      widget.onPointsUpdate(List.from(_points));
      print('🔵 UPDATE: ${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)}');
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isDrawing) {
      setState(() {
        _isDrawing = false;
      });
      widget.onPointsUpdate(List.from(_points));
      print('🔴 END - Total points: ${_points.length}');
    }
  }

  bool _isValidPoint(Offset point, Size size) {
    return point.dx >= 0 && 
           point.dx <= size.width && 
           point.dy >= 0 && 
           point.dy <= size.height &&
           point.dx.isFinite && 
           point.dy.isFinite;
  }

  @override
  void didUpdateWidget(SmoothSignatureCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _points = List.from(widget.points);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue.withOpacity(0.3), 
          width: 2
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background grid untuk debugging
          _buildDebugGrid(),
          // Signature area
          GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                painter: _SimpleSignaturePainter(_points),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugGrid() {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _SimpleSignaturePainter extends CustomPainter {
  final List<Offset> points;

  _SimpleSignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Clear background dengan warna sedikit transparan agar grid terlihat
    final backgroundPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    if (points.isEmpty) {
      // Draw instruction text when empty
      _drawInstructionText(canvas, size);
      return;
    }

    if (points.length < 2) {
      // Draw single point
      final dotPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[0], 3.0, dotPaint);
      return;
    }

    // Draw the signature path
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      if (point.dx.isFinite && point.dy.isFinite) {
        path.lineTo(point.dx, point.dy);
      }
    }
    
    canvas.drawPath(path, paint);

    // Debug: Draw points in red
    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      if (point.dx >= 0 && point.dx <= size.width && 
          point.dy >= 0 && point.dy <= size.height) {
        canvas.drawCircle(point, 2.0, dotPaint);
      }
    }
  }

  void _drawInstructionText(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.grey[400],
      fontSize: 16,
    );
    
    final textSpan = TextSpan(
      text: 'Gambar tanda tangan di sini',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SimpleSignaturePainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}