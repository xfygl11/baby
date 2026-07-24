enum RecordCategory {
  feeding,
  sleep,
  diaper,
  temperature,
  medication,
  stool,
  skin,
  allergy,
  doctorVisit,
  teeth,
  vision,
  milestone,
  vaccine,
  growth,
  diary,
  quote,
  activity,
  school,
  exam,
  homework,
  award,
  interest,
  parentMeeting,
  personality,
  emotion,
  festival,
  expense,
  photo,
  video,
  audio,
  capsule,
  word,
}

extension RecordCategoryX on RecordCategory {
  String get label {
    return switch (this) {
      RecordCategory.feeding => '喂养',
      RecordCategory.sleep => '睡眠',
      RecordCategory.diaper => '尿布',
      RecordCategory.temperature => '体温',
      RecordCategory.medication => '用药',
      RecordCategory.stool => '大便',
      RecordCategory.skin => '皮肤',
      RecordCategory.allergy => '过敏',
      RecordCategory.doctorVisit => '就诊',
      RecordCategory.teeth => '牙齿',
      RecordCategory.vision => '视力',
      RecordCategory.milestone => '里程碑',
      RecordCategory.vaccine => '疫苗',
      RecordCategory.growth => '生长',
      RecordCategory.diary => '日记',
      RecordCategory.quote => '语录',
      RecordCategory.activity => '互动',
      RecordCategory.school => '上学',
      RecordCategory.exam => '考试',
      RecordCategory.homework => '作业',
      RecordCategory.award => '获奖',
      RecordCategory.interest => '兴趣班',
      RecordCategory.parentMeeting => '家长会',
      RecordCategory.personality => '性格',
      RecordCategory.emotion => '情绪',
      RecordCategory.festival => '节日',
      RecordCategory.expense => '费用',
      RecordCategory.photo => '照片',
      RecordCategory.video => '视频',
      RecordCategory.audio => '声音',
      RecordCategory.capsule => '胶囊',
      RecordCategory.word => '词汇',
    };
  }

  String get icon {
    return switch (this) {
      RecordCategory.feeding => '🍼',
      RecordCategory.sleep => '😴',
      RecordCategory.diaper => '👶',
      RecordCategory.temperature => '🌡️',
      RecordCategory.medication => '💊',
      RecordCategory.stool => '💩',
      RecordCategory.skin => '🩹',
      RecordCategory.allergy => '⚠️',
      RecordCategory.doctorVisit => '🏥',
      RecordCategory.teeth => '🦷',
      RecordCategory.vision => '👁️',
      RecordCategory.milestone => '🏆',
      RecordCategory.vaccine => '💉',
      RecordCategory.growth => '📏',
      RecordCategory.diary => '📝',
      RecordCategory.quote => '💬',
      RecordCategory.activity => '🤹',
      RecordCategory.school => '🎒',
      RecordCategory.exam => '📚',
      RecordCategory.homework => '📖',
      RecordCategory.award => '🏅',
      RecordCategory.interest => '🎨',
      RecordCategory.parentMeeting => '👨‍👩‍👧',
      RecordCategory.personality => '🧠',
      RecordCategory.emotion => '😊',
      RecordCategory.festival => '🎉',
      RecordCategory.expense => '💰',
      RecordCategory.photo => '📷',
      RecordCategory.video => '🎬',
      RecordCategory.audio => '🎵',
      RecordCategory.capsule => '⏳',
      RecordCategory.word => '🔤',
    };
  }
}

enum BabyGender { female, male, unknown }

enum FeedingType { breastMilk, formula, solidFood, water, juice, other }

enum BreastSide { left, right, both }

enum SleepType { night, nap, micro }

enum SleepLocation { crib, bed, stroller, carSeat, carrier, other }

enum DiaperType { wet, dirty, mixed }

enum StoolColor { brown, yellow, green, black, red, white, gray }

enum TemperatureSite { armpit, ear, forehead, rectal, oral }

enum VaccineCategory { national, optional }

enum VaccineStatus { scheduled, completed, delayed, skipped, contraindicated }

enum MilestoneCategory { motor, language, cognitive, social, feeding, other }

enum GrowthStage { infant, toddler, preschool, school, teen }

enum PopupType {
  sleepWindow,
  sleepWake,
  nightWake,
  feedingInterval,
  vaccineReminder,
  temperatureCheck,
  medicationReminder,
  milestoneCheck,
  dailySummary,
  birthday,
  anomalyAlert,
}

enum PopupPriority { p0, p1, p2, p3 }

enum AiIntent {
  recordFeeding,
  recordBreastfeeding,
  recordSolidFood,
  queryFeedingToday,
  recordSleepStart,
  recordSleepEnd,
  querySleepToday,
  recordDiaper,
  recordTemperature,
  recordMedication,
  recordMilestone,
  recordVaccine,
  queryNextVaccine,
  recordGrowth,
  queryGrowth,
  predictGrowth,
  recordStool,
  recordSkin,
  recordAllergy,
  recordDoctorVisit,
  recordTeeth,
  recordVision,
  recordSchool,
  recordExam,
  recordAward,
  recordInterestClass,
  recordPersonality,
  recordEmotion,
  recordQuote,
  recordActivity,
  recordDiary,
  recordExpense,
  generateStory,
  dailySummary,
  annualReport,
  aiAdvice,
  setReminder,
  queryGeneral,
  showHelp,
  chat,
  unknown,
}

enum DialogState { idle, waitingTime, waitingAmount, waitingConfirm, waitingClarify }
