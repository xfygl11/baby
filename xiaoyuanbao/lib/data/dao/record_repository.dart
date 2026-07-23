import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../drift/app_database.dart';
import '../drift/tables/growth_records.dart';
import '../drift/tables/vaccine_records.dart';
import '../drift/tables/diaper_records.dart';
import '../drift/tables/diary_records.dart';
import '../drift/tables/milestone_records.dart';
import '../drift/tables/bath_records.dart';
import '../drift/tables/medicine_records.dart';
import '../drift/tables/ai_chat_messages.dart';
import '../drift/tables/ai_interaction_logs.dart';

class GrowthRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addRecord({
    required String babyId,
    required int type,
    required double value,
    required DateTime recordDate,
    double? percentile,
    String? zScore,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.growthRecords).insert(
          GrowthRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            value: value,
            recordDate: recordDate,
            percentile: Value(percentile),
            zScore: Value(zScore),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<GrowthRecord>> getRecords(String babyId, {int? type, int limit = 100}) async {
    final query = _db.select(_db.growthRecords)
      ..where((t) => t.babyId.equals(babyId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    if (type != null) query.where((t) => t.type.equals(type));
    return query.get();
  }

  Stream<List<GrowthRecord>> watchRecords(String babyId, {int? type}) {
    final query = _db.select(_db.growthRecords)
      ..where((t) => t.babyId.equals(babyId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    if (type != null) query.where((t) => t.type.equals(type));
    return query.watch();
  }

  Future<GrowthRecord?> getLatestRecord(String babyId, int type) async {
    return (_db.select(_db.growthRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.type.equals(type))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteRecord(String id) async {
    await (_db.update(_db.growthRecords)..where((t) => t.id.equals(id))).write(
          GrowthRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

class VaccineRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addVaccine({
    required String babyId,
    required String vaccineName,
    required int status,
    int category = 0,
    int doseNumber = 1,
    int totalDoses = 1,
    DateTime? scheduledDate,
    DateTime? vaccinationDate,
    String? vaccineCode,
    String? batchNumber,
    String? manufacturer,
    String? hospital,
    String? note,
    bool reminderEnabled = false,
    int? reminderDays,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.vaccineRecords).insert(
          VaccineRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            vaccineName: vaccineName,
            status: status,
            category: Value(category),
            doseNumber: doseNumber,
            totalDoses: totalDoses,
            scheduledDate: Value(scheduledDate),
            vaccinationDate: Value(vaccinationDate),
            vaccineCode: Value(vaccineCode),
            batchNumber: Value(batchNumber),
            manufacturer: Value(manufacturer),
            hospital: Value(hospital),
            note: Value(note),
            reminderEnabled: Value(reminderEnabled),
            reminderDays: Value(reminderDays),
          ),
        );
    return id;
  }

  Future<List<VaccineRecord>> getAllVaccines(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
            (t) => OrderingTerm.asc(t.doseNumber),
          ]))
        .get();
  }

  Stream<List<VaccineRecord>> watchAllVaccines(String babyId) {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
            (t) => OrderingTerm.asc(t.doseNumber),
          ]))
        .watch();
  }

  Future<List<VaccineRecord>> getPendingVaccines(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.status.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();
  }

  Future<VaccineRecord?> getNextVaccine(String babyId) async {
    final pending = await getPendingVaccines(babyId);
    if (pending.isEmpty) return null;
    return pending.first;
  }

  Future<int> getPendingCount(String babyId) async {
    final result = await _db.customSelect(
      'SELECT COUNT(*) as count FROM vaccine_records '
      'WHERE baby_id = ? AND is_deleted = 0 AND status = 0',
      variables: [Variable.withString(babyId)],
    ).getSingle();
    return result.data['count'] as int;
  }

  Future<void> updateStatus(String id, int status, {DateTime? vaccinationDate}) async {
    await (_db.update(_db.vaccineRecords)..where((t) => t.id.equals(id))).write(
          VaccineRecordsCompanion(
            status: Value(status),
            vaccinationDate: vaccinationDate != null ? Value(vaccinationDate) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteVaccine(String id) async {
    await (_db.update(_db.vaccineRecords)..where((t) => t.id.equals(id))).write(
          VaccineRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

class DiaryRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addDiary({
    required String babyId,
    required String content,
    required DateTime recordDate,
    String? title,
    int? mood,
    String? tags,
    String? images,
    bool isMilestone = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.diaryRecords).insert(
          DiaryRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            content: content,
            recordDate: recordDate,
            title: Value(title),
            mood: Value(mood),
            tags: Value(tags),
            images: Value(images),
            isMilestone: Value(isMilestone),
          ),
        );
    return id;
  }

  Future<List<DiaryRecord>> getDiaries(String babyId, {int limit = 50}) async {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
  }

  Stream<List<DiaryRecord>> watchDiaries(String babyId) {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Future<void> deleteDiary(String id) async {
    await (_db.update(_db.diaryRecords)..where((t) => t.id.equals(id))).write(
          DiaryRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

class MilestoneRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addMilestone({
    required String babyId,
    required String name,
    required int category,
    DateTime? achieveDate,
    String? description,
    String? imagePath,
    bool isCustom = false,
    String? templateId,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.milestoneRecords).insert(
          MilestoneRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            name: name,
            category: Value(category),
            achieveDate: Value(achieveDate),
            description: Value(description),
            imagePath: Value(imagePath),
            isCustom: Value(isCustom),
            templateId: Value(templateId),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<MilestoneRecord>> getAllMilestones(String babyId) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.achieveDate)]))
        .get();
  }

  Stream<List<MilestoneRecord>> watchAllMilestones(String babyId) {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.achieveDate)]))
        .watch();
  }

  Future<List<MilestoneRecord>> getByCategory(String babyId, int category) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.category.equals(category))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.achieveDate)]))
        .get();
  }

  Future<void> deleteMilestone(String id) async {
    await (_db.update(_db.milestoneRecords)..where((t) => t.id.equals(id))).write(
          MilestoneRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

class RecordRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addDiaperRecord({
    required String babyId,
    required int type,
    required DateTime changeTime,
    int? stoolConsistency,
    bool? hasRash,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.diaperRecords).insert(
          DiaperRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            changeTime: changeTime,
            stoolConsistency: Value(stoolConsistency),
            hasRash: Value(hasRash ?? false),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<DiaperRecord>> getTodayDiaperRecords(String babyId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.changeTime.isBiggerOrEqualValue(start))
          ..where((t) => t.changeTime.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.changeTime)]))
        .get();
  }

  Stream<List<DiaperRecord>> watchTodayDiaperRecords(String babyId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.changeTime.isBiggerOrEqualValue(start))
          ..where((t) => t.changeTime.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.changeTime)]))
        .watch();
  }

  Future<int> getTodayDiaperCount(String babyId) async {
    final records = await getTodayDiaperRecords(babyId);
    return records.length;
  }

  Future<String> addBathRecord({
    required String babyId,
    required DateTime bathTime,
    int? durationMinutes,
    double? waterTemperature,
    String? bathType,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.bathRecords).insert(
          BathRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            bathTime: bathTime,
            durationMinutes: Value(durationMinutes),
            waterTemperature: Value(waterTemperature),
            bathType: Value(bathType),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<String> addAiMessage({
    required String babyId,
    required String sessionId,
    required int role,
    required String content,
    int mode = 0,
    String? detectedIntent,
    String? extractedEntities,
    String? relatedRecordId,
    int status = 1,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.aiChatMessages).insert(
          AiChatMessagesCompanion.insert(
            id: id,
            babyId: babyId,
            sessionId: sessionId,
            role: role,
            content: content,
            mode: mode,
            detectedIntent: Value(detectedIntent),
            extractedEntities: Value(extractedEntities),
            relatedRecordId: Value(relatedRecordId),
            status: status,
          ),
        );
    return id;
  }

  Future<List<AiChatMessage>> getChatMessages(String babyId, String sessionId, {int limit = 50}) async {
    return (_db.select(_db.aiChatMessages)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.sessionId.equals(sessionId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Stream<List<AiChatMessage>> watchChatMessages(String babyId, String sessionId) {
    return (_db.select(_db.aiChatMessages)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.sessionId.equals(sessionId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> addInteractionLog({
    required String babyId,
    required String sessionId,
    required int type,
    required String userInput,
    required int result,
    String? detectedIntent,
    double? intentConfidence,
    String? extractedEntities,
    String? aiResponse,
    String? errorMessage,
    int? responseTimeMs,
    String? relatedRecordId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.aiInteractionLogs).insert(
          AiInteractionLogsCompanion.insert(
            id: id,
            babyId: babyId,
            sessionId: sessionId,
            type: type,
            userInput: userInput,
            result: result,
            detectedIntent: Value(detectedIntent),
            intentConfidence: Value(intentConfidence),
            extractedEntities: Value(extractedEntities),
            aiResponse: Value(aiResponse),
            errorMessage: Value(errorMessage),
            responseTimeMs: Value(responseTimeMs),
            relatedRecordId: Value(relatedRecordId),
          ),
        );
  }

  Future<String> addMedicineRecord({
    required String babyId,
    required String medicineName,
    required int type,
    DateTime? scheduledTime,
    DateTime? takenTime,
    int status = 0,
    double? dosage,
    int? unit,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.medicineRecords).insert(
          MedicineRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            medicineName: medicineName,
            type: type,
            scheduledTime: Value(scheduledTime),
            takenTime: Value(takenTime),
            status: status,
            dosage: Value(dosage),
            unit: Value(unit),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<void> deleteDiaper(String id) async {
    await (_db.update(_db.diaperRecords)..where((t) => t.id.equals(id))).write(
          DiaperRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
