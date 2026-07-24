import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/feeding_records.dart';
import '../tables/sleep_records.dart';
import '../tables/diaper_records.dart';
import '../tables/temperature_records.dart';
import '../tables/medication_records.dart';
import '../tables/growth_records.dart';
import '../tables/vaccine_records.dart';
import '../tables/milestone_records.dart';
import '../tables/diary_records.dart';
import '../../core/constants/app_enums.dart';

class RecordRepository {
  final AppDatabase _db;

  RecordRepository(this._db);

  Future<List<Map<String, dynamic>>> getTimelineRecords({
    required String babyId,
    int? limit,
    int? offset,
    List<RecordCategory>? categories,
  }) async {
    final allRecords = <Map<String, dynamic>>[];

    final shouldInclude = (RecordCategory category) {
      if (categories == null || categories.isEmpty) return true;
      return categories.contains(category);
    };

    if (shouldInclude(RecordCategory.feeding)) {
      final feedingRecords = await (_db.select(_db.feedingRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();
      for (final r in feedingRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.feeding.name,
          'time': r.startTime,
          'title': _getFeedingTitle(r),
          'subtitle': _getFeedingSubtitle(r),
          'icon': RecordCategory.feeding.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.sleep)) {
      final sleepRecords = await (_db.select(_db.sleepRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();
      for (final r in sleepRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.sleep.name,
          'time': r.startTime,
          'title': _getSleepTitle(r),
          'subtitle': _getSleepSubtitle(r),
          'icon': RecordCategory.sleep.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.diaper)) {
      final diaperRecords = await (_db.select(_db.diaperRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
          .get();
      for (final r in diaperRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.diaper.name,
          'time': r.recordTime,
          'title': _getDiaperTitle(r),
          'subtitle': _getDiaperSubtitle(r),
          'icon': RecordCategory.diaper.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.temperature)) {
      final temperatureRecords = await (_db.select(_db.temperatureRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
          .get();
      for (final r in temperatureRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.temperature.name,
          'time': r.recordTime,
          'title': _getTemperatureTitle(r),
          'subtitle': _getTemperatureSubtitle(r),
          'icon': RecordCategory.temperature.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.medication)) {
      final medicationRecords = await (_db.select(_db.medicationRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
          .get();
      for (final r in medicationRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.medication.name,
          'time': r.recordTime,
          'title': _getMedicationTitle(r),
          'subtitle': _getMedicationSubtitle(r),
          'icon': RecordCategory.medication.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.growth)) {
      final growthRecords = await (_db.select(_db.growthRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
          .get();
      for (final r in growthRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.growth.name,
          'time': r.recordDate,
          'title': _getGrowthTitle(r),
          'subtitle': _getGrowthSubtitle(r),
          'icon': RecordCategory.growth.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.vaccine)) {
      final vaccineRecords = await (_db.select(_db.vaccineRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([
              (t) => OrderingTerm.desc(t.vaccinationDate),
              (t) => OrderingTerm.desc(t.scheduledDate),
            ]))
          .get();
      for (final r in vaccineRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.vaccine.name,
          'time': r.vaccinationDate ?? r.scheduledDate ?? DateTime.now(),
          'title': _getVaccineTitle(r),
          'subtitle': _getVaccineSubtitle(r),
          'icon': RecordCategory.vaccine.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.milestone)) {
      final milestoneRecords = await (_db.select(_db.milestoneRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.achieveDate)]))
          .get();
      for (final r in milestoneRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.milestone.name,
          'time': r.achieveDate ?? DateTime.now(),
          'title': _getMilestoneTitle(r),
          'subtitle': _getMilestoneSubtitle(r),
          'icon': RecordCategory.milestone.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.diary)) {
      final diaryRecords = await (_db.select(_db.diaryRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
          .get();
      for (final r in diaryRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.diary.name,
          'time': r.recordDate,
          'title': _getDiaryTitle(r),
          'subtitle': _getDiarySubtitle(r),
          'icon': RecordCategory.diary.icon,
        });
      }
    }

    allRecords.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    if (offset != null && offset > 0) {
      if (offset >= allRecords.length) {
        return [];
      }
      allRecords.removeRange(0, offset);
    }

    if (limit != null && limit > 0 && allRecords.length > limit) {
      allRecords.removeRange(limit, allRecords.length);
    }

    return allRecords;
  }

  String _getFeedingTitle(FeedingRecord r) {
    final type = FeedingType.values[r.type];
    return switch (type) {
      FeedingType.breastMilk => '母乳喂养',
      FeedingType.formula => '配方奶',
      FeedingType.solidFood => '辅食',
      FeedingType.water => '喝水',
      FeedingType.juice => '果汁',
      FeedingType.other => '其他喂养',
    };
  }

  String _getFeedingSubtitle(FeedingRecord r) {
    final parts = <String>[];
    if (r.amountMl != null) {
      parts.add('${r.amountMl!.toStringAsFixed(0)}ml');
    }
    if (r.durationMinutes != null) {
      parts.add('${r.durationMinutes}分钟');
    }
    if (r.foodName != null && r.foodName!.isNotEmpty) {
      parts.add(r.foodName!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getSleepTitle(SleepRecord r) {
    final type = SleepType.values[r.type];
    return switch (type) {
      SleepType.night => '夜间睡眠',
      SleepType.nap => '小睡',
      SleepType.micro => '微睡眠',
    };
  }

  String _getSleepSubtitle(SleepRecord r) {
    final parts = <String>[];
    if (r.durationMinutes != null) {
      final hours = r.durationMinutes! ~/ 60;
      final mins = r.durationMinutes! % 60;
      if (hours > 0) {
        parts.add('$hours小时$mins分钟');
      } else {
        parts.add('$mins分钟');
      }
    }
    if (r.quality != null && r.quality!.isNotEmpty) {
      parts.add(r.quality!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getDiaperTitle(DiaperRecord r) {
    final type = DiaperType.values[r.type];
    return switch (type) {
      DiaperType.wet => '尿尿',
      DiaperType.dirty => '便便',
      DiaperType.mixed => '尿尿+便便',
    };
  }

  String _getDiaperSubtitle(DiaperRecord r) {
    final parts = <String>[];
    if (r.stoolColor != null) {
      final color = StoolColor.values[r.stoolColor!];
      parts.add(switch (color) {
        StoolColor.brown => '棕色',
        StoolColor.yellow => '黄色',
        StoolColor.green => '绿色',
        StoolColor.black => '黑色',
        StoolColor.red => '红色',
        StoolColor.white => '白色',
        StoolColor.gray => '灰色',
      });
    }
    if (r.hasRash) {
      parts.add('有红疹');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getTemperatureTitle(TemperatureRecord r) {
    return '体温 ${r.temperature.toStringAsFixed(1)}°C';
  }

  String _getTemperatureSubtitle(TemperatureRecord r) {
    final parts = <String>[];
    final site = TemperatureSite.values[r.site];
    parts.add(switch (site) {
      TemperatureSite.armpit => '腋下',
      TemperatureSite.ear => '耳温',
      TemperatureSite.forehead => '额温',
      TemperatureSite.rectal => '肛温',
      TemperatureSite.oral => '口温',
    });
    if (r.isFever) {
      parts.add('发烧');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getMedicationTitle(MedicationRecord r) {
    return r.medicineName;
  }

  String _getMedicationSubtitle(MedicationRecord r) {
    final parts = <String>[];
    parts.add('${r.dosage}${r.unit}');
    if (r.reason != null && r.reason!.isNotEmpty) {
      parts.add(r.reason!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getGrowthTitle(GrowthRecord r) {
    final parts = <String>[];
    if (r.weight != null) {
      parts.add('体重 ${r.weight}kg');
    }
    if (r.height != null) {
      parts.add('身高 ${r.height}cm');
    }
    if (r.headCircumference != null) {
      parts.add('头围 ${r.headCircumference}cm');
    }
    return parts.isNotEmpty ? parts.join(' · ') : '生长记录';
  }

  String _getGrowthSubtitle(GrowthRecord r) {
    final parts = <String>[];
    if (r.bmi != null) {
      parts.add('BMI ${r.bmi!.toStringAsFixed(1)}');
    }
    if (r.measurementPlace != null && r.measurementPlace!.isNotEmpty) {
      parts.add(r.measurementPlace!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getVaccineTitle(VaccineRecord r) {
    return r.vaccineName;
  }

  String _getVaccineSubtitle(VaccineRecord r) {
    final parts = <String>[];
    if (r.totalDoses != null && r.totalDoses! > 1) {
      parts.add('第${r.doseNumber}剂/共${r.totalDoses}剂');
    }
    final status = VaccineStatus.values[r.status];
    parts.add(switch (status) {
      VaccineStatus.scheduled => '已预约',
      VaccineStatus.completed => '已接种',
      VaccineStatus.delayed => '已推迟',
      VaccineStatus.skipped => '已跳过',
      VaccineStatus.contraindicated => '禁忌症',
    });
    if (r.hospital != null && r.hospital!.isNotEmpty) {
      parts.add(r.hospital!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getMilestoneTitle(MilestoneRecord r) {
    return r.name;
  }

  String _getMilestoneSubtitle(MilestoneRecord r) {
    final parts = <String>[];
    final category = MilestoneCategory.values[r.category];
    parts.add(switch (category) {
      MilestoneCategory.motor => '大运动',
      MilestoneCategory.language => '语言',
      MilestoneCategory.cognitive => '认知',
      MilestoneCategory.social => '社交',
      MilestoneCategory.feeding => '喂养',
      MilestoneCategory.other => '其他',
    });
    if (r.isCustom) {
      parts.add('自定义');
    }
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    return parts.join(' · ');
  }

  String _getDiaryTitle(DiaryRecord r) {
    if (r.title != null && r.title!.isNotEmpty) {
      return r.title!;
    }
    if (r.content.isNotEmpty) {
      return r.content.length > 20 ? '${r.content.substring(0, 20)}...' : r.content;
    }
    return '日记';
  }

  String _getDiarySubtitle(DiaryRecord r) {
    final parts = <String>[];
    if (r.mood != null && r.mood!.isNotEmpty) {
      parts.add(r.mood!);
    }
    if (r.weather != null && r.weather!.isNotEmpty) {
      parts.add(r.weather!);
    }
    if (r.location != null && r.location!.isNotEmpty) {
      parts.add(r.location!);
    }
    if (r.isFavorite) {
      parts.add('已收藏');
    }
    if (parts.isEmpty && r.content.isNotEmpty) {
      final preview = r.content.length > 50 ? '${r.content.substring(0, 50)}...' : r.content;
      parts.add(preview);
    }
    return parts.join(' · ');
  }
}
