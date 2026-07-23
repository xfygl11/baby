import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/babies.dart';
import 'tables/feeding_records.dart';
import 'tables/sleep_records.dart';
import 'tables/diaper_records.dart';
import 'tables/growth_records.dart';
import 'tables/vaccine_records.dart';
import 'tables/diary_records.dart';
import 'tables/ai_chat_messages.dart';
import 'tables/milestone_records.dart';
import 'tables/medicine_records.dart';
import 'tables/bath_records.dart';
import 'tables/play_records.dart';
import 'tables/tummy_time_records.dart';
import 'tables/app_settings.dart';
import 'tables/ai_interaction_logs.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Babies,
    FeedingRecords,
    SleepRecords,
    DiaperRecords,
    GrowthRecords,
    VaccineRecords,
    DiaryRecords,
    AiChatMessages,
    MilestoneRecords,
    MedicineRecords,
    BathRecords,
    PlayRecords,
    TummyTimeRecords,
    AppSettings,
    AiInteractionLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static final AppDatabase instance = AppDatabase();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'xiaoyuanbao.db'));
    return NativeDatabase.createInBackground(file);
  });
}
