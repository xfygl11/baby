import '../../core/constants/app_enums.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/emotion_repository.dart';
import '../../core/utils/date_time_utils.dart';

class InsightCard {
  final String id;
  final InsightType type;
  final String title;
  final String content;
  final String? icon;
  final String? actionLabel;
  final Map<String, dynamic>? data;

  InsightCard({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.icon,
    this.actionLabel,
    this.data,
  });
}

enum InsightType {
  sleepPattern,
  feedingPattern,
  growthTrend,
  milestoneProgress,
  emotionTrend,
  anomalyAlert,
  tip,
  celebration,
}

class PatternAnalyzer {
  final SleepRepository sleepRepository;
  final FeedingRepository feedingRepository;
  final GrowthRepository growthRepository;
  final BabyRepository babyRepository;

  PatternAnalyzer({
    required this.sleepRepository,
    required this.feedingRepository,
    required this.growthRepository,
    required this.babyRepository,
  });

  Future<Map<String, dynamic>> analyzeSleepPattern(String babyId, int days) async {
    final result = <String, dynamic>{};
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final sleeps = await sleepRepository.getSleepsByDateRange(babyId, startDate, endDate);
    if (sleeps.isEmpty) return result;

    int totalDuration = 0;
    int totalCount = 0;
    int nightWakeCount = 0;
    int longestSleep = 0;
    int shortestSleep = 99999;

    for (final sleep in sleeps) {
      if (sleep.endTime != null) {
        final duration = sleep.endTime!.difference(sleep.startTime).inMinutes;
        totalDuration += duration;
        totalCount++;
        longestSleep = longestSleep < duration ? duration : longestSleep;
        shortestSleep = shortestSleep > duration ? duration : shortestSleep;

        final hour = sleep.startTime.hour;
        if (hour >= 22 || hour < 6) {
          nightWakeCount++;
        }
      }
    }

    if (totalCount > 0) {
      final avgDuration = totalDuration ~/ totalCount;
      result['avgDailyDuration'] = (totalDuration / days).toDouble();
      result['avgNapDuration'] = avgDuration;
      result['totalCount'] = totalCount;
      result['nightWakeCount'] = nightWakeCount;
      result['longestSleep'] = longestSleep;
      result['shortestSleep'] = shortestSleep;
      result['hasData'] = true;
    }

    return result;
  }

  Future<Map<String, dynamic>> analyzeFeedingPattern(String babyId, int days) async {
    final result = <String, dynamic>{};
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final feedings = await feedingRepository.getFeedingsByDateRange(babyId, startDate, endDate);
    if (feedings.isEmpty) return result;

    int totalCount = 0;
    double totalAmount = 0;
    double minInterval = 99999;
    double maxInterval = 0;

    feedings.sort((a, b) => a.startTime.compareTo(b.startTime));

    for (int i = 0; i < feedings.length; i++) {
      totalCount++;
      if (feedings[i].amountMl != null) {
        totalAmount += feedings[i].amountMl!;
      }

      if (i > 0) {
        final interval = feedings[i].startTime.difference(feedings[i - 1].startTime).inMinutes / 60;
        minInterval = minInterval > interval ? interval : minInterval;
        maxInterval = maxInterval < interval ? interval : maxInterval;
      }
    }

    if (totalCount > 0) {
      result['avgDailyCount'] = (totalCount / days).toDouble();
      result['avgDailyAmount'] = (totalAmount / days).toDouble();
      result['avgAmount'] = totalAmount / totalCount;
      result['avgInterval'] = minInterval + maxInterval / 2;
      result['minInterval'] = minInterval;
      result['maxInterval'] = maxInterval;
      result['hasData'] = true;
    }

    return result;
  }

  Future<Map<String, dynamic>> analyzeGrowthTrend(String babyId, int days) async {
    final result = <String, dynamic>{};
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final growthRecords = await growthRepository.getGrowthByDateRange(babyId, startDate, endDate);
    if (growthRecords.length < 2) return result;

    growthRecords.sort((a, b) => a.recordDate.compareTo(b.recordDate));

    final first = growthRecords.first;
    final last = growthRecords.last;

    if (first.weight != null && last.weight != null) {
      final weightChange = last.weight! - first.weight!;
      final daysBetween = last.recordDate.difference(first.recordDate).inDays;
      result['weightChange'] = weightChange;
      result['weightChangePerWeek'] = daysBetween > 0 ? (weightChange / daysBetween) * 7 : 0;
    }

    if (first.height != null && last.height != null) {
      final heightChange = last.height! - first.height!;
      result['heightChange'] = heightChange;
    }

    result['hasData'] = true;
    return result;
  }
}

