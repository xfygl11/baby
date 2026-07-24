import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/drift/app_database.dart';
import '../../../data/drift/daos/time_capsule_repository.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class TimeCapsulePage extends ConsumerStatefulWidget {
  const TimeCapsulePage({super.key});

  @override
  ConsumerState<TimeCapsulePage> createState() => _TimeCapsulePageState();
}

/// 三个分区的聚合数据
class _CapsuleData {
  final TimeCapsuleRecord? nearest;
  final List<TimeCapsuleRecord> sealed;
  final List<TimeCapsuleRecord> ready;
  final List<TimeCapsuleRecord> unlocked;

  const _CapsuleData({
    required this.nearest,
    required this.sealed,
    required this.ready,
    required this.unlocked,
  });
}

class _TimeCapsulePageState extends ConsumerState<TimeCapsulePage> {
  String? _babyId;
  late Future<_CapsuleData> _dataFuture;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.value(const _CapsuleData(
      nearest: null,
      sealed: [],
      ready: [],
      unlocked: [],
    ));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<_CapsuleData> _loadData(String babyId) async {
    final repo = ref.read(timeCapsuleRepositoryProvider);
    final results = await Future.wait([
      repo.getNearestUnlocking(babyId),
      repo.getSealed(babyId),
      repo.getReadyToUnlock(babyId),
      repo.getUnlocked(babyId),
    ]);
    return _CapsuleData(
      nearest: results[0] as TimeCapsuleRecord?,
      sealed: results[1] as List<TimeCapsuleRecord>,
      ready: results[2] as List<TimeCapsuleRecord>,
      unlocked: results[3] as List<TimeCapsuleRecord>,
    );
  }

  void _reload() {
    final babyId = _babyId;
    if (babyId == null) return;
    setState(() {
      _dataFuture = _loadData(babyId);
    });
  }

