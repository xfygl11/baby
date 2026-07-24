import '../../data/drift/app_database.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/tables/growth_records.dart';

enum GrowthMetric { weight, height, headCircumference, bmi }

class GrowthDataPoint {
  final double ageMonths;
  final double p3;
  final double p10;
  final double p25;
  final double p50;
  final double p75;
  final double p90;
  final double p97;

  GrowthDataPoint({
    required this.ageMonths,
    required this.p3,
    required this.p10,
    required this.p25,
    required this.p50,
    required this.p75,
    required this.p90,
    required this.p97,
  });
}

class GrowthEvaluation {
  final double percentile;
  final String level;
  final String description;
  final String suggestion;

  GrowthEvaluation({
    required this.percentile,
    required this.level,
    required this.description,
    required this.suggestion,
  });
}

class GrowthService {
  final AppDatabase _db;
  late final GrowthRepository _growthRepository;

  GrowthService(this._db) {
    _growthRepository = GrowthRepository(_db);
  }

  static const List<GrowthDataPoint> _weightStandards = [
    GrowthDataPoint(ageMonths: 0, p3: 2.4, p10: 2.6, p25: 2.9, p50: 3.2, p75: 3.5, p90: 3.9, p97: 4.2),
    GrowthDataPoint(ageMonths: 1, p3: 3.2, p10: 3.4, p25: 3.7, p50: 4.2, p75: 4.5, p90: 4.9, p97: 5.3),
    GrowthDataPoint(ageMonths: 2, p3: 3.9, p10: 4.0, p25: 4.5, p50: 5.1, p75: 5.6, p90: 6.1, p97: 6.5),
    GrowthDataPoint(ageMonths: 3, p3: 4.5, p10: 4.8, p25: 5.3, p50: 5.8, p75: 6.4, p90: 6.9, p97: 7.5),
    GrowthDataPoint(ageMonths: 6, p3: 6.0, p10: 6.3, p25: 6.9, p50: 7.5, p75: 8.2, p90: 8.8, p97: 9.5),
    GrowthDataPoint(ageMonths: 9, p3: 6.9, p10: 7.3, p25: 8.0, p50: 8.8, p75: 9.5, p90: 10.3, p97: 11.0),
    GrowthDataPoint(ageMonths: 12, p3: 7.4, p10: 7.9, p25: 8.6, p50: 9.5, p75: 10.3, p90: 11.1, p97: 11.8),
    GrowthDataPoint(ageMonths: 18, p3: 8.4, p10: 8.9, p25: 9.7, p50: 10.7, p75: 11.7, p90: 12.6, p97: 13.4),
    GrowthDataPoint(ageMonths: 24, p3: 9.2, p10: 9.8, p25: 10.7, p50: 11.8, p75: 12.9, p90: 14.0, p97: 15.0),
  ];

  static const List<GrowthDataPoint> _heightStandards = [
    GrowthDataPoint(ageMonths: 0, p3: 45.4, p10: 46.6, p25: 47.8, p50: 49.1, p75: 50.4, p90: 51.6, p97: 52.8),
    GrowthDataPoint(ageMonths: 1, p3: 49.8, p10: 50.8, p25: 51.9, p50: 53.0, p75: 54.2, p90: 55.3, p97: 56.4),
    GrowthDataPoint(ageMonths: 2, p3: 53.2, p10: 54.3, p25: 55.4, p50: 56.7, p75: 57.9, p90: 59.1, p97: 60.3),
    GrowthDataPoint(ageMonths: 3, p3: 55.7, p10: 56.9, p25: 58.1, p50: 59.5, p75: 60.8, p90: 62.1, p97: 63.4),
    GrowthDataPoint(ageMonths: 6, p3: 61.4, p10: 62.7, p25: 64.2, p50: 65.7, p75: 67.3, p90: 68.7, p97: 70.0),
    GrowthDataPoint(ageMonths: 9, p3: 65.5, p10: 67.0, p25: 68.5, p50: 70.1, p75: 71.8, p90: 73.2, p97: 74.7),
    GrowthDataPoint(ageMonths: 12, p3: 69.0, p10: 70.5, p25: 72.1, p50: 74.0, p75: 75.9, p90: 77.6, p97: 79.3),
    GrowthDataPoint(ageMonths: 18, p3: 74.3, p10: 76.0, p25: 77.9, p50: 80.0, p75: 82.1, p90: 84.0, p97: 85.9),
    GrowthDataPoint(ageMonths: 24, p3: 77.7, p10: 79.6, p25: 81.7, p50: 84.0, p75: 86.2, p90: 88.2, p97: 90.3),
  ];

