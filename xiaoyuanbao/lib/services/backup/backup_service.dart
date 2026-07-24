import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/drift/app_database.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/diaper_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/medication_repository.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/ai_chat_repository.dart';
import '../../data/drift/daos/settings_repository.dart';

class BackupService {
  final AppDatabase _db;
  late final BabyRepository _babyRepo;
  late final FeedingRepository _feedingRepo;
  late final SleepRepository _sleepRepo;
  late final DiaperRepository _diaperRepo;
  late final TemperatureRepository _tempRepo;
  late final MedicationRepository _medRepo;
  late final GrowthRepository _growthRepo;
  late final VaccineRepository _vaccineRepo;
  late final MilestoneRepository _milestoneRepo;
  late final DiaryRepository _diaryRepo;
  late final AiChatRepository _chatRepo;
  late final SettingsRepository _settingsRepo;

  BackupService(this._db) {
    _babyRepo = BabyRepository(_db);
    _feedingRepo = FeedingRepository(_db);
    _sleepRepo = SleepRepository(_db);
    _diaperRepo = DiaperRepository(_db);
    _tempRepo = TemperatureRepository(_db);
    _medRepo = MedicationRepository(_db);
    _growthRepo = GrowthRepository(_db);
    _vaccineRepo = VaccineRepository(_db);
    _milestoneRepo = MilestoneRepository(_db);
    _diaryRepo = DiaryRepository(_db);
    _chatRepo = AiChatRepository(_db);
    _settingsRepo = SettingsRepository(_db);
  }

  Future<String> exportToJson(String babyId) async {
    final data = <String, dynamic>{
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'baby': await _exportBaby(babyId),
      'feedingRecords': await _exportFeeding(babyId),
      'sleepRecords': await _exportSleep(babyId),
      'diaperRecords': await _exportDiaper(babyId),
      'temperatureRecords': await _exportTemperature(babyId),
      'medicationRecords': await _exportMedication(babyId),
      'growthRecords': await _exportGrowth(babyId),
      'vaccineRecords': await _exportVaccine(babyId),
      'milestoneRecords': await _exportMilestone(babyId),
      'diaryRecords': await _exportDiary(babyId),
      'chatMessages': await _exportChat(babyId),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<Map<String, dynamic>> _exportBaby(String babyId) async {
    final baby = await _babyRepo.getBabyById(babyId);
    if (baby == null) return {};
    return {
      'id': baby.id,
      'name': baby.name,
      'gender': baby.gender,
      'birthDate': baby.birthDate.toIso8601String(),
      'birthWeight': baby.birthWeight,
      'birthHeight': baby.birthHeight,
      'birthHeadCircumference': baby.birthHeadCircumference,
      'bloodType': baby.bloodType,
      'fatherHeight': baby.fatherHeight,
      'motherHeight': baby.motherHeight,
      'avatarPath': baby.avatarPath,
    };
  }

  Future<List<Map<String, dynamic>>> _exportFeeding(String babyId) async {
    final records = await _feedingRepo.getAllFeeding(babyId);
    return records.map((r) => {
      'id': r.id,
      'type': r.type,
      'amountMl': r.amountMl,
      'startTime': r.startTime.toIso8601String(),
      'endTime': r.endTime?.toIso8601String(),
      'breastSide': r.breastSide,
      'formulaBrand': r.formulaBrand,
      'solidFoodType': r.solidFoodType,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSleep(String babyId) async {
    final records = await _sleepRepo.getAllSleep(babyId);
    return records.map((r) => {
      'id': r.id,
      'startTime': r.startTime.toIso8601String(),
      'endTime': r.endTime?.toIso8601String(),
      'type': r.type,
      'location': r.location,
      'quality': r.quality,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDiaper(String babyId) async {
    final records = await _diaperRepo.getAllDiaper(babyId);
    return records.map((r) => {
      'id': r.id,
      'time': r.time.toIso8601String(),
      'type': r.type,
      'stoolColor': r.stoolColor,
      'stoolConsistency': r.stoolConsistency,
      'amount': r.amount,
      'rash': r.rash,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTemperature(String babyId) async {
    final records = await _tempRepo.getAllTemperature(babyId);
    return records.map((r) => {
      'id': r.id,
      'temperature': r.temperature,
      'site': r.site,
      'time': r.time.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportMedication(String babyId) async {
    final records = await _medRepo.getAllMedication(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.medicationName,
      'dose': r.dose,
      'unit': r.unit,
      'time': r.time.toIso8601String(),
      'reason': r.reason,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGrowth(String babyId) async {
    final records = await _growthRepo.getAllGrowth(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.recordDate.toIso8601String(),
      'weight': r.weight,
      'height': r.height,
      'headCircumference': r.headCircumference,
      'bmi': r.bmi,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportVaccine(String babyId) async {
    final records = await _vaccineRepo.getAllVaccines(babyId);
    return records.map((r) => {
      'id': r.id,
      'vaccineName': r.vaccineName,
      'vaccineCode': r.vaccineCode,
      'category': r.category,
      'status': r.status,
      'doseNumber': r.doseNumber,
      'totalDoses': r.totalDoses,
      'scheduledDate': r.scheduledDate?.toIso8601String(),
      'vaccinationDate': r.vaccinationDate?.toIso8601String(),
      'batchNumber': r.batchNumber,
      'manufacturer': r.manufacturer,
      'hospital': r.hospital,
      'site': r.site,
      'reaction': r.reaction,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportMilestone(String babyId) async {
    final records = await _milestoneRepo.getAllMilestones(babyId);
    return records.map((r) => {
      'id': r.id,
      'category': r.category,
      'title': r.title,
      'description': r.description,
      'expectedAgeMonths': r.expectedAgeMonths,
      'actualAgeMonths': r.actualAgeMonths,
      'achieveDate': r.achieveDate?.toIso8601String(),
      'imagePath': r.imagePath,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDiary(String babyId) async {
    final records = await _diaryRepo.getAllDiary(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'title': r.title,
      'content': r.content,
      'mood': r.mood,
      'imagePaths': r.imagePaths,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportChat(String babyId) async {
    final messages = await _chatRepo.getRecentMessages(babyId, limit: 1000);
    return messages.map((m) => {
      'id': m.id,
      'role': m.role,
      'content': m.content,
      'intent': m.intent,
      'timestamp': m.timestamp.toIso8601String(),
      'messageType': m.messageType,
    }).toList();
  }

  Future<String> saveBackupToFile(String babyId) async {
    final jsonStr = await exportToJson(babyId);
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(directory.path, 'xiaoyuanbao_backup_$timestamp.json'));
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<bool> importFromJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      if (data['baby'] == null) return false;
      
      final babyData = data['baby'] as Map<String, dynamic>;
      final babyId = babyData['id'] as String;
      
      final existing = await _babyRepo.getBabyById(babyId);
      if (existing != null) {
        return false;
      }
      
      await _babyRepo.addBaby(
        name: babyData['name'] as String,
        gender: babyData['gender'] as int,
        birthDate: DateTime.parse(babyData['birthDate'] as String),
        birthWeight: (babyData['birthWeight'] as num?)?.toDouble(),
        birthHeight: (babyData['birthHeight'] as num?)?.toDouble(),
        bloodType: babyData['bloodType'] as String?,
        fatherHeight: (babyData['fatherHeight'] as num?)?.toDouble(),
        motherHeight: (babyData['motherHeight'] as num?)?.toDouble(),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