class AnomalyDetector {
  final SleepRepository sleepRepository;
  final FeedingRepository feedingRepository;
  final GrowthRepository growthRepository;
  final TemperatureRepository temperatureRepository;
  final EmotionRepository emotionRepository;
  final BabyRepository babyRepository;

  AnomalyDetector({
    required this.sleepRepository,
    required this.feedingRepository,
    required this.growthRepository,
    required this.temperatureRepository,
    required this.emotionRepository,
    required this.babyRepository,
  });

  Future<List<InsightCard>> detectAnomalies(String babyId) async {
    final anomalies = <InsightCard>[];

    final sleepAnomaly = await _detectSleepAnomaly(babyId);
    if (sleepAnomaly != null) anomalies.add(sleepAnomaly);

    final feedingAnomaly = await _detectFeedingAnomaly(babyId);
    if (feedingAnomaly != null) anomalies.add(feedingAnomaly);

    final growthAnomaly = await _detectGrowthAnomaly(babyId);
    if (growthAnomaly != null) anomalies.add(growthAnomaly);

    final temperatureAnomaly = await _detectTemperatureAnomaly(babyId);
    if (temperatureAnomaly != null) anomalies.add(temperatureAnomaly);

    final emotionAnomaly = await _detectEmotionAnomaly(babyId);
    if (emotionAnomaly != null) anomalies.add(emotionAnomaly);

    return anomalies;
  }

  Future<InsightCard?> _detectSleepAnomaly(String babyId) async {
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final expectedMinSleepHours = _getExpectedMinSleepHours(ageMonths);

    final sleepPattern = await PatternAnalyzer(
      sleepRepository: sleepRepository,
      feedingRepository: feedingRepository,
      growthRepository: growthRepository,
      babyRepository: babyRepository,
    ).analyzeSleepPattern(babyId, 3);

    if (!sleepPattern['hasData'] as bool) return null;

    final avgDuration = sleepPattern['avgDailyDuration'] as double;
    final avgHours = avgDuration / 60;

    if (avgHours < expectedMinSleepHours - 2) {
      return InsightCard(
        id: 'sleep_anomaly_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.anomalyAlert,
        title: '睡眠不足预警',
        content: '最近3天宝宝平均每天睡${avgHours.toStringAsFixed(1)}小时，低于${expectedMinSleepHours}小时的预期。注意观察是否有不适。',
        icon: '😴',
        actionLabel: '查看详情',
        data: {'avgSleepHours': avgHours, 'expectedMin': expectedMinSleepHours},
      );
    }

    return null;
  }

  Future<InsightCard?> _detectFeedingAnomaly(String babyId) async {
    final feedingPattern = await PatternAnalyzer(
      sleepRepository: sleepRepository,
      feedingRepository: feedingRepository,
      growthRepository: growthRepository,
      babyRepository: babyRepository,
    ).analyzeFeedingPattern(babyId, 3);

    if (!feedingPattern['hasData'] as bool) return null;

    final avgInterval = feedingPattern['avgInterval'] as double;

    if (avgInterval > 5) {
      return InsightCard(
        id: 'feeding_anomaly_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.anomalyAlert,
        title: '喂养间隔过长',
        content: '最近3天平均喂养间隔${avgInterval.toStringAsFixed(1)}小时，超过5小时。如果宝宝月龄较小，建议适当缩短间隔。',
        icon: '🍼',
        actionLabel: '记录喂养',
        data: {'avgInterval': avgInterval},
      );
    }

    return null;
  }

  Future<InsightCard?> _detectGrowthAnomaly(String babyId) async {
    final growthPattern = await PatternAnalyzer(
      sleepRepository: sleepRepository,
      feedingRepository: feedingRepository,
      growthRepository: growthRepository,
      babyRepository: babyRepository,
    ).analyzeGrowthTrend(babyId, 30);

    if (!growthPattern['hasData'] as bool) return null;

    final weightChange = growthPattern['weightChange'] as double?;
    if (weightChange != null && weightChange < 0.1) {
      return InsightCard(
        id: 'growth_anomaly_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.anomalyAlert,
        title: '体重增长缓慢',
        content: '最近一个月体重增长${weightChange.toStringAsFixed(2)}kg，低于正常增长范围。建议关注喂养情况。',
        icon: '📏',
        actionLabel: '记录生长',
        data: {'weightChange': weightChange},
      );
    }

    return null;
  }

