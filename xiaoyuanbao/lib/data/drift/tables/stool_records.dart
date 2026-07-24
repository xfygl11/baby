import 'package:drift/drift.dart';

@DataClassName('StoolRecord')
class StoolRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get time => dateTime()();
  IntColumn get color => intEnum<StoolColor>()();
  IntColumn get bristolType => intEnum<BristolType>()();
  TextColumn get amount => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum StoolColor { brown, yellow, green, black, red, white, gray }
enum BristolType { type1, type2, type3, type4, type5, type6, type7 }