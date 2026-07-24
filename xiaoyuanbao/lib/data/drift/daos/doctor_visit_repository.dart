import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/doctor_visit_records.dart';

class DoctorVisitRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  DoctorVisitRepository(this._db);

  Future<String> addDoctorVisit({
    required String babyId,
    required DateTime visitDate,
    required String hospital,
    required String department,
    required String diagnosis,
    String? prescription,
    double? cost,
    String? medicalRecordPath,
    DateTime? followUpDate,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.doctorVisitRecords).insert(
          DoctorVisitRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            visitDate: visitDate,
            hospital: hospital,
            department: department,
            diagnosis: diagnosis,
            prescription: Value(prescription),
            cost: Value(cost),
            medicalRecordPath: Value(medicalRecordPath),
            followUpDate: Value(followUpDate),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<DoctorVisitRecord>> getAllDoctorVisits(String babyId) async {
    return (_db.select(_db.doctorVisitRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.visitDate)]))
        .get();
  }

  Future<DoctorVisitRecord?> getDoctorVisitById(String id) async {
    return (_db.select(_db.doctorVisitRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateDoctorVisit(
    String id, {
    String? diagnosis,
    String? prescription,
    DateTime? followUpDate,
    String? note,
  }) async {
    await (_db.update(_db.doctorVisitRecords)..where((t) => t.id.equals(id))).write(
          DoctorVisitRecordsCompanion(
            diagnosis: diagnosis != null ? Value(diagnosis) : const Value.absent(),
            prescription: Value(prescription),
            followUpDate: Value(followUpDate),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteDoctorVisit(String id) async {
    await (_db.update(_db.doctorVisitRecords)..where((t) => t.id.equals(id))).write(
          DoctorVisitRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<DoctorVisitRecord>> getUpcomingFollowUps(String babyId) async {
    return (_db.select(_db.doctorVisitRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.followUpDate.isNotNull())
          ..where((t) => t.followUpDate.isBiggerOrEqualValue(DateTime.now()))
          ..orderBy([(t) => OrderingTerm.asc(t.followUpDate)]))
        .get();
  }
}