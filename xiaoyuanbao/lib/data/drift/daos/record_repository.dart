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
import '../tables/stool_records.dart';
import '../tables/skin_records.dart';
import '../tables/allergy_records.dart';
import '../tables/doctor_visit_records.dart';
import '../tables/teeth_records.dart';
import '../tables/vision_records.dart';
import '../tables/school_records.dart';
import '../tables/exam_records.dart';
import '../tables/award_records.dart';
import '../tables/interest_class_records.dart';
import '../tables/parent_meeting_records.dart';
import '../tables/personality_records.dart';
import '../tables/emotion_records.dart';
import '../tables/hobby_records.dart';
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

    if (shouldInclude(RecordCategory.stool)) {
      final stoolRecords = await (_db.select(_db.stoolRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.time)]))
          .get();
      for (final r in stoolRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.stool.name,
          'time': r.time,
          'title': _getStoolTitle(r),
          'subtitle': _getStoolSubtitle(r),
          'icon': RecordCategory.stool.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.skin)) {
      final skinRecords = await (_db.select(_db.skinRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.time)]))
          .get();
      for (final r in skinRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.skin.name,
          'time': r.time,
          'title': _getSkinTitle(r),
          'subtitle': _getSkinSubtitle(r),
          'icon': RecordCategory.skin.icon,
          'imagePath': r.imagePath,
        });
      }
    }

    if (shouldInclude(RecordCategory.allergy)) {
      final allergyRecords = await (_db.select(_db.allergyRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.lastOccurrence), (t) => OrderingTerm.desc(t.firstOccurrence)]))
          .get();
      for (final r in allergyRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.allergy.name,
          'time': r.lastOccurrence ?? r.firstOccurrence,
          'title': _getAllergyTitle(r),
          'subtitle': _getAllergySubtitle(r),
          'icon': RecordCategory.allergy.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.doctorVisit)) {
      final doctorVisitRecords = await (_db.select(_db.doctorVisitRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.visitDate)]))
          .get();
      for (final r in doctorVisitRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.doctorVisit.name,
          'time': r.visitDate,
          'title': _getDoctorVisitTitle(r),
          'subtitle': _getDoctorVisitSubtitle(r),
          'icon': RecordCategory.doctorVisit.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.teeth)) {
      final teethRecords = await (_db.select(_db.teethRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .get();
      for (final r in teethRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.teeth.name,
          'time': r.eventDate,
          'title': _getTeethTitle(r),
          'subtitle': _getTeethSubtitle(r),
          'icon': RecordCategory.teeth.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.vision)) {
      final visionRecords = await (_db.select(_db.visionRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.checkDate)]))
          .get();
      for (final r in visionRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.vision.name,
          'time': r.checkDate,
          'title': _getVisionTitle(r),
          'subtitle': _getVisionSubtitle(r),
          'icon': RecordCategory.vision.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.school)) {
      final schoolRecords = await (_db.select(_db.schoolRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.admissionDate)]))
          .get();
      for (final r in schoolRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.school.name,
          'time': r.admissionDate,
          'title': _getSchoolTitle(r),
          'subtitle': _getSchoolSubtitle(r),
          'icon': RecordCategory.school.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.exam)) {
      final examRecords = await (_db.select(_db.examRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.examDate)]))
          .get();
      for (final r in examRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.exam.name,
          'time': r.examDate,
          'title': _getExamTitle(r),
          'subtitle': _getExamSubtitle(r),
          'icon': RecordCategory.exam.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.award)) {
      final awardRecords = await (_db.select(_db.awardRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.awardDate)]))
          .get();
      for (final r in awardRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.award.name,
          'time': r.awardDate,
          'title': _getAwardTitle(r),
          'subtitle': _getAwardSubtitle(r),
          'icon': RecordCategory.award.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.interest)) {
      final interestClassRecords = await (_db.select(_db.interestClassRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .get();
      for (final r in interestClassRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.interest.name,
          'time': r.startDate,
          'title': _getInterestClassTitle(r),
          'subtitle': _getInterestClassSubtitle(r),
          'icon': RecordCategory.interest.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.parentMeeting)) {
      final parentMeetingRecords = await (_db.select(_db.parentMeetingRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.meetingDate)]))
          .get();
      for (final r in parentMeetingRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.parentMeeting.name,
          'time': r.meetingDate,
          'title': _getParentMeetingTitle(r),
          'subtitle': _getParentMeetingSubtitle(r),
          'icon': RecordCategory.parentMeeting.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.personality)) {
      final personalityRecords = await (_db.select(_db.personalityRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.observationDate)]))
          .get();
      for (final r in personalityRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.personality.name,
          'time': r.observationDate,
          'title': _getPersonalityTitle(r),
          'subtitle': _getPersonalitySubtitle(r),
          'icon': RecordCategory.personality.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.emotion)) {
      final emotionRecords = await (_db.select(_db.emotionRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
          .get();
      for (final r in emotionRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.emotion.name,
          'time': r.recordTime,
          'title': _getEmotionTitle(r),
          'subtitle': _getEmotionSubtitle(r),
          'icon': RecordCategory.emotion.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.photo)) {
      final photoRecords = await (_db.select(_db.photoRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.captureDate)]))
          .get();
      for (final r in photoRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.photo.name,
          'time': r.captureDate,
          'title': _getPhotoTitle(r),
          'subtitle': _getPhotoSubtitle(r),
          'icon': RecordCategory.photo.icon,
          'imagePath': r.thumbnailPath ?? r.filePath,
        });
      }
    }

    if (shouldInclude(RecordCategory.audio)) {
      final audioRecords = await (_db.select(_db.audioRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
          .get();
      for (final r in audioRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.audio.name,
          'time': r.recordDate,
          'title': _getAudioTitle(r),
          'subtitle': _getAudioSubtitle(r),
          'icon': RecordCategory.audio.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.quote)) {
      final quoteRecords = await (_db.select(_db.quoteRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
          .get();
      for (final r in quoteRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.quote.name,
          'time': r.recordTime,
          'title': _getQuoteTitle(r),
          'subtitle': _getQuoteSubtitle(r),
          'icon': RecordCategory.quote.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.activity)) {
      final activityRecords = await (_db.select(_db.activityRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();
      for (final r in activityRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.activity.name,
          'time': r.startTime,
          'title': _getActivityTitle(r),
          'subtitle': _getActivitySubtitle(r),
          'icon': RecordCategory.activity.icon,
        });
      }
    }

    if (shouldInclude(RecordCategory.expense)) {
      final expenseRecords = await (_db.select(_db.expenseRecords)
            ..where((t) => t.babyId.equals(babyId))
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
          .get();
      for (final r in expenseRecords) {
        allRecords.add({
          'id': r.id,
          'category': RecordCategory.expense.name,
          'time': r.expenseDate,
          'title': _getExpenseTitle(r),
          'subtitle': _getExpenseSubtitle(r),
          'icon': RecordCategory.expense.icon,
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

  String _getStoolTitle(StoolRecord r) {
    return '大便记录';
  }

  String _getStoolSubtitle(StoolRecord r) {
    final parts = <String>[];
    final color = StoolColor.values[r.color];
    parts.add(switch (color) {
      StoolColor.brown => '棕色',
      StoolColor.yellow => '黄色',
      StoolColor.green => '绿色',
      StoolColor.black => '黑色',
      StoolColor.red => '红色',
      StoolColor.white => '白色',
      StoolColor.gray => '灰色',
    });
    final bristol = BristolType.values[r.bristolType];
    parts.add(switch (bristol) {
      BristolType.type1 => '干硬',
      BristolType.type2 => '硬块',
      BristolType.type3 => '香肠状',
      BristolType.type4 => '柔软光滑',
      BristolType.type5 => '软块',
      BristolType.type6 => '糊状',
      BristolType.type7 => '水样',
    });
    if (r.amount != null && r.amount!.isNotEmpty) {
      parts.add(r.amount!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getSkinTitle(SkinRecord r) {
    final condition = SkinCondition.values[r.condition];
    return switch (condition) {
      SkinCondition.eczema => '湿疹',
      SkinCondition.heatRash => '痱子',
      SkinCondition.diaperRash => '尿布疹',
      SkinCondition.acne => '痤疮',
      SkinCondition.dry => '干燥',
      SkinCondition.other => '皮肤问题',
    };
  }

  String _getSkinSubtitle(SkinRecord r) {
    final parts = <String>[];
    if (r.location != null && r.location!.isNotEmpty) {
      parts.add('位置: ${r.location}');
    }
    final severity = Severity.values[r.severity];
    parts.add(switch (severity) {
      Severity.mild => '轻度',
      Severity.moderate => '中度',
      Severity.severe => '重度',
    });
    if (r.treatment != null && r.treatment!.isNotEmpty) {
      parts.add('治疗: ${r.treatment}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getAllergyTitle(AllergyRecord r) {
    return '过敏: ${r.allergen}';
  }

  String _getAllergySubtitle(AllergyRecord r) {
    final parts = <String>[];
    parts.add(r.reaction);
    final severity = AllergySeverity.values[r.severity];
    parts.add(switch (severity) {
      AllergySeverity.mild => '轻度',
      AllergySeverity.moderate => '中度',
      AllergySeverity.severe => '重度',
      AllergySeverity.emergency => '紧急',
    });
    if (r.treatment != null && r.treatment!.isNotEmpty) {
      parts.add('治疗: ${r.treatment}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getDoctorVisitTitle(DoctorVisitRecord r) {
    return '就诊: ${r.department}';
  }

  String _getDoctorVisitSubtitle(DoctorVisitRecord r) {
    final parts = <String>[];
    parts.add(r.hospital);
    parts.add('诊断: ${r.diagnosis}');
    if (r.cost != null) {
      parts.add('费用: ¥${r.cost!.toStringAsFixed(0)}');
    }
    if (r.followUpDate != null) {
      parts.add('复诊: ${r.followUpDate!.month}/${r.followUpDate!.day}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getTeethTitle(TeethRecord r) {
    final eventType = TeethEventType.values[r.eventType];
    return switch (eventType) {
      TeethEventType.eruption => '长牙',
      TeethEventType.shedding => '换牙',
      TeethEventType.permanentEruption => '恒牙萌出',
      TeethEventType.checkup => '牙齿检查',
    };
  }

  String _getTeethSubtitle(TeethRecord r) {
    final parts = <String>[];
    parts.add(r.positionName);
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getVisionTitle(VisionRecord r) {
    return '视力检查';
  }

  String _getVisionSubtitle(VisionRecord r) {
    final parts = <String>[];
    parts.add('左眼: ${r.leftEye.toStringAsFixed(1)}');
    parts.add('右眼: ${r.rightEye.toStringAsFixed(1)}');
    if (r.leftEyeSpherical != null) {
      parts.add('左眼度数: ${r.leftEyeSpherical}');
    }
    if (r.rightEyeSpherical != null) {
      parts.add('右眼度数: ${r.rightEyeSpherical}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getSchoolTitle(SchoolRecord r) {
    final type = SchoolType.values[r.schoolType];
    return switch (type) {
      SchoolType.kindergarten => '幼儿园',
      SchoolType.primary => '小学',
      SchoolType.middle => '初中',
      SchoolType.high => '高中',
    };
  }

  String _getSchoolSubtitle(SchoolRecord r) {
    final parts = <String>[];
    parts.add(r.schoolName);
    parts.add('${r.grade}年级${r.className}');
    if (r.teacherName.isNotEmpty) {
      parts.add('班主任: ${r.teacherName}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getExamTitle(ExamRecord r) {
    return '${r.examName} - ${r.subject}';
  }

  String _getExamSubtitle(ExamRecord r) {
    final parts = <String>[];
    final examType = ExamType.values[r.examType];
    parts.add(switch (examType) {
      ExamType.unitTest => '单元测试',
      ExamType.midterm => '期中考试',
      ExamType.final => '期末考试',
      ExamType.competition => '竞赛',
      ExamType.quiz => '小测验',
    });
    if (r.fullScore != null) {
      parts.add('${r.score}/${r.fullScore}分');
    } else {
      parts.add('${r.score}分');
    }
    if (r.rank != null) {
      parts.add('排名: ${r.rank}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getAwardTitle(AwardRecord r) {
    return r.awardName;
  }

  String _getAwardSubtitle(AwardRecord r) {
    final parts = <String>[];
    final level = AwardLevel.values[r.awardLevel];
    parts.add(switch (level) {
      AwardLevel.school => '校级',
      AwardLevel.district => '区级',
      AwardLevel.city => '市级',
      AwardLevel.province => '省级',
      AwardLevel.national => '国家级',
      AwardLevel.international => '国际级',
    });
    parts.add(r.awardingOrganization);
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getInterestClassTitle(InterestClassRecord r) {
    final type = InterestType.values[r.interestType];
    return switch (type) {
      InterestType.piano => '钢琴',
      InterestType.dance => '舞蹈',
      InterestType.painting => '绘画',
      InterestType.go => '围棋',
      InterestType.programming => '编程',
      InterestType.sports => '体育',
      InterestType.music => '音乐',
      InterestType.art => '艺术',
      InterestType.english => '英语',
      InterestType.math => '数学',
      InterestType.other => '兴趣班',
    };
  }

  String _getInterestClassSubtitle(InterestClassRecord r) {
    final parts = <String>[];
    parts.add(r.className);
    parts.add(r.organization);
    if (r.level != null && r.level!.isNotEmpty) {
      parts.add('等级: ${r.level}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getParentMeetingTitle(ParentMeetingRecord r) {
    return '家长会';
  }

  String _getParentMeetingSubtitle(ParentMeetingRecord r) {
    final parts = <String>[];
    if (r.keyPoints != null && r.keyPoints!.isNotEmpty) {
      parts.add(r.keyPoints!);
    }
    if (r.improvementPlan != null && r.improvementPlan!.isNotEmpty) {
      parts.add('改进计划: ${r.improvementPlan}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getPersonalityTitle(PersonalityRecord r) {
    final trait = PersonalityTrait.values[r.trait];
    return switch (trait) {
      PersonalityTrait.bold => '胆大',
      PersonalityTrait.cautious => '谨慎',
      PersonalityTrait.extroverted => '外向',
      PersonalityTrait.introverted => '内向',
      PersonalityTrait.sensitive => '敏感',
      PersonalityTrait.resilient => '坚韧',
      PersonalityTrait.curious => '好奇',
      PersonalityTrait.creative => '创意',
      PersonalityTrait.patient => '耐心',
      PersonalityTrait.impulsive => '冲动',
    };
  }

  String _getPersonalitySubtitle(PersonalityRecord r) {
    final parts = <String>[];
    parts.add(r.description);
    if (r.context != null && r.context!.isNotEmpty) {
      parts.add('场景: ${r.context}');
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getEmotionTitle(EmotionRecord r) {
    final emotion = EmotionType.values[r.emotionType];
    return switch (emotion) {
      EmotionType.happy => '开心',
      EmotionType.sad => '难过',
      EmotionType.angry => '生气',
      EmotionType.anxious => '焦虑',
      EmotionType.excited => '兴奋',
      EmotionType.calm => '平静',
      EmotionType.jealous => '嫉妒',
      EmotionType.proud => '自豪',
      EmotionType.shy => '害羞',
      EmotionType.tired => '疲惫',
    };
  }

  String _getEmotionSubtitle(EmotionRecord r) {
    final parts = <String>[];
    if (r.triggerEvent != null && r.triggerEvent!.isNotEmpty) {
      parts.add('原因: ${r.triggerEvent}');
    }
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    if (r.note != null && r.note!.isNotEmpty) {
      parts.add(r.note!);
    }
    return parts.join(' · ');
  }

  String _getPhotoTitle(PhotoRecord r) {
    if (r.title != null && r.title!.isNotEmpty) {
      return r.title!;
    }
    return '照片记录';
  }

  String _getPhotoSubtitle(PhotoRecord r) {
    final parts = <String>[];
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    if (r.location != null && r.location!.isNotEmpty) {
      parts.add(r.location!);
    }
    parts.add('${r.width}×${r.height}');
    if (r.isFavorite) {
      parts.add('已收藏');
    }
    return parts.join(' · ');
  }

  String _getAudioTitle(AudioRecord r) {
    if (r.title != null && r.title!.isNotEmpty) {
      return r.title!;
    }
    return '声音记录';
  }

  String _getAudioSubtitle(AudioRecord r) {
    final parts = <String>[];
    final minutes = r.durationSeconds ~/ 60;
    final seconds = r.durationSeconds % 60;
    parts.add('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}');
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    if (r.isFavorite) {
      parts.add('已收藏');
    }
    return parts.join(' · ');
  }

  String _getQuoteTitle(QuoteRecord r) {
    if (r.content.length > 20) {
      return r.content.substring(0, 20) + '...';
    }
    return r.content;
  }

  String _getQuoteSubtitle(QuoteRecord r) {
    final parts = <String>[];
    final speakerLabels = {
      'baby': '宝宝',
      'dad': '爸爸',
      'mom': '妈妈',
      'grandma': '奶奶',
      'grandpa': '爷爷',
    };
    parts.add(speakerLabels[r.speaker] ?? r.speaker);
    if (r.emotion != null && r.emotion!.isNotEmpty) {
      parts.add(r.emotion!);
    }
    if (r.isFavorite) {
      parts.add('已收藏');
    }
    return parts.join(' · ');
  }

  String _getActivityTitle(ActivityRecord r) {
    final activityLabels = {
      'reading': '读绘本',
      'music': '听音乐',
      'massage': '做抚触',
      'swimming': '游泳',
      'outdoor': '户外活动',
      'game': '游戏',
      'tummyTime': '趴趴时间',
      'dancing': '跳舞',
      'cooking': '做饭',
      'craft': '手工',
      'painting': '画画',
      'puzzle': '拼图',
      'storytelling': '讲故事',
      'sports': '运动',
      'other': '互动',
    };
    return activityLabels[r.activityType] ?? r.activityType;
  }

  String _getActivitySubtitle(ActivityRecord r) {
    final parts = <String>[];
    if (r.endTime != null) {
      final duration = r.endTime!.difference(r.startTime).inMinutes;
      parts.add('${duration}分钟');
    } else {
      parts.add('进行中');
    }
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    return parts.join(' · ');
  }

  String _getExpenseTitle(ExpenseRecord r) {
    final categoryLabels = {
      'formula': '奶粉',
      'diaper': '尿布',
      'medical': '医疗',
      'education': '教育',
      'toy': '玩具',
      'clothing': '服装',
      'food': '食品',
      'transportation': '交通',
      'entertainment': '娱乐',
      'other': '其他',
    };
    return categoryLabels[r.category] ?? r.category;
  }

  String _getExpenseSubtitle(ExpenseRecord r) {
    final parts = <String>[];
    parts.add('¥${r.amount.toStringAsFixed(2)}');
    if (r.description != null && r.description!.isNotEmpty) {
      parts.add(r.description!);
    }
    return parts.join(' · ');
  }
}
