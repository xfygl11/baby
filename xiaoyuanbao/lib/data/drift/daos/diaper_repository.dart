import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/diaper_records.dart';

class DiaperRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  DiaperRepository(this._db);

  Future<String> addDiaper({
    required String babyId,
    required int type,
    int? stoolColor,
    int? stoolConsistency,
    bool hasRash = false,
    String? rashSeverity,
    required DateTime recordTime,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.diaperRecords).insert(
          DiaperRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            stoolColor: Value(stoolColor),
            stoolConsistency: Value(stoolConsistency),
            hasRash: Value(hasRash),
            rashSeverity: Value(rashSeverity),
            recordTime: recordTime,
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<DiaperRecord>> getTodayDiapers(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<DiaperRecord?> getLatestDiaper(String babyId) async {
    return (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<DiaperRecord>> getDiapersByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(start))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<DiaperRecord?> getDiaperById(String id) async {
    return (_db.select(_db.diaperRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateDiaper(String id, DiaperRecordsCompanion data) async {
    await (_db.update(_db.diaperRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
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

  Future<Map<String, dynamic>> getDailyStats(String babyId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final records = await (_db.select(_db.diaperRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(start))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(end)))
        .get();

    int count = records.length;
    int wetCount = 0;
    int dirtyCount = 0;
    int mixedCount = 0;
    int rashCount = 0;

    for (final r in records) {
      if (r.type == DiaperTypeEnum.wet.index) {
        wetCount++;
      } else if (r.type == DiaperTypeEnum.dirty.index) {
        dirtyCount++;
      } else if (r.type == DiaperTypeEnum.mixed.index) {
        mixedCount++;
      }
      if (r.hasRash) {
        rashCount++;
      }
    }

    double avgInterval = 0;
    if (count >= 2) {
      final sorted = List<DiaperRecord>.from(records)
        ..sort((a, b) => a.recordTime.compareTo(b.recordTime));
      int totalInterval = 0;
      for (int i = 1; i < sorted.length; i++) {
        totalInterval +=
            sorted[i].recordTime.difference(sorted[i - 1].recordTime).inMinutes;
      }
      avgInterval = totalInterval / (count - 1);
    }

    return {
      'count': count,
      'wetCount': wetCount,
      'dirtyCount': dirtyCount,
      'mixedCount': mixedCount,
      'rashCount': rashCount,
      'avgIntervalMinutes': avgInterval,
    };
  }
}
