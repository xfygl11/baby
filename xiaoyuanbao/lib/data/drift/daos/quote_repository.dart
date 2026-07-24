import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/quote_records.dart';

class QuoteRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  QuoteRepository(this._db);

  Future<QuoteRecord> insert(QuoteRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    final insertedId = await _db.into(_db.quoteRecords).insert(companion);
    return _db.quoteRecords.get(insertedId);
  }

  Future<int> updateById(String id, QuoteRecordsCompanion entity) async {
    return _db.update(_db.quoteRecords)
      ..where((t) => t.id.equals(id))
      ..write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return _db.update(_db.quoteRecords)
      ..where((t) => t.id.equals(id))
      ..write(QuoteRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ));
  }

  Future<QuoteRecord?> getById(String id) async {
    return (_db.select(_db.quoteRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<QuoteRecord>> getAll(String babyId) async {
    return (_db.select(_db.quoteRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<List<QuoteRecord>> getBySpeaker(String babyId, String speaker) async {
    return (_db.select(_db.quoteRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.speaker.equals(speaker))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<List<QuoteRecord>> getFavorites(String babyId) async {
    return (_db.select(_db.quoteRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isFavorite.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<List<QuoteRecord>> getToday(String babyId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.quoteRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.recordTime.isBiggerOrEqual(today))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }
}