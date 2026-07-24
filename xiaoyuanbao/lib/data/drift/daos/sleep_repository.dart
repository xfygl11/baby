import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/sleep_records.dart';

class SleepRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SleepRepository(this._db);

  Future<String> addSleep({
    required String babyId,
    required int type,
    required int location,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    int nightWakings = 0,
    String? quality,
    String? note,
    bool isCompleted = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.sleepRecords).insert(
          SleepRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: Value(SleepTypeEnum.values[type]),
            location: Value(SleepLocationEnum.values[location]),
            startTime: startTime,
            endTime: Value(endTime),
            durationMinutes: Value(durationMinutes),
            nightWakings: Value(nightWakings),
            quality: Value(quality),
            note: Value(note),
            isCompleted: Value(isCompleted),
          ),
        );
    return id;
  }

  Future<List<SleepRecord>> getTodaySleeps(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.startTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<SleepRecord?> getLatestSleep(String babyId) async {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SleepRecord?> getActiveSleep(String babyId) async {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<SleepRecord>> getSleepsByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<SleepRecord?> getSleepById(String id) async {
    return (_db.select(_db.sleepRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateSleep(String id, SleepRecordsCompanion data) async {
    await (_db.update(_db.sleepRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteSleep(String id) async {
    await (_db.update(_db.sleepRecords)..where((t) => t.id.equals(id))).write(
          SleepRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<Map<String, dynamic>> getDailyStats(String babyId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final records = await (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerOrEqualValue(end)))
        .get();

    int totalDuration = 0;
    int count = records.length;
    int nightCount = 0;
    int napCount = 0;
    int totalNightWakings = 0;

    for (final r in records) {
      if (r.durationMinutes != null) {
        totalDuration += r.durationMinutes!;
      }
      if (r.type == SleepTypeEnum.night.index) {
        nightCount++;
      } else if (r.type == SleepTypeEnum.nap.index) {
        napCount++;
      }
      totalNightWakings += r.nightWakings;
    }

    double avgDuration = 0;
    if (count > 0) {
      avgDuration = totalDuration / count;
    }

    return {
      'count': count,
      'totalDurationMinutes': totalDuration,
      'avgDurationMinutes': avgDuration,
      'nightCount': nightCount,
      'napCount': napCount,
      'totalNightWakings': totalNightWakings,
    };
  }
}
