import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/word_records.dart';

class WordRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  WordRepository(this._db);

  Future<WordRecord> insert(WordRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    await _db.into(_db.wordRecords).insert(companion);
    return (await getById(id))!;
  }

  Future<int> updateById(String id, WordRecordsCompanion entity) async {
    return _db.update(_db.wordRecords)
      ..where((t) => t.id.equals(id))
      ..write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return _db.update(_db.wordRecords)
      ..where((t) => t.id.equals(id))
      ..write(WordRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ));
  }

  Future<WordRecord?> getById(String id) async {
    return (_db.select(_db.wordRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<WordRecord>> getAll(String babyId) async {
    return (_db.select(_db.wordRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.firstSaidAt)]))
        .get();
  }

  Future<List<WordRecord>> getByCategory(String babyId, String category) async {
    return (_db.select(_db.wordRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.category.equals(category))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.firstSaidAt)]))
        .get();
  }

  Future<WordRecord?> findByWord(String babyId, String word) async {
    return (_db.select(_db.wordRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.word.equals(word))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<WordRecord>> getFavorites(String babyId) async {
    return (_db.select(_db.wordRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isFavorite.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.firstSaidAt)]))
        .get();
  }

  Future<int> countByBaby(String babyId) async {
    final count = _db.wordRecords.id.count();
    final query = _db.selectOnly(_db.wordRecords)
      ..addColumns([count])
      ..where(_db.wordRecords.babyId.equals(babyId))
      ..where(_db.wordRecords.isDeleted.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<WordRecord>> getByMonth(String babyId, int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (_db.select(_db.wordRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.firstSaidAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.firstSaidAt)]))
        .get();
  }
}
