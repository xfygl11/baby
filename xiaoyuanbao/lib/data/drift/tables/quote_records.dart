import 'package:drift/drift.dart';

@DataClassName('QuoteRecord')
class QuoteRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get speaker => text().withLength(max: 50)();
  TextColumn get content => text()();
  TextColumn get emotion => text().nullable().withLength(max: 20)();
  DateTimeColumn get recordTime => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum QuoteSpeaker {
  baby,
  dad,
  mom,
  grandma,
  grandpa,
  aunt,
  uncle,
  other,
}

extension QuoteSpeakerExtension on QuoteSpeaker {
  String get label {
    switch (this) {
      case QuoteSpeaker.baby:
        return '宝宝';
      case QuoteSpeaker.dad:
        return '爸爸';
      case QuoteSpeaker.mom:
        return '妈妈';
      case QuoteSpeaker.grandma:
        return '奶奶';
      case QuoteSpeaker.grandpa:
        return '爷爷';
      case QuoteSpeaker.aunt:
        return '阿姨';
      case QuoteSpeaker.uncle:
        return '叔叔';
      case QuoteSpeaker.other:
        return '其他';
    }
  }
}