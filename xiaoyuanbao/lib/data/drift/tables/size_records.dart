import 'package:drift/drift.dart';

@DataClassName('SizeRecord')
class SizeRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get sizeType => text().withLength(max: 50)();
  TextColumn get size => text().withLength(max: 50)();
  DateTimeColumn get recordDate => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum SizeType {
  shoe,
  clothesTop,
  clothesBottom,
  clothesDress,
  underwear,
  hat,
  sock,
  other,
}

extension SizeTypeExtension on SizeType {
  String get label {
    switch (this) {
      case SizeType.shoe:
        return '鞋子';
      case SizeType.clothesTop:
        return '上衣';
      case SizeType.clothesBottom:
        return '裤子';
      case SizeType.clothesDress:
        return '连衣裙';
      case SizeType.underwear:
        return '内衣';
      case SizeType.hat:
        return '帽子';
      case SizeType.sock:
        return '袜子';
      case SizeType.other:
        return '其他';
    }
  }
}