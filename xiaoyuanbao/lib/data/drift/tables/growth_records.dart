import 'package:drift/drift.dart';

class GrowthRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  RealColumn get headCircumference => real().nullable()();
  RealColumn get bmi => real().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get measurementPlace => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
