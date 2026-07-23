import 'package:drift/drift.dart';

enum MedicineType { vitamin, antibiotic, antipyretic, cough, other }
enum MedicineUnit { mg, ml, tablet, capsule, drop, other }
enum MedicineStatus { pending, taken, skipped, missed }

class MedicineRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get medicineName => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<MedicineType>().withDefault(const Constant(0))();
  RealColumn get dosage => real().nullable()();
  IntColumn get unit => intEnum<MedicineUnit>().nullable()();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  DateTimeColumn get takenTime => dateTime().nullable()();
  IntColumn get status => intEnum<MedicineStatus>().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
