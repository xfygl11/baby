import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../core/utils/date_time_utils.dart';

class RedFlag {
  final int ageMonths;
  final String category;
  final String description;
  final String severity;
  final String advice;

  const RedFlag({
    required this.ageMonths,
    required this.category,
    required this.description,
    required this.severity,
    required this.advice,
  });
}

class RedFlagAlert {
  final RedFlag flag;
  final String detail;

  const RedFlagAlert({
    required this.flag,
    required this.detail,
  });
}

class RedFlagService {
  final MilestoneRepository _milestoneRepo;
  final BabyRepository _babyRepo;

  RedFlagService(this._milestoneRepo, this._babyRepo);

  static const _redFlagLibrary = <RedFlag>[
    RedFlag(
        ageMonths: 3,
        category: '运动',
        description: '抬头',
        severity: 'high',
        advice: '建议就诊评估大运动发育'),
    RedFlag(
        ageMonths: 3,
        category: '社交',
        description: '对声音无反应',
        severity: 'high',
        advice: '建议进行听力筛查'),
    RedFlag(
        ageMonths: 3,
        category: '社交',
        description: '眼神交流',
        severity: 'high',
        advice: '建议就诊评估社交发育'),
    RedFlag(
        ageMonths: 6,
        category: '运动',
        description: '伸手抓物',
        severity: 'medium',
        advice: '建议观察并咨询儿保医生'),
    RedFlag(
        ageMonths: 6,
        category: '语言',
        description: '发元音',
        severity: 'medium',
        advice: '建议多与宝宝交流并咨询医生'),
    RedFlag(
        ageMonths: 6,
        category: '运动',
        description: '拉坐头后垂',
        severity: 'high',
        advice: '建议就诊评估肌张力'),
    RedFlag(
        ageMonths: 9,
        category: '运动',
        description: '扶站',
        severity: 'medium',
        advice: '建议观察大运动发展'),
    RedFlag(
        ageMonths: 9,
        category: '语言',
        description: '叫mama',
        severity: 'medium',
        advice: '建议多模仿发音并观察'),
    RedFlag(
        ageMonths: 9,
        category: '社交',
        description: '对名字反应',
        severity: 'high',
        advice: '建议就诊评估听力与社交'),
    RedFlag(
        ageMonths: 12,
        category: '运动',
        description: '爬',
        severity: 'medium',
        advice: '建议提供爬行机会并观察'),
    RedFlag(
        ageMonths: 12,
        category: '社交',
        description: '用手指物',
        severity: 'high',
        advice: '建议就诊评估共同注意能力'),
    RedFlag(
        ageMonths: 12,
        category: '社交',
        description: '挥手',
        severity: 'low',
        advice: '建议多示范手势'),
    RedFlag(
        ageMonths: 18,
        category: '运动',
        description: '走',
        severity: 'high',
        advice: '建议就诊评估大运动发育'),
    RedFlag(
        ageMonths: 18,
        category: '语言',
        description: '说单词',
        severity: 'high',
        advice: '建议就诊评估语言发育'),
    RedFlag(
        ageMonths: 18,
        category: '社交',
        description: '假装游戏',
        severity: 'medium',
        advice: '建议多引导象征性游戏'),
    RedFlag(
        ageMonths: 24,
        category: '语言',
        description: '两个词短语',
        severity: 'high',
        advice: '建议就诊语言评估'),
    RedFlag(
        ageMonths: 24,
        category: '社交',
        description: '对其他孩子兴趣',
        severity: 'medium',
        advice: '建议增加社交机会并观察'),
  ];

  Future<List<RedFlagAlert>> checkRedFlags(String babyId) async {
    final baby = await _babyRepo.getBabyById(babyId);
    if (baby == null) return [];

    final ageResult = DateTimeUtils.calculateAge(baby.birthDate);
    final ageMonths = ageResult.years * 12 + ageResult.months;

    final alerts = <RedFlagAlert>[];
    final milestones = await _milestoneRepo.getAchievedMilestones(babyId);
    final achievedNames = milestones.map((m) => m.name.toLowerCase()).toSet();

    final relevantFlags =
        _redFlagLibrary.where((flag) => ageMonths >= flag.ageMonths);

    for (final flag in relevantFlags) {
      final matched = _isMilestoneAchieved(flag, achievedNames);
      if (!matched) {
        alerts.add(RedFlagAlert(
          flag: flag,
          detail: '宝宝 ${ageMonths} 个月（${ageResult.years}岁${ageResult.months}月）',
        ));
      }
    }

    return alerts;
  }

  bool _isMilestoneAchieved(RedFlag flag, Set<String> achievedNames) {
    final desc = flag.description.toLowerCase();
    for (final name in achievedNames) {
      if (name.contains(desc) || desc.contains(name)) {
        return true;
      }
    }
    return false;
  }

  List<RedFlag> getLibraryForAge(int ageMonths) {
    return _redFlagLibrary.where((f) => f.ageMonths <= ageMonths).toList();
  }
}
