import 'dart:math';
import '../../core/constants/app_enums.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/medication_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/tables/vaccine_records.dart';

class PopupAction {
  final String label;
  final String actionType;
  final bool isPrimary;

  PopupAction({
    required this.label,
    this.actionType = 'confirm',
    this.isPrimary = false,
  });
}

class SmartPopup {
  final String id;
  final PopupType type;
  final PopupPriority priority;
  final String title;
  final String message;
  final String? subtitle;
  final List<PopupAction> actions;
  final Map<String, dynamic>? data;

  SmartPopup({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.subtitle,
    this.actions = const [],
    this.data,
  });
}

class _PopupDisplayRecord {
  final PopupType type;
  final DateTime shownAt;
  final String? context;

  _PopupDisplayRecord({
    required this.type,
    required this.shownAt,
    this.context,
  });
}

class _PopupDismissCount {
  final PopupType type;
  int count;
  DateTime lastDismissAt;

  _PopupDismissCount({
    required this.type,
    this.count = 0,
    required this.lastDismissAt,
  });
}

class SmartPopupService {
  final SleepRepository sleepRepository;
  final FeedingRepository feedingRepository;
  final VaccineRepository vaccineRepository;
  final TemperatureRepository temperatureRepository;
  final MedicationRepository medicationRepository;
  final MilestoneRepository milestoneRepository;
  final BabyRepository babyRepository;

  final List<_PopupDisplayRecord> _shownHistory = [];
  final Map<PopupType, DateTime> _snoozeUntil = {};
  final Map<PopupType, _PopupDismissCount> _dismissCounts = {};
  final Map<PopupType, int> _dailyShownCount = {};
  DateTime _dailyCountDate = DateTime.now();

  int doNotDisturbStartHour = 22;
  int doNotDisturbEndHour = 6;

  SmartPopupService({
    required this.sleepRepository,
    required this.feedingRepository,
    required this.vaccineRepository,
    required this.temperatureRepository,
    required this.medicationRepository,
    required this.milestoneRepository,
    required this.babyRepository,
  });

  Future<SmartPopup?> checkForPopup(String babyId) async {
    _resetDailyCountIfNeeded();

    final pending = await getPendingPopups(babyId);
    if (pending.isEmpty) return null;

    pending.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    for (final popup in pending) {
      if (await shouldShowPopup(popup.type, babyId)) {
        return popup;
      }
    }

    return null;
  }

  Future<bool> shouldShowPopup(PopupType type, String babyId) async {
    final now = DateTime.now();

    if (_isDoNotDisturbTime(now)) {
      final priority = _getPriorityForType(type);
      if (priority != PopupPriority.p0) {
        return false;
      }
    }

    if (_isSnoozed(type, now)) {
      return false;
    }

    if (_wasShownRecently(type, now)) {
      return false;
    }

    if (_exceededDailyLimit(type)) {
      return false;
    }

    if (_isDismissedTooManyTimes(type)) {
      return false;
    }

    return true;
  }

  void markPopupShown(PopupType type, String babyId, {String? context}) {
    final now = DateTime.now();
    _shownHistory.add(_PopupDisplayRecord(
      type: type,
      shownAt: now,
      context: context,
    ));

    _dailyShownCount[type] = (_dailyShownCount[type] ?? 0) + 1;

    _shownHistory.removeWhere(
      (r) => now.difference(r.shownAt).inHours > 24,
    );
  }

  void snoozePopup(PopupType type, String babyId, int minutes) {
    final snoozeUntil = DateTime.now().add(Duration(minutes: minutes));
    _snoozeUntil[type] = snoozeUntil;
  }

  void dismissPopup(PopupType type, String babyId) {
    final now = DateTime.now();
    final existing = _dismissCounts[type];
    if (existing == null) {
      _dismissCounts[type] = _PopupDismissCount(
        type: type,
        count: 1,
        lastDismissAt: now,
      );
    } else {
      if (now.difference(existing.lastDismissAt).inDays > 7) {
        existing.count = 1;
      } else {
        existing.count++;
      }
      existing.lastDismissAt = now;
    }
  }

