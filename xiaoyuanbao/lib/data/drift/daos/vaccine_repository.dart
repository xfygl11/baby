import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/vaccine_records.dart';

class VaccineRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  VaccineRepository(this._db);

  Future<String> addVaccine({
    required String babyId,
    required String vaccineName,
    String? vaccineCode,
    VaccineCategoryEnum category = VaccineCategoryEnum.national,
    VaccineStatusEnum status = VaccineStatusEnum.scheduled,
    int doseNumber = 1,
    int totalDoses = 1,
    DateTime? scheduledDate,
    DateTime? vaccinationDate,
    String? batchNumber,
    String? manufacturer,
    String? hospital,
    String? site,
    String? reaction,
    String? note,
    int? reminderDays,
    bool reminderEnabled = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.vaccineRecords).insert(
          VaccineRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            vaccineName: vaccineName,
            vaccineCode: Value(vaccineCode),
            category: Value(category.index),
            status: Value(status.index),
            doseNumber: Value(doseNumber),
            totalDoses: Value(totalDoses),
            scheduledDate: Value(scheduledDate),
            vaccinationDate: Value(vaccinationDate),
            batchNumber: Value(batchNumber),
            manufacturer: Value(manufacturer),
            hospital: Value(hospital),
            site: Value(site),
            reaction: Value(reaction),
            note: Value(note),
            reminderDays: Value(reminderDays),
            reminderEnabled: Value(reminderEnabled),
          ),
        );
    return id;
  }

  Future<List<VaccineRecord>> getPendingVaccines(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.status.equals(VaccineStatusEnum.scheduled.index))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();
  }

  Future<List<VaccineRecord>> getCompletedVaccines(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.status.equals(VaccineStatusEnum.completed.index))
          ..orderBy([(t) => OrderingTerm.desc(t.vaccinationDate)]))
        .get();
  }

  Future<List<VaccineRecord>> getVaccinesByBabyId(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();
  }

  Future<VaccineRecord?> getVaccineById(String id) async {
    return (_db.select(_db.vaccineRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateVaccine(String id, VaccineRecordsCompanion data) async {
    await (_db.update(_db.vaccineRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
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

  Future<VaccineRecord?> getNextVaccine(String babyId) async {
    return (_db.select(_db.vaccineRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.status.equals(VaccineStatusEnum.scheduled.index))
          ..where((t) => t.scheduledDate.isBiggerOrEqualValue(DateTime.now()))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> markVaccineCompleted(
    String id, {
    DateTime? vaccinationDate,
    String? batchNumber,
    String? manufacturer,
    String? hospital,
    String? site,
    String? reaction,
    String? note,
  }) async {
    await (_db.update(_db.vaccineRecords)..where((t) => t.id.equals(id))).write(
          VaccineRecordsCompanion(
            status: Value(VaccineStatusEnum.completed.index),
            vaccinationDate: Value(vaccinationDate ?? DateTime.now()),
            batchNumber: Value(batchNumber),
            manufacturer: Value(manufacturer),
            hospital: Value(hospital),
            site: Value(site),
            reaction: Value(reaction),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<String>> batchInsertVaccines(
    String babyId,
    List<VaccineRecordsCompanion> vaccines,
  ) async {
    final ids = <String>[];
    await _db.transaction(() async {
      for (final vaccine in vaccines) {
        final id = _uuid.v4();
        ids.add(id);
        await _db.into(_db.vaccineRecords).insert(
              vaccine.copyWith(
                id: Value(id),
                babyId: Value(babyId),
              ),
            );
      }
    });
    return ids;
  }
}
