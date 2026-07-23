import 'package:drift/drift.dart';

enum GrowthType { weight, height, headCircumference, bmi }

class GrowthRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<GrowthType>()();
  RealColumn get value => real()();
  DateTimeColumn get recordDate => dateTime()();
  RealColumn get percentile => real().nullable()();
  TextColumn get zScore => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
