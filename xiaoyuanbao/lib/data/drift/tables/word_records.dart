import 'package:drift/drift.dart';

@DataClassName('WordRecord')
class WordRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get word => text().withLength(max: 60)();
  TextColumn get pinyin => text().nullable().withLength(max: 60)();
  TextColumn get context => text().nullable()();
  TextColumn get speaker => text().nullable().withLength(max: 30)();
  TextColumn get category => text().nullable().withLength(max: 30)();
  TextColumn get audioPath => text().nullable()();
  DateTimeColumn get firstSaidAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum WordCategory {
  animal,
  food,
  family,
  action,
  adjective,
  onomatopoeia,
  pronoun,
  number,
  body,
  vehicle,
  other,
}

extension WordCategoryExtension on WordCategory {
  String get label {
    return switch (this) {
      WordCategory.animal => '动物',
      WordCategory.food => '食物',
      WordCategory.family => '家庭',
      WordCategory.action => '动作',
      WordCategory.adjective => '形容词',
      WordCategory.onomatopoeia => '拟声词',
      WordCategory.pronoun => '代词',
      WordCategory.number => '数字',
      WordCategory.body => '身体',
      WordCategory.vehicle => '交通工具',
      WordCategory.other => '其他',
    };
  }
}
