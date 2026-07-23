import 'package:drift/drift.dart';

enum DiaperType { wet, dirty, mixed, dry }
enum StoolConsistency { normal, soft, hard, watery, mucousy, bloody }

class DiaperRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<DiaperType>()();
  DateTimeColumn get changeTime => dateTime()();
  IntColumn get stoolConsistency => intEnum<StoolConsistency>().nullable()();
  TextColumn get stoolColor => text().nullable()();
  BoolColumn get hasRash => boolean().withDefault(const Constant(false))();
  TextColumn get rashSeverity => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
