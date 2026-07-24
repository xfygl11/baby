import 'package:drift/drift.dart';

class ExamRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get examName => text()();
  IntColumn get examType => intEnum<ExamType>()();
  TextColumn get subject => text()();
  RealColumn get score => real()();
  RealColumn get fullScore => real().nullable()();
  IntColumn get rank => integer().nullable()();
  DateTimeColumn get examDate => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum ExamType { unitTest, midterm, final, competition, quiz }