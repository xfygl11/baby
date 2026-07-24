import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/drift/app_database.dart';
import '../providers/app_providers.dart';
import '../ai_assistant/ai_assistant_page.dart';
import '../time_capsule/time_capsule_page.dart';
import '../word_tracker/word_tracker_page.dart';
import '../on_this_day/on_this_day_page.dart';
import '../story/story_generator_page.dart';
import '../widgets/smart_popup_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    _checkForPopup();
  }

  Future<void> _checkForPopup() async {
    final babyAsync = await ref.read(currentBabyProvider.future);
    if (babyAsync == null || !mounted) return;

    final popupService = ref.read(smartPopupServiceProvider);
    final popup = await popupService.checkForPopup(babyAsync.id);

    if (popup != null && mounted) {
      SmartPopupWidget.show(context, popup);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      _checkForPopup();
    } else {
      _pauseTimer();
    }
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return Scaffold(
      backgroundColor: theme.stageBg,
      body: babyAsync.when(
        data: (baby) {
          if (baby == null) {
            return _buildEmptyWelcome(theme);
          }
          return _buildHomeContent(theme, baby);
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.stageAccent),
        ),
        error: (error, stack) => Center(
          child: Text('加载失败: $error', style: TextStyle(color: theme.textPrimary)),
        ),
      ),
    );
  }

  Widget _buildEmptyWelcome(AppTheme theme) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(theme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: theme.stageAccent),
            SizedBox(height: theme.spacingXl),
            Text(
              '小元宝成长记',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.spacingMd),
            Text(
              '陪伴宝宝0-18岁成长的智能记录APP',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.spacingXxl * 2),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('开始记录'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingXl,
                  vertical: theme.spacingMd,
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: theme.spacingLg),
            Text(
              '说第一句话开始记录吧～',
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(AppTheme theme, Baby baby) {
    final age = DateTimeUtils.calculateAge(baby.birthDate, now: _now);
    final stage = _getGrowthStage(age);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(theme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, baby, age),
            SizedBox(height: theme.spacingXl),
            _buildAgeAdaptiveOverview(theme, baby.id, stage),
            SizedBox(height: theme.spacingXl),
            _buildRecentRecords(theme, baby.id),
            SizedBox(height: theme.spacingXl),
            _buildAgeAdaptiveQuickActions(theme, stage),
            SizedBox(height: theme.spacingXl),
            _buildSmartRecommendation(theme),
            SizedBox(height: theme.spacingXl),
            _buildFeatureEntries(theme, stage),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureEntries(AppTheme theme, GrowthStage stage) {
    final entries = <_FeatureEntry>[
      _FeatureEntry(
        icon: Icons.mailbox_outlined,
        label: '时间胶囊',
        color: const Color(0xFFE91E63),
        page: const TimeCapsulePage(),
      ),
      _FeatureEntry(
        icon: Icons.history_edu_outlined,
        label: '往日重现',
        color: const Color(0xFF9C27B0),
        page: const OnThisDayPage(),
      ),
      _FeatureEntry(
        icon: Icons.auto_stories_outlined,
        label: 'AI故事',
        color: const Color(0xFF673AB7),
        page: const StoryGeneratorPage(),
      ),
      if (stage == GrowthStage.infant ||
          stage == GrowthStage.toddler ||
          stage == GrowthStage.preschool)
        _FeatureEntry(
          icon: Icons.abc,
          label: '词汇收集',
          color: const Color(0xFF3F51B5),
          page: const WordTrackerPage(),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '更多功能',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: theme.spacingMd),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: theme.spacingMd,
          crossAxisSpacing: theme.spacingMd,
          childAspectRatio: 0.9,
          children: entries.map((entry) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => entry.page),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: entry.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                    ),
                    child: Icon(
                      entry.icon,
                      color: entry.color,
                      size: 26,
                    ),
                  ),
                  SizedBox(height: theme.spacingXs),
                  Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  GrowthStage _getGrowthStage(AgeResult age) {
    if (age.years < 1) return GrowthStage.infant;
    if (age.years < 3) return GrowthStage.toddler;
    if (age.years < 6) return GrowthStage.preschool;
    if (age.years < 12) return GrowthStage.school;
    return GrowthStage.teen;
  }

  Widget _buildHeader(AppTheme theme, Baby baby, AgeResult age) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.stageAccent,
              child: Text(
                baby.name.isNotEmpty ? baby.name[0] : '宝',
                style: TextStyle(
                  color: theme.onAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${baby.name}成长记',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: theme.spacingXs),
                  Text(
                    '陪伴是最好的礼物',
                    style: TextStyle(color: theme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacingXl),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(theme.spacingXl),
          decoration: BoxDecoration(
            color: theme.stageSurface,
            borderRadius: BorderRadius.circular(theme.radiusLg),
            border: Border.all(color: theme.stageAccent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${age.years}岁 ${age.months}月 ${age.days}天',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: theme.spacingSm),
              Text(
                '${age.hours.toString().padLeft(2, '0')}:${age.minutes.toString().padLeft(2, '0')}:${age.seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 20,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeAdaptiveOverview(AppTheme theme, String babyId, GrowthStage stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日概览',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: theme.spacingMd),
        FutureBuilder<Map<String, dynamic>>(
          future: _getStageOverviewData(babyId, stage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 100,
                        margin: i < 2 ? EdgeInsets.only(right: theme.spacingMd) : null,
                        decoration: BoxDecoration(
                          color: theme.stageSurface,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(color: theme.textTertiary.withOpacity(0.15)),
                        ),
                        child: Center(child: CircularProgressIndicator(color: theme.stageAccent, strokeWidth: 2)),
                      ),
                    ),
                ],
              );
            }

            final data = snapshot.data ?? {};
            final cards = _getStageOverviewCards(stage, data);

            return Row(
              children: cards,
            );
          },
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getStageOverviewData(String babyId, GrowthStage stage) async {
    final data = <String, dynamic>{};

    switch (stage) {
      case GrowthStage.infant:
        data['feeding'] = await ref.read(feedingRepositoryProvider).getDailyStats(babyId, DateTime.now());
        data['sleep'] = await ref.read(sleepRepositoryProvider).getDailyStats(babyId, DateTime.now());
        data['nextVaccine'] = await ref.read(vaccineRepositoryProvider).getNextVaccine(babyId);
        break;
      case GrowthStage.toddler:
        data['sleep'] = await ref.read(sleepRepositoryProvider).getDailyStats(babyId, DateTime.now());
        data['diaper'] = await ref.read(diaperRepositoryProvider).getDailyStats(babyId, DateTime.now());
        data['nextVaccine'] = await ref.read(vaccineRepositoryProvider).getNextVaccine(babyId);
        break;
      case GrowthStage.preschool:
        data['milestone'] = await ref.read(milestoneRepositoryProvider).getMilestonesByBabyId(babyId);
        data['growth'] = await ref.read(growthRepositoryProvider).getLatestGrowth(babyId);
        data['nextVaccine'] = await ref.read(vaccineRepositoryProvider).getNextVaccine(babyId);
        break;
      case GrowthStage.school:
        data['exam'] = await ref.read(examRepositoryProvider).getLatestExam(babyId);
        data['award'] = await ref.read(awardRepositoryProvider).getLatestAward(babyId);
        data['school'] = await ref.read(schoolRepositoryProvider).getCurrentSchool(babyId);
        break;
      case GrowthStage.teen:
        data['exam'] = await ref.read(examRepositoryProvider).getLatestExam(babyId);
        data['award'] = await ref.read(awardRepositoryProvider).getLatestAward(babyId);
        data['emotion'] = await ref.read(emotionRepositoryProvider).getLatestEmotion(babyId);
        break;
    }

    return data;
  }

  List<Widget> _getStageOverviewCards(GrowthStage stage, Map<String, dynamic> data) {
    final theme = AppTheme.of(context);
    final cards = <Widget>[];

    switch (stage) {
      case GrowthStage.infant:
        final feeding = data['feeding'] as Map<String, dynamic>? ?? {'count': 0, 'totalAmount': 0.0};
        final sleep = data['sleep'] as Map<String, dynamic>? ?? {'count': 0, 'totalDurationMinutes': 0};
        final vaccine = data['nextVaccine'] as VaccineRecord?;

        cards.addAll([
          Expanded(
            child: _OverviewCard(
              icon: '🍼',
              title: '今日喂养',
              primary: '${feeding['count']}次',
              secondary: '${(feeding['totalAmount'] as double).toStringAsFixed(0)}ml',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '😴',
              title: '今日睡眠',
              primary: '${sleep['count']}次',
              secondary: _formatDuration(sleep['totalDurationMinutes'] as int),
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '💉',
              title: '下次疫苗',
              primary: vaccine != null
                  ? vaccine.vaccineName.length > 6
                      ? '${vaccine.vaccineName.substring(0, 6)}...'
                      : vaccine.vaccineName
                  : '暂无',
              secondary: vaccine != null && vaccine.scheduledDate != null
                  ? '${vaccine.scheduledDate!.difference(DateTime.now()).inDays + 1}天后'
                  : '--',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.toddler:
        final sleep = data['sleep'] as Map<String, dynamic>? ?? {'count': 0, 'totalDurationMinutes': 0};
        final diaper = data['diaper'] as Map<String, dynamic>? ?? {'wetCount': 0, 'dirtyCount': 0};
        final vaccine = data['nextVaccine'] as VaccineRecord?;

        cards.addAll([
          Expanded(
            child: _OverviewCard(
              icon: '😴',
              title: '今日睡眠',
              primary: '${sleep['count']}次',
              secondary: _formatDuration(sleep['totalDurationMinutes'] as int),
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '👶',
              title: '今日尿布',
              primary: '${(diaper['wetCount'] as int?) ?? 0}湿',
              secondary: '${(diaper['dirtyCount'] as int?) ?? 0}便',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '💉',
              title: '下次疫苗',
              primary: vaccine != null
                  ? vaccine.vaccineName.length > 6
                      ? '${vaccine.vaccineName.substring(0, 6)}...'
                      : vaccine.vaccineName
                  : '暂无',
              secondary: vaccine != null && vaccine.scheduledDate != null
                  ? '${vaccine.scheduledDate!.difference(DateTime.now()).inDays + 1}天后'
                  : '--',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.preschool:
        final milestones = data['milestone'] as List<MilestoneRecord>? ?? [];
        final growth = data['growth'] as GrowthRecord?;
        final vaccine = data['nextVaccine'] as VaccineRecord?;

        cards.addAll([
          Expanded(
            child: _OverviewCard(
              icon: '🏆',
              title: '已达里程碑',
              primary: '${milestones.length}个',
              secondary: milestones.isNotEmpty ? milestones.last.name : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '📏',
              title: '最新成长',
              primary: growth?.weight != null ? '${growth!.weight}kg' : '--',
              secondary: growth?.height != null ? '${growth!.height}cm' : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '💉',
              title: '下次疫苗',
              primary: vaccine != null
                  ? vaccine.vaccineName.length > 6
                      ? '${vaccine.vaccineName.substring(0, 6)}...'
                      : vaccine.vaccineName
                  : '暂无',
              secondary: vaccine != null && vaccine.scheduledDate != null
                  ? '${vaccine.scheduledDate!.difference(DateTime.now()).inDays + 1}天后'
                  : '--',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.school:
        final exam = data['exam'] as ExamRecord?;
        final award = data['award'] as AwardRecord?;
        final school = data['school'] as SchoolRecord?;

        cards.addAll([
          Expanded(
            child: _OverviewCard(
              icon: '📚',
              title: '最近考试',
              primary: exam != null ? '${exam.score}分' : '--',
              secondary: exam != null ? '${exam.examName}' : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '🏅',
              title: '最近获奖',
              primary: award != null ? award.awardName : '--',
              secondary: award != null ? '${award.awardingOrganization}' : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '🎒',
              title: '所在学校',
              primary: school != null ? school.schoolName : '--',
              secondary: school != null ? '${school.grade}年级' : '--',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.teen:
        final exam = data['exam'] as ExamRecord?;
        final award = data['award'] as AwardRecord?;
        final emotion = data['emotion'] as EmotionRecord?;

        cards.addAll([
          Expanded(
            child: _OverviewCard(
              icon: '📚',
              title: '最近考试',
              primary: exam != null ? '${exam.score}分' : '--',
              secondary: exam != null ? '${exam.examName}' : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '🏅',
              title: '最近获奖',
              primary: award != null ? award.awardName : '--',
              secondary: award != null ? '${award.awardingOrganization}' : '--',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _OverviewCard(
              icon: '😊',
              title: '最近情绪',
              primary: emotion != null ? _getEmotionLabel(emotion.emotionType) : '--',
              secondary: emotion != null ? '${emotion.triggerEvent ?? ''}' : '--',
              onTap: () {},
            ),
          ),
        ]);
        break;
    }

    return cards;
  }

  String _getEmotionLabel(int emotionType) {
    final emotions = [
      '开心', '难过', '生气', '焦虑', '兴奋', '平静', '嫉妒', '自豪', '害羞', '疲惫'
    ];
    if (emotionType >= 0 && emotionType < emotions.length) {
      return emotions[emotionType];
    }
    return '未知';
  }

  Future<Map<String, dynamic>> _getFeedingStats(String babyId) async {
    final repo = ref.read(feedingRepositoryProvider);
    return await repo.getDailyStats(babyId, DateTime.now());
  }

  Future<Map<String, dynamic>> _getSleepStats(String babyId) async {
    final repo = ref.read(sleepRepositoryProvider);
    return await repo.getDailyStats(babyId, DateTime.now());
  }

  Future<VaccineRecord?> _getNextVaccine(String babyId) async {
    final repo = ref.read(vaccineRepositoryProvider);
    return await repo.getNextVaccine(babyId);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h${mins}m';
    }
    return '${mins}分钟';
  }

  Widget _buildRecentRecords(AppTheme theme, String babyId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近记录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: theme.spacingSm),
        FutureBuilder<List<TimelineItem>>(
          future: _getRecentRecords(babyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: theme.stageAccent),
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(theme.spacingXl),
                decoration: BoxDecoration(
                  color: theme.stageSurface,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 40, color: theme.textTertiary),
                    SizedBox(height: theme.spacingMd),
                    Text(
                      '还没有记录',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: theme.stageSurface,
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < records.length && i < 3; i++) ...[
                    _RecordItem(record: records[i]),
                    if (i < records.length - 1 && i < 2)
                      Divider(height: 1, color: theme.textTertiary.withOpacity(0.2)),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<List<TimelineItem>> _getRecentRecords(String babyId) async {
    final timelineService = ref.read(timelineServiceProvider);
    return await timelineService.getTimeline(babyId, limit: 3);
  }

  Widget _buildAgeAdaptiveQuickActions(AppTheme theme, GrowthStage stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: theme.spacingMd),
        Row(
          children: _getStageQuickActions(stage),
        ),
      ],
    );
  }

  List<Widget> _getStageQuickActions(GrowthStage stage) {
    final theme = AppTheme.of(context);
    final actions = <Widget>[];

    switch (stage) {
      case GrowthStage.infant:
        actions.addAll([
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic,
              label: '说话记录',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              isPrimary: true,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.baby_changing_station,
              label: '换尿布',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.snooze,
              label: '睡了',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.toddler:
        actions.addAll([
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic,
              label: '说话记录',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              isPrimary: true,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.baby_changing_station,
              label: '便便',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.camera_alt,
              label: '拍照',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.preschool:
        actions.addAll([
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic,
              label: '说话记录',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              isPrimary: true,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.star,
              label: '里程碑',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.edit_note,
              label: '写日记',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.school:
        actions.addAll([
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic,
              label: '说话记录',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              isPrimary: true,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.school,
              label: '考试',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.trophy,
              label: '获奖',
              onTap: () {},
            ),
          ),
        ]);
        break;
      case GrowthStage.teen:
        actions.addAll([
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic,
              label: '说话记录',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                );
              },
              isPrimary: true,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.psychology,
              label: '情绪',
              onTap: () {},
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.edit_note,
              label: '日记',
              onTap: () {},
            ),
          ),
        ]);
        break;
    }

    return actions;
  }

  Widget _buildSmartRecommendation(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.stageAccent.withOpacity(0.1),
            theme.stageAccentLight.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.stageAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(theme.spacingMd),
            decoration: BoxDecoration(
              color: theme.stageAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Icon(Icons.auto_awesome, color: theme.stageAccent, size: 28),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 智能推荐',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '试试问小元宝助手：今天总结一下？',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.stageAccent),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String icon;
  final String title;
  final String primary;
  final String secondary;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.primary,
    required this.secondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.stageSurface,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(theme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: theme.textTertiary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              SizedBox(height: theme.spacingXs),
              Text(
                title,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: theme.spacingXs),
              Text(
                primary,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                secondary,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  final TimelineItem record;

  const _RecordItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.stageBg,
                borderRadius: BorderRadius.circular(theme.radiusSm),
              ),
              child: Text(record.icon, style: const TextStyle(fontSize: 20)),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    record.subtitle,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: theme.spacingSm),
            Text(
              DateTimeUtils.relativeTime(record.time),
              style: TextStyle(
                color: theme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureEntry {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  const _FeatureEntry({
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: isPrimary ? theme.stageAccent : theme.stageSurface,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: theme.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: isPrimary
                ? null
                : Border.all(color: theme.textTertiary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isPrimary ? theme.onAccent : theme.stageAccent,
                size: 28,
              ),
              SizedBox(height: theme.spacingSm),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? theme.onAccent : theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
