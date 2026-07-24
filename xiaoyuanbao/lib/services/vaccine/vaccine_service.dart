import '../../data/drift/app_database.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/tables/vaccine_records.dart';

class VaccineService {
  final AppDatabase _db;
  late final VaccineRepository _vaccineRepository;

  VaccineService(this._db) {
    _vaccineRepository = VaccineRepository(_db);
  }

  static const List<Map<String, dynamic>> _nationalVaccines = [
    {
      'name': '乙肝疫苗',
      'months': 0,
      'dose': 1,
      'totalDoses': 3,
      'disease': '乙型肝炎',
    },
    {
      'name': '卡介苗',
      'months': 0,
      'dose': 1,
      'totalDoses': 1,
      'disease': '结核病',
    },
    {
      'name': '乙肝疫苗',
      'months': 1,
      'dose': 2,
      'totalDoses': 3,
      'disease': '乙型肝炎',
    },
    {
      'name': '脊灰灭活疫苗',
      'months': 2,
      'dose': 1,
      'totalDoses': 4,
      'disease': '脊髓灰质炎',
    },
    {
      'name': '脊灰灭活疫苗',
      'months': 3,
      'dose': 2,
      'totalDoses': 4,
      'disease': '脊髓灰质炎',
    },
    {
      'name': '百白破疫苗',
      'months': 3,
      'dose': 1,
      'totalDoses': 4,
      'disease': '百日咳白喉破伤风',
    },
    {
      'name': '脊灰减毒活疫苗',
      'months': 4,
      'dose': 3,
      'totalDoses': 4,
      'disease': '脊髓灰质炎',
    },
    {
      'name': '百白破疫苗',
      'months': 4,
      'dose': 2,
      'totalDoses': 4,
      'disease': '百日咳白喉破伤风',
    },
    {
      'name': '百白破疫苗',
      'months': 5,
      'dose': 3,
      'totalDoses': 4,
      'disease': '百日咳白喉破伤风',
    },
    {
      'name': 'A群流脑多糖疫苗',
      'months': 6,
      'dose': 1,
      'totalDoses': 2,
      'disease': 'A群流脑',
    },
    {
      'name': '乙肝疫苗',
      'months': 6,
      'dose': 3,
      'totalDoses': 3,
      'disease': '乙型肝炎',
    },
    {
      'name': 'A群流脑多糖疫苗',
      'months': 9,
      'dose': 2,
      'totalDoses': 2,
      'disease': 'A群流脑',
    },
    {
      'name': '麻腮风疫苗',
      'months': 8,
      'dose': 1,
      'totalDoses': 2,
      'disease': '麻疹腮腺炎风疹',
    },
    {
      'name': '乙脑减毒活疫苗',
      'months': 8,
      'dose': 1,
      'totalDoses': 2,
      'disease': '流行性乙型脑炎',
    },
    {
      'name': '甲肝减毒活疫苗',
      'months': 18,
      'dose': 1,
      'totalDoses': 1,
      'disease': '甲型肝炎',
    },
    {
      'name': '百白破疫苗',
      'months': 18,
      'dose': 4,
      'totalDoses': 4,
      'disease': '百日咳白喉破伤风',
    },
    {
      'name': '麻腮风疫苗',
      'months': 18,
      'dose': 2,
      'totalDoses': 2,
      'disease': '麻疹腮腺炎风疹',
    },
    {
      'name': '乙脑减毒活疫苗',
      'months': 24,
      'dose': 2,
      'totalDoses': 2,
      'disease': '流行性乙型脑炎',
    },
    {
      'name': 'A群C群流脑多糖疫苗',
      'months': 36,
      'dose': 1,
      'totalDoses': 2,
      'disease': 'A群C群流脑',
    },
    {
      'name': 'A群C群流脑多糖疫苗',
      'months': 72,
      'dose': 2,
      'totalDoses': 2,
      'disease': 'A群C群流脑',
    },
    {
      'name': '脊灰减毒活疫苗',
      'months': 48,
      'dose': 4,
      'totalDoses': 4,
      'disease': '脊髓灰质炎',
    },
  ];

