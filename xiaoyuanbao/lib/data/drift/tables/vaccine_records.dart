import 'package:drift/drift.dart';

enum VaccineStatus { scheduled, completed, delayed, skipped, contraindicated }
enum VaccineCategory { national, optional }

class VaccineRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get vaccineName => text().withLength(min: 1, max: 100)();
  TextColumn get vaccineCode => text().nullable()();
  IntColumn get category => intEnum<VaccineCategory>().withDefault(const Constant(0))();
  IntColumn get status => intEnum<VaccineStatus>().withDefault(const Constant(0))();
  IntColumn get doseNumber => integer().withDefault(const Constant(1))();
  IntColumn get totalDoses => integer().withDefault(const Constant(1))();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get vaccinationDate => dateTime().nullable()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get hospital => text().nullable()();
  TextColumn get site => text().nullable()();
  TextColumn get reaction => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get reminderDays => integer().nullable()();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
