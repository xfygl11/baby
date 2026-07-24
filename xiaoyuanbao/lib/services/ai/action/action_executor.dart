import 'package:drift/drift.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/drift/daos/baby_repository.dart';
import '../../../data/drift/daos/feeding_repository.dart';
import '../../../data/drift/daos/sleep_repository.dart';
import '../../../data/drift/daos/diaper_repository.dart';
import '../../../data/drift/daos/temperature_repository.dart';
import '../../../data/drift/daos/medication_repository.dart';
import '../../../data/drift/daos/growth_repository.dart';
import '../../../data/drift/daos/vaccine_repository.dart';
import '../../../data/drift/daos/milestone_repository.dart';
import '../../../data/drift/daos/diary_repository.dart';
import '../../../data/drift/tables/feeding_records.dart';
import '../../../data/drift/tables/sleep_records.dart';
import '../../../data/drift/tables/diaper_records.dart';
import '../../../data/drift/tables/temperature_records.dart';
import '../../../data/drift/tables/vaccine_records.dart';
import '../../../data/drift/tables/milestone_records.dart';

class ActionResult {
  final bool success;
  final String message;
  final String? recordId;
  final String? recordType;
  final Map<String, dynamic>? data;
  final List<String>? createdRecordIds;

  ActionResult({
    required this.success,
    required this.message,
    this.recordId,
    this.recordType,
    this.data,
    this.createdRecordIds,
  });

  factory ActionResult.success({
    required String message,
    String? recordId,
    String? recordType,
    Map<String, dynamic>? data,
    List<String>? createdRecordIds,
  }) {
    return ActionResult(
      success: true,
      message: message,
      recordId: recordId,
      recordType: recordType,
      data: data,
      createdRecordIds: createdRecordIds,
    );
  }

  factory ActionResult.failure(String message) {
    return ActionResult(
      success: false,
      message: message,
    );
  }
}

class ActionExecutor {
  final BabyRepository? babyRepository;
  final FeedingRepository? feedingRepository;
  final SleepRepository? sleepRepository;
  final DiaperRepository? diaperRepository;
  final TemperatureRepository? temperatureRepository;
  final MedicationRepository? medicationRepository;
  final GrowthRepository? growthRepository;
  final VaccineRepository? vaccineRepository;
  final MilestoneRepository? milestoneRepository;
  final DiaryRepository? diaryRepository;

  ActionExecutor({
    this.babyRepository,
    this.feedingRepository,
    this.sleepRepository,
    this.diaperRepository,
    this.temperatureRepository,
    this.medicationRepository,
    this.growthRepository,
    this.vaccineRepository,
    this.milestoneRepository,
    this.diaryRepository,
  });

  Future<ActionResult> execute(
    AiIntent intent,
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    try {
      switch (intent) {
        case AiIntent.recordFeeding:
        case AiIntent.recordBreastfeeding:
        case AiIntent.recordSolidFood:
          return _recordFeeding(intent, entities, babyId);
        case AiIntent.recordSleepStart:
          return _recordSleepStart(entities, babyId);
        case AiIntent.recordSleepEnd:
          return _recordSleepEnd(entities, babyId);
        case AiIntent.recordDiaper:
        case AiIntent.recordStool:
          return _recordDiaper(intent, entities, babyId);
        case AiIntent.recordTemperature:
          return _recordTemperature(entities, babyId);
        case AiIntent.recordMedication:
          return _recordMedication(entities, babyId);
        case AiIntent.recordGrowth:
          return _recordGrowth(entities, babyId);
        case AiIntent.recordVaccine:
          return _recordVaccine(entities, babyId);
        case AiIntent.recordMilestone:
          return _recordMilestone(entities, babyId);
        case AiIntent.recordDiary:
          return _recordDiary(entities, babyId);
        case AiIntent.queryFeedingToday:
          return _queryFeedingToday(babyId);
        case AiIntent.querySleepToday:
          return _querySleepToday(babyId);
        case AiIntent.queryNextVaccine:
          return _queryNextVaccine(babyId);
        case AiIntent.queryGrowth:
          return _queryGrowth(babyId);
        case AiIntent.dailySummary:
          return _dailySummary(babyId);
        default:
          return ActionResult.failure('暂不支持该操作');
      }
    } catch (e) {
      return ActionResult.failure('操作失败：${e.toString()}');
    }
  }

