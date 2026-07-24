import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../services/growth/growth_service.dart';
import '../../../services/vaccine/vaccine_service.dart';
import '../../../services/milestone/milestone_service.dart';

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.stageBg,
      appBar: AppBar(
        title: const Text('成长发育'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.stageAccent,
          unselectedLabelColor: theme.textSecondary,
          indicatorColor: theme.stageAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '📈 生长曲线'),
            Tab(text: '💉 疫苗'),
            Tab(text: '🏆 里程碑'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GrowthCurveTab(),
          VaccineTab(),
          MilestoneTab(),
        ],
      ),
    );
  }
}

// ==================== 生长曲线 Tab ====================

class GrowthCurveTab extends StatefulWidget {
  const GrowthCurveTab({super.key});

  @override
  State<GrowthCurveTab> createState() => _GrowthCurveTabState();
}

class _GrowthCurveTabState extends State<GrowthCurveTab> {
  GrowthMetric _selectedMetric = GrowthMetric.weight;

  final List<Map<String, dynamic>> _growthRecords = [
    {'date': DateTime(2024, 6, 1), 'weight': 3.2, 'height': 49.5, 'head': 34.0},
    {'date': DateTime(2024, 7, 1), 'weight': 4.5, 'height': 54.0, 'head': 36.5},
    {'date': DateTime(2024, 8, 1), 'weight': 5.8, 'height': 59.0, 'head': 39.0},
    {'date': DateTime(2024, 9, 1), 'weight': 7.0, 'height': 63.5, 'head': 41.0},
    {'date': DateTime(2024, 10, 1), 'weight': 7.8, 'height': 67.0, 'head': 42.5},
    {'date': DateTime(2024, 11, 1), 'weight': 8.5, 'height': 70.0, 'head': 43.5},
    {'date': DateTime(2024, 12, 1), 'weight': 9.0, 'height': 72.5, 'head': 44.2},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final latest = _growthRecords.last;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLatestDataCard(latest, theme),
          SizedBox(height: theme.spacingLg),
          _buildMetricSelector(theme),
          SizedBox(height: theme.spacingMd),
          _buildGrowthChart(theme),
          SizedBox(height: theme.spacingLg),
          _buildEvaluationCard(theme),
          SizedBox(height: theme.spacingLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text('记录新数据'),
            ),
          ),
          SizedBox(height: theme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildLatestDataCard(Map<String, dynamic> latest, AppTheme theme) {
    final weight = latest['weight'] as double;
    final height = latest['height'] as double;
    final head = latest['head'] as double;
    final bmi = weight / ((height / 100) * (height / 100));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingSm,
                  vertical: theme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: theme.stageAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                ),
                child: Text(
                  '最新数据',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.stageAccentDark,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateTimeUtils.formatDateCn(latest['date'] as DateTime),
                style: TextStyle(fontSize: 13, color: theme.textTertiary),
              ),
            ],
          ),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              _buildMetricItem('📏', '身高', '${height.toStringAsFixed(1)} cm', theme),
              Container(width: 1, height: 50, color: theme.stageSurface),
              _buildMetricItem('⚖️', '体重', '${weight.toStringAsFixed(1)} kg', theme),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            children: [
              _buildMetricItem('🌀', '头围', '${head.toStringAsFixed(1)} cm', theme),
              Container(width: 1, height: 50, color: theme.stageSurface),
              _buildMetricItem('📊', 'BMI', bmi.toStringAsFixed(1), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String icon, String label, String value, AppTheme theme) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          SizedBox(height: theme.spacingXs),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(AppTheme theme) {
    final metrics = [
      (GrowthMetric.weight, '体重', '⚖️'),
      (GrowthMetric.height, '身高', '📏'),
      (GrowthMetric.headCircumference, '头围', '🌀'),
      (GrowthMetric.bmi, 'BMI', '📊'),
    ];

    return Container(
      padding: EdgeInsets.all(theme.spacingXs),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        borderRadius: BorderRadius.circular(theme.radiusPill),
      ),
      child: Row(
        children: metrics.map((m) {
          final isSelected = _selectedMetric == m.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMetric = m.$1;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: theme.spacingSm),
                decoration: BoxDecoration(
                  color: isSelected ? theme.paper : Colors.transparent,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.$3, style: const TextStyle(fontSize: 14)),
                    SizedBox(width: theme.spacingXs),
                    Text(
                      m.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.textPrimary : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrowthChart(AppTheme theme) {
    return Container(
      width: double.infinity,
      height: 280,
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '生长曲线图',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: theme.spacingSm),
          Row(
            children: [
              _buildLegendItem('P3', theme.textTertiary, theme),
              _buildLegendItem('P50', theme.stageAccent, theme),
              _buildLegendItem('P97', theme.textTertiary, theme),
              _buildLegendItem('宝宝', theme.success, theme),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: GrowthChartPainter(
                accentColor: theme.stageAccent,
                gridColor: theme.stageSurface,
                textColor: theme.textTertiary,
                babyColor: theme.success,
                records: _growthRecords,
                metric: _selectedMetric,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, AppTheme theme) {
    return Padding(
      padding: EdgeInsets.only(right: theme.spacingMd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          SizedBox(width: theme.spacingXs),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.success.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.green, size: 24),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '发育正常 · P50-P75 区间',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '宝宝生长发育良好，继续保持均衡营养和规律作息',
                  style: TextStyle(fontSize: 13, color: theme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GrowthChartPainter extends CustomPainter {
  final Color accentColor;
  final Color gridColor;
  final Color textColor;
  final Color babyColor;
  final List<Map<String, dynamic>> records;
  final GrowthMetric metric;

  GrowthChartPainter({
    required this.accentColor,
    required this.gridColor,
    required this.textColor,
    required this.babyColor,
    required this.records,
    required this.metric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = gridColor..strokeWidth = 1;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(40, y), Offset(size.width - 10, y), paint);
    }

    for (int i = 0; i <= 6; i++) {
      final x = 40 + (size.width - 50) * i / 6;
      textPainter.text = TextSpan(
        text: '${i + 6}月',
        style: TextStyle(fontSize: 10, color: textColor),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 2));
    }

    final p50Paint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final p3Path = Path();
    final p50Path = Path();
    final p97Path = Path();

    for (int i = 0; i <= 6; i++) {
      final x = 40 + (size.width - 50) * i / 6;
      final age = 6 + i;
      final standards = _getStandardValues(age);
      final p3Y = size.height - 20 - (standards['p3']! - _minValue) / (_maxValue - _minValue) * (size.height - 30);
      final p50Y = size.height - 20 - (standards['p50']! - _minValue) / (_maxValue - _minValue) * (size.height - 30);
      final p97Y = size.height - 20 - (standards['p97']! - _minValue) / (_maxValue - _minValue) * (size.height - 30);

      if (i == 0) {
        p3Path.moveTo(x, p3Y);
        p50Path.moveTo(x, p50Y);
        p97Path.moveTo(x, p97Y);
      } else {
        p3Path.lineTo(x, p3Y);
        p50Path.lineTo(x, p50Y);
        p97Path.lineTo(x, p97Y);
      }
    }

    final p3Paint = Paint()
      ..color = textColor.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final p97Paint = Paint()
      ..color = textColor.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(p3Path, p3Paint);
    canvas.drawPath(p50Path, p50Paint);
    canvas.drawPath(p97Path, p97Paint);

    final babyPaint = Paint()
      ..color = babyColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final babyPath = Path();
    for (int i = 0; i < records.length; i++) {
      final x = 40 + (size.width - 50) * i / (records.length - 1);
      final value = _getMetricValue(records[i]);
      final y = size.height - 20 - (value - _minValue) / (_maxValue - _minValue) * (size.height - 30);

      if (i == 0) {
        babyPath.moveTo(x, y);
      } else {
        babyPath.lineTo(x, y);
      }
    }
    canvas.drawPath(babyPath, babyPaint);

    final dotPaint = Paint()
      ..color = babyColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < records.length; i++) {
      final x = 40 + (size.width - 50) * i / (records.length - 1);
      final value = _getMetricValue(records[i]);
      final y = size.height - 20 - (value - _minValue) / (_maxValue - _minValue) * (size.height - 30);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  double get _minValue {
    switch (metric) {
      case GrowthMetric.weight:
        return 2.0;
      case GrowthMetric.height:
        return 45.0;
      case GrowthMetric.headCircumference:
        return 30.0;
      case GrowthMetric.bmi:
        return 10.0;
    }
  }

  double get _maxValue {
    switch (metric) {
      case GrowthMetric.weight:
        return 12.0;
      case GrowthMetric.height:
        return 80.0;
      case GrowthMetric.headCircumference:
        return 50.0;
      case GrowthMetric.bmi:
        return 20.0;
    }
  }

  double _getMetricValue(Map<String, dynamic> record) {
    switch (metric) {
      case GrowthMetric.weight:
        return record['weight'] as double;
      case GrowthMetric.height:
        return record['height'] as double;
      case GrowthMetric.headCircumference:
        return record['head'] as double;
      case GrowthMetric.bmi:
        final w = record['weight'] as double;
        final h = record['height'] as double;
        return w / ((h / 100) * (h / 100));
    }
  }

  Map<String, double> _getStandardValues(int ageMonths) {
    final standards = {
      GrowthMetric.weight: {'p3': 6.0, 'p50': 7.5, 'p97': 9.5},
      GrowthMetric.height: {'p3': 61.4, 'p50': 65.7, 'p97': 70.0},
      GrowthMetric.headCircumference: {'p3': 39.9, 'p50': 42.4, 'p97': 44.9},
      GrowthMetric.bmi: {'p3': 14.0, 'p50': 16.5, 'p97': 19.0},
    };
    final base = standards[metric]!;
    final factor = (ageMonths - 6) / 6;
    return {
      'p3': base['p3']! + factor * 1.5,
      'p50': base['p50']! + factor * 2.0,
      'p97': base['p97']! + factor * 2.5,
    };
  }

  @override
  bool shouldRepaint(covariant GrowthChartPainter oldDelegate) {
    return oldDelegate.metric != metric;
  }
}

// ==================== 疫苗 Tab ====================

class VaccineTab extends StatefulWidget {
  const VaccineTab({super.key});

  @override
  State<VaccineTab> createState() => _VaccineTabState();
}

class _VaccineTabState extends State<VaccineTab> {
  int _selectedSegment = 0;

  final List<Map<String, dynamic>> _upcomingVaccines = [
    {'name': '百白破疫苗', 'dose': '第3剂', 'scheduledDate': DateTime.now().add(const Duration(days: 5)), 'disease': '百日咳白喉破伤风', 'category': '国家免疫'},
    {'name': 'A群流脑多糖疫苗', 'dose': '第1剂', 'scheduledDate': DateTime.now().add(const Duration(days: 20)), 'disease': 'A群流脑', 'category': '国家免疫'},
    {'name': '乙肝疫苗', 'dose': '第3剂', 'scheduledDate': DateTime.now().add(const Duration(days: 35)), 'disease': '乙型肝炎', 'category': '国家免疫'},
    {'name': '麻腮风疫苗', 'dose': '第1剂', 'scheduledDate': DateTime.now().add(const Duration(days: 60)), 'disease': '麻疹腮腺炎风疹', 'category': '国家免疫'},
  ];

  final List<Map<String, dynamic>> _completedVaccines = [
    {'name': '乙肝疫苗', 'dose': '第1剂', 'completedDate': DateTime.now().subtract(const Duration(days: 150)), 'disease': '乙型肝炎', 'category': '国家免疫'},
    {'name': '卡介苗', 'dose': '第1剂', 'completedDate': DateTime.now().subtract(const Duration(days: 148)), 'disease': '结核病', 'category': '国家免疫'},
    {'name': '乙肝疫苗', 'dose': '第2剂', 'completedDate': DateTime.now().subtract(const Duration(days: 120)), 'disease': '乙型肝炎', 'category': '国家免疫'},
    {'name': '脊灰灭活疫苗', 'dose': '第1剂', 'completedDate': DateTime.now().subtract(const Duration(days: 90)), 'disease': '脊髓灰质炎', 'category': '国家免疫'},
    {'name': '脊灰灭活疫苗', 'dose': '第2剂', 'completedDate': DateTime.now().subtract(const Duration(days: 60)), 'disease': '脊髓灰质炎', 'category': '国家免疫'},
    {'name': '百白破疫苗', 'dose': '第1剂', 'completedDate': DateTime.now().subtract(const Duration(days: 60)), 'disease': '百日咳白喉破伤风', 'category': '国家免疫'},
    {'name': '脊灰减毒活疫苗', 'dose': '第3剂', 'completedDate': DateTime.now().subtract(const Duration(days: 30)), 'disease': '脊髓灰质炎', 'category': '国家免疫'},
    {'name': '百白破疫苗', 'dose': '第2剂', 'completedDate': DateTime.now().subtract(const Duration(days: 30)), 'disease': '百日咳白喉破伤风', 'category': '国家免疫'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final total = _upcomingVaccines.length + _completedVaccines.length;
    final nextVaccine = _upcomingVaccines.first;
    final daysUntil = nextVaccine['scheduledDate'].difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(_completedVaccines.length, total, theme),
          SizedBox(height: theme.spacingLg),
          _buildNextVaccineCard(nextVaccine, daysUntil, theme),
          SizedBox(height: theme.spacingLg),
          _buildSegmentControl(theme),
          SizedBox(height: theme.spacingMd),
          if (_selectedSegment == 0)
            _buildUpcomingList(theme)
          else if (_selectedSegment == 1)
            _buildCompletedList(theme)
          else
            Column(
              children: [
                _buildUpcomingList(theme),
                SizedBox(height: theme.spacingLg),
                _buildCompletedList(theme),
              ],
            ),
          SizedBox(height: theme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, AppTheme theme) {
    final progress = completed / total;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.stageAccent, theme.stageAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: theme.stageAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💉', style: TextStyle(fontSize: 28)),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '疫苗接种进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.onAccent,
                      ),
                    ),
                    SizedBox(height: theme.spacingXs),
                    Text(
                      '已接种 $completed / 共 $total 剂',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.onAccent.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.onAccent.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.onAccent),
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% 完成',
            style: TextStyle(
              fontSize: 12,
              color: theme.onAccent.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextVaccineCard(Map<String, dynamic> vaccine, int days, AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingSm,
                  vertical: theme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: theme.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: theme.warning),
                    SizedBox(width: theme.spacingXs),
                    Text(
                      '下一针',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingSm,
                  vertical: theme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: theme.stageAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                ),
                child: Text(
                  vaccine['category'],
                  style: TextStyle(fontSize: 11, color: theme.stageAccentDark),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Text(
            vaccine['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '${vaccine['dose']} · ${vaccine['disease']}',
            style: TextStyle(fontSize: 14, color: theme.textSecondary),
          ),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.textTertiary),
              SizedBox(width: theme.spacingXs),
              Text(
                DateTimeUtils.formatDateCn(vaccine['scheduledDate']),
                style: TextStyle(fontSize: 14, color: theme.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: days <= 7
                      ? theme.danger.withOpacity(0.1)
                      : theme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                child: Text(
                  days <= 0 ? '今天接种' : '还有 $days 天',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: days <= 7 ? theme.danger : theme.info,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentControl(AppTheme theme) {
    final segments = ['待接种', '已接种', '全部'];

    return Container(
      padding: EdgeInsets.all(theme.spacingXs),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegment = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: theme.spacingSm),
                decoration: BoxDecoration(
                  color: isSelected ? theme.paper : Colors.transparent,
                  borderRadius: BorderRadius.circular(theme.radiusSm - 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    segments[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? theme.textPrimary : theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUpcomingList(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
          child: Text(
            '待接种 (${_upcomingVaccines.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: theme.spacingSm),
        ...List.generate(_upcomingVaccines.length, (index) {
          final vaccine = _upcomingVaccines[index];
          final days = vaccine['scheduledDate'].difference(DateTime.now()).inDays;
          return _buildVaccineItem(
            vaccine: vaccine,
            isCompleted: false,
            daysUntil: days,
            theme: theme,
          );
        }),
      ],
    );
  }

  Widget _buildCompletedList(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
          child: Text(
            '已接种 (${_completedVaccines.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: theme.spacingSm),
        ...List.generate(_completedVaccines.length, (index) {
          final vaccine = _completedVaccines[index];
          return _buildVaccineItem(
            vaccine: vaccine,
            isCompleted: true,
            daysUntil: 0,
            theme: theme,
          );
        }),
      ],
    );
  }

  Widget _buildVaccineItem({
    required Map<String, dynamic> vaccine,
    required bool isCompleted,
    required int daysUntil,
    required AppTheme theme,
  }) {
    final date = isCompleted ? vaccine['completedDate'] : vaccine['scheduledDate'];

    return Container(
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: isCompleted ? theme.stageSurface.withOpacity(0.5) : theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(
          color: isCompleted ? theme.stageSurface : theme.stageSurface,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.success.withOpacity(0.15)
                  : theme.info.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isCompleted ? '✅' : '💉',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vaccine['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? theme.textSecondary : theme.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '${vaccine['dose']} · ${vaccine['disease']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? theme.textTertiary : theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateTimeUtils.formatDateCn(date),
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? theme.textTertiary : theme.textSecondary,
                ),
              ),
              if (!isCompleted) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  daysUntil <= 0 ? '今天' : '$daysUntil天后',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: daysUntil <= 7 ? theme.danger : theme.info,
                  ),
                ),
              ],
              if (isCompleted) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  '已完成',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.success,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== 里程碑 Tab ====================

class MilestoneTab extends StatefulWidget {
  const MilestoneTab({super.key});

  @override
  State<MilestoneTab> createState() => _MilestoneTabState();
}

class _MilestoneTabState extends State<MilestoneTab> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': '大运动', 'icon': '🏃', 'index': 0},
    {'name': '语言', 'icon': '🗣️', 'index': 1},
    {'name': '认知', 'icon': '🧠', 'index': 2},
    {'name': '社交', 'icon': '👥', 'index': 3},
    {'name': '喂养', 'icon': '🍼', 'index': 4},
  ];

  final List<Map<String, dynamic>> _allMilestones = [
    {'name': '抬头45°', 'category': 0, 'expectedMonths': 2, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 30)), 'description': '俯卧时能抬头45度，头部能短暂保持稳定'},
    {'name': '抬头90°/俯卧抬胸', 'category': 0, 'expectedMonths': 3, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 15)), 'description': '俯卧时能抬头90度，胸部可离开床面'},
    {'name': '翻身（俯→仰）', 'category': 0, 'expectedMonths': 4, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 5)), 'description': '能从俯卧位翻身为仰卧位'},
    {'name': '独立坐', 'category': 0, 'expectedMonths': 6, 'achieved': false, 'description': '不需要支撑能独立坐立片刻'},
    {'name': '翻身（仰→俯）', 'category': 0, 'expectedMonths': 6, 'achieved': false, 'description': '能从仰卧位翻身为俯卧位'},
    {'name': '独坐稳', 'category': 0, 'expectedMonths': 8, 'achieved': false, 'description': '能独立坐稳，身体前倾时能恢复平衡'},
    {'name': '会爬', 'category': 0, 'expectedMonths': 8, 'achieved': false, 'description': '能用手和膝盖支撑身体爬行'},
    {'name': '会微笑', 'category': 1, 'expectedMonths': 1, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 40)), 'description': '对人或声音能发出微笑'},
    {'name': '发出元音', 'category': 1, 'expectedMonths': 2, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 25)), 'description': '能发出a、o、e等元音'},
    {'name': '笑出声', 'category': 1, 'expectedMonths': 3, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 10)), 'description': '被逗引时能笑出声音'},
    {'name': '咿呀发声', 'category': 1, 'expectedMonths': 3, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 8)), 'description': '能咿咿呀呀发出连续的声音'},
    {'name': '叫名字有反应', 'category': 1, 'expectedMonths': 6, 'achieved': false, 'description': '听到自己名字会转头或有反应'},
    {'name': '发辅音', 'category': 1, 'expectedMonths': 6, 'achieved': false, 'description': '能发出b、m、d等辅音'},
    {'name': '追视红球', 'category': 2, 'expectedMonths': 1, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 42)), 'description': '眼睛能跟随红球左右移动'},
    {'name': '伸手抓物', 'category': 2, 'expectedMonths': 3, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 12)), 'description': '能主动伸手去抓眼前的物品'},
    {'name': '吃手', 'category': 2, 'expectedMonths': 3, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 15)), 'description': '能把手放到嘴里吸吮'},
    {'name': '主动抓物', 'category': 2, 'expectedMonths': 6, 'achieved': false, 'description': '能主动伸手抓住物品并握住'},
    {'name': '眼神对视', 'category': 3, 'expectedMonths': 1, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 38)), 'description': '能与照顾者有眼神对视'},
    {'name': '被逗会笑', 'category': 3, 'expectedMonths': 2, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 28)), 'description': '被人逗引时会露出笑容'},
    {'name': '认生', 'category': 3, 'expectedMonths': 6, 'achieved': false, 'description': '见到陌生人会表现出紧张或哭闹'},
    {'name': '躲猫猫', 'category': 3, 'expectedMonths': 6, 'achieved': false, 'description': '喜欢玩躲猫猫游戏，会寻找被藏起来的脸'},
    {'name': '扶瓶', 'category': 4, 'expectedMonths': 4, 'achieved': true, 'achieveDate': DateTime.now().subtract(const Duration(days: 3)), 'description': '能自己扶着奶瓶喝奶'},
    {'name': '添加辅食', 'category': 4, 'expectedMonths': 6, 'achieved': false, 'description': '开始添加辅食，能接受泥糊状食物'},
    {'name': '会用勺', 'category': 4, 'expectedMonths': 6, 'achieved': false, 'description': '对勺子感兴趣，会抓握勺子'},
  ];

  List<Map<String, dynamic>> get _filteredMilestones {
    return _allMilestones.where((m) => m['category'] == _selectedCategory).toList()
      ..sort((a, b) {
        if (a['achieved'] == b['achieved']) {
          return (a['expectedMonths'] as int).compareTo(b['expectedMonths'] as int);
        }
        return a['achieved'] ? -1 : 1;
      });
  }

  int get _totalAchieved => _allMilestones.where((m) => m['achieved'] == true).length;
  int get _totalCount => _allMilestones.length;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final milestones = _filteredMilestones;
    final achievedInCategory = milestones.where((m) => m['achieved'] == true).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(theme),
          SizedBox(height: theme.spacingLg),
          _buildCategoryTabs(theme),
          SizedBox(height: theme.spacingMd),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
            child: Row(
              children: [
                Text(
                  '${_categories[_selectedCategory]['name']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(width: theme.spacingXs),
                Text(
                  '($achievedInCategory/${milestones.length})',
                  style: TextStyle(fontSize: 14, color: theme.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: theme.spacingSm),
          ...List.generate(milestones.length, (index) {
            return _buildMilestoneItem(milestones[index], theme);
          }),
          SizedBox(height: theme.spacingLg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.medical_services_outlined, size: 20),
              label: const Text('发育检查'),
            ),
          ),
          SizedBox(height: theme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppTheme theme) {
    final progress = _totalAchieved / _totalCount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.milestoneGold.withOpacity(0.9), theme.milestoneGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: theme.milestoneGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 28)),
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '里程碑进度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '已达成 $_totalAchieved / 共 $_totalCount 项',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: theme.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(AppTheme theme) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['index'];
          final achievedInCat = _allMilestones
              .where((m) => m['category'] == category['index'] && m['achieved'] == true)
              .length;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['index'] as int;
              });
            },
            child: Container(
              width: 72,
              padding: EdgeInsets.all(theme.spacingSm),
              decoration: BoxDecoration(
                color: isSelected ? theme.paper : theme.stageSurface,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(
                  color: isSelected ? theme.milestoneGold : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category['icon'], style: const TextStyle(fontSize: 22)),
                  SizedBox(height: theme.spacingXs),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? theme.textPrimary : theme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '$achievedInCat项',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone, AppTheme theme) {
    final achieved = milestone['achieved'] as bool;
    final expectedMonths = milestone['expectedMonths'] as int;

    return Container(
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: achieved ? theme.milestoneGold.withOpacity(0.05) : theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(
          color: achieved
              ? theme.milestoneGold.withOpacity(0.3)
              : theme.stageSurface,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: achieved
                  ? theme.milestoneGold.withOpacity(0.15)
                  : theme.stageSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achieved ? '✅' : '⬜',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  milestone['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: achieved ? theme.textPrimary : theme.textSecondary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  milestone['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: theme.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (achieved) ...[
                Text(
                  '达成',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.milestoneGold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DateTimeUtils.formatDateCn(milestone['achieveDate']),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTertiary,
                  ),
                ),
              ] else ...[
                Text(
                  '${expectedMonths}月龄',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '预期',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
