import '../../data/drift/app_database.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/diaper_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/medication_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../core/utils/date_time_utils.dart';

class DailySummary {
  final DateTime date;
  final String ageLabel;
  final int feedingCount;
  final double totalMilkMl;
  final int sleepCount;
  final int totalSleepMinutes;
  final int diaperCount;
  final int dirtyDiaperCount;
  final int temperatureCount;
  final double? maxTemperature;
  final int milestoneCount;
  final List<String> milestoneNames;
  final int diaryCount;
  final int vaccineCount;
  final List<String> vaccineNames;

  DailySummary({
    required this.date,
    required this.ageLabel,
    required this.feedingCount,
    required this.totalMilkMl,
    required this.sleepCount,
    required this.totalSleepMinutes,
    required this.diaperCount,
    required this.dirtyDiaperCount,
    required this.temperatureCount,
    this.maxTemperature,
    required this.milestoneCount,
    required this.milestoneNames,
    required this.diaryCount,
    required this.vaccineCount,
    required this.vaccineNames,
  });
}

class WeeklySummary {
  final DateTime startDate;
  final DateTime endDate;
  final String ageLabel;
  final int feedingCount;
  final double totalMilkMl;
  final double avgDailyFeeding;
  final int sleepCount;
  final int totalSleepMinutes;
  final double avgDailySleepMinutes;
  final int diaperCount;
  final int dirtyDiaperCount;
  final double avgDailyDiaper;
  final int temperatureCount;
  final double? maxTemperature;
  final int milestoneCount;
  final List<String> milestoneNames;
  final int diaryCount;
  final int vaccineCount;
  final List<String> vaccineNames;
  final double? weightChange;
  final double? heightChange;
  final List<String> highlights;

  WeeklySummary({
    required this.startDate,
    required this.endDate,
    required this.ageLabel,
    required this.feedingCount,
    required this.totalMilkMl,
    required this.avgDailyFeeding,
    required this.sleepCount,
    required this.totalSleepMinutes,
    required this.avgDailySleepMinutes,
    required this.diaperCount,
    required this.dirtyDiaperCount,
    required this.avgDailyDiaper,
    required this.temperatureCount,
    this.maxTemperature,
    required this.milestoneCount,
    required this.milestoneNames,
    required this.diaryCount,
    required this.vaccineCount,
    required this.vaccineNames,
    this.weightChange,
    this.heightChange,
    required this.highlights,
  });
}

class SummaryService {
  final AppDatabase _db;
  late final FeedingRepository _feedingRepository;
  late final SleepRepository _sleepRepository;
  late final DiaperRepository _diaperRepository;
  late final TemperatureRepository _temperatureRepository;
  late final MedicationRepository _medicationRepository;
  late final MilestoneRepository _milestoneRepository;
  late final VaccineRepository _vaccineRepository;
  late final DiaryRepository _diaryRepository;
  late final GrowthRepository _growthRepository;
  late final BabyRepository _babyRepository;

  SummaryService(this._db) {
    _feedingRepository = FeedingRepository(_db);
    _sleepRepository = SleepRepository(_db);
    _diaperRepository = DiaperRepository(_db);
    _temperatureRepository = TemperatureRepository(_db);
    _medicationRepository = MedicationRepository(_db);
    _milestoneRepository = MilestoneRepository(_db);
    _vaccineRepository = VaccineRepository(_db);
    _diaryRepository = DiaryRepository(_db);
    _growthRepository = GrowthRepository(_db);
    _babyRepository = BabyRepository(_db);
  }