  int _enumToIndex(dynamic value, List<dynamic> enumValues) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      for (int i = 0; i < enumValues.length; i++) {
        if (enumValues[i].name == value || enumValues[i].toString().split('.').last == value) {
          return i;
        }
      }
      return 0;
    }
    for (int i = 0; i < enumValues.length; i++) {
      if (value.toString() == enumValues[i].toString()) {
        return i;
      }
    }
    return 0;
  }

  T _toEnum<T>(dynamic value, List<T> enumValues, T defaultValue) {
    if (value == null) return defaultValue;
    if (value is T) return value;
    if (value is int) {
      if (value >= 0 && value < enumValues.length) {
        return enumValues[value];
      }
      return defaultValue;
    }
    if (value is String) {
      for (final enumValue in enumValues) {
        if (enumValue.toString().split('.').last == value || enumValue.toString() == value) {
          return enumValue;
        }
      }
      return defaultValue;
    }
    for (final enumValue in enumValues) {
      if (value.toString() == enumValue.toString()) {
        return enumValue;
      }
    }
    return defaultValue;
  }

  Future<ActionResult> _recordFeeding(
    AiIntent intent,
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (feedingRepository == null) {
      return ActionResult.failure('喂养记录服务未初始化');
    }

    int type;
    double? amountMl;
    int? breastSide;
    String? foodName;

    if (intent == AiIntent.recordBreastfeeding) {
      type = FeedingTypeEnum.breastMilk.index;
      final sideValue = entities['breastSide'];
      if (sideValue != null) {
        breastSide = _enumToIndex(sideValue, BreastSideEnum.values);
      } else {
        breastSide = BreastSideEnum.both.index;
      }
    } else if (intent == AiIntent.recordSolidFood) {
      type = FeedingTypeEnum.solidFood.index;
      foodName = entities['foodName'] as String? ?? '辅食';
    } else {
      final feedingTypeValue = entities['feedingType'];
      if (feedingTypeValue != null) {
        type = _enumToIndex(feedingTypeValue, FeedingTypeEnum.values);
      } else {
        type = FeedingTypeEnum.formula.index;
      }
    }

    if (entities['amount'] != null) {
      amountMl = (entities['amount'] as num).toDouble();
    } else if (entities['amountMl'] != null) {
      amountMl = (entities['amountMl'] as num).toDouble();
    }

    final now = DateTime.now();
    final durationMinutes = entities['durationMinutes'] as int?;
    final note = entities['note'] as String?;

    final id = await feedingRepository!.addFeeding(
      babyId: babyId,
      type: type,
      amountMl: amountMl,
      breastSide: breastSide,
      foodName: foodName,
      startTime: now,
      durationMinutes: durationMinutes,
      note: note,
      isCompleted: true,
    );

    return ActionResult.success(
      message: '喂养记录已创建',
      recordId: id,
      recordType: 'feeding',
      data: {
        'type': type,
        'amountMl': amountMl,
        'breastSide': breastSide,
        'foodName': foodName,
        'startTime': now.toIso8601String(),
        'durationMinutes': durationMinutes,
      },
    );
  }

  Future<ActionResult> _recordSleepStart(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (sleepRepository == null) {
      return ActionResult.failure('睡眠记录服务未初始化');
    }

    final sleepTypeValue = entities['sleepType'];
    int type = _enumToIndex(sleepTypeValue, SleepTypeEnum.values);

    final locationValue = entities['sleepLocation'] ?? entities['location'];
    int location = _enumToIndex(locationValue, SleepLocationEnum.values);

    final now = DateTime.now();
    final note = entities['note'] as String?;

    final id = await sleepRepository!.addSleep(
      babyId: babyId,
      type: type,
      location: location,
      startTime: now,
      note: note,
      isCompleted: false,
    );

    return ActionResult.success(
      message: '睡眠记录已开始',
      recordId: id,
      recordType: 'sleep',
      data: {
        'type': type,
        'location': locationIndex,
        'startTime': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordSleepEnd(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (sleepRepository == null) {
      return ActionResult.failure('睡眠记录服务未初始化');
    }

    final activeSleep = await sleepRepository!.getActiveSleep(babyId);
    if (activeSleep == null) {
      return ActionResult.failure('没有进行中的睡眠记录');
    }

    final now = DateTime.now();
    final duration = now.difference(activeSleep.startTime).inMinutes;
    final quality = entities['quality'] as String?;
    final note = entities['note'] as String?;
    final nightWakings = entities['nightWakings'] as int? ?? 0;

    await sleepRepository!.updateSleep(
      activeSleep.id,
      SleepRecordsCompanion(
        endTime: Value(now),
        durationMinutes: Value(duration),
        quality: Value(quality),
        note: Value(note),
        nightWakings: Value(nightWakings),
        isCompleted: const Value(true),
      ),
    );

    final todayStats = await sleepRepository!.getDailyStats(babyId, DateTime.now());

    return ActionResult.success(
      message: '睡眠记录已结束',
      recordId: activeSleep.id,
      recordType: 'sleep',
      data: {
        'startTime': activeSleep.startTime.toIso8601String(),
        'endTime': now.toIso8601String(),
        'durationMinutes': duration,
        'totalDurationMinutes': todayStats['totalDurationMinutes'],
        'count': todayStats['count'],
      },
    );
  }

  Future<ActionResult> _recordDiaper(
    AiIntent intent,
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (diaperRepository == null) {
      return ActionResult.failure('尿布记录服务未初始化');
    }

    int type;
    if (intent == AiIntent.recordStool) {
      type = DiaperTypeEnum.dirty.index;
    } else {
      final diaperTypeValue = entities['diaperType'];
      if (diaperTypeValue != null) {
        type = _enumToIndex(diaperTypeValue, DiaperTypeEnum.values);
      } else {
        type = DiaperTypeEnum.mixed.index;
      }
    }

    final stoolColorValue = entities['stoolColor'];
    int? stoolColor;
    if (stoolColorValue != null) {
      stoolColor = _enumToIndex(stoolColorValue, StoolColorEnum.values);
    }

    final stoolConsistency = entities['stoolConsistency'] as int?;
    final hasRash = entities['hasRash'] as bool? ?? false;
    final rashSeverity = entities['rashSeverity'] as String?;
    final note = entities['note'] as String?;
    final now = DateTime.now();

    final id = await diaperRepository!.addDiaper(
      babyId: babyId,
      type: type,
      stoolColor: stoolColor,
      stoolConsistency: stoolConsistency,
      hasRash: hasRash,
      rashSeverity: rashSeverity,
      recordTime: now,
      note: note,
    );

    return ActionResult.success(
      message: '尿布记录已创建',
      recordId: id,
      recordType: 'diaper',
      data: {
        'type': type,
        'stoolColor': stoolColor,
        'stoolConsistency': stoolConsistency,
        'hasRash': hasRash,
        'recordTime': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordTemperature(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (temperatureRepository == null) {
      return ActionResult.failure('体温记录服务未初始化');
    }

    final temperature = entities['temperature'] as double?;
    if (temperature == null) {
      return ActionResult.failure('请提供体温数值');
    }

    final siteValue = entities['site'];
    final site = _toEnum<TemperatureSiteEnum>(
      siteValue,
      TemperatureSiteEnum.values,
      TemperatureSiteEnum.armpit,
    );

    final note = entities['note'] as String?;
    final now = DateTime.now();

    final id = await temperatureRepository!.addTemperature(
      babyId: babyId,
      temperature: temperature,
      site: site,
      recordTime: now,
      note: note,
    );

    final isFever = temperature >= 37.5;

    return ActionResult.success(
      message: isFever ? '体温记录已创建，有点发烧哦' : '体温记录已创建',
      recordId: id,
      recordType: 'temperature',
      data: {
        'temperature': temperature,
        'site': site.index,
        'isFever': isFever,
        'recordTime': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordMedication(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (medicationRepository == null) {
      return ActionResult.failure('用药记录服务未初始化');
    }

    final medicineName = entities['medicineName'] as String?;
    if (medicineName == null || medicineName.isEmpty) {
      return ActionResult.failure('请提供药品名称');
    }

    final dosage = entities['dosage'] as double? ?? 0;
    final unit = entities['unit'] as String? ?? 'ml';
    final reason = entities['reason'] as String?;
    final note = entities['note'] as String?;
    final now = DateTime.now();

    final id = await medicationRepository!.addMedication(
      babyId: babyId,
      medicineName: medicineName,
      dosage: dosage,
      unit: unit,
      reason: reason,
      recordTime: now,
      note: note,
    );

    return ActionResult.success(
      message: '用药记录已创建',
      recordId: id,
      recordType: 'medication',
      data: {
        'medicineName': medicineName,
        'dosage': dosage,
        'unit': unit,
        'reason': reason,
        'recordTime': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordGrowth(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (growthRepository == null) {
      return ActionResult.failure('生长记录服务未初始化');
    }

    final weight = entities['weight'] as double?;
    final height = entities['height'] as double?;
    final headCircumference = entities['headCircumference'] as double?;
    final note = entities['note'] as String?;
    final measurementPlace = entities['measurementPlace'] as String?;

    if (weight == null && height == null && headCircumference == null) {
      return ActionResult.failure('请提供至少一项生长数据（体重、身高或头围）');
    }

    final now = DateTime.now();

    final id = await growthRepository!.addGrowth(
      babyId: babyId,
      weight: weight,
      height: height,
      headCircumference: headCircumference,
      recordDate: now,
      note: note,
      measurementPlace: measurementPlace,
    );

    double? bmi;
    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }

    return ActionResult.success(
      message: '生长记录已创建',
      recordId: id,
      recordType: 'growth',
      data: {
        'weight': weight,
        'height': height,
        'headCircumference': headCircumference,
        'bmi': bmi,
        'recordDate': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordVaccine(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (vaccineRepository == null) {
      return ActionResult.failure('疫苗记录服务未初始化');
    }

    final vaccineName = entities['vaccineName'] as String?;
    if (vaccineName == null || vaccineName.isEmpty) {
      return ActionResult.failure('请提供疫苗名称');
    }

    final vaccineCode = entities['vaccineCode'] as String?;
    final categoryValue = entities['category'];
    final category = _toEnum<VaccineCategoryEnum>(
      categoryValue,
      VaccineCategoryEnum.values,
      VaccineCategoryEnum.national,
    );

    final isCompleted = entities['isCompleted'] as bool? ?? true;
    final status = isCompleted
        ? VaccineStatusEnum.completed
        : VaccineStatusEnum.scheduled;

    final doseNumber = entities['doseNumber'] as int? ?? 1;
    final totalDoses = entities['totalDoses'] as int? ?? 1;
    final scheduledDate = entities['scheduledDate'] as DateTime?;
    final vaccinationDate =
        isCompleted ? (entities['vaccinationDate'] as DateTime? ?? DateTime.now()) : null;
    final batchNumber = entities['batchNumber'] as String?;
    final manufacturer = entities['manufacturer'] as String?;
    final hospital = entities['hospital'] as String?;
    final site = entities['site'] as String?;
    final reaction = entities['reaction'] as String?;
    final note = entities['note'] as String?;
    final reminderDays = entities['reminderDays'] as int?;
    final reminderEnabled = entities['reminderEnabled'] as bool? ?? false;

    final id = await vaccineRepository!.addVaccine(
      babyId: babyId,
      vaccineName: vaccineName,
      vaccineCode: vaccineCode,
      category: category,
      status: status,
      doseNumber: doseNumber,
      totalDoses: totalDoses,
      scheduledDate: scheduledDate,
      vaccinationDate: vaccinationDate,
      batchNumber: batchNumber,
      manufacturer: manufacturer,
      hospital: hospital,
      site: site,
      reaction: reaction,
      note: note,
      reminderDays: reminderDays,
      reminderEnabled: reminderEnabled,
    );

    return ActionResult.success(
      message: '疫苗记录已创建',
      recordId: id,
      recordType: 'vaccine',
      data: {
        'vaccineName': vaccineName,
        'category': category.index,
        'status': status.index,
        'doseNumber': doseNumber,
        'totalDoses': totalDoses,
        'vaccinationDate': vaccinationDate?.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _recordMilestone(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (milestoneRepository == null) {
      return ActionResult.failure('里程碑记录服务未初始化');
    }

    final name = entities['milestoneName'] as String? ?? entities['title'] as String?;
    if (name == null || name.isEmpty) {
      return ActionResult.failure('请提供里程碑名称');
    }

    final categoryValue = entities['category'];
    int category = _enumToIndex(categoryValue, MilestoneCategoryEnum.values);

    final achieveDate = entities['achieveDate'] as DateTime? ?? DateTime.now();
    final description = entities['description'] as String?;
    final imagePath = entities['imagePath'] as String?;
    final isCustom = entities['isCustom'] as bool? ?? false;
    final templateId = entities['templateId'] as String?;
    final note = entities['note'] as String?;
    final expectedAgeMonths = entities['expectedAgeMonths'] as int?;

    final id = await milestoneRepository!.addMilestone(
      babyId: babyId,
      name: name,
      category: category,
      achieveDate: achieveDate,
      description: description,
      imagePath: imagePath,
      isCustom: isCustom,
      templateId: templateId,
      note: note,
      expectedAgeMonths: expectedAgeMonths,
    );

    return ActionResult.success(
      message: '里程碑记录已创建',
      recordId: id,
      recordType: 'milestone',
      data: {
        'name': name,
        'category': category,
        'achieveDate': achieveDate.toIso8601String(),
        'description': description,
      },
    );
  }

  Future<ActionResult> _recordDiary(
    Map<String, dynamic> entities,
    String babyId,
  ) async {
    if (diaryRepository == null) {
      return ActionResult.failure('日记记录服务未初始化');
    }

    final content = entities['content'] as String?;
    if (content == null || content.isEmpty) {
      return ActionResult.failure('请提供日记内容');
    }

    final title = entities['title'] as String?;
    final mood = entities['mood'] as String?;
    final imagePaths = entities['imagePaths'] as String?;
    final weather = entities['weather'] as String?;
    final location = entities['location'] as String?;
    final isFavorite = entities['isFavorite'] as bool? ?? false;
    final now = DateTime.now();

    final id = await diaryRepository!.addDiary(
      babyId: babyId,
      content: content,
      title: title,
      mood: mood,
      imagePaths: imagePaths,
      recordDate: now,
      weather: weather,
      location: location,
      isFavorite: isFavorite,
    );

    return ActionResult.success(
      message: '日记记录已创建',
      recordId: id,
      recordType: 'diary',
      data: {
        'title': title,
        'content': content,
        'mood': mood,
        'recordDate': now.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _queryFeedingToday(String babyId) async {
    if (feedingRepository == null) {
      return ActionResult.failure('喂养记录服务未初始化');
    }

    final stats = await feedingRepository!.getDailyStats(babyId, DateTime.now());
    final records = await feedingRepository!.getTodayFeedings(babyId);

    return ActionResult.success(
      message: '今日喂养统计',
      recordType: 'feeding_stats',
      data: {
        'count': stats['count'],
        'totalAmount': stats['totalAmount'],
        'avgIntervalMinutes': stats['avgIntervalMinutes'],
        'records': records.map((r) => {
          'id': r.id,
          'type': r.type,
          'amountMl': r.amountMl,
          'startTime': r.startTime.toIso8601String(),
        }).toList(),
      },
    );
  }

  Future<ActionResult> _querySleepToday(String babyId) async {
    if (sleepRepository == null) {
      return ActionResult.failure('睡眠记录服务未初始化');
    }

    final stats = await sleepRepository!.getDailyStats(babyId, DateTime.now());
    final records = await sleepRepository!.getTodaySleeps(babyId);

    return ActionResult.success(
      message: '今日睡眠统计',
      recordType: 'sleep_stats',
      data: {
        'count': stats['count'],
        'totalDurationMinutes': stats['totalDurationMinutes'],
        'avgDurationMinutes': stats['avgDurationMinutes'],
        'nightCount': stats['nightCount'],
        'napCount': stats['napCount'],
        'totalNightWakings': stats['totalNightWakings'],
        'records': records.map((r) => {
          'id': r.id,
          'type': r.type,
          'startTime': r.startTime.toIso8601String(),
          'endTime': r.endTime?.toIso8601String(),
          'durationMinutes': r.durationMinutes,
          'isCompleted': r.isCompleted,
        }).toList(),
      },
    );
  }

  Future<ActionResult> _queryNextVaccine(String babyId) async {
    if (vaccineRepository == null) {
      return ActionResult.failure('疫苗记录服务未初始化');
    }

    final nextVaccine = await vaccineRepository!.getNextVaccine(babyId);

    if (nextVaccine == null) {
      return ActionResult.success(
        message: '暂无待接种疫苗',
        recordType: 'vaccine',
        data: null,
      );
    }

    return ActionResult.success(
      message: '下次疫苗查询成功',
      recordType: 'vaccine',
      data: {
        'id': nextVaccine.id,
        'vaccineName': nextVaccine.vaccineName,
        'vaccineCode': nextVaccine.vaccineCode,
        'category': nextVaccine.category,
        'doseNumber': nextVaccine.doseNumber,
        'totalDoses': nextVaccine.totalDoses,
        'scheduledDate': nextVaccine.scheduledDate?.toIso8601String(),
      },
    );
  }

  Future<ActionResult> _queryGrowth(String babyId) async {
    if (growthRepository == null) {
      return ActionResult.failure('生长记录服务未初始化');
    }

    final latest = await growthRepository!.getLatestGrowth(babyId);
    final allRecords = await growthRepository!.getGrowthRecords(babyId);

    if (latest == null) {
      return ActionResult.success(
        message: '暂无生长记录',
        recordType: 'growth',
        data: null,
      );
    }

    return ActionResult.success(
      message: '生长记录查询成功',
      recordType: 'growth',
      data: {
        'latest': {
          'id': latest.id,
          'weight': latest.weight,
          'height': latest.height,
          'headCircumference': latest.headCircumference,
          'bmi': latest.bmi,
          'recordDate': latest.recordDate.toIso8601String(),
        },
        'totalRecords': allRecords.length,
      },
    );
  }

  Future<ActionResult> _dailySummary(String babyId) async {
    final now = DateTime.now();
    final data = <String, dynamic>{};

    try {
      if (feedingRepository != null) {
        final feedingStats = await feedingRepository!.getDailyStats(babyId, now);
        data['feeding'] = feedingStats;
      }
    } catch (_) {}

    try {
      if (sleepRepository != null) {
        final sleepStats = await sleepRepository!.getDailyStats(babyId, now);
        data['sleep'] = sleepStats;
      }
    } catch (_) {}

    try {
      if (diaperRepository != null) {
        final diaperStats = await diaperRepository!.getDailyStats(babyId, now);
        data['diaper'] = diaperStats;
      }
    } catch (_) {}

    try {
      if (temperatureRepository != null) {
        final temps = await temperatureRepository!.getTodayTemperatures(babyId);
        data['temperature'] = {
          'count': temps.length,
          'latest': temps.isNotEmpty ? {
            'temperature': temps.first.temperature,
            'isFever': temps.first.isFever,
            'recordTime': temps.first.recordTime.toIso8601String(),
          } : null,
        };
      }
    } catch (_) {}

    try {
      if (milestoneRepository != null) {
        final milestones = await milestoneRepository!.getMilestonesByBabyId(babyId);
        final todayMilestones = milestones.where((m) =>
          m.achieveDate != null &&
          m.achieveDate!.year == now.year &&
          m.achieveDate!.month == now.month &&
          m.achieveDate!.day == now.day
        ).toList();
        data['milestones'] = {
          'todayCount': todayMilestones.length,
          'todayList': todayMilestones.map((m) => {
            'id': m.id,
            'name': m.name,
            'category': m.category,
          }).toList(),
        };
      }
    } catch (_) {}

    return ActionResult.success(
      message: '每日总结已生成',
      recordType: 'daily_summary',
      data: data,
    );
  }
}
