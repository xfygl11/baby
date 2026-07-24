import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/vision_records.dart';

class VisionRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  VisionRepository(this._db);

  Future<String> addVision({
    required String babyId,
    required DateTime checkDate,
    required double leftEye,
    required double rightEye,
    double? leftEyeSpherical,
    double? rightEyeSpherical,
    double? leftEyeCylindrical,
    double? rightEyeCylindrical,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.visionRecords).insert(
          VisionRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            checkDate: checkDate,
            leftEye: leftEye,
            rightEye: rightEye,
            leftEyeSpherical: Value(leftEyeSpherical),
            rightEyeSpherical: Value(rightEyeSpherical),
            leftEyeCylindrical: Value(leftEyeCylindrical),
            rightEyeCylindrical: Value(rightEyeCylindrical),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<VisionRecord>> getAllVision(String babyId) async {
    return (_db.select(_db.visionRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.checkDate)]))
        .get();
  }

  Future<VisionRecord?> getVisionById(String id) async {
    return (_db.select(_db.visionRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateVision(
    String id, {
    double? leftEye,
    double? rightEye,
    String? note,
  }) async {
    await (_db.update(_db.visionRecords)..where((t) => t.id.equals(id))).write(
          VisionRecordsCompanion(
            leftEye: Value(leftEye),
            rightEye: Value(rightEye),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteVision(String id) async {
    await (_db.update(_db.visionRecords)..where((t) => t.id.equals(id))).write(
          VisionRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}