  void _showCreateDialog(Baby baby) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _CreateCapsuleDialog(baby: baby),
    );
    if (created == true) {
      _reload();
    }
  }

  Future<void> _unlock(TimeCapsuleRecord capsule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('开启时间胶囊'),
        content: Text(
          '「${capsule.title}」封存于 ${DateTimeUtils.formatDateCn(capsule.sealedAt)}，'
          '现在已经到了开启的时刻。要现在打开它吗？',
          style: TextStyle(fontSize: 14, color: AppTheme.of(ctx).textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('再等等'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('开启'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(timeCapsuleRepositoryProvider);
    await repo.markUnlocked(capsule.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('时间胶囊已开启 ✨')),
    );
    _reload();
  }

  void _showDetail(TimeCapsuleRecord capsule) {
    showDialog(
      context: context,
      builder: (_) => _CapsuleDetailDialog(capsule: capsule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return Scaffold(
      backgroundColor: theme.stageBg,
      appBar: AppBar(title: const Text('时间胶囊')),
      body: babyAsync.when(
        loading: () => const LoadingWidget(message: '加载中...'),
        error: (error, stack) => Center(
          child: Text(
            '加载失败: $error',
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
        data: (baby) {
          if (baby == null) {
            return const EmptyStateWidget(
              icon: Icons.child_care,
              title: '尚未添加宝宝',
              subtitle: '请先在个人中心添加宝宝信息',
            );
          }
          if (baby.id != _babyId) {
            _babyId = baby.id;
            _dataFuture = _loadData(baby.id);
          }
          return _buildBody(theme, baby);
        },
      ),
      floatingActionButton: babyAsync.maybeWhen(
        data: (baby) => baby == null
            ? null
            : FloatingActionButton(
                onPressed: () => _showCreateDialog(baby),
                child: const Icon(Icons.add),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildBody(AppTheme theme, Baby baby) {
    return FutureBuilder<_CapsuleData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '加载胶囊中...');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
          );
        }
        final data = snapshot.data!;
        final nearest = data.nearest;
        // 顶部卡片已经突出展示 nearest，列表中不再重复
        final sealed = nearest == null
            ? data.sealed
            : data.sealed.where((c) => c.id != nearest.id).toList();
        final ready = data.ready;
        final unlocked = data.unlocked;

        final allEmpty = nearest == null &&
            sealed.isEmpty &&
            ready.isEmpty &&
            unlocked.isEmpty;
        if (allEmpty) {
          return EmptyStateWidget(
            icon: Icons.mail_outline,
            title: '还没有时间胶囊',
            subtitle: '把今天的话封存起来，留给未来的萱萱',
            actionLabel: '创建胶囊',
            onAction: () => _showCreateDialog(baby),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(theme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nearest != null) ...[
                  _buildCountdownCard(nearest, theme),
                  SizedBox(height: theme.spacingLg),
                ],
                if (ready.isNotEmpty) ...[
                  _buildSectionHeader('可解锁', ready.length, theme),
                  SizedBox(height: theme.spacingSm),
                  ...ready.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: theme.spacingSm),
                        child: _buildReadyCard(c, theme),
                      )),
                  SizedBox(height: theme.spacingLg),
                ],
                if (sealed.isNotEmpty) ...[
                  _buildSectionHeader('待解锁', sealed.length, theme),
                  SizedBox(height: theme.spacingSm),
                  ...sealed.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: theme.spacingSm),
                        child: _buildSealedCard(c, theme),
                      )),
                  SizedBox(height: theme.spacingLg),
                ],
                if (unlocked.isNotEmpty) ...[
                  _buildSectionHeader('已解锁', unlocked.length, theme),
                  SizedBox(height: theme.spacingSm),
                  ...unlocked.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: theme.spacingSm),
                        child: _buildUnlockedCard(c, theme),
                      )),
                ],
                SizedBox(height: theme.spacingXxl),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== 顶部倒计时卡片 ====================

  Widget _buildCountdownCard(TimeCapsuleRecord capsule, AppTheme theme) {
    final remaining = capsule.unlockAt.difference(_now);
    final countdown = _formatCountdown(remaining);
    final days = remaining.inDays;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.stageAccent, theme.stageAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: theme.stageAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📬', style: TextStyle(fontSize: 24)),
              SizedBox(width: theme.spacingSm),
              Text(
                '下一封时间胶囊',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.onAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Text(
            capsule.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.onAccent,
            ),
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: theme.onAccent,
                ),
              ),
              SizedBox(width: theme.spacingXs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '天',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.onAccent.withOpacity(0.9),
                  ),
                ),
              ),
              const Spacer(),
              if (capsule.mood != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacingSm,
                    vertical: theme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.onAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(theme.radiusPill),
                  ),
                  child: Text(
                    capsule.mood!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.onAccent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            countdown,
            style: TextStyle(
              fontSize: 13,
              color: theme.onAccent.withOpacity(0.85),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            children: [
              Icon(Icons.event, size: 14, color: theme.onAccent.withOpacity(0.85)),
              SizedBox(width: theme.spacingXs),
              Text(
                '解锁日期 ${DateTimeUtils.formatDateCn(capsule.unlockAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.onAccent.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 分区标题 ====================

  Widget _buildSectionHeader(String title, int count, AppTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.spacingXs),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(width: theme.spacingXs),
          Text(
            '($count)',
            style: TextStyle(fontSize: 14, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ==================== 可解锁卡片 ====================

  Widget _buildReadyCard(TimeCapsuleRecord capsule, AppTheme theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.milestoneGold.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.milestoneGold.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.milestoneGold.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔓', style: TextStyle(fontSize: 22)),
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  capsule.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingXs),
                Text(
                  '封存于 ${DateTimeUtils.formatDateCn(capsule.sealedAt)}，可以开启了',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: theme.spacingSm),
          FilledButton(
            onPressed: () => _unlock(capsule),
            style: FilledButton.styleFrom(
              backgroundColor: theme.milestoneGold,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacingMd,
                vertical: theme.spacingXs,
              ),
            ),
            child: const Text('解锁'),
          ),
        ],
      ),
    );
  }

  // ==================== 待解锁（密封）卡片 ====================

  Widget _buildSealedCard(TimeCapsuleRecord capsule, AppTheme theme) {
    final remaining = capsule.unlockAt.difference(_now);
    final countdown = _formatCountdown(remaining);

    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.stageSurface,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔒', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      capsule.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '封存于 ${DateTimeUtils.formatDateCn(capsule.sealedAt)}',
                      style: TextStyle(fontSize: 12, color: theme.textTertiary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingSm,
                  vertical: theme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: theme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                ),
                child: Text(
                  countdown,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.info,
                  ),
                ),
              ),
            ],
          ),
          if (capsule.letter != null && capsule.letter!.isNotEmpty) ...[
            SizedBox(height: theme.spacingMd),
            SizedBox(
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(theme.radiusSm),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 底层：信件文字（将被模糊覆盖）
                    Padding(
                      padding: EdgeInsets.all(theme.spacingSm),
                      child: Text(
                        capsule.letter!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                    // 中层：模糊覆盖，营造封存感
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: theme.stageSurface.withOpacity(0.55),
                      ),
                    ),
                    // 顶层：封存提示
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline,
                              size: 15, color: theme.textSecondary),
                          SizedBox(width: theme.spacingXs),
                          Text(
                            '信件已封存，解锁后可见',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: theme.spacingSm),
          Row(
            children: [
              Icon(Icons.event,
                  size: 13, color: theme.textTertiary),
              SizedBox(width: theme.spacingXs),
              Text(
                '解锁日期 ${DateTimeUtils.formatDateCn(capsule.unlockAt)}',
                style: TextStyle(fontSize: 12, color: theme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 已解锁卡片 ====================

  Widget _buildUnlockedCard(TimeCapsuleRecord capsule, AppTheme theme) {
    final preview = capsule.letter ?? '';
    return Material(
      color: theme.paper,
      borderRadius: BorderRadius.circular(theme.radiusLg),
      child: InkWell(
        onTap: () => _showDetail(capsule),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        child: Container(
          padding: EdgeInsets.all(theme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusLg),
            border: Border.all(color: theme.stageSurface, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💌', style: TextStyle(fontSize: 22)),
                ),
              ),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            capsule.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        if (capsule.mood != null) ...[
                          SizedBox(width: theme.spacingXs),
                          Text(
                            capsule.mood!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      preview.isEmpty
                          ? '开启于 ${DateTimeUtils.formatDateCn(capsule.unlockedAt ?? capsule.unlockAt)}'
                          : preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                    SizedBox(height: theme.spacingXs),
                    Row(
                      children: [
                        if (capsule.photoPath != null)
                          _buildMediaTag(Icons.photo_outlined, theme),
                        if (capsule.audioPath != null)
                          Padding(
                            padding: EdgeInsets.only(left: theme.spacingXs),
                            child: _buildMediaTag(Icons.graphic_eq, theme),
                          ),
                        if (capsule.videoPath != null)
                          Padding(
                            padding: EdgeInsets.only(left: theme.spacingXs),
                            child: _buildMediaTag(Icons.videocam_outlined, theme),
                          ),
                        const Spacer(),
                        Text(
                          capsule.unlockedAt != null
                              ? DateTimeUtils.formatDateCn(capsule.unlockedAt!)
                              : '',
                          style: TextStyle(
                              fontSize: 11, color: theme.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: theme.spacingSm),
              Icon(Icons.chevron_right,
                  size: 20, color: theme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTag(IconData icon, AppTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        borderRadius: BorderRadius.circular(theme.radiusSm),
      ),
      child: Icon(icon, size: 14, color: theme.textTertiary),
    );
  }

  // ==================== 工具方法 ====================

  String _formatCountdown(Duration d) {
    if (d.isNegative) return '已到期';
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (days > 0) {
      return '还有 $days 天 $hours 小时';
    }
    if (hours > 0) {
      return '还有 $hours 小时 $minutes 分钟';
    }
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '还有 $mm:$ss';
  }
}

// ==================== 创建时间胶囊对话框 ====================

class _CreateCapsuleDialog extends ConsumerStatefulWidget {
  final Baby baby;

  const _CreateCapsuleDialog({required this.baby});

  @override
  ConsumerState<_CreateCapsuleDialog> createState() =>
      _CreateCapsuleDialogState();
}

class _CreateCapsuleDialogState extends ConsumerState<_CreateCapsuleDialog> {
  final _titleCtrl = TextEditingController();
  final _letterCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _mood;
  DateTime? _unlockDate;
  bool _saving = false;

  static const _moodOptions = <String>['开心', '感动', '期待', '怀念', '温暖', '爱意'];

  static const _preset18 = '18岁生日';
  static const _presetMarry = '结婚那天';
  static const _preset1y = '1年后';
  static const _preset5y = '5年后';
  static const _presetCustom = '自定义';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _letterCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String label) async {
    final baby = widget.baby;
    final now = DateTime.now();
    switch (label) {
      case _preset18:
        setState(() => _unlockDate = DateTime(
            baby.birthDate.year + 18, baby.birthDate.month, baby.birthDate.day));
        break;
      case _presetMarry:
        // 结婚日期无法预知，这里以成年后约 10 年作为象征性未来日期，
        // 用户可继续点击“自定义”调整。
        setState(() => _unlockDate = DateTime(
            baby.birthDate.year + 28, baby.birthDate.month, baby.birthDate.day));
        break;
      case _preset1y:
        setState(() =>
            _unlockDate = DateTime(now.year + 1, now.month, now.day));
        break;
      case _preset5y:
        setState(() =>
            _unlockDate = DateTime(now.year + 5, now.month, now.day));
        break;
      case _presetCustom:
        final picked = await showDatePicker(
          context: context,
          initialDate: now.add(const Duration(days: 1)),
          firstDate: now,
          lastDate: DateTime(now.year + 100),
          helpText: '选择解锁日期',
        );
        if (picked != null && mounted) {
          setState(() => _unlockDate = picked);
        }
        break;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_unlockDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择解锁时间')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(timeCapsuleRepositoryProvider);
      final letterText = _letterCtrl.text.trim();
      await repo.insert(TimeCapsuleRecordsCompanion(
        babyId: Value(widget.baby.id),
        title: Value(_titleCtrl.text.trim()),
        letter: Value(letterText.isEmpty ? null : letterText),
        mood: Value(_mood),
        sealedAt: Value(DateTime.now()),
        unlockAt: Value(_unlockDate!),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final presets = [
      _preset18,
      _presetMarry,
      _preset1y,
      _preset5y,
      _presetCustom,
    ];

    return AlertDialog(
      title: const Text('新建时间胶囊'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '给未来的萱萱起个名字',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
              SizedBox(height: theme.spacingMd),
              TextFormField(
                controller: _letterCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '信件内容',
                  hintText: '写下此刻想说的话…',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: theme.spacingMd),
              Text('心情', style: TextStyle(
                fontSize: 13, color: theme.textSecondary)),
              SizedBox(height: theme.spacingXs),
              Wrap(
                spacing: theme.spacingSm,
                runSpacing: theme.spacingXs,
                children: _moodOptions.map((m) {
                  final selected = _mood == m;
                  return GestureDetector(
                    onTap: () => setState(() => _mood = selected ? null : m),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacingMd,
                        vertical: theme.spacingXs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.stageAccent
                            : theme.stageSurface,
                        borderRadius: BorderRadius.circular(theme.radiusPill),
                        border: Border.all(
                          color: selected
                              ? theme.stageAccent
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? theme.onAccent : theme.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: theme.spacingMd),
              Text('解锁时间', style: TextStyle(
                fontSize: 13, color: theme.textSecondary)),
              SizedBox(height: theme.spacingXs),
              Wrap(
                spacing: theme.spacingSm,
                runSpacing: theme.spacingXs,
                children: presets.map((p) {
                  final isCustom = p == _presetCustom;
                  final selected = !isCustom && _unlockDate != null &&
                      _isPresetActive(p);
                  return GestureDetector(
                    onTap: () => _applyPreset(p),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacingMd,
                        vertical: theme.spacingXs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.stageAccent.withOpacity(0.12)
                            : theme.stageSurface,
                        borderRadius: BorderRadius.circular(theme.radiusPill),
                        border: Border.all(
                          color: selected
                              ? theme.stageAccent
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? theme.stageAccentDark
                              : theme.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_unlockDate != null) ...[
                SizedBox(height: theme.spacingSm),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(theme.spacingSm),
                  decoration: BoxDecoration(
                    color: theme.stageAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_available,
                          size: 16, color: theme.stageAccentDark),
                      SizedBox(width: theme.spacingXs),
                      Expanded(
                        child: Text(
                          '将于 ${DateTimeUtils.formatDateCn(_unlockDate!)} 解锁',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.stageAccentDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? '保存中…' : '封存'),
        ),
      ],
    );
  }

  /// 判断某个预设当前是否处于选中态
  bool _isPresetActive(String preset) {
    if (_unlockDate == null) return false;
    final baby = widget.baby;
    final now = DateTime.now();
    final d = _unlockDate!;
    switch (preset) {
      case _preset18:
        return d.year == baby.birthDate.year + 18 &&
            d.month == baby.birthDate.month &&
            d.day == baby.birthDate.day;
      case _presetMarry:
        return d.year == baby.birthDate.year + 28 &&
            d.month == baby.birthDate.month &&
            d.day == baby.birthDate.day;
      case _preset1y:
        return d.year == now.year + 1 && d.month == now.month && d.day == now.day;
      case _preset5y:
        return d.year == now.year + 5 && d.month == now.month && d.day == now.day;
      default:
        return false;
    }
  }
}

// ==================== 已解锁胶囊详情对话框 ====================

class _CapsuleDetailDialog extends StatelessWidget {
  final TimeCapsuleRecord capsule;

  const _CapsuleDetailDialog({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Dialog(
      backgroundColor: theme.paper,
      insetPadding: EdgeInsets.all(theme.spacingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radiusLg),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(theme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💌', style: TextStyle(fontSize: 28)),
                SizedBox(width: theme.spacingSm),
                Expanded(
                  child: Text(
                    capsule.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: theme.spacingSm),
            Wrap(
              spacing: theme.spacingSm,
              runSpacing: theme.spacingXs,
              children: [
                _buildMetaChip(
                  Icons.schedule,
                  '封存 ${DateTimeUtils.formatDateCn(capsule.sealedAt)}',
                  theme,
                ),
                _buildMetaChip(
                  Icons.lock_open,
                  '开启 ${DateTimeUtils.formatDateCn(capsule.unlockedAt ?? capsule.unlockAt)}',
                  theme,
                ),
                if (capsule.mood != null)
                  _buildMetaChip(Icons.mood, capsule.mood!, theme),
              ],
            ),
            SizedBox(height: theme.spacingLg),
            if (capsule.photoPath != null &&
                capsule.photoPath!.isNotEmpty) ...[
              _buildPhoto(theme),
              SizedBox(height: theme.spacingLg),
            ],
            Text(
              '信件内容',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            SizedBox(height: theme.spacingSm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(theme.spacingMd),
              decoration: BoxDecoration(
                color: theme.stageSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: theme.stageSurface, width: 1),
              ),
              child: Text(
                capsule.letter?.isNotEmpty == true
                    ? capsule.letter!
                    : '（这封胶囊没有写下文字）',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.textPrimary,
                ),
              ),
            ),
            if (capsule.audioPath != null &&
                capsule.audioPath!.isNotEmpty) ...[
              SizedBox(height: theme.spacingLg),
              _buildAudioStub(theme),
            ],
            SizedBox(height: theme.spacingLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text, AppTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingSm,
        vertical: theme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        borderRadius: BorderRadius.circular(theme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.textTertiary),
          SizedBox(width: theme.spacingXs),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(AppTheme theme) {
    final file = File(capsule.photoPath!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: Image.file(
        file,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: double.infinity,
          height: 220,
          color: theme.stageSurface,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined,
                  size: 40, color: theme.textTertiary),
              SizedBox(height: theme.spacingXs),
              Text(
                '图片无法加载',
                style: TextStyle(fontSize: 12, color: theme.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioStub(AppTheme theme) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(theme.spacingMd),
        decoration: BoxDecoration(
          color: theme.stageAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: theme.stageAccent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.graphic_eq, color: theme.stageAccentDark),
            SizedBox(width: theme.spacingSm),
            Expanded(
              child: Text(
                '语音留言',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('音频播放功能开发中')),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('播放'),
            ),
          ],
        ),
      ),
    );
  }
}
