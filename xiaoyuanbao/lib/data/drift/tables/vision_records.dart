import 'package:drift/drift.dart';

@DataClassName('VisionRecord')
class VisionRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get checkDate => dateTime()();
  RealColumn get leftEye => real()();
  RealColumn get rightEye => real()();
  RealColumn get leftEyeSpherical => real().nullable()();
  RealColumn get rightEyeSpherical => real().nullable()();
  RealColumn get leftEyeCylindrical => real().nullable()();
  RealColumn get rightEyeCylindrical => real().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}