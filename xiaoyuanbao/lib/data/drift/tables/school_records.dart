import 'package:drift/drift.dart';

class SchoolRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get schoolName => text()();
  IntColumn get schoolType => intEnum<SchoolType>()();
  IntColumn get grade => integer()();
  TextColumn get className => text()();
  TextColumn get teacherName => text()();
  DateTimeColumn get admissionDate => dateTime()();
  DateTimeColumn get graduationDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum SchoolType { kindergarten, primary, middle, high }