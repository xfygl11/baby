import 'package:drift/drift.dart';

enum FeedingType { breastmilk, formula, mixed, solidFood, water, other }
enum BreastSide { left, right, both, none }

class FeedingRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<FeedingType>()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  RealColumn get amountMl => real().nullable()();
  IntColumn get breastSide => intEnum<BreastSide>().nullable()();
  TextColumn get foodName => text().nullable()();
  RealColumn get foodAmount => real().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
