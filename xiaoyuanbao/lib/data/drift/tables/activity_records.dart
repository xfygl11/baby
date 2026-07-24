import 'package:drift/drift.dart';

@DataClassName('ActivityRecord')
class ActivityRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get activityType => text().withLength(max: 50)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum ActivityType {
  reading,
  music,
  massage,
  swimming,
  outdoor,
  game,
  tummyTime,
  dancing,
  cooking,
  craft,
  painting,
  puzzle,
  storytelling,
  sports,
  other,
}

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.reading:
        return '读绘本';
      case ActivityType.music:
        return '听音乐';
      case ActivityType.massage:
        return '做抚触';
      case ActivityType.swimming:
        return '游泳';
      case ActivityType.outdoor:
        return '户外活动';
      case ActivityType.game:
        return '游戏';
      case ActivityType.tummyTime:
        return '趴趴时间';
      case ActivityType.dancing:
        return '跳舞';
      case ActivityType.cooking:
        return '做饭';
      case ActivityType.craft:
        return '手工';
      case ActivityType.painting:
        return '画画';
      case ActivityType.puzzle:
        return '拼图';
      case ActivityType.storytelling:
        return '讲故事';
      case ActivityType.sports:
        return '运动';
      case ActivityType.other:
        return '其他';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.reading:
        return '📚';
      case ActivityType.music:
        return '🎵';
      case ActivityType.massage:
        return '🤱';
      case ActivityType.swimming:
        return '🏊';
      case ActivityType.outdoor:
        return '🌳';
      case ActivityType.game:
        return '🎮';
      case ActivityType.tummyTime:
        return '🐣';
      case ActivityType.dancing:
        return '💃';
      case ActivityType.cooking:
        return '🍳';
      case ActivityType.craft:
        return '✂️';
      case ActivityType.painting:
        return '🎨';
      case ActivityType.puzzle:
        return '🧩';
      case ActivityType.storytelling:
        return '🗣️';
      case ActivityType.sports:
        return '⚽';
      case ActivityType.other:
        return '📝';
    }
  }
}