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
import '../../data/drift/daos/time_capsule_repository.dart';
import '../../data/drift/daos/word_repository.dart';

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
  late final TimeCapsuleRepository _timeCapsuleRepo;
  late final WordRepository _wordRepo;

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
    _timeCapsuleRepo = TimeCapsuleRepository(_db);
    _wordRepo = WordRepository(_db);
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
      'timeCapsuleRecords': await _exportTimeCapsule(babyId),
      'wordRecords': await _exportWord(babyId),
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
    final records = await _feedingRepo.getFeedingsByDateRange(
      babyId,
      DateTime(2000),
      DateTime(2100),
    );
    return records.map((r) => {
      'id': r.id,
      'type': r.type,
      'amountMl': r.amountMl,
      'startTime': r.startTime.toIso8601String(),
      'endTime': r.endTime?.toIso8601String(),
      'breastSide': r.breastSide,
      'formulaBrand': r.formulaBrand,
      'foodName': r.foodName,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSleep(String babyId) async {
    final records = await _sleepRepo.getSleepsByDateRange(
      babyId,
      DateTime(2000),
      DateTime(2100),
    );
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
    final records = await _diaperRepo.getDiapersByDateRange(
      babyId,
      DateTime(2000),
      DateTime(2100),
    );
    return records.map((r) => {
      'id': r.id,
      'time': r.recordTime.toIso8601String(),
      'type': r.type,
      'stoolColor': r.stoolColor,
      'stoolConsistency': r.stoolConsistency,
      // 'amount': skipped - field not in DiaperRecords table,
      'hasRash': r.hasRash,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTemperature(String babyId) async {
    final records = await _tempRepo.getTemperaturesByDateRange(
      babyId,
      DateTime(2000),
      DateTime(2100),
    );
    return records.map((r) => {
      'id': r.id,
      'temperature': r.temperature,
      'site': r.site,
      'time': r.recordTime.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportMedication(String babyId) async {
    final records = await _medRepo.getMedicationsByDateRange(
      babyId,
      DateTime(2000),
      DateTime(2100),
    );
    return records.map((r) => {
      'id': r.id,
      'name': r.medicineName,
      'dose': r.dosage,
      'unit': r.unit,
      'time': r.recordTime.toIso8601String(),
      'reason': r.reason,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGrowth(String babyId) async {
    final records = await _growthRepo.getGrowthRecords(babyId);
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
    final records = await _vaccineRepo.getVaccinesByBabyId(babyId);
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
    final records = await _milestoneRepo.getMilestonesByBabyId(babyId);
    return records.map((r) => {
      'id': r.id,
      'category': r.category,
      'name': r.name,
      'description': r.description,
      'expectedAgeMonths': r.expectedAgeMonths,
      // 'actualAgeMonths': skipped - field not in MilestoneRecords table,
      'achieveDate': r.achieveDate?.toIso8601String(),
      'imagePath': r.imagePath,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDiary(String babyId) async {
    final records = await _diaryRepo.getDiariesByBabyId(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.recordDate.toIso8601String(),
      'title': r.title,
      'content': r.content,
      'mood': r.mood,
      'imagePaths': r.imagePaths,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportChat(String babyId) async {
    final messages = await _chatRepo.getRecentMessages(babyId, 1000);
    return messages.map((m) => {
      'id': m.id,
      'role': m.role,
      'content': m.content,
      'intent': m.intent,
      'timestamp': m.createdAt.toIso8601String(),
      'messageType': m.messageType,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportStool(String babyId) async {
    final records = await _stoolRepo.getAllStool(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.time.toIso8601String(),
      // 'frequency': skipped - field not in StoolRecords table,
      'color': r.color,
      'consistency': r.bristolType,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSkin(String babyId) async {
    final records = await _skinRepo.getAllSkin(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.time.toIso8601String(),
      'conditionType': r.condition,
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
      'firstOccurrence': r.firstOccurrence.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDoctorVisit(String babyId) async {
    final records = await _doctorVisitRepo.getAllDoctorVisits(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.visitDate.toIso8601String(),
      'hospital': r.hospital,
      // 'doctor': skipped - field not in DoctorVisitRecords table,
      // 'reason': skipped - field not in DoctorVisitRecords table,
      'department': r.department,
      'diagnosis': r.diagnosis,
      // 'treatment': skipped - field not in DoctorVisitRecords table,
      'prescription': r.prescription,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTeeth(String babyId) async {
    final records = await _teethRepo.getAllTeeth(babyId);
    return records.map((r) => {
      'id': r.id,
      'position': r.position,
      'eventDate': r.eventDate.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportVision(String babyId) async {
    final records = await _visionRepo.getAllVision(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.checkDate.toIso8601String(),
      'leftEye': r.leftEye,
      'rightEye': r.rightEye,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSchool(String babyId) async {
    final records = await _schoolRepo.getAllSchools(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.schoolName,
      'type': r.schoolType,
      'startDate': r.admissionDate.toIso8601String(),
      'endDate': r.graduationDate?.toIso8601String(),
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportExam(String babyId) async {
    final records = await _examRepo.getAllExams(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.examDate.toIso8601String(),
      'name': r.examName,
      'subject': r.subject,
      'score': r.score,
      'maxScore': r.fullScore,
      'rank': r.rank,
      // 'totalStudents': skipped - field not in ExamRecords table,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAward(String babyId) async {
    final records = await _awardRepo.getAllAwards(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.awardDate.toIso8601String(),
      'name': r.awardName,
      'level': r.awardLevel,
      // 'description': skipped - field not in AwardRecords table,
      'imagePath': r.certificatePath,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportInterestClass(String babyId) async {
    final records = await _interestClassRepo.getAllInterestClasses(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.className,
      'startDate': r.startDate.toIso8601String(),
      'endDate': r.endDate?.toIso8601String(),
      // 'frequency': skipped - field not in InterestClassRecords table,
      // 'cost': skipped - field not in InterestClassRecords table,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportParentMeeting(String babyId) async {
    final records = await _parentMeetingRepo.getAllParentMeetings(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.meetingDate.toIso8601String(),
      'teacher': r.teacherComments,
      'summary': r.keyPoints,
      'notes': r.note,
      'actionItems': r.improvementPlan,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportPersonality(String babyId) async {
    final records = await _personalityRepo.getAllPersonality(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.observationDate.toIso8601String(),
      'trait': r.trait,
      // 'rating': skipped - field not in PersonalityRecords table,
      'description': r.description,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportEmotion(String babyId) async {
    final records = await _emotionRepo.getAllEmotions(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.recordTime.toIso8601String(),
      'emotionType': r.emotionType,
      // 'intensity': skipped - field not in EmotionRecords table,
      'trigger': r.triggerEvent,
      'note': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportHobby(String babyId) async {
    final records = await _hobbyRepo.getAllHobbies(babyId);
    return records.map((r) => {
      'id': r.id,
      'name': r.hobbyName,
      'level': r.intensity,
      // 'startDate': skipped - field not in HobbyRecords table (uses startAgeMonths),
      'description': r.note,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportPhoto(String babyId) async {
    final records = await _photoRepo.getPhotosByBabyId(babyId);
    return records.map((r) => {
      'id': r.id,
      'path': r.filePath,
      'thumbnailPath': r.thumbnailPath,
      'date': r.captureDate.toIso8601String(),
      'caption': r.title,
      'location': r.location,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAudio(String babyId) async {
    final records = await _audioRepo.getAudiosByBabyId(babyId);
    return records.map((r) => {
      'id': r.id,
      'path': r.filePath,
      'date': r.recordDate.toIso8601String(),
      'title': r.title,
      'duration': r.durationSeconds,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportQuote(String babyId) async {
    final records = await _quoteRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'speaker': r.speaker,
      'content': r.content,
      'emotion': r.emotion,
      'date': r.recordTime.toIso8601String(),
      'isFavorite': r.isFavorite,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportActivity(String babyId) async {
    final records = await _activityRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'type': r.activityType,
      'startTime': r.startTime.toIso8601String(),
      // 'endTime': skipped - column not generated in ActivityRecords table,
      'description': r.description,
      // 'location': skipped - field not in ActivityRecords table,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGrowthMessage(String babyId) async {
    final records = await _growthMessageRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'age': r.age,
      'content': r.content,
      'audioPath': r.audioPath,
      'isLocked': r.isLocked,
      'unlockDate': r.unlockDate.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportExpense(String babyId) async {
    final records = await _expenseRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.expenseDate.toIso8601String(),
      'category': r.category,
      'amount': r.amount,
      'description': r.description,
      // 'note': skipped - field not in ExpenseRecords table,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportItem(String babyId) async {
    final records = await _itemRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'type': r.itemType,
      'brand': r.brand,
      'size': r.size,
      // 'purchaseDate': skipped - field not in ItemRecords table,
      'usageStartDate': r.startDate.toIso8601String(),
      // 'usageEndDate': skipped - endDate column not generated in ItemRecords table,
      // 'price': skipped - field not in ItemRecords table,
      'note': r.description,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSize(String babyId) async {
    final records = await _sizeRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'date': r.recordDate.toIso8601String(),
      'type': r.sizeType,
      'value': r.size,
      // 'note': skipped - field not in SizeRecords table,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTimeCapsule(String babyId) async {
    final records = await _timeCapsuleRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'title': r.title,
      'letter': r.letter,
      'photoPath': r.photoPath,
      'audioPath': r.audioPath,
      'videoPath': r.videoPath,
      'mood': r.mood,
      'sealedAt': r.sealedAt.toIso8601String(),
      'unlockAt': r.unlockAt.toIso8601String(),
      'isUnlocked': r.isUnlocked,
      'unlockedAt': r.unlockedAt?.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportWord(String babyId) async {
    final records = await _wordRepo.getAll(babyId);
    return records.map((r) => {
      'id': r.id,
      'word': r.word,
      'pinyin': r.pinyin,
      'context': r.context,
      'speaker': r.speaker,
      'category': r.category,
      'audioPath': r.audioPath,
      'firstSaidAt': r.firstSaidAt.toIso8601String(),
      'isFavorite': r.isFavorite,
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