  Future<InsightCard?> _detectTemperatureAnomaly(String babyId) async {
    final latestTemp = await temperatureRepository.getLatestTemperature(babyId);
    if (latestTemp == null) return null;

    if (latestTemp.temperature >= 38.5) {
      return InsightCard(
        id: 'temp_anomaly_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.anomalyAlert,
        title: '高烧预警',
        content: '宝宝体温${latestTemp.temperature.toStringAsFixed(1)}°C，建议及时就医或服用退烧药。',
        icon: '🌡️',
        actionLabel: '记录用药',
        data: {'temperature': latestTemp.temperature},
      );
    }

    return null;
  }

  Future<InsightCard?> _detectEmotionAnomaly(String babyId) async {
    final emotions = await emotionRepository.getEmotionsByDateRange(
      babyId,
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now(),
    );

    if (emotions.isEmpty) return null;

    final negativeEmotions = emotions.where((e) {
      final negativeTypes = [1, 2, 3];
      return negativeTypes.contains(e.emotionType);
    }).length;

    if (negativeEmotions >= emotions.length * 0.6) {
      return InsightCard(
        id: 'emotion_anomaly_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.anomalyAlert,
        title: '情绪不稳定',
        content: '最近3天宝宝负面情绪较多，建议多关注宝宝的情绪变化，多给予陪伴和安抚。',
        icon: '😊',
        actionLabel: '记录情绪',
        data: {'negativeCount': negativeEmotions, 'totalCount': emotions.length},
      );
    }

    return null;
  }

  int _calculateAgeMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months;
  }

  double _getExpectedMinSleepHours(int ageMonths) {
    if (ageMonths < 3) return 14;
    if (ageMonths < 6) return 13;
    if (ageMonths < 12) return 12;
    if (ageMonths < 18) return 11.5;
    if (ageMonths < 24) return 11;
    return 10;
  }
}

class SuggestionService {
  final PatternAnalyzer patternAnalyzer;
  final AnomalyDetector anomalyDetector;
  final MilestoneRepository milestoneRepository;
  final DiaryRepository diaryRepository;
  final BabyRepository babyRepository;

  SuggestionService({
    required this.patternAnalyzer,
    required this.anomalyDetector,
    required this.milestoneRepository,
    required this.diaryRepository,
    required this.babyRepository,
  });

  Future<List<InsightCard>> getDailyInsights(String babyId) async {
    final insights = <InsightCard>[];

    final anomalies = await anomalyDetector.detectAnomalies(babyId);
    insights.addAll(anomalies);

    final patternInsights = await _generatePatternInsights(babyId);
    insights.addAll(patternInsights);

    final milestoneInsights = await _generateMilestoneInsights(babyId);
    insights.addAll(milestoneInsights);

    final celebrationInsights = await _generateCelebrationInsights(babyId);
    insights.addAll(celebrationInsights);

    final tipInsights = await _generateTipInsights(babyId);
    insights.addAll(tipInsights);

    insights.sort((a, b) => _getInsightPriority(a.type).compareTo(_getInsightPriority(b.type)));

    return insights.take(5).toList();
  }

  Future<List<InsightCard>> _generatePatternInsights(String babyId) async {
    final insights = <InsightCard>[];

    final sleepPattern = await patternAnalyzer.analyzeSleepPattern(babyId, 7);
    if (sleepPattern['hasData'] as bool) {
      final avgHours = (sleepPattern['avgDailyDuration'] as double) / 60;
      final nightWakes = sleepPattern['nightWakeCount'] as int;

      if (avgHours >= 12 && nightWakes <= 1) {
        insights.add(InsightCard(
          id: 'sleep_good_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.sleepPattern,
          title: '睡眠棒棒的！',
          content: '本周宝宝平均每天睡${avgHours.toStringAsFixed(1)}小时，夜醒只有${nightWakes}次，睡眠质量很好哦～',
          icon: '💤',
          data: {'avgHours': avgHours, 'nightWakes': nightWakes},
        ));
      }
    }

    final feedingPattern = await patternAnalyzer.analyzeFeedingPattern(babyId, 7);
    if (feedingPattern['hasData'] as bool) {
      final avgAmount = feedingPattern['avgAmount'] as double;
      final avgInterval = feedingPattern['avgInterval'] as double;

      if (avgAmount > 100 && avgInterval > 2) {
        insights.add(InsightCard(
          id: 'feeding_good_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.feedingPattern,
          title: '喂养规律',
          content: '本周平均每次喝奶${avgAmount.toStringAsFixed(0)}ml，间隔${avgInterval.toStringAsFixed(1)}小时，规律很棒！',
          icon: '🍼',
          data: {'avgAmount': avgAmount, 'avgInterval': avgInterval},
        ));
      }
    }

    return insights;
  }

