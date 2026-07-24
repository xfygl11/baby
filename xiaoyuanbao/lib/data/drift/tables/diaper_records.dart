import 'package:drift/drift.dart';

class DiaperRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<DiaperTypeEnum>().withDefault(const Constant(0))();
  IntColumn get stoolColor => intEnum<StoolColorEnum>().nullable()();
  IntColumn get stoolConsistency => integer().nullable()();
  BoolColumn get hasRash => boolean().withDefault(const Constant(false))();
  TextColumn get rashSeverity => text().nullable()();
  DateTimeColumn get recordTime => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum DiaperTypeEnum { wet, dirty, mixed }
enum StoolColorEnum { brown, yellow, green, black, red, white, gray }