  static const List<Map<String, dynamic>> _optionalVaccines = [
    {
      'name': '13价肺炎疫苗',
      'disease': '肺炎球菌疾病',
    },
    {
      'name': '五联疫苗',
      'disease': '百日咳白喉破伤风脊髓灰质炎Hib',
    },
    {
      'name': '轮状病毒疫苗',
      'disease': '轮状病毒腹泻',
    },
    {
      'name': '手足口疫苗(EV71)',
      'disease': '手足口病',
    },
    {
      'name': '流感疫苗',
      'disease': '流行性感冒',
    },
    {
      'name': '水痘疫苗',
      'disease': '水痘',
    },
    {
      'name': 'Hib疫苗',
      'disease': 'B型流感嗜血杆菌感染',
    },
  ];

  Future<void> generateVaccineSchedule(String babyId, DateTime birthDate) async {
    final existingVaccines = await _vaccineRepository.getVaccinesByBabyId(babyId);
    if (existingVaccines.isNotEmpty) {
      return;
    }

    final vaccines = <VaccineRecordsCompanion>[];

    for (final vaccine in _nationalVaccines) {
      final months = vaccine['months'] as int;
      final scheduledDate = _calculateVaccineDate(birthDate, months);
      vaccines.add(
        VaccineRecordsCompanion.insert(
          vaccineName: vaccine['name'] as String,
          category: Value(VaccineCategoryEnum.national.index),
          status: Value(VaccineStatusEnum.scheduled.index),
          doseNumber: Value(vaccine['dose'] as int),
          totalDoses: Value(vaccine['totalDoses'] as int),
          scheduledDate: Value(scheduledDate),
          note: Value(vaccine['disease'] as String),
        ),
      );
    }

    await _vaccineRepository.batchInsertVaccines(babyId, vaccines);
  }

  DateTime _calculateVaccineDate(DateTime birthDate, int months) {
    int year = birthDate.year;
    int month = birthDate.month + months;
    int day = birthDate.day;

    while (month > 12) {
      year += 1;
      month -= 12;
    }

    if (day > 28) {
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      day = day > lastDayOfMonth ? lastDayOfMonth : day;
    }

    return DateTime(year, month, day);
  }

  String calculateVaccineDate(DateTime birthDate, int months) {
    final date = _calculateVaccineDate(birthDate, months);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<VaccineRecord>> getUpcomingVaccines(String babyId, {int days = 30}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    final allPending = await _vaccineRepository.getPendingVaccines(babyId);

    return allPending.where((vaccine) {
      if (vaccine.scheduledDate == null) return false;
      return vaccine.scheduledDate!.isAfter(now) &&
          vaccine.scheduledDate!.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<VaccineRecord?> getNextVaccine(String babyId) async {
    return _vaccineRepository.getNextVaccine(babyId);
  }

  Future<List<VaccineRecord>> getCompletedVaccines(String babyId) async {
    return _vaccineRepository.getCompletedVaccines(babyId);
  }

  Future<void> markVaccineCompleted(
    String vaccineId, {
    DateTime? vaccinationDate,
    String? hospital,
    String? batchNumber,
  }) async {
    await _vaccineRepository.markVaccineCompleted(
      vaccineId,
      vaccinationDate: vaccinationDate,
      hospital: hospital,
      batchNumber: batchNumber,
    );
  }

  Future<int> getCompletedCount(String babyId) async {
    final completed = await _vaccineRepository.getCompletedVaccines(babyId);
    return completed.length;
  }

  Future<int> getTotalCount(String babyId) async {
    final all = await _vaccineRepository.getVaccinesByBabyId(babyId);
    return all.length;
  }

  List<Map<String, dynamic>> getOptionalVaccines() {
    return _optionalVaccines;
  }

  List<Map<String, dynamic>> getNationalVaccines() {
    return _nationalVaccines;
  }
}