  Future<DailySummary> getDailySummary(String babyId, DateTime date) async {
    final start = DateTimeUtils.startOfDay(date);
    final end = DateTimeUtils.endOfDay(date);

    final baby = await _babyRepository.getBabyById(babyId);
    String ageLabel = '';
    if (baby != null) {
      final age = DateTimeUtils.calculateAge(baby.birthDate, now: date);
      ageLabel = '${age.years}岁${age.months}月${age.days}天';
    }

    final feedingStats = await _feedingRepository.getDailyStats(babyId, date);
    final sleepStats = await _sleepRepository.getDailyStats(babyId, date);
    final diaperStats = await _diaperRepository.getDailyStats(babyId, date);

    final temps = await _temperatureRepository.getTemperaturesByDateRange(
      babyId,
      start,
      end,
    );
    double? maxTemp;
    if (temps.isNotEmpty) {
      maxTemp = temps.map((t) => t.temperature).reduce((a, b) => a > b ? a : b);
    }

    final milestones = await _milestoneRepository.getMilestonesByBabyId(babyId);
    final dayMilestones = milestones.where((m) {
      if (m.achieveDate == null) return false;
      return DateTimeUtils.isSameDay(m.achieveDate!, date);
    }).toList();

    final vaccines = await _vaccineRepository.getVaccinesByBabyId(babyId);
    final dayVaccines = vaccines.where((v) {
      if (v.vaccinationDate == null) return false;
      return DateTimeUtils.isSameDay(v.vaccinationDate!, date);
    }).toList();

    final diaries = await _diaryRepository.getDiariesByDateRange(
      babyId,
      start,
      end,
    );

    return DailySummary(
      date: date,
      ageLabel: ageLabel,
      feedingCount: feedingStats['count'] as int? ?? 0,
      totalMilkMl: (feedingStats['totalAmount'] as num?)?.toDouble() ?? 0,
      sleepCount: sleepStats['count'] as int? ?? 0,
      totalSleepMinutes: sleepStats['totalDurationMinutes'] as int? ?? 0,
      diaperCount: diaperStats['count'] as int? ?? 0,
      dirtyDiaperCount: (diaperStats['dirtyCount'] as int? ?? 0) +
          (diaperStats['mixedCount'] as int? ?? 0),
      temperatureCount: temps.length,
      maxTemperature: maxTemp,
      milestoneCount: dayMilestones.length,
      milestoneNames: dayMilestones.map((m) => m.name).toList(),
      diaryCount: diaries.length,
      vaccineCount: dayVaccines.length,
      vaccineNames: dayVaccines.map((v) => v.vaccineName).toList(),
    );
  }