  Future<List<SmartPopup>> getPendingPopups(String babyId) async {
    final popups = <SmartPopup>[];

    final sleepWindow = await _checkSleepWindow(babyId);
    if (sleepWindow != null) popups.add(sleepWindow);

    final sleepWake = await _checkSleepWake(babyId);
    if (sleepWake != null) popups.add(sleepWake);

    final nightWake = await _checkNightWake(babyId);
    if (nightWake != null) popups.add(nightWake);

    final feedingInterval = await _checkFeedingInterval(babyId);
    if (feedingInterval != null) popups.add(feedingInterval);

    final vaccineReminder = await _checkVaccineReminder(babyId);
    if (vaccineReminder != null) popups.add(vaccineReminder);

    final temperatureCheck = await _checkTemperatureCheck(babyId);
    if (temperatureCheck != null) popups.add(temperatureCheck);

    final medicationReminder = await _checkMedicationReminder(babyId);
    if (medicationReminder != null) popups.add(medicationReminder);

    final milestoneCheck = await _checkMilestoneCheck(babyId);
    if (milestoneCheck != null) popups.add(milestoneCheck);

    final dailySummary = await _checkDailySummary(babyId);
    if (dailySummary != null) popups.add(dailySummary);

    final birthday = await _checkBirthday(babyId);
    if (birthday != null) popups.add(birthday);

    final anomalyAlert = await _checkAnomalyAlert(babyId);
    if (anomalyAlert != null) popups.add(anomalyAlert);

    return popups;
  }

