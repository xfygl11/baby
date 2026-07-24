import 'package:drift/drift.dart';

@DataClassName('ItemRecord')
class ItemRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get itemType => text().withLength(max: 50)();
  TextColumn get brand => text().nullable().withLength(max: 100)();
  TextColumn get size => text().nullable().withLength(max: 50)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum ItemType {
  bottle,
  diaper,
  clothes,
  shoes,
  toy,
  book,
  stroller,
  carseat,
  highchair,
  bed,
  backpack,
  other,
}

extension ItemTypeExtension on ItemType {
  String get label {
    switch (this) {
      case ItemType.bottle:
        return '奶瓶';
      case ItemType.diaper:
        return '尿布';
      case ItemType.clothes:
        return '衣服';
      case ItemType.shoes:
        return '鞋子';
      case ItemType.toy:
        return '玩具';
      case ItemType.book:
        return '书籍';
      case ItemType.stroller:
        return '推车';
      case ItemType.carseat:
        return '安全座椅';
      case ItemType.highchair:
        return '餐椅';
      case ItemType.bed:
        return '床';
      case ItemType.backpack:
        return '书包';
      case ItemType.other:
        return '其他';
    }
  }

  String get icon {
    switch (this) {
      case ItemType.bottle:
        return '🍼';
      case ItemType.diaper:
        return '👶';
      case ItemType.clothes:
        return '👕';
      case ItemType.shoes:
        return '👟';
      case ItemType.toy:
        return '🧸';
      case ItemType.book:
        return '📚';
      case ItemType.stroller:
        return '🚼';
      case ItemType.carseat:
        return '🚗';
      case ItemType.highchair:
        return '🪑';
      case ItemType.bed:
        return '🛏️';
      case ItemType.backpack:
        return '🎒';
      case ItemType.other:
        return '📦';
    }
  }
}