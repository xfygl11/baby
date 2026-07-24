import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../services/memory/on_this_day_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class OnThisDayPage extends ConsumerStatefulWidget {
  const OnThisDayPage({super.key});

  @override
  ConsumerState<OnThisDayPage> createState() => _OnThisDayPageState();
}

class _OnThisDayPageState extends ConsumerState<OnThisDayPage> {
  String? _babyId;
  late Future<List<OnThisDayMemory>> _memoriesFuture;

  @override
  void initState() {
    super.initState();
    _memoriesFuture = Future.value(<OnThisDayMemory>[]);
  }

  Future<List<OnThisDayMemory>> _loadMemories(String babyId) {
    final service = ref.read(onThisDayServiceProvider);
    return service.getMemories(babyId);
  }

  void _reload() {
    final babyId = _babyId;
    if (babyId == null) return;
    setState(() {
      _memoriesFuture = _loadMemories(babyId);
    });
  }

  Future<void> _onRefresh() async {
    final babyId = _babyId;
    if (babyId == null) return;
    try {
      final memories = await _loadMemories(babyId);
      if (!mounted) return;
      setState(() {
        _memoriesFuture = Future.value(memories);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败: $e')),
      );
    }
  }

  void _showFeatureInDev() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDetail(OnThisDayMemory memory) {
    final theme = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusLg),
        ),
      ),
      builder: (_) => _buildDetailSheet(memory, theme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return Scaffold(
      backgroundColor: theme.stageBg,
      body: SafeArea(
        child: babyAsync.when(
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
              _memoriesFuture = _loadMemories(baby.id);
            }
            return Column(
              children: [
                _buildHeader(theme),
                Expanded(child: _buildMemoriesArea(theme)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    final today = DateTimeUtils.formatDateCn(DateTime.now());
    final canPop = Navigator.of(context).canPop();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        canPop ? theme.spacingXs : theme.spacingLg,
        theme.spacingSm,
        theme.spacingLg,
        theme.spacingMd,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.stageAccent, theme.stageAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              icon: Icon(Icons.arrow_back, color: theme.onAccent),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.onAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('📜', style: TextStyle(fontSize: 24)),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '往日重现',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.onAccent,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'N年前的今天 · $today',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.onAccent.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesArea(AppTheme theme) {
    return FutureBuilder<List<OnThisDayMemory>>(
      future: _memoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: '翻开回忆中…');
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '加载失败',
            subtitle: '${snapshot.error}',
            actionLabel: '重试',
            onAction: _reload,
          );
        }
        final memories = snapshot.data ?? [];
        if (memories.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyStateWidget(
                    icon: Icons.auto_awesome,
                    title: '当年的今天还没有记录哦',
                    subtitle: '要不要写点什么？',
                    actionLabel: '写点什么',
                    onAction: _showFeatureInDev,
                  ),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: _buildGroupedList(theme, memories),
        );
      },
    );
  }

  Widget _buildGroupedList(AppTheme theme, List<OnThisDayMemory> memories) {
    final grouped = <int, List<OnThisDayMemory>>{};
    for (final m in memories) {
      grouped.putIfAbsent(m.yearsAgo, () => []).add(m);
    }
    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final entries = <_ListEntry>[];
    for (final year in years) {
      entries.add(_ListEntry.header(year));
      for (final m in grouped[year]!) {
        entries.add(_ListEntry.item(m));
      }
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        theme.spacingLg,
        theme.spacingSm,
        theme.spacingLg,
        theme.spacingLg,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isHeader) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : theme.spacingLg,
              bottom: theme.spacingSm,
            ),
            child: _buildGroupHeader(theme, entry.yearsAgo!),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: theme.spacingSm),
          child: _buildMemoryCard(theme, entry.memory!),
        );
      },
    );
  }

  Widget _buildGroupHeader(AppTheme theme, int yearsAgo) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacingMd,
            vertical: theme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: theme.stageAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(theme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 14, color: theme.stageAccent),
              SizedBox(width: theme.spacingXs),
              Text(
                '$yearsAgo年前的今天',
                style: TextStyle(
                  color: theme.stageAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(AppTheme theme, OnThisDayMemory memory) {
    final emoji = _categoryEmoji(memory.category);
    final color = _categoryColor(memory.category, theme);
    final dateStr = DateTimeUtils.formatDateCn(memory.recordDate);
    final subtitle = memory.subtitle;
    final hasPhoto =
        memory.photoPath != null && memory.photoPath!.isNotEmpty;

    return Material(
      color: theme.paper,
      borderRadius: BorderRadius.circular(theme.radiusLg),
      child: InkWell(
        onTap: () => _showDetail(memory),
        borderRadius: BorderRadius.circular(theme.radiusLg),
        child: Container(
          padding: EdgeInsets.all(theme.spacingMd),
          decoration: BoxDecoration(
            color: theme.paper,
            borderRadius: BorderRadius.circular(theme.radiusLg),
            border: Border.all(color: theme.stageSurface),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              SizedBox(width: theme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayTitle(memory.title),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: theme.spacingXs + 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: theme.textTertiary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTertiary,
                          ),
                        ),
                        SizedBox(width: theme.spacingSm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacingXs + 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(theme.radiusPill),
                          ),
                          child: Text(
                            memory.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasPhoto) ...[
                SizedBox(width: theme.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  child: Image.file(
                    File(memory.photoPath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 56,
                      height: 56,
                      color: theme.stageSurface,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 24,
                        color: theme.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSheet(OnThisDayMemory memory, AppTheme theme) {
    final emoji = _categoryEmoji(memory.category);
    final color = _categoryColor(memory.category, theme);
    final dateStr = DateTimeUtils.formatDateCn(memory.recordDate);
    final body = _detailBody(memory);
    final hasPhoto =
        memory.photoPath != null && memory.photoPath!.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacingLg,
          theme.spacingSm,
          theme.spacingLg,
          theme.spacingLg,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: EdgeInsets.only(bottom: theme.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacingSm,
                      vertical: theme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(theme.radiusPill),
                    ),
                    child: Text(
                      '$emoji ${memory.category}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacingMd),
              Text(
                _displayTitle(memory.title),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              if (hasPhoto) ...[
                SizedBox(height: theme.spacingMd),
                ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusLg),
                  child: Image.file(
                    File(memory.photoPath!),
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: double.infinity,
                      height: 240,
                      color: theme.stageSurface,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: theme.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
              if (body.isNotEmpty) ...[
                SizedBox(height: theme.spacingMd),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: theme.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: theme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case '照片':
        return '📷';
      case '日记':
        return '📝';
      case '里程碑':
        return '🏆';
      case '语录':
        return '💬';
      default:
        return '📌';
    }
  }

  Color _categoryColor(String category, AppTheme theme) {
    switch (category) {
      case '照片':
        return theme.info;
      case '日记':
        return theme.stageAccent;
      case '里程碑':
        return theme.milestoneGold;
      case '语录':
        return theme.success;
      default:
        return theme.stageAccent;
    }
  }

  String _displayTitle(String title) {
    if (title.isEmpty) return title;
    final firstRune = title.runes.first;
    final isEmoji = firstRune > 0x2600;
    if (isEmoji) {
      final spaceIdx = title.indexOf(' ');
      if (spaceIdx > 0) {
        return title.substring(spaceIdx + 1).trim();
      }
    }
    return title;
  }

  String _detailBody(OnThisDayMemory memory) {
    if (memory.category == '日记') {
      final content = memory.raw['content'];
      if (content is String && content.isNotEmpty) return content;
    }
    return memory.subtitle ?? '';
  }
}

class _ListEntry {
  final int? yearsAgo;
  final OnThisDayMemory? memory;
  final bool isHeader;
  const _ListEntry.header(this.yearsAgo)
      : memory = null,
        isHeader = true;
  const _ListEntry.item(this.memory)
      : yearsAgo = null,
        isHeader = false;
}
