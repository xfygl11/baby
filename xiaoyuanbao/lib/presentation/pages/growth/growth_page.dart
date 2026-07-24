import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/drift/app_database.dart';
import '../../../data/drift/daos/growth_repository.dart';
import '../../../data/drift/daos/teeth_repository.dart';
import '../../../services/growth/growth_service.dart';
import '../../../services/milestone/milestone_service.dart';
import '../../../services/vaccine/vaccine_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class GrowthPage extends ConsumerStatefulWidget {
  const GrowthPage({super.key});

  @override
  ConsumerState<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends ConsumerState<GrowthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return babyAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.stageBg,
        body: const LoadingWidget(message: '加载中...'),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.stageBg,
        body: Center(
          child: Text(
            '加载失败: $error',
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
      ),
      data: (baby) {
        if (baby == null) {
          return Scaffold(
            backgroundColor: theme.stageBg,
            appBar: AppBar(title: const Text('成长发育')),
            body: const EmptyStateWidget(
              icon: Icons.child_care,
              title: '尚未添加宝宝',
              subtitle: '请先在个人中心添加宝宝信息',
            ),
          );
        }
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
              labelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '📈 生长曲线'),
                Tab(text: '💉 疫苗'),
                Tab(text: '🏆 里程碑'),
                Tab(text: '🦷 牙齿'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              GrowthCurveTab(baby: baby),
              VaccineTab(baby: baby),
              MilestoneTab(baby: baby),
              TeethTab(baby: baby),
            ],
          ),
        );
      },
    );
  }
}

// ==================== 生长曲线 Tab ====================

class GrowthCurveTab extends ConsumerStatefulWidget {
  final Baby baby;

  const GrowthCurveTab({super.key, required this.baby});

  @override
  ConsumerState<GrowthCurveTab> createState() => _GrowthCurveTabState();
}

