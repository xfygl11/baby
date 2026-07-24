import 'package:drift/drift.dart';

@DataClassName('TimeCapsuleRecord')
class TimeCapsuleRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get title => text().withLength(max: 100)();
  TextColumn get letter => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get videoPath => text().nullable()();
  TextColumn get mood => text().nullable().withLength(max: 30)();
  DateTimeColumn get sealedAt => dateTime()();
  DateTimeColumn get unlockAt => dateTime()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum CapsuleStatus { sealed, unlocked, overdue }