  Future<SmartPopup?> _checkSleepWindow(String babyId) async {
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final awakeWindow = _getAwakeWindowMinutes(ageMonths);

    final latestSleep = await sleepRepository.getLatestSleep(babyId);
    if (latestSleep == null || latestSleep.endTime == null) return null;

    final timeSinceWake = DateTime.now().difference(latestSleep.endTime!).inMinutes;
    final windowStart = awakeWindow - 15;
    final windowEnd = awakeWindow + 15;

    if (timeSinceWake >= windowStart && timeSinceWake <= windowEnd) {
      final minsLeft = (awakeWindow - timeSinceWake).abs();
      return SmartPopup(
        id: 'sleep_window_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.sleepWindow,
        priority: PopupPriority.p2,
        title: '宝宝快要困了',
        message: '距离上次醒来已过${timeSinceWake}分钟，${minsLeft <= 5 ? '现在' : '约${minsLeft}分钟后'}是入睡好时机',
        subtitle: '建议尽快安排小睡',
        actions: [
          PopupAction(label: '开始记录睡眠', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '稍后提醒', actionType: 'snooze'),
        ],
        data: {'sleepType': 'nap'},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkSleepWake(String babyId) async {
    final activeSleep = await sleepRepository.getActiveSleep(babyId);
    if (activeSleep == null) return null;

    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final expectedNapDuration = _getExpectedNapDuration(ageMonths);

    final elapsed = DateTime.now().difference(activeSleep.startTime).inMinutes;
    if (elapsed >= expectedNapDuration - 10 && elapsed <= expectedNapDuration + 20) {
      return SmartPopup(
        id: 'sleep_wake_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.sleepWake,
        priority: PopupPriority.p2,
        title: '小睡时间差不多了',
        message: '宝宝已睡${elapsed}分钟，可以考虑叫醒了',
        subtitle: '避免影响夜间睡眠',
        actions: [
          PopupAction(label: '结束睡眠', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '让TA继续睡', actionType: 'dismiss'),
        ],
        data: {'sleepRecordId': activeSleep.id, 'duration': elapsed},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkNightWake(String babyId) async {
    final now = DateTime.now();
    if (now.hour < 20 || now.hour > 6) {
      if (!(now.hour >= 0 && now.hour < 6)) {
        return null;
      }
    }

    final activeSleep = await sleepRepository.getActiveSleep(babyId);
    if (activeSleep == null) return null;

    final latestTemperatures = await temperatureRepository.getTodayTemperatures(babyId);
    final recentFever = latestTemperatures.where(
      (t) => t.isFever && now.difference(t.recordTime).inHours < 4,
    );
    if (recentFever.isNotEmpty) {
      return SmartPopup(
        id: 'night_wake_fever_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.nightWake,
        priority: PopupPriority.p0,
        title: '夜醒快速记录',
        message: '宝宝半夜醒来了，快速记录一下情况吧',
        subtitle: '发烧中，注意监测体温',
        actions: [
          PopupAction(label: '记录夜醒', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '测体温', actionType: 'custom'),
          PopupAction(label: '稍后再说', actionType: 'dismiss'),
        ],
        data: {'hasFever': true},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkFeedingInterval(String babyId) async {
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final intervalRange = _getFeedingIntervalHours(ageMonths);
    final minInterval = intervalRange['min']! * 60;
    final maxInterval = intervalRange['max']! * 60;

    final latestFeeding = await feedingRepository.getLatestFeeding(babyId);
    if (latestFeeding == null) return null;

    final timeSinceFeeding = DateTime.now().difference(latestFeeding.startTime).inMinutes;

    if (timeSinceFeeding >= minInterval && timeSinceFeeding <= maxInterval + 30) {
      final hours = (timeSinceFeeding / 60).toStringAsFixed(1);
      return SmartPopup(
        id: 'feeding_interval_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.feedingInterval,
        priority: PopupPriority.p2,
        title: '宝宝可能饿了',
        message: '距离上次喂养已过${hours}小时',
        subtitle: '根据月龄建议${intervalRange['min']}-${intervalRange['max']}小时喂一次',
        actions: [
          PopupAction(label: '开始记录喂养', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '稍后提醒', actionType: 'snooze'),
        ],
        data: {'timeSinceLast': timeSinceFeeding},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkVaccineReminder(String babyId) async {
    final nextVaccine = await vaccineRepository.getNextVaccine(babyId);
    if (nextVaccine == null || nextVaccine.scheduledDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      nextVaccine.scheduledDate!.year,
      nextVaccine.scheduledDate!.month,
      nextVaccine.scheduledDate!.day,
    );

    final daysUntil = scheduled.difference(today).inDays;

    if (daysUntil < 0) {
      return SmartPopup(
        id: 'vaccine_overdue_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.vaccineReminder,
        priority: PopupPriority.p1,
        title: '疫苗已超期',
        message: '${nextVaccine.vaccineName}已逾期${daysUntil.abs()}天',
        subtitle: '请尽快预约接种',
        actions: [
          PopupAction(label: '查看详情', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '已接种', actionType: 'custom'),
        ],
        data: {'vaccineId': nextVaccine.id, 'daysOverdue': daysUntil.abs()},
      );
    }

    if (daysUntil == 0) {
      return SmartPopup(
        id: 'vaccine_today_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.vaccineReminder,
        priority: PopupPriority.p1,
        title: '今天是疫苗日',
        message: '今天要接种${nextVaccine.vaccineName}',
        subtitle: '记得带好接种本哦',
        actions: [
          PopupAction(label: '查看详情', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '知道了', actionType: 'dismiss'),
        ],
        data: {'vaccineId': nextVaccine.id},
      );
    }

    if (daysUntil <= 7 && daysUntil > 0) {
      return SmartPopup(
        id: 'vaccine_upcoming_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.vaccineReminder,
        priority: PopupPriority.p1,
        title: '疫苗倒计时',
        message: '距离${nextVaccine.vaccineName}接种还有${daysUntil}天',
        subtitle: '第${nextVaccine.doseNumber}剂/共${nextVaccine.totalDoses}剂',
        actions: [
          PopupAction(label: '查看详情', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '知道了', actionType: 'dismiss'),
        ],
        data: {'vaccineId': nextVaccine.id, 'daysUntil': daysUntil},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkTemperatureCheck(String babyId) async {
    final now = DateTime.now();
    final latestTemp = await temperatureRepository.getLatestTemperature(babyId);
    if (latestTemp == null || !latestTemp.isFever) return null;

    final timeSinceFever = now.difference(latestTemp.recordTime).inHours;

    if (timeSinceFever >= 4 && timeSinceFever <= 6) {
      return SmartPopup(
        id: 'temp_check_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.temperatureCheck,
        priority: PopupPriority.p1,
        title: '该复测体温了',
        message: '距离上次发烧记录已过${timeSinceFever}小时',
        subtitle: '上次体温：${latestTemp.temperature.toStringAsFixed(1)}°C',
        actions: [
          PopupAction(label: '记录体温', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '稍后提醒', actionType: 'snooze'),
        ],
        data: {'lastTemp': latestTemp.temperature, 'lastTempId': latestTemp.id},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkMedicationReminder(String babyId) async {
    final latestMed = await medicationRepository.getLatestMedication(babyId);
    if (latestMed == null) return null;

    final now = DateTime.now();
    final timeSince = now.difference(latestMed.recordTime).inHours;

    if (timeSince >= 6 && timeSince <= 8) {
      return SmartPopup(
        id: 'med_reminder_${DateTime.now().millisecondsSinceEpoch}',
        type: PopupType.medicationReminder,
        priority: PopupPriority.p1,
        title: '吃药时间到了',
        message: '${latestMed.medicineName}该吃了',
        subtitle: '距离上次服药已过${timeSince}小时',
        actions: [
          PopupAction(label: '记录服药', actionType: 'confirm', isPrimary: true),
          PopupAction(label: '稍后提醒', actionType: 'snooze'),
        ],
        data: {'medicineName': latestMed.medicineName, 'dosage': latestMed.dosage, 'unit': latestMed.unit},
      );
    }

    return null;
  }

  Future<SmartPopup?> _checkMilestoneCheck(String babyId) async {
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final ageMonths = _calculateAgeMonths(baby.birthDate);
    final keyMonths = [1, 2, 3, 4, 6, 8, 9, 10, 12, 15, 18, 24];

    bool isKeyMonth = false;
    int? targetMonth;
    for (final m in keyMonths) {
      if (ageMonths == m) {
        isKeyMonth = true;
        targetMonth = m;
        break;
      }
    }

    if (!isKeyMonth || targetMonth == null) return null;

    final milestones = await milestoneRepository.getMilestonesByBabyId(babyId);
    final monthMilestones = milestones.where(
      (m) => m.expectedAgeMonths == targetMonth && m.achieveDate == null,
    );

    if (monthMilestones.isEmpty) return null;

    final shownToday = _dailyShownCount[PopupType.milestoneCheck] ?? 0;
    if (shownToday > 0) return null;

    return SmartPopup(
      id: 'milestone_check_${DateTime.now().millisecondsSinceEpoch}',
      type: PopupType.milestoneCheck,
      priority: PopupPriority.p1,
      title: '发育检查时间',
      message: '宝宝${targetMonth}个月啦，来做个发育评估吧',
      subtitle: '共${monthMilestones.length}项待检查',
      actions: [
        PopupAction(label: '开始检查', actionType: 'confirm', isPrimary: true),
        PopupAction(label: '稍后再说', actionType: 'dismiss'),
      ],
      data: {'ageMonths': targetMonth, 'pendingCount': monthMilestones.length},
    );
  }

  Future<SmartPopup?> _checkDailySummary(String babyId) async {
    final now = DateTime.now();
    if (now.hour < 21 || now.hour >= 23) return null;

    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayFeedings = await feedingRepository.getFeedingsByDateRange(
      babyId,
      todayStart,
      todayEnd,
    );
    final todaySleeps = await sleepRepository.getSleepsByDateRange(
      babyId,
      todayStart,
      todayEnd,
    );

    final hasRecords = todayFeedings.isNotEmpty || todaySleeps.isNotEmpty;
    if (!hasRecords) return null;

    final shownToday = _dailyShownCount[PopupType.dailySummary] ?? 0;
    if (shownToday > 0) return null;

    return SmartPopup(
      id: 'daily_summary_${DateTime.now().millisecondsSinceEpoch}',
      type: PopupType.dailySummary,
      priority: PopupPriority.p2,
      title: '今日总结',
      message: '来看看宝宝今天的情况吧',
      subtitle: '喂养${todayFeedings.length}次 · 睡眠${todaySleeps.length}次',
      actions: [
        PopupAction(label: '查看总结', actionType: 'confirm', isPrimary: true),
        PopupAction(label: '明天再说', actionType: 'dismiss'),
      ],
      data: {
        'feedingCount': todayFeedings.length,
        'sleepCount': todaySleeps.length,
      },
    );
  }

  Future<SmartPopup?> _checkBirthday(String babyId) async {
    final baby = await babyRepository.getBabyById(babyId);
    if (baby == null) return null;

    final now = DateTime.now();
    final birthDate = baby.birthDate;

    if (now.month == birthDate.month && now.day == birthDate.day) {
      final ageYears = now.year - birthDate.year;
      if (ageYears > 0) {
        final shownToday = _dailyShownCount[PopupType.birthday] ?? 0;
        if (shownToday > 0) return null;

        return SmartPopup(
          id: 'birthday_${DateTime.now().millisecondsSinceEpoch}',
          type: PopupType.birthday,
          priority: PopupPriority.p3,
          title: '生日快乐！',
          message: '今天是宝宝${ageYears}岁生日',
          subtitle: '记录一下这特别的日子吧',
          actions: [
            PopupAction(label: '写篇日记', actionType: 'confirm', isPrimary: true),
            PopupAction(label: '谢谢提醒', actionType: 'dismiss'),
          ],
          data: {'age': ageYears, 'birthDate': birthDate.toIso8601String()},
        );
      }

      final ageMonths = _calculateAgeMonths(birthDate);
      if (ageMonths > 0) {
        final shownToday = _dailyShownCount[PopupType.birthday] ?? 0;
        if (shownToday > 0) return null;

        return SmartPopup(
          id: 'monthday_${DateTime.now().millisecondsSinceEpoch}',
          type: PopupType.birthday,
          priority: PopupPriority.p3,
          title: '成长快乐！',
          message: '今天宝宝满${ageMonths}个月啦',
          subtitle: '记录一下这个值得纪念的日子',
          actions: [
            PopupAction(label: '写篇日记', actionType: 'confirm', isPrimary: true),
            PopupAction(label: '谢谢提醒', actionType: 'dismiss'),
          ],
          data: {'ageMonths': ageMonths, 'birthDate': birthDate.toIso8601String()},
        );
      }
    }

    return null;
  }

  Future<SmartPopup?> _checkAnomalyAlert(String babyId) async {
    final latestTemp = await temperatureRepository.getLatestTemperature(babyId);
    if (latestTemp != null && latestTemp.isFever) {
      if (latestTemp.temperature >= 39.0) {
        final timeSince = DateTime.now().difference(latestTemp.recordTime).inMinutes;
        if (timeSince < 30) {
          return SmartPopup(
            id: 'anomaly_high_fever_${DateTime.now().millisecondsSinceEpoch}',
            type: PopupType.anomalyAlert,
            priority: PopupPriority.p0,
            title: '高烧预警',
            message: '宝宝体温${latestTemp.temperature.toStringAsFixed(1)}°C，属于高烧',
            subtitle: '建议及时就医或服用退烧药',
            actions: [
              PopupAction(label: '记录用药', actionType: 'custom', isPrimary: true),
              PopupAction(label: '了解更多', actionType: 'confirm'),
            ],
            data: {'temperature': latestTemp.temperature, 'recordId': latestTemp.id},
          );
        }
      }
    }

    return null;
  }

  bool _isDoNotDisturbTime(DateTime now) {
    if (doNotDisturbStartHour < doNotDisturbEndHour) {
      return now.hour >= doNotDisturbStartHour && now.hour < doNotDisturbEndHour;
    } else {
      return now.hour >= doNotDisturbStartHour || now.hour < doNotDisturbEndHour;
    }
  }

  bool _isSnoozed(PopupType type, DateTime now) {
    final snoozeUntil = _snoozeUntil[type];
    if (snoozeUntil == null) return false;
    return now.isBefore(snoozeUntil);
  }

  bool _wasShownRecently(PopupType type, DateTime now) {
    for (int i = _shownHistory.length - 1; i >= 0; i--) {
      final record = _shownHistory[i];
      if (record.type == type) {
        final diff = now.difference(record.shownAt).inMinutes;
        return diff < 30;
      }
    }
    return false;
  }

  bool _exceededDailyLimit(PopupType type) {
    final priority = _getPriorityForType(type);
    final count = _dailyShownCount[type] ?? 0;
    final limit = _getDailyLimitForPriority(priority);
    if (limit == null) return false;
    return count >= limit;
  }

  bool _isDismissedTooManyTimes(PopupType type) {
    final dismiss = _dismissCounts[type];
    if (dismiss == null) return false;
    if (DateTime.now().difference(dismiss.lastDismissAt).inDays > 7) {
      return false;
    }
    return dismiss.count >= 3;
  }

  PopupPriority _getPriorityForType(PopupType type) {
    switch (type) {
      case PopupType.anomalyAlert:
      case PopupType.nightWake:
        return PopupPriority.p0;
      case PopupType.vaccineReminder:
      case PopupType.temperatureCheck:
      case PopupType.medicationReminder:
      case PopupType.milestoneCheck:
        return PopupPriority.p1;
      case PopupType.feedingInterval:
      case PopupType.sleepWindow:
      case PopupType.sleepWake:
      case PopupType.dailySummary:
        return PopupPriority.p2;
      case PopupType.birthday:
        return PopupPriority.p3;
    }
  }

  int? _getDailyLimitForPriority(PopupPriority priority) {
    switch (priority) {
      case PopupPriority.p0:
        return null;
      case PopupPriority.p1:
        return 3;
      case PopupPriority.p2:
        return 5;
      case PopupPriority.p3:
        return 2;
    }
  }

  void _resetDailyCountIfNeeded() {
    final now = DateTime.now();
    if (now.year != _dailyCountDate.year ||
        now.month != _dailyCountDate.month ||
        now.day != _dailyCountDate.day) {
      _dailyShownCount.clear();
      _dailyCountDate = now;
    }
  }

  int _calculateAgeMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months--;
    }
    return max(0, months);
  }

  int _getAwakeWindowMinutes(int ageMonths) {
    if (ageMonths < 1) return 45;
    if (ageMonths < 3) return 60;
    if (ageMonths < 6) return 90;
    if (ageMonths < 9) return 120;
    if (ageMonths < 12) return 150;
    if (ageMonths < 18) return 180;
    if (ageMonths < 24) return 240;
    return 300;
  }

  int _getExpectedNapDuration(int ageMonths) {
    if (ageMonths < 3) return 45;
    if (ageMonths < 6) return 90;
    if (ageMonths < 12) return 120;
    if (ageMonths < 18) return 90;
    if (ageMonths < 24) return 60;
    return 60;
  }

  Map<String, double> _getFeedingIntervalHours(int ageMonths) {
    if (ageMonths < 1) return {'min': 2.0, 'max': 3.0};
    if (ageMonths < 3) return {'min': 2.5, 'max': 3.5};
    if (ageMonths < 6) return {'min': 3.0, 'max': 4.0};
    if (ageMonths < 9) return {'min': 3.5, 'max': 4.5};
    if (ageMonths < 12) return {'min': 4.0, 'max': 5.0};
    if (ageMonths < 18) return {'min': 4.0, 'max': 5.0};
    return {'min': 4.0, 'max': 6.0};
  }
}
