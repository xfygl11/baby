import 'package:drift/drift.dart';

class FeedingRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<FeedingTypeEnum>().withDefault(const Constant(0))();
  RealColumn get amountMl => real().nullable()();
  IntColumn get breastSide => intEnum<BreastSideEnum>().nullable()();
  TextColumn get formulaBrand => text().nullable()();
  TextColumn get foodName => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum FeedingTypeEnum { breastMilk, formula, solidFood, water, juice, other }
enum BreastSideEnum { left, right, both }
