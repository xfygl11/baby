import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../drift/app_database.dart';
import '../drift/tables/sleep_records.dart';

class SleepRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> startSleep({
    required String babyId,
    required int type,
    DateTime? startTime,
    String? environment,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.sleepRecords).insert(
          SleepRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            startTime: startTime ?? DateTime.now(),
            sleepEnvironment: Value(environment),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<void> endSleep(String id, {DateTime? endTime, int? quality}) async {
    final record = await (_db.select(_db.sleepRecords)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (record == null) return;
    final actualEndTime = endTime ?? DateTime.now();
    final duration = actualEndTime.difference(record.startTime).inMinutes;
    await (_db.update(_db.sleepRecords)..where((t) => t.id.equals(id))).write(
          SleepRecordsCompanion(
            endTime: Value(actualEndTime),
            durationMinutes: Value(duration),
            quality: quality != null ? Value(quality) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<SleepRecord?> getOngoingSleep(String babyId) async {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.endTime.isNull())
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<SleepRecord?> watchOngoingSleep(String babyId) {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.endTime.isNull())
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<SleepRecord>> getRecentSleep(String babyId, {int limit = 20}) async {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .get();
  }

  Stream<List<SleepRecord>> watchRecentSleep(String babyId, {int limit = 20}) {
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .watch();
  }

  Future<List<SleepRecord>> getTodaySleep(String babyId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.sleepRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerThanValue(end)))
        .get();
  }

  Future<int> getTodayTotalSleepMinutes(String babyId) async {
    final sleeps = await getTodaySleep(babyId);
    int total = 0;
    for (var s in sleeps) {
      if (s.endTime != null) {
        total += s.durationMinutes ?? 0;
      } else {
        total += DateTime.now().difference(s.startTime).inMinutes;
      }
    }
    return total;
  }

  Future<int> getThisWeekTotalMinutes(String babyId) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final result = await _db.customSelect(
      'SELECT COALESCE(SUM(duration_minutes), 0) as total FROM sleep_records '
      'WHERE baby_id = ? AND is_deleted = 0 AND start_time >= ?',
      variables: [
        Variable.withString(babyId),
        Variable.withDateTime(DateTime(start.year, start.month, start.day)),
      ],
    ).getSingle();
    return result.data['total'] as int;
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
}
