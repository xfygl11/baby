import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/drift/app_database.dart';
import '../../../data/drift/daos/word_repository.dart';
import '../../../data/drift/tables/word_records.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class WordTrackerPage extends ConsumerStatefulWidget {
  const WordTrackerPage({super.key});

  @override
  ConsumerState<WordTrackerPage> createState() => _WordTrackerPageState();
}

class _WordTrackerPageState extends ConsumerState<WordTrackerPage> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return babyAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.stageBg,
        body: const LoadingWidget(message: '加载中...'),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.stageBg,
        body: Center(
          child: Text(
            '加载失败: $error',
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
      ),
      data: (baby) {
        if (baby == null) {
          return Scaffold(
            backgroundColor: theme.stageBg,
            appBar: AppBar(title: const Text('词汇收集板')),
            body: const EmptyStateWidget(
              icon: Icons.child_care,
              title: '尚未添加宝宝',
              subtitle: '请先在个人中心添加宝宝信息',
            ),
          );
        }
        return _WordTrackerView(baby: baby);
      },
    );
  }
}

class _WordTrackerData {
  final List<WordRecord> words;
  final int totalCount;
  final int thisMonthCount;
  final int ageMonths;

  const _WordTrackerData({
    required this.words,
    required this.totalCount,
    required this.thisMonthCount,
    required this.ageMonths,
  });
}

class _WordTrackerView extends ConsumerStatefulWidget {
  final Baby baby;

  const _WordTrackerView({required this.baby});

  @override
  ConsumerState<_WordTrackerView> createState() => _WordTrackerViewState();
}

class _WordTrackerViewState extends ConsumerState<_WordTrackerView> {
  WordCategory? _selectedCategory;
  late Future<_WordTrackerData> _dataFuture;

  /// 发育参考里程碑：月龄 -> 期望词汇量
  static const List<({int months, int count})> _milestones = [
    (months: 18, count: 50),
    (months: 24, count: 200),
    (months: 36, count: 1000),
  ];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_WordTrackerData> _loadData() async {
    final repo = ref.read(wordRepositoryProvider);
    final babyId = widget.baby.id;
    final words = await repo.getAll(babyId);
    final now = DateTime.now();
    final thisMonthCount = words.where((w) {
      return w.firstSaidAt.year == now.year &&
          w.firstSaidAt.month == now.month;
    }).length;
    final age = DateTimeUtils.calculateAge(widget.baby.birthDate);
    final ageMonths = age.years * 12 + age.months;
    return _WordTrackerData(
      words: words,
      totalCount: words.length,
      thisMonthCount: thisMonthCount,
      ageMonths: ageMonths,
    );
  }

