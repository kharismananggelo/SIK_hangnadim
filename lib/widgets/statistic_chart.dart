// statistics_chart.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/work_permit_letter.dart';

class StatisticsChart extends StatefulWidget {
  final List<WorkPermitLetter> workPermits;
  final VoidCallback onRefresh;

  const StatisticsChart({
    super.key,
    required this.workPermits,
    required this.onRefresh,
  });

  @override
  State<StatisticsChart> createState() => _StatisticsChartState();
}

class _StatisticsChartState extends State<StatisticsChart>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  bool _isRefreshing = false;
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;
  late AnimationController _refreshAnimationController;
  late AnimationController _segmentTransitionController;
  late Animation<double> _segmentTransitionAnimation;

  String? _previousSelectedCategory;

  @override
  void initState() {
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    );

    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _segmentTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _segmentTransitionAnimation = CurvedAnimation(
      parent: _segmentTransitionController,
      curve: Curves.easeInOut,
    );

    super.initState();

    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _refreshAnimationController.dispose();
    _segmentTransitionController.dispose();
    super.dispose();
  }

  Map<String, int> _calculateStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int aktif = 0;
    int selesai = 0;
    int expired = 0;
    int pending = 0;
    int expireHariIni = 0;

    for (var permit in widget.workPermits) {
      final endDate = DateTime(
        permit.endedAt.year,
        permit.endedAt.month,
        permit.endedAt.day,
      );
      final isExpired = endDate.isBefore(today);
      final expiresToday = endDate.isAtSameMomentAs(today);

      switch (permit.status) {
        case 'verified':
          if (isExpired) {
            expired++;
          } else if (expiresToday) {
            expireHariIni++;
          } else {
            aktif++;
          }
          break;
        case 'approved':
          selesai++;
          break;
        case 'completed':
          selesai++;
          break;
        case 'submitted':
        case 'pending':
          pending++;
          break;
        default:
          pending++;
          break;
      }
    }

    return {
      'Aktif': aktif,
      'Selesai': selesai,
      'Expired': expired,
      'Pending': pending,
      'Expire Hari Ini': expireHariIni,
    };
  }

  double _calculatePercentage(int value, int total) {
    return total > 0 ? value / total : 0.0;
  }

  void _handleChartTap(String category) {
    if (_isRefreshing) return;

    final stats = _calculateStatistics();

    setState(() {
      _previousSelectedCategory = _selectedCategory;
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });

    // PERBAIKAN: Selalu gunakan segment transition untuk perubahan segment
    // Hanya restart chart animation jika benar-benar perlu
    final shouldRestartAnimation =
        stats[category] == 0 ||
        (_selectedCategory != null && stats[_selectedCategory!] == 0);

    if (shouldRestartAnimation) {
      _chartAnimationController.forward(from: 0.0);
      _segmentTransitionController.reset();
    } else {
      _segmentTransitionController.forward(from: 0.0);
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    _refreshAnimationController.repeat();

    setState(() {
      _isRefreshing = true;
      _previousSelectedCategory = null;
    });

    try {
      widget.onRefresh();
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      if (mounted) {
        _refreshAnimationController.stop();
        setState(() {
          _isRefreshing = false;
          _selectedCategory = null;
          _previousSelectedCategory = null;
        });
        _chartAnimationController.forward(from: 0.0);
        _segmentTransitionController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      height: 460,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik SIK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Klik bagian chart untuk melihat detail surat',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  child: _isRefreshing
                      ? RotationTransition(
                          turns: _refreshAnimationController,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _handleRefresh,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                ),
              ],
            ),
          ),

          if (_isRefreshing)
            _buildRefreshingChartSection()
          else
            _buildAnimatedChartSection(),

          const SizedBox(height: 12),

          Expanded(
            child: _isRefreshing
                ? _buildRefreshingStatisticsList()
                : _buildNormalStatisticsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChartSection() {
    final stats = _calculateStatistics();
    final total = stats.values.reduce((a, b) => a + b);

    final selectedCount = _selectedCategory != null
        ? stats[_selectedCategory] ?? 0
        : total;

    final selectedPercentage = _selectedCategory != null
        ? _calculatePercentage(selectedCount, total)
        : 1.0;

    final selectedColor = _selectedCategory != null
        ? _getColorForCategory(_selectedCategory!)
        : Colors.blue[900];

    final chartData = [
      _ChartData('Aktif', stats['Aktif']!, const Color(0xFF4CAF50)),
      _ChartData('Selesai', stats['Selesai']!, const Color(0xFF2196F3)),
      _ChartData('Pending', stats['Pending']!, const Color(0xFFFF9800)),
      _ChartData('Expired', stats['Expired']!, const Color(0xFFF44336)),
      _ChartData(
        'Expire Hari Ini',
        stats['Expire Hari Ini']!,
        const Color(0xFF9C27B0),
      ),
    ];

    final validData = chartData.where((data) => data.count > 0).toList();

    final isSelectedCategoryEmpty =
        _selectedCategory != null && stats[_selectedCategory] == 0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _chartAnimation,
        _segmentTransitionAnimation,
      ]),
      builder: (context, child) {
        return Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Opacity(
                  opacity: _chartAnimation.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedCount.toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: selectedColor!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedCategory != null) ...[
                        Text(
                          _selectedCategory!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedColor,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'SIK Bulan Ini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Container(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[300]!,
                      ),
                      backgroundColor: Colors.transparent,
                    ),

                    if (validData.isNotEmpty)
                      GestureDetector(
                        onTapDown: (details) {
                          _handleChartTapOnSegment(details, validData, total);
                        },
                        child: CustomPaint(
                          size: const Size(100, 100),
                          painter: _AnimatedChartPainter(
                            data: validData,
                            total: total,
                            selectedCategory: _selectedCategory,
                            previousSelectedCategory: _previousSelectedCategory,
                            chartAnimation: _chartAnimation,
                            segmentTransitionAnimation:
                                _segmentTransitionAnimation,
                            isSelectedCategoryEmpty: isSelectedCategoryEmpty,
                          ),
                        ),
                      ),

                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ScaleTransition(
                        scale: _chartAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedCategory != null
                                  ? '${(selectedPercentage * 100).toStringAsFixed(0)}%'
                                  : '100%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedCategory != null
                                  ? _selectedCategory!
                                  : 'Total',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefreshingChartSection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 120,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                  backgroundColor: Colors.transparent,
                ),

                RotationTransition(
                  turns: _refreshAnimationController,
                  child: const CircularProgressIndicator(
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),

                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 30,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalStatisticsList() {
    final stats = _calculateStatistics();
    final statItems = [
      _StatItem(
        'Aktif',
        stats['Aktif']!,
        const Color(0xFF4CAF50),
        'SIK yang sedang aktif (berjalan)',
      ),
      _StatItem(
        'Selesai',
        stats['Selesai']!,
        const Color(0xFF2196F3),
        'SIK yang sudah selesai dan dikonfirmasi',
      ),
      _StatItem(
        'Expired',
        stats['Expired']!,
        const Color(0xFFF44336),
        'SIK yang sudah expired',
      ),
      _StatItem(
        'Pending',
        stats['Pending']!,
        const Color(0xFFFF9800),
        'SIK Pending, perlu direview',
      ),
      _StatItem(
        'Expire Hari Ini',
        stats['Expire Hari Ini']!,
        const Color(0xFF9C27B0),
        'SIK yang akan expire hari ini',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: statItems.map((item) => _buildStatListItem(item)).toList(),
      ),
    );
  }

  Widget _buildRefreshingStatisticsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(5, (index) => _buildRefreshingStatListItem()),
      ),
    );
  }

  Widget _buildStatListItem(_StatItem item) {
    final isSelected = _selectedCategory == item.title;

    return GestureDetector(
      onTap: () => _handleChartTap(item.title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? item.color.withOpacity(0.06) : Colors.transparent,
          border: isSelected
              ? Border.all(color: item.color.withOpacity(0.9), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: item.color.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 8 : 6,
              height: isSelected ? 8 : 6,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: item.color.withOpacity(0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 12,
                vertical: isSelected ? 6 : 5,
              ),
              decoration: BoxDecoration(
                color: item.color.withOpacity(isSelected ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: item.color.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 28),
                child: Center(
                  child: Text(
                    item.count.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshingStatListItem() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 20,
              height: 13,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChartTapOnSegment(
    TapDownDetails details,
    List<_ChartData> data,
    int total,
  ) {
    if (_isRefreshing) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    final center = const Offset(50, 50);
    final radius = 45.0;

    final distance = (localPosition - center).distance;

    if (distance <= radius) {
      final dx = localPosition.dx - center.dx;
      final dy = localPosition.dy - center.dy;
      var angle = (atan2(dy, dx) * 180 / pi) + 90;
      if (angle < 0) angle += 360;

      double cumulativeAngle = 0.0;

      for (var chartData in data) {
        final percentage = chartData.count / total;
        final sweepAngle = percentage * 360;

        cumulativeAngle += sweepAngle;

        if (angle <= cumulativeAngle) {
          _handleChartTap(chartData.title);
          break;
        }
      }
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Aktif':
        return const Color(0xFF4CAF50);
      case 'Selesai':
        return const Color(0xFF2196F3);
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Expired':
        return const Color(0xFFF44336);
      case 'Expire Hari Ini':
        return const Color(0xFF9C27B0);
      default:
        return Colors.blue;
    }
  }
}

class _AnimatedChartPainter extends CustomPainter {
  final List<_ChartData> data;
  final int total;
  final String? selectedCategory;
  final String? previousSelectedCategory;
  final Animation<double> chartAnimation;
  final Animation<double> segmentTransitionAnimation;
  final bool isSelectedCategoryEmpty;

  _AnimatedChartPainter({
    required this.data,
    required this.total,
    required this.selectedCategory,
    required this.previousSelectedCategory,
    required this.chartAnimation,
    required this.segmentTransitionAnimation,
    required this.isSelectedCategoryEmpty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final strokeWidth = 10.0;
    final gapSize = 2.0;

    double startAngle = -90 * (pi / 180);

    final validData = data.where((d) => d.count > 0).toList();
    final validDataCount = validData.length;

    // PERBAIKAN: Cek apakah selected category valid (ada di validData)
    final isSelectedCategoryValid =
        selectedCategory != null &&
        validData.any((d) => d.title == selectedCategory);
    final isPreviousCategoryValid =
        previousSelectedCategory != null &&
        validData.any((d) => d.title == previousSelectedCategory);

    // PERBAIKAN: Hitung jumlah segment yang benar untuk distribusi
    final segmentsForDistribution = isSelectedCategoryValid
        ? validDataCount - 1
        : 0;

    if (isSelectedCategoryEmpty) {
      final paint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        360 * (pi / 180) * chartAnimation.value,
        false,
        paint,
      );
      return;
    }

    for (var chartData in data) {
      if (chartData.count == 0) continue;

      final percentage = chartData.count / total;
      var animatedSweepAngle =
          percentage * 360 * (pi / 180) * chartAnimation.value;

      final isSelected = selectedCategory == chartData.title;
      final wasSelected = previousSelectedCategory == chartData.title;

      // PERBAIKAN: Animasi hanya untuk perubahan state yang valid
      final shouldAnimateTransition =
          (previousSelectedCategory == null && selectedCategory != null) ||
          (previousSelectedCategory != null && selectedCategory == null) ||
          (previousSelectedCategory != null &&
              selectedCategory != null &&
              previousSelectedCategory != selectedCategory);

      // PERBAIKAN: Hitung target state dengan pengecekan validitas
      double targetSweepAngle;
      if (isSelected && isSelectedCategoryValid) {
        targetSweepAngle = 0.80 * 360 * (pi / 180) * chartAnimation.value;
      } else if (selectedCategory != null && isSelectedCategoryValid) {
        final smallPercentage = segmentsForDistribution > 0
            ? 0.20 / segmentsForDistribution
            : 0.0;
        targetSweepAngle =
            smallPercentage * 360 * (pi / 180) * chartAnimation.value;
      } else {
        targetSweepAngle = percentage * 360 * (pi / 180) * chartAnimation.value;
      }

      // PERBAIKAN: Hitung start state dengan pengecekan validitas
      double startSweepAngle;
      if (wasSelected && isPreviousCategoryValid) {
        startSweepAngle = 0.80 * 360 * (pi / 180) * chartAnimation.value;
      } else if (previousSelectedCategory != null && isPreviousCategoryValid) {
        final previousSegmentsCount = validDataCount - 1;
        final smallPercentage = previousSegmentsCount > 0
            ? 0.20 / previousSegmentsCount
            : 0.0;
        startSweepAngle =
            smallPercentage * 360 * (pi / 180) * chartAnimation.value;
      } else {
        startSweepAngle = percentage * 360 * (pi / 180) * chartAnimation.value;
      }

      // APLIKASI ANIMASI SMOOTH
      if (shouldAnimateTransition && segmentTransitionAnimation.value < 1.0) {
        animatedSweepAngle =
            startSweepAngle +
            (targetSweepAngle - startSweepAngle) *
                segmentTransitionAnimation.value;
      } else {
        animatedSweepAngle = targetSweepAngle;
      }

      if (animatedSweepAngle > gapSize * (pi / 180)) {
        animatedSweepAngle -= gapSize * (pi / 180);
      }

      // PERBAIKAN: Animasi opacity dengan pengecekan validitas
      final targetOpacity = isSelected
          ? 1.0
          : (isSelectedCategoryValid && !isSelected ? 0.4 : 1.0);
      final startOpacity = wasSelected
          ? 1.0
          : (isPreviousCategoryValid && !wasSelected ? 0.4 : 1.0);

      double currentOpacity;
      if (shouldAnimateTransition && segmentTransitionAnimation.value < 1.0) {
        currentOpacity =
            startOpacity +
            (targetOpacity - startOpacity) * segmentTransitionAnimation.value;
      } else {
        currentOpacity = targetOpacity;
      }

      final color = chartData.color.withOpacity(currentOpacity);

      // PERBAIKAN: Animasi stroke width dengan pengecekan validitas
      final targetStrokeWidth = (isSelected && isSelectedCategoryValid)
          ? strokeWidth + 3
          : strokeWidth;
      final startStrokeWidth = (wasSelected && isPreviousCategoryValid)
          ? strokeWidth + 3
          : strokeWidth;

      double currentStrokeWidth;
      if (shouldAnimateTransition && segmentTransitionAnimation.value < 1.0) {
        currentStrokeWidth =
            startStrokeWidth +
            (targetStrokeWidth - startStrokeWidth) *
                segmentTransitionAnimation.value;
      } else {
        currentStrokeWidth = targetStrokeWidth;
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        animatedSweepAngle,
        false,
        paint,
      );

      startAngle += animatedSweepAngle + gapSize * (pi / 180);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatItem {
  final String title;
  final int count;
  final Color color;
  final String description;

  _StatItem(this.title, this.count, this.color, this.description);
}

class _ChartData {
  final String title;
  final int count;
  final Color color;

  _ChartData(this.title, this.count, this.color);
}
