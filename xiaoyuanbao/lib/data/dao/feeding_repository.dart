import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../drift/app_database.dart';
import '../drift/tables/feeding_records.dart';

class FeedingRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createFeeding({
    required String babyId,
    required int type,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? amountMl,
    int? breastSide,
    String? foodName,
    double? foodAmount,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.feedingRecords).insert(
          FeedingRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            startTime: startTime,
            endTime: Value(endTime),
            durationMinutes: Value(durationMinutes),
            amountMl: Value(amountMl),
            breastSide: Value(breastSide),
            foodName: Value(foodName),
            foodAmount: Value(foodAmount),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<FeedingRecord>> getRecentFeedings(String babyId, {int limit = 20}) async {
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .get();
  }

  Stream<List<FeedingRecord>> watchTodayFeedings(String babyId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .watch();
  }

  Future<int> getTodayFeedCount(String babyId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final result = await _db.customSelect(
      'SELECT COUNT(*) as count FROM feeding_records '
      'WHERE baby_id = ? AND is_deleted = 0 AND start_time >= ? AND start_time < ?',
      variables: [
        Variable.withString(babyId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).getSingle();
    return result.data['count'] as int;
  }

  Future<double> getTodayTotalMl(String babyId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final result = await _db.customSelect(
      'SELECT COALESCE(SUM(amount_ml), 0) as total FROM feeding_records '
      'WHERE baby_id = ? AND is_deleted = 0 AND start_time >= ? AND start_time < ?',
      variables: [
        Variable.withString(babyId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).getSingle();
    return (result.data['total'] as num).toDouble();
  }

  Future<FeedingRecord?> getLastFeeding(String babyId) async {
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteFeeding(String id) async {
    await (_db.update(_db.feedingRecords)..where((t) => t.id.equals(id))).write(
          FeedingRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
