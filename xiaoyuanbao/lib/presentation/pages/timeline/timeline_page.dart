import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../services/timeline/timeline_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../ai_assistant/ai_assistant_page.dart';
import '../record/edit_record_page.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _babyId;
  List<TimelineGroup> _groups = [];
  List<TimelineItem>? _searchResults;

  RecordCategory? _selectedFilter;
  bool _isSearchExpanded = false;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _isRefreshing = false;
  bool _hasMore = false;
  String? _loadError;

  int _loadedLimit = _pageSize;

  static const _filterChips = <_FilterChipData>[
    _FilterChipData(label: '全部'),
    _FilterChipData(label: '喂养', category: RecordCategory.feeding),
    _FilterChipData(label: '睡眠', category: RecordCategory.sleep),
    _FilterChipData(label: '尿布', category: RecordCategory.diaper),
    _FilterChipData(label: '体温', category: RecordCategory.temperature),
    _FilterChipData(label: '疫苗', category: RecordCategory.vaccine),
    _FilterChipData(label: '里程碑', category: RecordCategory.milestone),
    _FilterChipData(label: '日记', category: RecordCategory.diary),
    _FilterChipData(label: '语录', category: RecordCategory.quote),
    _FilterChipData(label: '互动', category: RecordCategory.activity),
    _FilterChipData(label: '费用', category: RecordCategory.expense),
    _FilterChipData(label: '牙齿', category: RecordCategory.teeth),
    _FilterChipData(label: '身高体重', category: RecordCategory.growth),
    _FilterChipData(label: '考试', category: RecordCategory.exam),
    _FilterChipData(label: '获奖', category: RecordCategory.award),
    _FilterChipData(label: '情绪', category: RecordCategory.emotion),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_searchResults != null || _isLoading || _isRefreshing) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 80) {
      _loadMore();
    }
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  Future<List<TimelineGroup>> _fetchGroups() async {
    final timelineService = ref.read(timelineServiceProvider);
    if (_babyId == null) return [];
    if (_selectedFilter == null) {
      return await timelineService.getTimelineGroupedByDate(
        _babyId!,
        limit: _loadedLimit,
      );
    }
    final items = await timelineService.getTimeline(
      _babyId!,
      limit: _loadedLimit,
      categories: [_selectedFilter!.name],
    );
    return await _groupItems(items);
  }

  Future<List<TimelineGroup>> _groupItems(List<TimelineItem> items) async {
    if (items.isEmpty) return [];
    final baby = await ref.read(currentBabyProvider.future);
    final grouped = <DateTime, List<TimelineItem>>{};
    for (final item in items) {
      final date = DateTimeUtils.startOfDay(item.time);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(item);
    }
    final result = <TimelineGroup>[];
    for (final entry in grouped.entries) {
      String ageLabel = '';
      if (baby != null) {
        final age = DateTimeUtils.calculateAge(baby.birthDate, now: entry.key);
        ageLabel = '${age.years}岁${age.months}月${age.days}天';
      }
      result.add(TimelineGroup(
        date: entry.key,
        ageLabel: ageLabel,
        items: entry.value,
      ));
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  bool _computeHasMore(List<TimelineGroup> groups) {
    final count = groups.fold<int>(0, (sum, g) => sum + g.items.length);
    return count >= _loadedLimit;
  }

  Future<void> _loadInitialData() async {
    if (_babyId == null) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final groups = await _fetchGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _isLoading = false;
        _hasMore = _computeHasMore(groups);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore ||
        !_hasMore ||
        _isLoading ||
        _isRefreshing ||
        _babyId == null) {
      return;
    }
    setState(() => _isLoadingMore = true);
    final previousLimit = _loadedLimit;
    _loadedLimit += _pageSize;
    try {
      final groups = await _fetchGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _isLoadingMore = false;
        _hasMore = _computeHasMore(groups);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadedLimit = previousLimit;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (_babyId == null) return;
    _isRefreshing = true;
    _loadedLimit = _pageSize;
    _loadError = null;
    try {
      final groups = await _fetchGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _hasMore = _computeHasMore(groups);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    } finally {
      _isRefreshing = false;
    }
  }

  void _onFilterTap(RecordCategory? category) {
    if (_selectedFilter == category) return;
    _selectedFilter = category;
    _loadedLimit = _pageSize;
    _searchResults = null;
    _isSearching = false;
    if (_isSearchExpanded) {
      _searchController.clear();
    }
    _loadInitialData();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        _searchResults = null;
        _isSearching = false;
      }
    });
  }

  Future<void> _onSearch(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    if (_babyId == null) return;
    setState(() => _isSearching = true);
    try {
      final timelineService = ref.read(timelineServiceProvider);
      final results = await timelineService.searchRecords(_babyId!, trimmed);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  void _navigateToAiAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiAssistantPage()),
    );
  }

  void _onItemTap(TimelineItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditRecordPage(recordId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录时光'),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: babyAsync.when(
        data: (baby) {
          if (baby == null) {
            return EmptyStateWidget(
              icon: Icons.child_care,
              title: '还没有宝宝信息',
              subtitle: '请先在首页添加宝宝',
            );
          }
          if (baby.id != _babyId) {
            _babyId = baby.id;
            _isLoading = true;
            _groups = [];
            _searchResults = null;
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
          }
          return _buildBody(appTheme);
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: '加载失败',
          subtitle: '请稍后重试',
          actionLabel: '重试',
          onAction: () => _loadInitialData(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAiAssistant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(AppTheme appTheme) {
    return Column(
      children: [
        if (_isSearchExpanded) _buildSearchField(appTheme),
        _buildFilterChips(appTheme),
        Expanded(child: _buildContent(appTheme)),
      ],
    );
  }

  Widget _buildSearchField(AppTheme appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: appTheme.spacingLg,
        vertical: appTheme.spacingSm,
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearch,
        decoration: InputDecoration(
          hintText: '搜索记录…',
          prefixIcon: Icon(Icons.search, color: appTheme.textTertiary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = null);
                  },
                )
              : null,
          filled: true,
          fillColor: appTheme.stageSurface,
          contentPadding: EdgeInsets.symmetric(horizontal: appTheme.spacingMd),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.radiusPill),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.radiusPill),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.radiusPill),
            borderSide: BorderSide(color: appTheme.stageAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppTheme appTheme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: appTheme.spacingLg),
        itemCount: _filterChips.length,
        separatorBuilder: (_, __) => SizedBox(width: appTheme.spacingSm),
        itemBuilder: (context, index) {
          final chip = _filterChips[index];
          final selected = _selectedFilter == chip.category;
          return Center(
            child: GestureDetector(
              onTap: () => _onFilterTap(chip.category),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: appTheme.spacingMd,
                  vertical: appTheme.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: selected ? appTheme.stageAccent : appTheme.stageSurface,
                  borderRadius: BorderRadius.circular(appTheme.radiusPill),
                  border: Border.all(
                    color: selected
                        ? appTheme.stageAccent
                        : appTheme.textTertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  chip.label,
                  style: TextStyle(
                    color: selected ? appTheme.onAccent : appTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AppTheme appTheme) {
    if (_isSearching) {
      return const LoadingWidget(message: '搜索中…');
    }
    if (_searchResults != null) {
      return _buildSearchResults(appTheme);
    }
    if (_isLoading) {
      return const LoadingWidget(message: '加载中…');
    }
    if (_loadError != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: '加载失败',
        subtitle: '请稍后重试',
        actionLabel: '重试',
        onAction: () => _loadInitialData(),
      );
    }
    if (_groups.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.auto_awesome,
        title: '还没有记录',
        subtitle: '说第一句话，让记忆开始流淌',
        actionLabel: '开始记录',
        onAction: _navigateToAiAssistant,
      );
    }
    return _buildGroupedList(appTheme);
  }

  Widget _buildSearchResults(AppTheme appTheme) {
    if (_searchResults!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: '没有找到相关记录',
        subtitle: '换个关键词试试',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(appTheme.spacingLg),
      itemCount: _searchResults!.length,
      separatorBuilder: (_, __) => SizedBox(height: appTheme.spacingSm),
      itemBuilder: (context, index) =>
          _buildTimelineItem(appTheme, _searchResults![index]),
    );
  }

  Widget _buildGroupedList(AppTheme appTheme) {
    final entries = <_ListEntry>[];
    for (final group in _groups) {
      entries.add(_ListEntry.header(group));
      for (final item in group.items) {
        entries.add(_ListEntry.item(item));
      }
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          appTheme.spacingLg,
          appTheme.spacingSm,
          appTheme.spacingLg,
          appTheme.spacingLg,
        ),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == entries.length) {
            return _buildFooter(appTheme);
          }
          final entry = entries[index];
          final isFirst = index == 0;
          if (entry.isHeader) {
            return Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : appTheme.spacingLg,
                bottom: appTheme.spacingSm,
              ),
              child: _buildGroupHeader(appTheme, entry.group!),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: appTheme.spacingSm),
            child: _buildTimelineItem(appTheme, entry.item!),
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(AppTheme appTheme, TimelineGroup group) {
    final dateStr = DateTimeUtils.formatDateCn(group.date);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: appTheme.spacingMd,
            vertical: appTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: appTheme.stageAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(appTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: appTheme.stageAccent),
              SizedBox(width: appTheme.spacingXs),
              Text(
                dateStr,
                style: TextStyle(
                  color: appTheme.stageAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (group.ageLabel.isNotEmpty) ...[
                SizedBox(width: appTheme.spacingXs),
                Text(
                  '· ${group.ageLabel}',
                  style: TextStyle(
                    color: appTheme.stageAccent.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(AppTheme appTheme, TimelineItem item) {
    final timeStr = DateTimeUtils.formatTime(item.time);
    return Material(
      color: appTheme.stageSurface,
      borderRadius: BorderRadius.circular(appTheme.radiusMd),
      child: InkWell(
        onTap: () => _onItemTap(item),
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(appTheme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(appTheme.radiusMd),
            border: Border.all(color: appTheme.textTertiary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: appTheme.stageAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(appTheme.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(item.icon, style: const TextStyle(fontSize: 24)),
              ),
              SizedBox(width: appTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                timeStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appTheme.textTertiary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppTheme appTheme) {
    if (_isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: appTheme.spacingMd),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: appTheme.stageAccent,
            ),
          ),
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: appTheme.spacingMd),
        child: Center(
          child: Text(
            '没有更多了',
            style: TextStyle(color: appTheme.textTertiary, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _FilterChipData {
  final String label;
  final RecordCategory? category;
  const _FilterChipData({required this.label, this.category});
}

class _ListEntry {
  final TimelineGroup? group;
  final TimelineItem? item;
  final bool isHeader;
  const _ListEntry.header(this.group)
      : item = null,
        isHeader = true;
  const _ListEntry.item(this.item)
      : group = null,
        isHeader = false;
}
