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
import '../../data/drift/daos/stool_repository.dart';
import '../../data/drift/daos/skin_repository.dart';
import '../../data/drift/daos/allergy_repository.dart';
import '../../data/drift/daos/doctor_visit_repository.dart';
import '../../data/drift/daos/teeth_repository.dart';
import '../../data/drift/daos/vision_repository.dart';
import '../../data/drift/daos/school_repository.dart';
import '../../data/drift/daos/exam_repository.dart';
import '../../data/drift/daos/award_repository.dart';
import '../../data/drift/daos/interest_class_repository.dart';
import '../../data/drift/daos/parent_meeting_repository.dart';
import '../../data/drift/daos/personality_repository.dart';
import '../../data/drift/daos/emotion_repository.dart';
import '../../data/drift/daos/hobby_repository.dart';
import '../../data/drift/daos/photo_repository.dart';
import '../../data/drift/daos/audio_repository.dart';
import '../../data/drift/daos/quote_repository.dart';
import '../../data/drift/daos/activity_repository.dart';
import '../../data/drift/daos/growth_message_repository.dart';
import '../../data/drift/daos/expense_repository.dart';
import '../../data/drift/daos/item_repository.dart';
import '../../data/drift/daos/size_repository.dart';

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
  late final StoolRepository _stoolRepo;
  late final SkinRepository _skinRepo;
  late final AllergyRepository _allergyRepo;
  late final DoctorVisitRepository _doctorVisitRepo;
  late final TeethRepository _teethRepo;
  late final VisionRepository _visionRepo;
  late final SchoolRepository _schoolRepo;
  late final ExamRepository _examRepo;
  late final AwardRepository _awardRepo;
  late final InterestClassRepository _interestClassRepo;
  late final ParentMeetingRepository _parentMeetingRepo;
  late final PersonalityRepository _personalityRepo;
  late final EmotionRepository _emotionRepo;
  late final HobbyRepository _hobbyRepo;
  late final PhotoRepository _photoRepo;
  late final AudioRepository _audioRepo;
  late final QuoteRepository _quoteRepo;
  late final ActivityRepository _activityRepo;
  late final GrowthMessageRepository _growthMessageRepo;
  late final ExpenseRepository _expenseRepo;
  late final ItemRepository _itemRepo;
  late final SizeRepository _sizeRepo;

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
    _stoolRepo = StoolRepository(_db);
    _skinRepo = SkinRepository(_db);
    _allergyRepo = AllergyRepository(_db);
    _doctorVisitRepo = DoctorVisitRepository(_db);
    _teethRepo = TeethRepository(_db);
    _visionRepo = VisionRepository(_db);
    _schoolRepo = SchoolRepository(_db);
    _examRepo = ExamRepository(_db);
    _awardRepo = AwardRepository(_db);
    _interestClassRepo = InterestClassRepository(_db);
    _parentMeetingRepo = ParentMeetingRepository(_db);
    _personalityRepo = PersonalityRepository(_db);
    _emotionRepo = EmotionRepository(_db);
    _hobbyRepo = HobbyRepository(_db);
    _photoRepo = PhotoRepository(_db);
    _audioRepo = AudioRepository(_db);
    _quoteRepo = QuoteRepository(_db);
    _activityRepo = ActivityRepository(_db);
    _growthMessageRepo = GrowthMessageRepository(_db);
    _expenseRepo = ExpenseRepository(_db);
    _itemRepo = ItemRepository(_db);
    _sizeRepo = SizeRepository(_db);
  }

  Future<String> exportToJson(String babyId) async {
    final data = <String, dynamic>{
      'version': 2,
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
      'stoolRecords': await _exportStool(babyId),
      'skinRecords': await _exportSkin(babyId),
      'allergyRecords': await _exportAllergy(babyId),
      'doctorVisitRecords': await _exportDoctorVisit(babyId),
      'teethRecords': await _exportTeeth(babyId),
      'visionRecords': await _exportVision(babyId),
      'schoolRecords': await _exportSchool(babyId),
      'examRecords': await _exportExam(babyId),
      'awardRecords': await _exportAward(babyId),
      'interestClassRecords': await _exportInterestClass(babyId),
      'parentMeetingRecords': await _exportParentMeeting(babyId),
      'personalityRecords': await _exportPersonality(babyId),
      'emotionRecords': await _exportEmotion(babyId),
      'hobbyRecords': await _exportHobby(babyId),
      'photoRecords': await _exportPhoto(babyId),
      'audioRecords': await _exportAudio(babyId),
      'quoteRecords': await _exportQuote(babyId),
      'activityRecords': await _exportActivity(babyId),
      'growthMessageRecords': await _exportGrowthMessage(babyId),
      'expenseRecords': await _exportExpense(babyId),
      'itemRecords': await _exportItem(babyId),
      'sizeRecords': await _exportSize(babyId),
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

  Future<List<Map<String, dynamic>>> _exportStool(String babyId) async {
    final records = await _stoolRepo.getAllStool(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'frequency': r.frequency,
      'color': r.color,
      'consistency': r.consistency,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSkin(String babyId) async {
    final records = await _skinRepo.getAllSkin(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'conditionType': r.conditionType,
      'location': r.location,
      'severity': r.severity,
      'treatment': r.treatment,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAllergy(String babyId) async {
    final records = await _allergyRepo.getAllAllergies(babyId);
    return records.map((r) => {
      'id': r.id,
      'allergen': r.allergen,
      'reaction': r.reaction,
      'severity': r.severity,
      'firstOccurrence': r.firstOccurrence?.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDoctorVisit(String babyId) async {
    final records = await _doctorVisitRepo.getAllDoctorVisits(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'hospital': r.hospital,
      'doctor': r.doctor,
      'reason': r.reason,
      'diagnosis': r.diagnosis,
      'treatment': r.treatment,
      'prescription': r.prescription,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTeeth(String babyId) async {
    final records = await _teethRepo.getAllTeeth(babyId);
    return records.map((r) => {
      'id': r.id,
      'toothNumber': r.toothNumber,
      'eruptionDate': r.eruptionDate?.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportVision(String babyId) async {
    final records = await _visionRepo.getAllVision(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'leftEye': r.leftEye,
      'rightEye': r.rightEye,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSchool(String babyId) async {
    final records = await _schoolRepo.getAllSchools(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.name,
      'type': r.type,
      'startDate': r.startDate?.toIso8601String(),
      'endDate': r.endDate?.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportExam(String babyId) async {
    final records = await _examRepo.getAllExams(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'name': r.name,
      'subject': r.subject,
      'score': r.score,
      'maxScore': r.maxScore,
      'rank': r.rank,
      'totalStudents': r.totalStudents,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAward(String babyId) async {
    final records = await _awardRepo.getAllAwards(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'name': r.name,
      'level': r.level,
      'description': r.description,
      'imagePath': r.imagePath,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportInterestClass(String babyId) async {
    final records = await _interestClassRepo.getAllInterestClasses(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.name,
      'startDate': r.startDate?.toIso8601String(),
      'endDate': r.endDate?.toIso8601String(),
      'frequency': r.frequency,
      'cost': r.cost,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportParentMeeting(String babyId) async {
    final records = await _parentMeetingRepo.getAllParentMeetings(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'teacher': r.teacher,
      'summary': r.summary,
      'notes': r.notes,
      'actionItems': r.actionItems,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportPersonality(String babyId) async {
    final records = await _personalityRepo.getAllPersonality(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'trait': r.trait,
      'rating': r.rating,
      'description': r.description,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportEmotion(String babyId) async {
    final records = await _emotionRepo.getAllEmotions(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'emotionType': r.emotionType,
      'intensity': r.intensity,
      'trigger': r.trigger,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportHobby(String babyId) async {
    final records = await _hobbyRepo.getAllHobbies(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.name,
      'level': r.level,
      'startDate': r.startDate?.toIso8601String(),
      'description': r.description,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportPhoto(String babyId) async {
    final records = await _photoRepo.getAllPhotos(babyId);
    return records.map((r) => {
      'id': r.id,
      'path': r.path,
      'thumbnailPath': r.thumbnailPath,
      'date': r.date.toIso8601String(),
      'caption': r.caption,
      'location': r.location,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAudio(String babyId) async {
    final records = await _audioRepo.getAllAudios(babyId);
    return records.map((r) => {
      'id': r.id,
      'path': r.path,
      'date': r.date.toIso8601String(),
      'title': r.title,
      'duration': r.duration,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportQuote(String babyId) async {
    final records = await _quoteRepo.getAllQuotes(babyId);
    return records.map((r) => {
      'id': r.id,
      'speaker': r.speaker,
      'content': r.content,
      'emotion': r.emotion,
      'date': r.date.toIso8601String(),
      'isFavorite': r.isFavorite,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportActivity(String babyId) async {
    final records = await _activityRepo.getAllActivities(babyId);
    return records.map((r) => {
      'id': r.id,
      'type': r.type,
      'startTime': r.startTime.toIso8601String(),
      'endTime': r.endTime?.toIso8601String(),
      'description': r.description,
      'location': r.location,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGrowthMessage(String babyId) async {
    final records = await _growthMessageRepo.getAllGrowthMessages(babyId);
    return records.map((r) => {
      'id': r.id,
      'age': r.age,
      'content': r.content,
      'audioPath': r.audioPath,
      'isLocked': r.isLocked,
      'unlockDate': r.unlockDate?.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportExpense(String babyId) async {
    final records = await _expenseRepo.getAllExpenses(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'category': r.category,
      'amount': r.amount,
      'description': r.description,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportItem(String babyId) async {
    final records = await _itemRepo.getAllItems(babyId);
    return records.map((r) => {
      'id': r.id,
      'type': r.type,
      'brand': r.brand,
      'size': r.size,
      'purchaseDate': r.purchaseDate?.toIso8601String(),
      'usageStartDate': r.usageStartDate?.toIso8601String(),
      'usageEndDate': r.usageEndDate?.toIso8601String(),
      'price': r.price,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSize(String babyId) async {
    final records = await _sizeRepo.getAllSizes(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'type': r.type,
      'value': r.value,
      'note': r.note,
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

  Future<List<String>> listBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.json') && f.path.contains('xiaoyuanbao_backup'),
    ).toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.map((f) => f.path).toList();
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