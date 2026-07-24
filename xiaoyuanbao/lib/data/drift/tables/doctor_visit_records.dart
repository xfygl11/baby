import 'package:drift/drift.dart';

@DataClassName('DoctorVisitRecord')
class DoctorVisitRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get hospital => text().withLength(min: 1, max: 100)();
  TextColumn get department => text().withLength(min: 1, max: 50)();
  TextColumn get diagnosis => text().withLength(min: 1, max: 500)();
  TextColumn get prescription => text().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get medicalRecordPath => text().nullable()();
  DateTimeColumn get followUpDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}