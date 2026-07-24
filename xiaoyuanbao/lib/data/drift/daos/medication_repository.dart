import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/medication_records.dart';

class MedicationRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  MedicationRepository(this._db);

  Future<String> addMedication({
    required String babyId,
    required String medicineName,
    required double dosage,
    required String unit,
    String? reason,
    required DateTime recordTime,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.medicationRecords).insert(
          MedicationRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            medicineName: medicineName,
            dosage: dosage,
            unit: unit,
            reason: Value(reason),
            recordTime: recordTime,
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<MedicationRecord>> getTodayMedications(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (_db.select(_db.medicationRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<MedicationRecord?> getLatestMedication(String babyId) async {
    return (_db.select(_db.medicationRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<MedicationRecord>> getMedicationsByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.medicationRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(start))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<MedicationRecord?> getMedicationById(String id) async {
    return (_db.select(_db.medicationRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateMedication(
      String id, MedicationRecordsCompanion data) async {
    await (_db.update(_db.medicationRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteMedication(String id) async {
    await (_db.update(_db.medicationRecords)..where((t) => t.id.equals(id)))
        .write(
      MedicationRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