  Future<List<InsightCard>> _generateMilestoneInsights(String babyId) async {
    final insights = <InsightCard>[];
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return insights;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final milestones = await milestoneRepository.getMilestonesByBabyId(babyId);

    final pendingMilestones = milestones.where(
      (m) => m.expectedAgeMonths != null && m.expectedAgeMonths! <= ageMonths && m.achieveDate == null,
    ).toList();

    if (pendingMilestones.isNotEmpty && pendingMilestones.length <= 3) {
      insights.add(InsightCard(
        id: 'milestone_pending_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.milestoneProgress,
        title: '发育检查',
        content: '宝宝${ageMonths}个月了，还有${pendingMilestones.length}项发育里程碑待确认：${pendingMilestones.map((m) => m.name).join('、')}',
        icon: '🏆',
        actionLabel: '去检查',
        data: {'ageMonths': ageMonths, 'pendingCount': pendingMilestones.length},
      ));
    }

    final recentAchieved = milestones.where(
      (m) => m.achieveDate != null && DateTime.now().difference(m.achieveDate!).inDays <= 7,
    ).toList();

    if (recentAchieved.isNotEmpty) {
      insights.add(InsightCard(
        id: 'milestone_achieved_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.celebration,
        title: '恭喜！达成新里程碑',
        content: '本周宝宝达成了${recentAchieved.length}个里程碑：${recentAchieved.map((m) => m.name).join('、')}，太棒了！',
        icon: '🎉',
        actionLabel: '查看详情',
        data: {'milestones': recentAchieved.map((m) => m.name).toList()},
      ));
    }

    return insights;
  }

  Future<List<InsightCard>> _generateCelebrationInsights(String babyId) async {
    final insights = <InsightCard>[];
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return insights;

    final age = DateTimeUtils.calculateAge(baby.birthDate);

    if (age.days == 100) {
      insights.add(InsightCard(
        id: 'celebration_100days_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.celebration,
        title: '百天快乐！',
        content: '宝宝今天满100天啦！时间过得真快，这100天里宝宝学会了好多新本领～',
        icon: '💯',
        actionLabel: '写篇日记',
        data: {'age': '100天'},
      ));
    }

    if (age.months == 6) {
      insights.add(InsightCard(
        id: 'celebration_halfyear_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.celebration,
        title: '半岁啦！',
        content: '宝宝今天满6个月了，可以开始尝试辅食了哦～',
        icon: '🎂',
        actionLabel: '记录成长',
        data: {'age': '6个月'},
      ));
    }

    return insights;
  }

  Future<List<InsightCard>> _generateTipInsights(String babyId) async {
    final insights = <InsightCard>[];
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return insights;

    final ageMonths = _calculateAgeMonths(baby.birthDate);

    if (ageMonths == 3) {
      insights.add(InsightCard(
        id: 'tip_3months_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.tip,
        title: '育儿小贴士',
        content: '3个月的宝宝开始喜欢看彩色玩具了，可以在小床上方悬挂一些颜色鲜艳的摇铃，帮助锻炼追视能力。',
        icon: '💡',
      ));
    }

    if (ageMonths == 6) {
      insights.add(InsightCard(
        id: 'tip_6months_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.tip,
        title: '辅食添加指南',
        content: '6个月是添加辅食的最佳时机！建议从高铁米粉开始，由稀到稠、由少到多逐步尝试。',
        icon: '🥣',
      ));
    }

    if (ageMonths == 12) {
      insights.add(InsightCard(
        id: 'tip_12months_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.tip,
        title: '周岁寄语',
        content: '宝宝一岁了！可以考虑给宝宝记录一段成长寄语，18岁时解锁，会是一份很珍贵的礼物～',
        icon: '💝',
        actionLabel: '写寄语',
      ));
    }

    final todayDiaries = await diaryRepository.getDiariesByDateRange(
      babyId,
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );

    if (todayDiaries.isEmpty) {
      insights.add(InsightCard(
        id: 'tip_diary_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.tip,
        title: '记录成长',
        content: '已经一周没有写日记了，记录一下宝宝最近的趣事吧，以后翻起来会很珍贵～',
        icon: '📝',
        actionLabel: '写日记',
      ));
    }

    return insights;
  }

  int _getInsightPriority(InsightType type) {
    switch (type) {
      case InsightType.anomalyAlert:
        return 0;
      case InsightType.celebration:
        return 1;
      case InsightType.growthTrend:
        return 2;
      case InsightType.milestoneProgress:
        return 3;
      case InsightType.sleepPattern:
        return 4;
      case InsightType.feedingPattern:
        return 5;
      case InsightType.emotionTrend:
        return 6;
      case InsightType.tip:
        return 7;
    }
  }

  int _calculateAgeMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months;
  }
}