class _GrowthCurveTabState extends ConsumerState<GrowthCurveTab> {
  GrowthMetric _selectedMetric = GrowthMetric.weight;
  late Future<List<GrowthRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadRecords();
  }

  Future<List<GrowthRecord>> _loadRecords() {
    final growthService = ref.read(growthServiceProvider);
    return growthService.getGrowthRecords(widget.baby.id);
  }

  void _refresh() {
    setState(() {
      _recordsFuture = _loadRecords();
    });
  }

  void _showAddRecordDialog() {
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final headCtrl = TextEditingController();
    final theme = AppTheme.of(context);
    final inputType =
        const TextInputType(numberWithOptions(decimal: true));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记录新数据'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightCtrl,
              keyboardType: inputType,
              decoration: const InputDecoration(
                labelText: '体重 (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: theme.spacingMd),
            TextField(
              controller: heightCtrl,
              keyboardType: inputType,
              decoration: const InputDecoration(
                labelText: '身高 (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: theme.spacingMd),
            TextField(
              controller: headCtrl,
              keyboardType: inputType,
              decoration: const InputDecoration(
                labelText: '头围 (cm)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final w = double.tryParse(weightCtrl.text.trim());
              final h = double.tryParse(heightCtrl.text.trim());
              final hc = double.tryParse(headCtrl.text.trim());
              if (w == null && h == null && hc == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请至少输入一项数据')),
                );
                return;
              }
              final repo = ref.read(growthRepositoryProvider);
              await repo.addGrowth(
                babyId: widget.baby.id,
                weight: w,
                height: h,
                headCircumference: hc,
                recordDate: DateTime.now(),
              );
              if (!mounted) return;
              Navigator.of(ctx).pop();
              _refresh();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FutureBuilder<List<GrowthRecord>>(
      future: _recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '加载生长数据...');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
          );
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.show_chart,
            title: '还没有生长记录',
            subtitle: '点击下方按钮记录宝宝的第一条生长数据',
            actionLabel: '记录新数据',
            onAction: _showAddRecordDialog,
          );
        }

        final latest = records.first;
        final chartRecords = records.reversed.toList();
        final ageResult = DateTimeUtils.calculateAge(
          widget.baby.birthDate,
          now: latest.recordDate,
        );
        final ageMonths = ageResult.years * 12 + ageResult.months;

        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLatestDataCard(latest, theme),
              SizedBox(height: theme.spacingLg),
              _buildMetricSelector(theme),
              SizedBox(height: theme.spacingMd),
              _buildGrowthChart(chartRecords, theme),
              SizedBox(height: theme.spacingLg),
              _buildEvaluationCard(latest, ageMonths, theme),
              SizedBox(height: theme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _showAddRecordDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('记录新数据'),
                ),
              ),
              SizedBox(height: theme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLatestDataCard(GrowthRecord latest, AppTheme theme) {
    final weight = latest.weight;
    final height = latest.height;
    final head = latest.headCircumference;
    final bmi = (weight != null && height != null && height > 0)
        ? weight / ((height / 100) * (height / 100))
        : null;

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
                DateTimeUtils.formatDateCn(latest.recordDate),
                style: TextStyle(fontSize: 13, color: theme.textTertiary),
              ),
            ],
          ),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              _buildMetricItem(
                '📏',
                '身高',
                height != null ? '${height.toStringAsFixed(1)} cm' : '--',
                theme,
              ),
              Container(width: 1, height: 50, color: theme.stageSurface),
              _buildMetricItem(
                '⚖️',
                '体重',
                weight != null ? '${weight.toStringAsFixed(1)} kg' : '--',
                theme,
              ),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            children: [
              _buildMetricItem(
                '🌀',
                '头围',
                head != null ? '${head.toStringAsFixed(1)} cm' : '--',
                theme,
              ),
              Container(width: 1, height: 50, color: theme.stageSurface),
              _buildMetricItem(
                '📊',
                'BMI',
                bmi != null ? bmi.toStringAsFixed(1) : '--',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      String icon, String label, String value, AppTheme theme) {
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
                        color:
                            isSelected ? theme.textPrimary : theme.textSecondary,
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

  Widget _buildGrowthChart(
      List<GrowthRecord> chartRecords, AppTheme theme) {
    final recordsMaps = chartRecords
        .map((r) => <String, dynamic>{
              'date': r.recordDate,
              'weight': r.weight ?? 0.0,
              'height': r.height ?? 0.0,
              'head': r.headCircumference ?? 0.0,
            })
        .toList();

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
            child: recordsMaps.length >= 2
                ? CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: GrowthChartPainter(
                      accentColor: theme.stageAccent,
                      gridColor: theme.stageSurface,
                      textColor: theme.textTertiary,
                      babyColor: theme.success,
                      records: recordsMaps,
                      metric: _selectedMetric,
                    ),
                  )
                : Center(
                    child: Text(
                      '至少需要 2 条记录才能绘制曲线',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTertiary,
                      ),
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

  Color _evalColor(String level, AppTheme theme) {
    switch (level) {
      case 'normal':
      case 'mildLow':
      case 'mildHigh':
        return theme.success;
      case 'moderateLow':
      case 'moderateHigh':
        return theme.warning;
      case 'severeLow':
      case 'severeHigh':
        return theme.danger;
      default:
        return theme.success;
    }
  }

  IconData _evalIcon(String level) {
    switch (level) {
      case 'normal':
      case 'mildLow':
      case 'mildHigh':
        return Icons.favorite;
      case 'severeLow':
      case 'severeHigh':
        return Icons.error_outline;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Widget _buildEvaluationCard(
      GrowthRecord latest, int ageMonths, AppTheme theme) {
    final growthService = ref.read(growthServiceProvider);

    double value;
    switch (_selectedMetric) {
      case GrowthMetric.weight:
        value = latest.weight ?? 0;
        break;
      case GrowthMetric.height:
        value = latest.height ?? 0;
        break;
      case GrowthMetric.headCircumference:
        value = latest.headCircumference ?? 0;
        break;
      case GrowthMetric.bmi:
        final w = latest.weight ?? 0;
        final h = latest.height ?? 0;
        value = (h > 0) ? w / ((h / 100) * (h / 100)) : 0;
        break;
    }

    final evaluation =
        growthService.evaluateGrowth(value, ageMonths, _selectedMetric);
    final color = _evalColor(evaluation.level, theme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_evalIcon(evaluation.level), color: color, size: 24),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${evaluation.description} · P${evaluation.percentile.round()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  evaluation.suggestion,
                  style:
                      TextStyle(fontSize: 13, color: theme.textSecondary),
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
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
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
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height - 2));
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
      final p3Y = size.height -
          20 -
          (standards['p3']! - _minValue) /
              (_maxValue - _minValue) *
              (size.height - 30);
      final p50Y = size.height -
          20 -
          (standards['p50']! - _minValue) /
              (_maxValue - _minValue) *
              (size.height - 30);
      final p97Y = size.height -
          20 -
          (standards['p97']! - _minValue) /
              (_maxValue - _minValue) *
              (size.height - 30);

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
      final y = size.height -
          20 -
          (value - _minValue) / (_maxValue - _minValue) * (size.height - 30);

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
      final y = size.height -
          20 -
          (value - _minValue) / (_maxValue - _minValue) * (size.height - 30);
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
    return oldDelegate.metric != metric ||
        oldDelegate.records != records;
  }
}

// ==================== 疫苗 Tab ====================

class _VaccineTabData {
  final int completedCount;
  final int totalCount;
  final VaccineRecord? nextVaccine;
  final List<VaccineRecord> pending;
  final List<VaccineRecord> completed;

  const _VaccineTabData({
    required this.completedCount,
    required this.totalCount,
    required this.nextVaccine,
    required this.pending,
    required this.completed,
  });
}

class VaccineTab extends ConsumerStatefulWidget {
  final Baby baby;

  const VaccineTab({super.key, required this.baby});

  @override
  ConsumerState<VaccineTab> createState() => _VaccineTabState();
}

class _VaccineTabState extends ConsumerState<VaccineTab> {
  int _selectedSegment = 0;
  late Future<_VaccineTabData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_VaccineTabData> _loadData() async {
    final vaccineService = ref.read(vaccineServiceProvider);
    final vaccineRepo = ref.read(vaccineRepositoryProvider);
    final babyId = widget.baby.id;

    final results = await Future.wait([
      vaccineService.getCompletedCount(babyId),
      vaccineService.getTotalCount(babyId),
      vaccineService.getNextVaccine(babyId),
      vaccineRepo.getPendingVaccines(babyId),
      vaccineService.getCompletedVaccines(babyId),
    ]);

    return _VaccineTabData(
      completedCount: results[0] as int,
      totalCount: results[1] as int,
      nextVaccine: results[2] as VaccineRecord?,
      pending: results[3] as List<VaccineRecord>,
      completed: results[4] as List<VaccineRecord>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FutureBuilder<_VaccineTabData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '加载疫苗数据...');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
          );
        }
        final data = snapshot.data!;
        final total = data.totalCount;

        if (total == 0) {
          return EmptyStateWidget(
            icon: Icons.vaccines_outlined,
            title: '暂无疫苗数据',
            subtitle: '宝宝出生后会自动生成疫苗接种计划',
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(data.completedCount, total, theme),
              SizedBox(height: theme.spacingLg),
              if (data.nextVaccine != null)
                _buildNextVaccineCard(data.nextVaccine!, theme)
              else
                _buildNoNextVaccineCard(theme),
              SizedBox(height: theme.spacingLg),
              _buildSegmentControl(theme),
              SizedBox(height: theme.spacingMd),
              if (_selectedSegment == 0)
                _buildPendingList(data.pending, theme)
              else if (_selectedSegment == 1)
                _buildCompletedList(data.completed, theme)
              else
                Column(
                  children: [
                    _buildPendingList(data.pending, theme),
                    SizedBox(height: theme.spacingLg),
                    _buildCompletedList(data.completed, theme),
                  ],
                ),
              SizedBox(height: theme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(int completed, int total, AppTheme theme) {
    final progress = total > 0 ? completed / total : 0.0;

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

  Widget _buildNextVaccineCard(VaccineRecord vaccine, AppTheme theme) {
    final scheduled = vaccine.scheduledDate;
    final days = scheduled != null
        ? scheduled.difference(DateTime.now()).inDays
        : 0;

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
                  '国家免疫',
                  style:
                      TextStyle(fontSize: 11, color: theme.stageAccentDark),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Text(
            vaccine.vaccineName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '第${vaccine.doseNumber}剂 · ${vaccine.note ?? ''}',
            style: TextStyle(fontSize: 14, color: theme.textSecondary),
          ),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16, color: theme.textTertiary),
              SizedBox(width: theme.spacingXs),
              Text(
                scheduled != null
                    ? DateTimeUtils.formatDateCn(scheduled)
                    : '待定',
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
                  scheduled == null
                      ? '待定'
                      : (days <= 0 ? '今天接种' : '还有 $days 天'),
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

  Widget _buildNoNextVaccineCard(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '暂无待接种疫苗',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '已按时完成当前阶段的疫苗接种',
                  style: TextStyle(fontSize: 13, color: theme.textSecondary),
                ),
              ],
            ),
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
                  borderRadius:
                      BorderRadius.circular(theme.radiusSm - 2),
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
                      color:
                          isSelected ? theme.textPrimary : theme.textSecondary,
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

  Widget _buildPendingList(
      List<VaccineRecord> pending, AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
          child: Text(
            '待接种 (${pending.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: theme.spacingSm),
        if (pending.isEmpty)
          _buildEmptyListHint('暂无待接种疫苗', theme)
        else
          ...List.generate(pending.length, (index) {
            return _buildVaccineItem(
              vaccine: pending[index],
              isCompleted: false,
              theme: theme,
            );
          }),
      ],
    );
  }

  Widget _buildCompletedList(
      List<VaccineRecord> completed, AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
          child: Text(
            '已接种 (${completed.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: theme.spacingSm),
        if (completed.isEmpty)
          _buildEmptyListHint('暂无已接种疫苗', theme)
        else
          ...List.generate(completed.length, (index) {
            return _buildVaccineItem(
              vaccine: completed[index],
              isCompleted: true,
              theme: theme,
            );
          }),
      ],
    );
  }

  Widget _buildEmptyListHint(String text, AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: theme.textTertiary),
      ),
    );
  }

  Widget _buildVaccineItem({
    required VaccineRecord vaccine,
    required bool isCompleted,
    required AppTheme theme,
  }) {
    final date =
        isCompleted ? vaccine.vaccinationDate : vaccine.scheduledDate;
    final daysUntil = (!isCompleted && vaccine.scheduledDate != null)
        ? vaccine.scheduledDate!.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: isCompleted ? theme.stageSurface.withOpacity(0.5) : theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(
          color: theme.stageSurface,
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
                  vaccine.vaccineName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isCompleted ? theme.textSecondary : theme.textPrimary,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '第${vaccine.doseNumber}剂 · ${vaccine.note ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? theme.textTertiary
                        : theme.textSecondary,
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
                date != null ? DateTimeUtils.formatDateCn(date) : '待定',
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted
                      ? theme.textTertiary
                      : theme.textSecondary,
                ),
              ),
              if (!isCompleted) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  daysUntil <= 0 ? '已到期' : '$daysUntil天后',
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

class _MilestoneTabData {
  final Map<int, List<MilestoneRecord>> byCategory;
  final double progress;
  final int ageMonths;

  const _MilestoneTabData({
    required this.byCategory,
    required this.progress,
    required this.ageMonths,
  });
}

class MilestoneTab extends ConsumerStatefulWidget {
  final Baby baby;

  const MilestoneTab({super.key, required this.baby});

  @override
  ConsumerState<MilestoneTab> createState() => _MilestoneTabState();
}

class _MilestoneTabState extends ConsumerState<MilestoneTab> {
  int _selectedCategory = 0;

  static const List<Map<String, dynamic>> _categories = [
    {'name': '大运动', 'icon': '🏃', 'index': 0},
    {'name': '语言', 'icon': '🗣️', 'index': 1},
    {'name': '认知', 'icon': '🧠', 'index': 2},
    {'name': '社交', 'icon': '👥', 'index': 3},
    {'name': '喂养', 'icon': '🍼', 'index': 4},
  ];

  late Future<_MilestoneTabData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_MilestoneTabData> _loadData() async {
    final service = ref.read(milestoneServiceProvider);
    final babyId = widget.baby.id;
    final age = DateTimeUtils.calculateAge(widget.baby.birthDate);
    final ageMonths = age.years * 12 + age.months;

    final results = await Future.wait([
      service.getMilestonesByCategory(babyId, 0),
      service.getMilestonesByCategory(babyId, 1),
      service.getMilestonesByCategory(babyId, 2),
      service.getMilestonesByCategory(babyId, 3),
      service.getMilestonesByCategory(babyId, 4),
      service.getMilestoneProgress(babyId, ageMonths),
    ]);

    return _MilestoneTabData(
      byCategory: {
        0: results[0] as List<MilestoneRecord>,
        1: results[1] as List<MilestoneRecord>,
        2: results[2] as List<MilestoneRecord>,
        3: results[3] as List<MilestoneRecord>,
        4: results[4] as List<MilestoneRecord>,
      },
      progress: results[5] as double,
      ageMonths: ageMonths,
    );
  }

  List<MilestoneRecord> _sortedForCategory(
      Map<int, List<MilestoneRecord>> byCategory, int category) {
    final list = List<MilestoneRecord>.from(byCategory[category] ?? []);
    list.sort((a, b) {
      final aAch = a.achieveDate != null;
      final bAch = b.achieveDate != null;
      if (aAch != bAch) return aAch ? -1 : 1;
      return (a.expectedAgeMonths ?? 0).compareTo(b.expectedAgeMonths ?? 0);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FutureBuilder<_MilestoneTabData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '加载里程碑数据...');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
          );
        }
        final data = snapshot.data!;
        final allMilestones = <MilestoneRecord>[];
        for (int i = 0; i < 5; i++) {
          allMilestones.addAll(data.byCategory[i] ?? []);
        }

        if (allMilestones.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.emoji_events_outlined,
            title: '暂无里程碑数据',
            subtitle: '宝宝出生后会自动生成发育里程碑清单',
          );
        }

        final milestones = _sortedForCategory(
            data.byCategory, _selectedCategory);
        final achievedInCategory =
            milestones.where((m) => m.achieveDate != null).length;

        final ageMonths = data.ageMonths;
        final relevant = allMilestones.where((m) =>
            m.expectedAgeMonths != null &&
            m.expectedAgeMonths! <= ageMonths);
        final achievedRelevant =
            relevant.where((m) => m.achieveDate != null).length;
        final relevantTotal = relevant.length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(
                achievedRelevant,
                relevantTotal,
                data.progress,
                theme,
              ),
              SizedBox(height: theme.spacingLg),
              _buildCategoryTabs(data.byCategory, theme),
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
                      style: TextStyle(
                          fontSize: 14, color: theme.textSecondary),
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
                  icon: const Icon(Icons.medical_services_outlined,
                      size: 20),
                  label: const Text('发育检查'),
                ),
              ),
              SizedBox(height: theme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(
    int achievedRelevant,
    int relevantTotal,
    double progress,
    AppTheme theme,
  ) {
    final progressValue = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.milestoneGold.withOpacity(0.9),
            theme.milestoneGold
          ],
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
                  relevantTotal == 0
                      ? '暂无适龄里程碑'
                      : '已达成 $achievedRelevant / 共 $relevantTotal 项',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: theme.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(
      Map<int, List<MilestoneRecord>> byCategory, AppTheme theme) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final catIndex = category['index'] as int;
          final isSelected = _selectedCategory == catIndex;
          final achievedInCat = (byCategory[catIndex] ?? [])
              .where((m) => m.achieveDate != null)
              .length;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = catIndex;
              });
            },
            child: Container(
              width: 72,
              padding: EdgeInsets.all(theme.spacingSm),
              decoration: BoxDecoration(
                color: isSelected ? theme.paper : theme.stageSurface,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(
                  color:
                      isSelected ? theme.milestoneGold : Colors.transparent,
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
                      color: isSelected
                          ? theme.textPrimary
                          : theme.textSecondary,
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

  Widget _buildMilestoneItem(MilestoneRecord milestone, AppTheme theme) {
    final achieved = milestone.achieveDate != null;
    final expectedMonths = milestone.expectedAgeMonths ?? 0;

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
                  milestone.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        achieved ? theme.textPrimary : theme.textSecondary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  milestone.description ?? '',
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
                  DateTimeUtils.formatDateCn(milestone.achieveDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTertiary,
                  ),
                ),
              ] else ...[
                Text(
                  '$expectedMonths月龄',
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

// ==================== 牙齿 Tab ====================

class TeethTab extends ConsumerStatefulWidget {
  final Baby baby;

  const TeethTab({super.key, required this.baby});

  @override
  ConsumerState<TeethTab> createState() => _TeethTabState();
}

class _TeethTabState extends ConsumerState<TeethTab> {
  late Future<List<TeethRecord>> _teethFuture;
  final List<String> _toothNames = [
    '下中切牙', '下侧切牙', '下尖牙', '下第一乳磨牙', '下第二乳磨牙',
    '上中切牙', '上侧切牙', '上尖牙', '上第一乳磨牙', '上第二乳磨牙',
  ];

  @override
  void initState() {
    super.initState();
    _teethFuture = _loadTeeth();
  }

  Future<List<TeethRecord>> _loadTeeth() {
    final repo = ref.read(teethRepositoryProvider);
    return repo.getAllTeeth(widget.baby.id);
  }

  void _refresh() {
    setState(() {
      _teethFuture = _loadTeeth();
    });
  }

  void _showAddToothDialog() {
    int? selectedTooth;
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记录出牙'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择牙齿:', style: TextStyle(fontSize: 14, color: theme.textSecondary)),
            SizedBox(height: theme.spacingSm),
            Wrap(
              spacing: theme.spacingSm,
              runSpacing: theme.spacingSm,
              children: List.generate(20, (index) {
                final isSelected = selectedTooth == index;
                final name = _toothNames[index ~/ 2];
                final side = index % 2 == 0 ? '左' : '右';
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedTooth = index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: theme.spacingSm),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.stageAccent : theme.stageSurface,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(color: isSelected ? theme.stageAccent : theme.textTertiary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$side$name',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? theme.onAccent : theme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (selectedTooth == null) return;
              final repo = ref.read(teethRepositoryProvider);
              await repo.addTeeth(
                babyId: widget.baby.id,
                toothNumber: selectedTooth!,
                eruptionDate: DateTime.now(),
              );
              Navigator.of(ctx).pop();
              _refresh();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FutureBuilder<List<TeethRecord>>(
      future: _teethFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '加载牙齿数据...');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
          );
        }
        final teeth = snapshot.data ?? [];
        final eruptedCount = teeth.where((t) => t.eruptionDate != null).length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            children: [
              _buildProgressCard(eruptedCount, theme),
              SizedBox(height: theme.spacingLg),
              _buildTeethChart(teeth, theme),
              SizedBox(height: theme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _showAddToothDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('记录新出牙'),
                ),
              ),
              SizedBox(height: theme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(int eruptedCount, AppTheme theme) {
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
              const Text('🦷', style: TextStyle(fontSize: 28)),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '出牙进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.onAccent,
                      ),
                    ),
                    SizedBox(height: theme.spacingXs),
                    Text(
                      '已长出 $eruptedCount / 共 20 颗乳牙',
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
              value: eruptedCount / 20,
              minHeight: 8,
              backgroundColor: theme.onAccent.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.onAccent),
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '${(eruptedCount / 20 * 100).toStringAsFixed(0)}% 完成',
            style: TextStyle(
              fontSize: 12,
              color: theme.onAccent.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeethChart(List<TeethRecord> teeth, AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '乳牙示意图',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: theme.spacingLg),
          _buildUpperJaw(teeth, theme),
          SizedBox(height: theme.spacingLg),
          _buildLowerJaw(teeth, theme),
        ],
      ),
    );
  }

  Widget _buildUpperJaw(List<TeethRecord> teeth, AppTheme theme) {
    return Column(
      children: [
        Text('上颌', style: TextStyle(fontSize: 12, color: theme.textTertiary)),
        SizedBox(height: theme.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTooth(teeth, 9, theme),
            _buildTooth(teeth, 8, theme),
            _buildTooth(teeth, 7, theme),
            _buildTooth(teeth, 6, theme),
            _buildTooth(teeth, 5, theme),
            _buildTooth(teeth, 4, theme),
            _buildTooth(teeth, 3, theme),
            _buildTooth(teeth, 2, theme),
            _buildTooth(teeth, 1, theme),
            _buildTooth(teeth, 0, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildLowerJaw(List<TeethRecord> teeth, AppTheme theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTooth(teeth, 10, theme),
            _buildTooth(teeth, 11, theme),
            _buildTooth(teeth, 12, theme),
            _buildTooth(teeth, 13, theme),
            _buildTooth(teeth, 14, theme),
            _buildTooth(teeth, 15, theme),
            _buildTooth(teeth, 16, theme),
            _buildTooth(teeth, 17, theme),
            _buildTooth(teeth, 18, theme),
            _buildTooth(teeth, 19, theme),
          ],
        ),
        SizedBox(height: theme.spacingSm),
        Text('下颌', style: TextStyle(fontSize: 12, color: theme.textTertiary)),
      ],
    );
  }

  Widget _buildTooth(List<TeethRecord> teeth, int toothNumber, AppTheme theme) {
    final tooth = teeth.firstWhere((t) => t.toothNumber == toothNumber, orElse: () => TeethRecord(
      id: '',
      babyId: '',
      toothNumber: toothNumber,
      eruptionDate: null,
      note: null,
    ));
    final erupted = tooth.eruptionDate != null;

    return Container(
      width: 32,
      height: 36,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: erupted ? theme.success.withOpacity(0.2) : theme.stageSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
        border: Border.all(
          color: erupted ? theme.success : theme.textTertiary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            erupted ? '◆' : '◇',
            style: TextStyle(
              fontSize: 14,
              color: erupted ? theme.success : theme.textTertiary.withOpacity(0.3),
            ),
          ),
          SizedBox(height: 2),
          Text(
            '${toothNumber + 1}',
            style: TextStyle(
              fontSize: 9,
              color: erupted ? theme.textSecondary : theme.textTertiary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
