import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/school_records.dart';

class SchoolRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SchoolRepository(this._db);

  Future<String> addSchool({
    required String babyId,
    required String schoolName,
    required SchoolType schoolType,
    required int grade,
    required String className,
    required String teacherName,
    required DateTime admissionDate,
    DateTime? graduationDate,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.schoolRecords).insert(
          SchoolRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            schoolName: schoolName,
            schoolType: schoolType,
            grade: grade,
            className: className,
            teacherName: teacherName,
            admissionDate: admissionDate,
            graduationDate: Value(graduationDate),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<SchoolRecord>> getAllSchools(String babyId) async {
    return (_db.select(_db.schoolRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.admissionDate)]))
        .get();
  }

  Future<SchoolRecord?> getSchoolById(String id) async {
    return (_db.select(_db.schoolRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<SchoolRecord?> getCurrentSchool(String babyId) async {
    return (_db.select(_db.schoolRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.graduationDate.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.admissionDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> updateSchool(
    String id, {
    String? schoolName,
    int? grade,
    String? className,
    String? teacherName,
    DateTime? graduationDate,
    String? note,
  }) async {
    await (_db.update(_db.schoolRecords)..where((t) => t.id.equals(id))).write(
          SchoolRecordsCompanion(
            schoolName: Value(schoolName),
            grade: Value(grade),
            className: Value(className),
            teacherName: Value(teacherName),
            graduationDate: Value(graduationDate),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteSchool(String id) async {
    await (_db.update(_db.schoolRecords)..where((t) => t.id.equals(id))).write(
          SchoolRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}