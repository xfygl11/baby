import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/expense_records.dart';

class ExpenseRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ExpenseRepository(this._db);

  Future<ExpenseRecord> insert(ExpenseRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    final insertedId = await _db.into(_db.expenseRecords).insert(companion);
    return _db.expenseRecords.get(insertedId);
  }

  Future<int> updateById(String id, ExpenseRecordsCompanion entity) async {
    return _db.update(_db.expenseRecords)
      ..where((t) => t.id.equals(id))
      ..write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return _db.update(_db.expenseRecords)
      ..where((t) => t.id.equals(id))
      ..write(ExpenseRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ));
  }

  Future<ExpenseRecord?> getById(String id) async {
    return (_db.select(_db.expenseRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<ExpenseRecord>> getAll(String babyId) async {
    return (_db.select(_db.expenseRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
        .get();
  }

  Future<List<ExpenseRecord>> getToday(String babyId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.expenseRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.expenseDate.isBiggerOrEqual(today))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
        .get();
  }

  Future<List<ExpenseRecord>> getByCategory(String babyId, String category) async {
    return (_db.select(_db.expenseRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.category.equals(category))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
        .get();
  }

  Future<List<ExpenseRecord>> getByMonth(String babyId, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);
    return (_db.select(_db.expenseRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.expenseDate.isBiggerOrEqual(startDate))
          ..where((t) => t.expenseDate.isSmallerThan(endDate))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
        .get();
  }

  Future<double> getTotalByMonth(String babyId, int year, int month) async {
    final records = await getByMonth(babyId, year, month);
    return records.fold(0.0, (sum, r) => sum + r.amount);
  }

  Future<double> getTotalByCategory(String babyId, String category) async {
    final records = await getByCategory(babyId, category);
    return records.fold(0.0, (sum, r) => sum + r.amount);
  }

  Future<Map<String, double>> getCategoryStats(String babyId, int year, int month) async {
    final records = await getByMonth(babyId, year, month);
    final stats = <String, double>{};
    for (final record in records) {
      stats[record.category] = (stats[record.category] ?? 0.0) + record.amount;
    }
    return stats;
  }
}