  Future<String> generateDailySummaryText(
    String babyId,
    DateTime date, {
    String babyName = '小元宝',
  }) async {
    final summary = await getDailySummary(babyId, date);
    final dateStr = DateTimeUtils.formatDateCn(date);

    final buffer = StringBuffer();
    buffer.writeln('🌟 $babyName 的 $dateStr');
    buffer.writeln('今天是你出生后的第 ${summary.ageLabel} 日子呀~');
    buffer.writeln('');

    final hasData = summary.feedingCount > 0 ||
        summary.sleepCount > 0 ||
        summary.diaperCount > 0 ||
        summary.milestoneCount > 0 ||
        summary.diaryCount > 0 ||
        summary.vaccineCount > 0;

    if (!hasData) {
      buffer.writeln('今天还没有记录呢~ 📝');
      buffer.writeln('明天也要记得记录宝宝的点点滴滴哦！');
      buffer.writeln('');
      buffer.writeln('愿 $babyName 每天都健康快乐成长 💖');
      return buffer.toString();
    }

    buffer.writeln('🍼 喂养小记');
    if (summary.feedingCount > 0) {
      buffer.writeln('今天喂了 ${summary.feedingCount} 次');
      if (summary.totalMilkMl > 0) {
        buffer.writeln('一共喝了 ${summary.totalMilkMl.toStringAsFixed(0)}ml 奶');
      }
      buffer.writeln('宝宝吃得香香，长得棒棒~');
    } else {
      buffer.writeln('今天还没有喂养记录呢');
    }
    buffer.writeln('');

    buffer.writeln('😴 睡眠时光');
    if (summary.sleepCount > 0) {
      final hours = summary.totalSleepMinutes ~/ 60;
      final mins = summary.totalSleepMinutes % 60;
      buffer.writeln('睡了 ${summary.sleepCount} 次');
      buffer.writeln('总共睡了 $hours 小时 $mins 分钟');
      buffer.writeln('睡得好才能长高高哦~');
    } else {
      buffer.writeln('今天还没有睡眠记录呢');
    }
    buffer.writeln('');

    buffer.writeln('👶 尿布日记');
    if (summary.diaperCount > 0) {
      buffer.writeln('换了 ${summary.diaperCount} 次尿布');
      if (summary.dirtyDiaperCount > 0) {
        buffer.writeln('其中有 ${summary.dirtyDiaperCount} 次便便');
      }
      buffer.writeln('小屁股干干净净，舒服极了~');
    } else {
      buffer.writeln('今天还没有尿布记录呢');
    }
    buffer.writeln('');

    if (summary.temperatureCount > 0) {
      buffer.writeln('🌡️ 体温记录');
      buffer.writeln('量了 ${summary.temperatureCount} 次体温');
      if (summary.maxTemperature != null) {
        final temp = summary.maxTemperature!.toStringAsFixed(1);
        buffer.writeln('最高体温 $temp°C');
        if (summary.maxTemperature! >= 37.5) {
          buffer.writeln('宝宝有点发烧，要多注意哦~');
        } else {
          buffer.writeln('体温正常，身体棒棒~');
        }
      }
      buffer.writeln('');
    }

    final highlights = <String>[];
    if (summary.milestoneCount > 0) {
      highlights.add('🏆 达成了 ${summary.milestoneCount} 个里程碑：${summary.milestoneNames.join('、')}');
    }
    if (summary.vaccineCount > 0) {
      highlights.add('💉 接种了 ${summary.vaccineCount} 剂疫苗：${summary.vaccineNames.join('、')}');
    }
    if (summary.diaryCount > 0) {
      highlights.add('📝 写了 ${summary.diaryCount} 篇日记');
    }

    if (highlights.isNotEmpty) {
      buffer.writeln('✨ 今日亮点');
      for (final h in highlights) {
        buffer.writeln(h);
      }
      buffer.writeln('');
    }

    buffer.writeln('💖 给宝宝的话');
    if (summary.milestoneCount > 0) {
      buffer.writeln('恭喜我的小宝贝又学会了新本领！每一次进步都让爸爸妈妈好开心~');
    } else if (summary.vaccineCount > 0) {
      buffer.writeln('今天打疫苗的宝宝勇敢极了！虽然有点疼，但这是在保护你哦~');
    } else if (summary.temperatureCount > 0 && (summary.maxTemperature ?? 0) >= 37.5) {
      buffer.writeln('宝宝今天不舒服了，心疼坏了~ 快快好起来，爸爸妈妈陪着你！');
    } else {
      buffer.writeln('又是平凡又美好的一天，能陪伴你长大，真好~');
    }
    buffer.writeln('');
    buffer.writeln('晚安，我的小宝贝 $babyName 🌙');
    buffer.writeln('明天也要继续健康快乐地长大哦~');

    final text = buffer.toString();
    if (text.length > 300) {
      return text.substring(0, 297) + '...';
    }
    return text;
  }

  Future<WeeklySummary> getWeeklySummary(String babyId, DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final start = DateTimeUtils.startOfDay(startOfWeek);
    final end = DateTimeUtils.endOfDay(startOfWeek.add(const Duration(days: 6)));

    final baby = await _babyRepository.getBabyById(babyId);
    String ageLabel = '';
    if (baby != null) {
      final age = DateTimeUtils.calculateAge(baby.birthDate, now: end);
      ageLabel = '${age.years}岁${age.months}月${age.days}天';
    }

    int totalFeeding = 0;
    double totalMilk = 0;
    int totalSleep = 0;
    int totalSleepCount = 0;
    int totalDiaper = 0;
    int totalDirtyDiaper = 0;
    int totalTemp = 0;
    double? maxTemp;

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final feedingStats = await _feedingRepository.getDailyStats(babyId, day);
      totalFeeding += feedingStats['count'] as int? ?? 0;
      totalMilk += (feedingStats['totalAmount'] as num?)?.toDouble() ?? 0;

      final sleepStats = await _sleepRepository.getDailyStats(babyId, day);
      totalSleep += sleepStats['totalDurationMinutes'] as int? ?? 0;
      totalSleepCount += sleepStats['count'] as int? ?? 0;

      final diaperStats = await _diaperRepository.getDailyStats(babyId, day);
      totalDiaper += diaperStats['count'] as int? ?? 0;
      totalDirtyDiaper += (diaperStats['dirtyCount'] as int? ?? 0) +
          (diaperStats['mixedCount'] as int? ?? 0);
    }