  static const List<GrowthDataPoint> _headCircumferenceStandards = [
    GrowthDataPoint(ageMonths: 0, p3: 31.7, p10: 32.4, p25: 33.1, p50: 33.9, p75: 34.7, p90: 35.4, p97: 36.1),
    GrowthDataPoint(ageMonths: 1, p3: 34.8, p10: 35.5, p25: 36.2, p50: 36.9, p75: 37.7, p90: 38.4, p97: 39.1),
    GrowthDataPoint(ageMonths: 3, p3: 37.6, p10: 38.3, p25: 39.0, p50: 39.8, p75: 40.6, p90: 41.3, p97: 42.1),
    GrowthDataPoint(ageMonths: 6, p3: 39.9, p10: 40.7, p25: 41.5, p50: 42.4, p75: 43.3, p90: 44.1, p97: 44.9),
    GrowthDataPoint(ageMonths: 12, p3: 41.7, p10: 42.6, p25: 43.5, p50: 44.5, p75: 45.4, p90: 46.3, p97: 47.2),
    GrowthDataPoint(ageMonths: 18, p3: 42.8, p10: 43.7, p25: 44.7, p50: 45.7, p75: 46.7, p90: 47.6, p97: 48.5),
    GrowthDataPoint(ageMonths: 24, p3: 43.6, p10: 44.5, p25: 45.5, p50: 46.6, p75: 47.6, p90: 48.6, p97: 49.5),
  ];

  List<GrowthDataPoint> _getStandards(GrowthMetric metric) {
    switch (metric) {
      case GrowthMetric.weight:
        return _weightStandards;
      case GrowthMetric.height:
        return _heightStandards;
      case GrowthMetric.headCircumference:
        return _headCircumferenceStandards;
      case GrowthMetric.bmi:
        return _weightStandards;
    }
  }

