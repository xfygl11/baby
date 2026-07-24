import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/babies.dart';
import 'tables/feeding_records.dart';
import 'tables/sleep_records.dart';
import 'tables/diaper_records.dart';
import 'tables/temperature_records.dart';
import 'tables/medication_records.dart';
import 'tables/growth_records.dart';
import 'tables/vaccine_records.dart';
import 'tables/milestone_records.dart';
import 'tables/diary_records.dart';
import 'tables/app_settings.dart';
import 'tables/ai_chat_messages.dart';
import 'tables/stool_records.dart';
import 'tables/skin_records.dart';
import 'tables/allergy_records.dart';
import 'tables/doctor_visit_records.dart';
import 'tables/teeth_records.dart';
import 'tables/vision_records.dart';
import 'tables/school_records.dart';
import 'tables/exam_records.dart';
import 'tables/award_records.dart';
import 'tables/interest_class_records.dart';
import 'tables/parent_meeting_records.dart';
import 'tables/personality_records.dart';
import 'tables/emotion_records.dart';
import 'tables/hobby_records.dart';
import 'tables/photo_records.dart';
import 'tables/audio_records.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Babies,
    FeedingRecords,
    SleepRecords,
    DiaperRecords,
    TemperatureRecords,
    MedicationRecords,
    GrowthRecords,
    VaccineRecords,
    MilestoneRecords,
    DiaryRecords,
    AppSettings,
    AiChatMessages,
    StoolRecords,
    SkinRecords,
    AllergyRecords,
    DoctorVisitRecords,
    TeethRecords,
    VisionRecords,
    SchoolRecords,
    ExamRecords,
    AwardRecords,
    InterestClassRecords,
    ParentMeetingRecords,
    PersonalityRecords,
    EmotionRecords,
    HobbyRecords,
    PhotoRecords,
    AudioRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase._internal(this._db) : super(_db);
  final QueryExecutor _db;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static final AppDatabase instance = AppDatabase();
  
  static Future<AppDatabase> openAsync() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'xiaoyuanbao.db');
    final file = File(dbPath);
    final database = NativeDatabase(file);
    return AppDatabase._internal(database);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'xiaoyuanbao.db'));
    return NativeDatabase(file);
  });
}