  void _refresh() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  void _onCategoryTap(WordCategory? category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _toggleFavorite(WordRecord word) async {
    final repo = ref.read(wordRepositoryProvider);
    await repo.updateById(
      word.id,
      WordRecordsCompanion(isFavorite: Value(!word.isFavorite)),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.stageBg,
      appBar: AppBar(title: const Text('词汇收集板')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWordDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_WordTrackerData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: '加载词汇数据...');
          }
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: '加载失败',
              subtitle: '${snapshot.error}',
              actionLabel: '重试',
              onAction: _refresh,
            );
          }
          final data = snapshot.data!;
          final filtered = _selectedCategory == null
              ? data.words
              : data.words
                  .where((w) => w.category == _selectedCategory!.name)
                  .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeaderCard(data, theme)),
              SliverToBoxAdapter(child: _buildCategoryChips(theme)),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    icon: Icons.spellcheck,
                    title: _selectedCategory == null ? '还没有记录词汇' : '该分类暂无词汇',
                    subtitle: _selectedCategory == null
                        ? '点击右下角按钮记录宝宝说的第一个词'
                        : '换个分类看看，或添加一个新词',
                    actionLabel: _selectedCategory == null ? '添加词汇' : null,
                    onAction: _selectedCategory == null ? _showAddWordDialog : null,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    theme.spacingLg,
                    theme.spacingSm,
                    theme.spacingLg,
                    theme.spacingXl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: theme.spacingSm,
                      crossAxisSpacing: theme.spacingSm,
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildWordCard(filtered[index], theme),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ==================== 头部统计卡片 ====================

  Widget _buildHeaderCard(_WordTrackerData data, AppTheme theme) {
    return Container(
      margin: EdgeInsets.all(theme.spacingLg),
      padding: EdgeInsets.all(theme.spacingLg),
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
                  color: theme.stageAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📝', style: TextStyle(fontSize: 20)),
                ),
              ),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Text(
                  '词汇总览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingSm,
                  vertical: theme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: theme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: theme.success),
                    SizedBox(width: theme.spacingXs),
                    Text(
                      '本月 +${data.thisMonthCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.totalCount}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                  height: 1,
                ),
              ),
              SizedBox(width: theme.spacingSm),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '已记录的词',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingLg),
          Container(
            height: 1,
            color: theme.stageSurface,
          ),
          SizedBox(height: theme.spacingMd),
          Row(
            children: [
              Icon(Icons.flag_outlined, size: 16, color: theme.stageAccent),
              SizedBox(width: theme.spacingXs),
              Text(
                '发育参考 · 当前 ${data.ageMonths} 个月',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          ..._milestones.map((m) => _buildMilestoneRow(m, data, theme)),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(
    ({int months, int count}) milestone,
    _WordTrackerData data,
    AppTheme theme,
  ) {
    final reached = data.totalCount >= milestone.count;
    final isCurrent = _isCurrentMilestone(milestone, data.ageMonths);
    final progress =
        (data.totalCount / milestone.count).clamp(0.0, 1.0).toDouble();
    final color = reached
        ? theme.success
        : (isCurrent ? theme.stageAccent : theme.textTertiary);

    return Padding(
      padding: EdgeInsets.only(top: theme.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              '${milestone.months}个月·${milestone.count}词',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? theme.textPrimary : theme.textSecondary,
              ),
            ),
          ),
          SizedBox(width: theme.spacingSm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radiusPill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.stageSurface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          SizedBox(width: theme.spacingSm),
          SizedBox(
            width: 56,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reached)
                  Icon(Icons.check_circle, size: 14, color: theme.success)
                else
                  Text(
                    '${data.totalCount}/${milestone.count}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentMilestone(
      ({int months, int count}) milestone, int ageMonths) {
    if (ageMonths < _milestones.first.months) {
      return milestone.months == _milestones.first.months;
    }
    for (int i = 0; i < _milestones.length; i++) {
      if (ageMonths < _milestones[i].months) {
        return milestone.months == _milestones[i].months;
      }
    }
    return milestone.months == _milestones.last.months;
  }

  // ==================== 分类筛选 ====================

  Widget _buildCategoryChips(AppTheme theme) {
    final chips = <_CategoryChipData>[
      _CategoryChipData(label: '全部', emoji: '📚', category: null),
      ...WordCategory.values.map(
        (c) => _CategoryChipData(
          label: c.label,
          emoji: _categoryEmoji(c),
          category: c,
        ),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: theme.spacingLg),
        itemCount: chips.length,
        separatorBuilder: (_, __) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final selected = _selectedCategory == chip.category;
          return Center(
            child: GestureDetector(
              onTap: () => _onCategoryTap(chip.category),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: selected ? theme.stageAccent : theme.stageSurface,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  border: Border.all(
                    color: selected
                        ? theme.stageAccent
                        : theme.textTertiary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chip.emoji, style: const TextStyle(fontSize: 13)),
                    SizedBox(width: theme.spacingXs),
                    Text(
                      chip.label,
                      style: TextStyle(
                        color: selected
                            ? theme.onAccent
                            : theme.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== 词汇卡片 ====================

  Widget _buildWordCard(WordRecord word, AppTheme theme) {
    return GestureDetector(
      onTap: () => _showDetailSheet(word),
      child: Container(
        padding: EdgeInsets.all(theme.spacingMd),
        decoration: BoxDecoration(
          color: theme.paper,
          borderRadius: BorderRadius.circular(theme.radiusLg),
          border: Border.all(
            color: word.isFavorite
                ? theme.milestoneGold.withOpacity(0.4)
                : theme.stageSurface,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.stageAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(theme.radiusPill),
                  ),
                  child: Text(
                    _categoryLabel(word.category),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.stageAccentDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleFavorite(word),
                  child: Icon(
                    word.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 22,
                    color: word.isFavorite
                        ? theme.milestoneGold
                        : theme.textTertiary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              word.word,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (word.pinyin != null && word.pinyin!.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                word.pinyin!,
                style: TextStyle(fontSize: 12, color: theme.textTertiary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: theme.spacingXs),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 12, color: theme.textTertiary),
                SizedBox(width: theme.spacingXs),
                Expanded(
                  child: Text(
                    DateTimeUtils.formatDateCn(word.firstSaidAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 添加词汇对话框 ====================

  void _showAddWordDialog() {
    final theme = AppTheme.of(context);
    final wordCtrl = TextEditingController();
    final pinyinCtrl = TextEditingController();
    final contextCtrl = TextEditingController();
    final speakerCtrl = TextEditingController();
    var selectedCategory = WordCategory.other;
    var selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('记录新词'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wordCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '词汇 *',
                    hintText: '宝宝说的新词',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: theme.spacingMd),
                TextField(
                  controller: pinyinCtrl,
                  decoration: const InputDecoration(
                    labelText: '拼音',
                    hintText: '可选',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: theme.spacingMd),
                DropdownButtonFormField<WordCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                  items: WordCategory.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Text(_categoryEmoji(c),
                                    style: const TextStyle(fontSize: 16)),
                                SizedBox(width: theme.spacingSm),
                                Text(c.label),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedCategory = v);
                    }
                  },
                ),
                SizedBox(height: theme.spacingMd),
                TextField(
                  controller: contextCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '情境',
                    hintText: '在什么场景下说的',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: theme.spacingMd),
                TextField(
                  controller: speakerCtrl,
                  decoration: const InputDecoration(
                    labelText: '对谁说的',
                    hintText: '可选',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: theme.spacingMd),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: widget.baby.birthDate,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '首次说出日期',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: theme.stageAccent),
                        SizedBox(width: theme.spacingSm),
                        Text(
                          DateTimeUtils.formatDateCn(selectedDate),
                          style: TextStyle(color: theme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final word = wordCtrl.text.trim();
                if (word.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入词汇')),
                  );
                  return;
                }
                final repo = ref.read(wordRepositoryProvider);
                final existing =
                    await repo.findByWord(widget.baby.id, word);
                if (existing != null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('这个词已经记录过了')),
                  );
                  return;
                }
                final pinyin = pinyinCtrl.text.trim();
                final contextText = contextCtrl.text.trim();
                final speaker = speakerCtrl.text.trim();
                await repo.insert(WordRecordsCompanion(
                  babyId: Value(widget.baby.id),
                  word: Value(word),
                  pinyin: Value(pinyin.isEmpty ? null : pinyin),
                  context: Value(contextText.isEmpty ? null : contextText),
                  speaker: Value(speaker.isEmpty ? null : speaker),
                  category: Value(selectedCategory.name),
                  firstSaidAt: Value(selectedDate),
                  isFavorite: const Value(false),
                ));
                if (!mounted) return;
                Navigator.of(ctx).pop();
                _refresh();
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 词汇详情底部弹层 ====================

  void _showDetailSheet(WordRecord word) {
    final theme = AppTheme.of(context);
    var favorite = word.isFavorite;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusLg),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacingLg,
                theme.spacingMd,
                theme.spacingLg,
                theme.spacingLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.stageSurface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: theme.spacingLg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                              ),
                            ),
                            if (word.pinyin != null &&
                                word.pinyin!.isNotEmpty) ...[
                              SizedBox(height: theme.spacingXs),
                              Text(
                                word.pinyin!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final repo = ref.read(wordRepositoryProvider);
                          await repo.updateById(
                            word.id,
                            WordRecordsCompanion(
                                isFavorite: Value(!favorite)),
                          );
                          setSheetState(() => favorite = !favorite);
                          _refresh();
                        },
                        child: Icon(
                          favorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: favorite
                              ? theme.milestoneGold
                              : theme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacingMd),
                  Wrap(
                    spacing: theme.spacingSm,
                    runSpacing: theme.spacingXs,
                    children: [
                      _buildDetailChip(
                        _categoryEmoji(_parseCategory(word.category)),
                        _categoryLabel(word.category),
                        theme,
                      ),
                      _buildDetailChip(
                        '📅',
                        DateTimeUtils.formatDateCn(word.firstSaidAt),
                        theme,
                      ),
                      if (word.speaker != null &&
                          word.speaker!.isNotEmpty)
                        _buildDetailChip(
                          '🗣️',
                          '对 ${word.speaker}',
                          theme,
                        ),
                    ],
                  ),
                  if (word.context != null &&
                      word.context!.isNotEmpty) ...[
                    SizedBox(height: theme.spacingLg),
                    Text(
                      '情境',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    SizedBox(height: theme.spacingXs),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(theme.spacingMd),
                        decoration: BoxDecoration(
                          color: theme.stageSurface,
                          borderRadius:
                              BorderRadius.circular(theme.radiusMd),
                        ),
                        child: Text(
                          word.context!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                  SizedBox(height: theme.spacingXl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: ctx,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('删除词汇'),
                                content: Text('确定要删除「${word.word}」吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dCtx).pop(false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dCtx).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.danger,
                                    ),
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            final repo = ref.read(wordRepositoryProvider);
                            await repo.deleteById(word.id);
                            if (!mounted) return;
                            Navigator.of(ctx).pop();
                            _refresh();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.danger,
                            side: BorderSide(color: theme.danger),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('删除'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailChip(String emoji, String text, AppTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingXs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        borderRadius: BorderRadius.circular(theme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          SizedBox(width: theme.spacingXs),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================

  String _categoryLabel(String? category) {
    return _parseCategory(category).label;
  }

  WordCategory _parseCategory(String? category) {
    if (category == null) return WordCategory.other;
    try {
      return WordCategory.values.byName(category);
    } catch (_) {
      return WordCategory.other;
    }
  }

  String _categoryEmoji(WordCategory category) {
    return switch (category) {
      WordCategory.animal => '🐾',
      WordCategory.food => '🍎',
      WordCategory.family => '👨‍👩‍👧',
      WordCategory.action => '🏃',
      WordCategory.adjective => '✨',
      WordCategory.onomatopoeia => '🔊',
      WordCategory.pronoun => '👤',
      WordCategory.number => '🔢',
      WordCategory.body => '🖐️',
      WordCategory.vehicle => '🚗',
      WordCategory.other => '💬',
    };
  }
}

class _CategoryChipData {
  final String label;
  final String emoji;
  final WordCategory? category;

  const _CategoryChipData({
    required this.label,
    required this.emoji,
    required this.category,
  });
}