  double _interpolate(double x, double x1, double y1, double x2, double y2) {
    if (x1 == x2) return y1;
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  GrowthDataPoint _getInterpolatedPoint(int ageMonths, GrowthMetric metric) {
    final standards = _getStandards(metric);
    final age = ageMonths.toDouble();

    if (age <= standards.first.ageMonths) {
      return standards.first;
    }
    if (age >= standards.last.ageMonths) {
      return standards.last;
    }

    for (int i = 0; i < standards.length - 1; i++) {
      final curr = standards[i];
      final next = standards[i + 1];
      if (age >= curr.ageMonths && age <= next.ageMonths) {
        final p3 = _interpolate(age, curr.ageMonths, curr.p3, next.ageMonths, next.p3);
        final p10 = _interpolate(age, curr.ageMonths, curr.p10, next.ageMonths, next.p10);
        final p25 = _interpolate(age, curr.ageMonths, curr.p25, next.ageMonths, next.p25);
        final p50 = _interpolate(age, curr.ageMonths, curr.p50, next.ageMonths, next.p50);
        final p75 = _interpolate(age, curr.ageMonths, curr.p75, next.ageMonths, next.p75);
        final p90 = _interpolate(age, curr.ageMonths, curr.p90, next.ageMonths, next.p90);
        final p97 = _interpolate(age, curr.ageMonths, curr.p97, next.ageMonths, next.p97);
        return GrowthDataPoint(
          ageMonths: age,
          p3: p3,
          p10: p10,
          p25: p25,
          p50: p50,
          p75: p75,
          p90: p90,
          p97: p97,
        );
      }
    }

    return standards.last;
  }

  double calculatePercentile(double value, int ageMonths, GrowthMetric metric) {
    final point = _getInterpolatedPoint(ageMonths, metric);

    final percentiles = [
      (3.0, point.p3),
      (10.0, point.p10),
      (25.0, point.p25),
      (50.0, point.p50),
      (75.0, point.p75),
      (90.0, point.p90),
      (97.0, point.p97),
    ];

    if (value <= point.p3) {
      if (value <= 0) return 0.0;
      final ratio = value / point.p3;
      return (3.0 * ratio).clamp(0.0, 3.0);
    }

    if (value >= point.p97) {
      final diff = value - point.p97;
      final range = point.p97 - point.p90;
      if (range <= 0) return 97.0;
      final extraPercent = (diff / range) * 7.0;
      return (97.0 + extraPercent).clamp(97.0, 100.0);
    }

    for (int i = 0; i < percentiles.length - 1; i++) {
      final p1 = percentiles[i];
      final p2 = percentiles[i + 1];
      if (value >= p1.$2 && value <= p2.$2) {
        return _interpolate(value, p1.$2, p1.$1, p2.$2, p2.$1);
      }
    }

    return 50.0;
  }

  GrowthEvaluation evaluateGrowth(double value, int ageMonths, GrowthMetric metric) {
    final percentile = calculatePercentile(value, ageMonths, metric);
    String level;
    String description;
    String suggestion;

    final metricName = _getMetricName(metric);

    if (percentile < 3) {
      level = 'severeLow';
      description = '$metricName严重偏低';
      suggestion = '建议及时咨询儿科医生，检查是否存在营养不良或其他健康问题，确保宝宝获得充足的营养。';
    } else if (percentile < 10) {
      level = 'moderateLow';
      description = '$metricName偏低';
      suggestion = '建议关注宝宝的营养摄入，定期监测生长情况，如有疑虑可咨询医生。';
    } else if (percentile < 25) {
      level = 'mildLow';
      description = '$metricName略低';
      suggestion = '宝宝生长在正常范围内偏低水平，保持均衡营养，定期监测即可。';
    } else if (percentile <= 75) {
      level = 'normal';
      description = '$metricName正常';
      suggestion = '宝宝生长发育良好，继续保持良好的喂养和生活习惯。';
    } else if (percentile <= 90) {
      level = 'mildHigh';
      description = '$metricName略高';
      suggestion = '宝宝生长在正常范围内偏高水平，保持均衡营养，适当活动。';
    } else if (percentile <= 97) {
      level = 'moderateHigh';
      description = '$metricName偏高';
      suggestion = '建议关注宝宝的营养均衡，避免过度喂养，适当增加活动量。';
    } else {
      level = 'severeHigh';
      description = '$metricName严重偏高';
      suggestion = '建议咨询儿科医生，评估是否存在过度喂养或其他健康问题。';
    }

    return GrowthEvaluation(
      percentile: percentile,
      level: level,
      description: description,
      suggestion: suggestion,
    );
  }

  String _getMetricName(GrowthMetric metric) {
    switch (metric) {
      case GrowthMetric.weight:
        return '体重';
      case GrowthMetric.height:
        return '身高';
      case GrowthMetric.headCircumference:
        return '头围';
      case GrowthMetric.bmi:
        return 'BMI';
    }
  }

  List<GrowthDataPoint> getStandardCurve(int ageMonths, GrowthMetric metric) {
    final standards = _getStandards(metric);
    final result = <GrowthDataPoint>[];

    for (int i = 0; i <= ageMonths; i++) {
      result.add(_getInterpolatedPoint(i, metric));
    }

    return result;
  }

  Future<List<GrowthRecord>> getGrowthRecords(String babyId) async {
    return _growthRepository.getGrowthRecords(babyId);
  }

  Future<double?> calculatePredictedAdultHeight(
    String babyId, {
    double? fatherHeight,
    double? motherHeight,
  }) async {
    if (fatherHeight == null || motherHeight == null) {
      final records = await _growthRepository.getGrowthRecords(babyId);
      if (records.isEmpty) return null;
      final latest = records.first;
      if (latest.height == null) return null;
      return latest.height! * 1.5;
    }

    final targetHeight = (fatherHeight + motherHeight - 13) / 2;
    return targetHeight;
  }

  String getGrowthStatusText(double percentile) {
    if (percentile < 3) {
      return '严重偏低';
    } else if (percentile < 10) {
      return '偏低';
    } else if (percentile < 25) {
      return '略低';
    } else if (percentile <= 75) {
      return '正常';
    } else if (percentile <= 90) {
      return '略高';
    } else if (percentile <= 97) {
      return '偏高';
    } else {
      return '严重偏高';
    }
  }
}
