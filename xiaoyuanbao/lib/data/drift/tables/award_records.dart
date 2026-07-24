import 'package:drift/drift.dart';

class AwardRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get awardName => text()();
  IntColumn get awardLevel => intEnum<AwardLevel>()();
  DateTimeColumn get awardDate => dateTime()();
  TextColumn get awardingOrganization => text()();
  TextColumn get certificatePath => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum AwardLevel { school, district, city, province, national, international }