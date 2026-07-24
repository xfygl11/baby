import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/feeding_records.dart';

class FeedingRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  FeedingRepository(this._db);

  Future<String> addFeeding({
    required String babyId,
    required int type,
    double? amountMl,
    int? breastSide,
    String? formulaBrand,
    String? foodName,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? note,
    bool isCompleted = true,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.feedingRecords).insert(
          FeedingRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            type: type,
            amountMl: Value(amountMl),
            breastSide: Value(breastSide),
            formulaBrand: Value(formulaBrand),
            foodName: Value(foodName),
            startTime: startTime,
            endTime: Value(endTime),
            durationMinutes: Value(durationMinutes),
            note: Value(note),
            isCompleted: Value(isCompleted),
          ),
        );
    return id;
  }

  Future<List<FeedingRecord>> getTodayFeedings(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.startTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<FeedingRecord?> getLatestFeeding(String babyId) async {
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<FeedingRecord>> getFeedingsByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<FeedingRecord?> getFeedingById(String id) async {
    return (_db.select(_db.feedingRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateFeeding(String id, FeedingRecordsCompanion data) async {
    await (_db.update(_db.feedingRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
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

  Future<Map<String, dynamic>> getDailyStats(String babyId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final records = await (_db.select(_db.feedingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.startTime.isSmallerOrEqualValue(end)))
        .get();

    double totalAmount = 0;
    int count = records.length;
    
    for (final r in records) {
      if (r.amountMl != null) {
        totalAmount += r.amountMl!;
      }
    }

    double avgInterval = 0;
    if (count >= 2) {
      final sorted = List<FeedingRecord>.from(records)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      int totalInterval = 0;
      for (int i = 1; i < sorted.length; i++) {
        totalInterval += sorted[i].startTime.difference(sorted[i-1].startTime).inMinutes;
      }
      avgInterval = totalInterval / (count - 1);
    }

    return {
      'count': count,
      'totalAmount': totalAmount,
      'avgIntervalMinutes': avgInterval,
    };
  }
}
