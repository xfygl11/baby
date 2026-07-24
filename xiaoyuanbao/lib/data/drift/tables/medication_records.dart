import 'package:drift/drift.dart';

class MedicationRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get medicineName => text().withLength(min: 1, max: 100)();
  RealColumn get dosage => real()();
  TextColumn get unit => text().withLength(min: 1, max: 20)();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get recordTime => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}