    final temps = await _temperatureRepository.getTemperaturesByDateRange(
      babyId,
      start,
      end,
    );
    totalTemp = temps.length;
    if (temps.isNotEmpty) {
      maxTemp = temps.map((t) => t.temperature).reduce((a, b) => a > b ? a : b);
    }

    final milestones = await _milestoneRepository.getMilestonesByBabyId(babyId);
    final weekMilestones = milestones.where((m) {
      if (m.achieveDate == null) return false;
      return m.achieveDate!.isAfter(start.subtract(const Duration(seconds: 1))) &&
          m.achieveDate!.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    final vaccines = await _vaccineRepository.getVaccinesByBabyId(babyId);
    final weekVaccines = vaccines.where((v) {
      if (v.vaccinationDate == null) return false;
      return v.vaccinationDate!.isAfter(start.subtract(const Duration(seconds: 1))) &&
          v.vaccinationDate!.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    final diaries = await _diaryRepository.getDiariesByDateRange(
      babyId,
      start,
      end,
    );

    final growthRecords = await _growthRepository.getGrowthByDateRange(
      babyId,
      start.subtract(const Duration(days: 30)),
      end,
    );
    growthRecords.sort((a, b) => a.recordDate.compareTo(b.recordDate));

    double? weightChange;
    double? heightChange;
    if (growthRecords.length >= 2) {
      final first = growthRecords.first;
      final last = growthRecords.last;
      if (first.weight != null && last.weight != null) {
        weightChange = last.weight! - first.weight!;
      }
      if (first.height != null && last.height != null) {
        heightChange = last.height! - first.height!;
      }
    }

    final highlights = <String>[];
    if (weekMilestones.isNotEmpty) {
      highlights.add('达成 ${weekMilestones.length} 个里程碑');
    }
    if (weekVaccines.isNotEmpty) {
      highlights.add('接种 ${weekVaccines.length} 剂疫苗');
    }
    if (diaries.isNotEmpty) {
      highlights.add('写了 ${diaries.length} 篇日记');
    }
    if (weightChange != null && weightChange > 0) {
      highlights.add('体重增长了 ${weightChange.toStringAsFixed(2)}kg');
    }
    if (heightChange != null && heightChange > 0) {
      highlights.add('身高增长了 ${heightChange.toStringAsFixed(1)}cm');
    }

    return WeeklySummary(
      startDate: start,
      endDate: end,
      ageLabel: ageLabel,
      feedingCount: totalFeeding,
      totalMilkMl: totalMilk,
      avgDailyFeeding: totalFeeding / 7,
      sleepCount: totalSleepCount,
      totalSleepMinutes: totalSleep,
      avgDailySleepMinutes: totalSleep / 7,
      diaperCount: totalDiaper,
      dirtyDiaperCount: totalDirtyDiaper,
      avgDailyDiaper: totalDiaper / 7,
      temperatureCount: totalTemp,
      maxTemperature: maxTemp,
      milestoneCount: weekMilestones.length,
      milestoneNames: weekMilestones.map((m) => m.name).toList(),
      diaryCount: diaries.length,
      vaccineCount: weekVaccines.length,
      vaccineNames: weekVaccines.map((v) => v.vaccineName).toList(),
      weightChange: weightChange,
      heightChange: heightChange,
      highlights: highlights,
    );
  }
}
