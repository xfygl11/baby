import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drift/app_database.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/record_repository.dart';
import '../../data/drift/daos/settings_repository.dart';
import '../../data/drift/daos/ai_chat_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/medication_repository.dart';
import '../../data/drift/daos/stool_repository.dart';
import '../../data/drift/daos/skin_repository.dart';
import '../../data/drift/daos/allergy_repository.dart';
import '../../data/drift/daos/doctor_visit_repository.dart';
import '../../data/drift/daos/teeth_repository.dart';
import '../../data/drift/daos/vision_repository.dart';
import '../../data/drift/daos/school_repository.dart';
import '../../data/drift/daos/exam_repository.dart';
import '../../data/drift/daos/award_repository.dart';
import '../../data/drift/daos/interest_class_repository.dart';
import '../../data/drift/daos/parent_meeting_repository.dart';
import '../../data/drift/daos/personality_repository.dart';
import '../../data/drift/daos/emotion_repository.dart';
import '../../data/drift/daos/hobby_repository.dart';
import '../../data/drift/daos/photo_repository.dart';
import '../../data/drift/daos/audio_repository.dart';
import '../../data/drift/daos/quote_repository.dart';
import '../../data/drift/daos/activity_repository.dart';
import '../../data/drift/daos/growth_message_repository.dart';
import '../../data/drift/daos/expense_repository.dart';
import '../../data/drift/daos/item_repository.dart';
import '../../data/drift/daos/size_repository.dart';
import '../../services/ai/ai_service.dart';
import '../../services/media/photo_service.dart';
import '../../services/media/audio_service.dart';
import '../../services/vaccine/vaccine_service.dart';
import '../../services/growth/growth_service.dart';
import '../../services/milestone/milestone_service.dart';
import '../../services/timeline/timeline_service.dart';
import '../../services/summary/summary_service.dart';
import '../../services/popup/smart_popup_service.dart';
import '../../services/backup/backup_service.dart';
import '../../services/notification/notification_service.dart';
import '../../core/constants/app_enums.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BabyRepository(db);
});

final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FeedingRepository(db);
});

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SleepRepository(db);
});

final vaccineRepositoryProvider = Provider<VaccineRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VaccineRepository(db);
});

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GrowthRepository(db);
});

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MilestoneRepository(db);
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DiaryRepository(db);
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecordRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AiChatRepository(db);
});

final temperatureRepositoryProvider = Provider<TemperatureRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TemperatureRepository(db);
});

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MedicationRepository(db);
});

final stoolRepositoryProvider = Provider<StoolRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StoolRepository(db);
});

final skinRepositoryProvider = Provider<SkinRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SkinRepository(db);
});

final allergyRepositoryProvider = Provider<AllergyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AllergyRepository(db);
});

final doctorVisitRepositoryProvider = Provider<DoctorVisitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DoctorVisitRepository(db);
});

final teethRepositoryProvider = Provider<TeethRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TeethRepository(db);
});

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VisionRepository(db);
});

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SchoolRepository(db);
});

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExamRepository(db);
});

final awardRepositoryProvider = Provider<AwardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AwardRepository(db);
});

final interestClassRepositoryProvider = Provider<InterestClassRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InterestClassRepository(db);
});

final parentMeetingRepositoryProvider = Provider<ParentMeetingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ParentMeetingRepository(db);
});

final personalityRepositoryProvider = Provider<PersonalityRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PersonalityRepository(db);
});

final emotionRepositoryProvider = Provider<EmotionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EmotionRepository(db);
});

final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HobbyRepository(db);
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PhotoRepository(db);
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AudioRepository(db);
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return QuoteRepository(db);
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ActivityRepository(db);
});

final growthMessageRepositoryProvider = Provider<GrowthMessageRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GrowthMessageRepository(db);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ItemRepository(db);
});

final sizeRepositoryProvider = Provider<SizeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SizeRepository(db);
});

final photoServiceProvider = Provider<PhotoService>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return PhotoService(repo);
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final repo = ref.watch(audioRepositoryProvider);
  return AudioService(repo);
});

final currentBabyProvider = FutureProvider<Baby?>((ref) async {
  final repo = ref.watch(babyRepositoryProvider);
  return await repo.getActiveBaby();
});

final aiServiceProvider = ChangeNotifierProvider<AiService>((ref) {
  final db = ref.watch(databaseProvider);
  return AiService(db);
});

final vaccineServiceProvider = Provider<VaccineService>((ref) {
  final db = ref.watch(databaseProvider);
  return VaccineService(db);
});

final growthServiceProvider = Provider<GrowthService>((ref) {
  final db = ref.watch(databaseProvider);
  return GrowthService(db);
});

final milestoneServiceProvider = Provider<MilestoneService>((ref) {
  final repo = ref.watch(milestoneRepositoryProvider);
  return MilestoneService(repo);
});

final timelineServiceProvider = Provider<TimelineService>((ref) {
  final db = ref.watch(databaseProvider);
  return TimelineService(db);
});

final summaryServiceProvider = Provider<SummaryService>((ref) {
  final db = ref.watch(databaseProvider);
  return SummaryService(db);
});

final smartPopupServiceProvider = Provider<SmartPopupService>((ref) {
  final sleepRepo = ref.watch(sleepRepositoryProvider);
  final feedingRepo = ref.watch(feedingRepositoryProvider);
  final vaccineRepo = ref.watch(vaccineRepositoryProvider);
  final tempRepo = ref.watch(temperatureRepositoryProvider);
  final medRepo = ref.watch(medicationRepositoryProvider);
  final milestoneRepo = ref.watch(milestoneRepositoryProvider);
  final babyRepo = ref.watch(babyRepositoryProvider);
  return SmartPopupService(
    sleepRepository: sleepRepo,
    feedingRepository: feedingRepo,
    vaccineRepository: vaccineRepo,
    temperatureRepository: tempRepo,
    medicationRepository: medRepo,
    milestoneRepository: milestoneRepo,
    babyRepository: babyRepo,
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final themeStageProvider = StateProvider<GrowthStage>((ref) {
  return GrowthStage.infant;
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
