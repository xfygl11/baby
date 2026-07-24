import '../../data/drift/app_database.dart';
import '../../data/drift/daos/record_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/date_time_utils.dart';

class TimelineItem {
  final String id;
  final String category;
  final DateTime time;
  final String title;
  final String subtitle;
  final String icon;
  final String? imagePath;
  final Map<String, dynamic>? extra;

  TimelineItem({
    required this.id,
    required this.category,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imagePath,
    this.extra,
  });
}

class TimelineGroup {
  final DateTime date;
  final String ageLabel;
  final List<TimelineItem> items;

  TimelineGroup({
    required this.date,
    required this.ageLabel,
    required this.items,
  });
}

class TimelineService {
  final AppDatabase _db;
  late final RecordRepository _recordRepository;
  late final BabyRepository _babyRepository;

  TimelineService(this._db) {
    _recordRepository = RecordRepository(_db);
    _babyRepository = BabyRepository(_db);
  }

  Future<List<TimelineItem>> getTimeline(
    String babyId, {
    int limit = 20,
    int offset = 0,
    List<String>? categories,
  }) async {
    final categoryEnums = categories
        ?.map((e) => RecordCategory.values.firstWhere(
              (c) => c.name == e,
              orElse: () => RecordCategory.diary,
            ))
        .toList();

    final records = await _recordRepository.getTimelineRecords(
      babyId: babyId,
      limit: limit,
      offset: offset,
      categories: categoryEnums,
    );

    return records
        .map((r) => TimelineItem(
              id: r['id'] as String,
              category: r['category'] as String,
              time: r['time'] as DateTime,
              title: r['title'] as String,
              subtitle: r['subtitle'] as String,
              icon: r['icon'] as String,
              imagePath: r['imagePath'] as String?,
              extra: r['extra'] as Map<String, dynamic>?,
            ))
        .toList();
  }

  Future<List<TimelineGroup>> getTimelineGroupedByDate(
    String babyId, {
    int limit = 50,
  }) async {
    final items = await getTimeline(babyId, limit: limit);
    final baby = await _babyRepository.getBabyById(babyId);

    if (items.isEmpty) {
      return [];
    }

    final groups = <DateTime, List<TimelineItem>>{};
    for (final item in items) {
      final date = DateTimeUtils.startOfDay(item.time);
      groups.putIfAbsent(date, () => []);
      groups[date]!.add(item);
    }

    final result = <TimelineGroup>[];
    for (final entry in groups.entries) {
      String ageLabel = '';
      if (baby != null) {
        final age = DateTimeUtils.calculateAge(baby.birthDate, now: entry.date);
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

  Future<int> getTimelineCount(String babyId) async {
    final allRecords = await _recordRepository.getTimelineRecords(
      babyId: babyId,
    );
    return allRecords.length;
  }

  Future<List<TimelineItem>> searchRecords(
    String babyId,
    String keyword,
  ) async {
    final allRecords = await _recordRepository.getTimelineRecords(
      babyId: babyId,
    );

    final lowerKeyword = keyword.toLowerCase();
    final filtered = allRecords.where((r) {
      final title = (r['title'] as String).toLowerCase();
      final subtitle = (r['subtitle'] as String).toLowerCase();
      return title.contains(lowerKeyword) || subtitle.contains(lowerKeyword);
    }).toList();

    return filtered
        .map((r) => TimelineItem(
              id: r['id'] as String,
              category: r['category'] as String,
              time: r['time'] as DateTime,
              title: r['title'] as String,
              subtitle: r['subtitle'] as String,
              icon: r['icon'] as String,
              imagePath: r['imagePath'] as String?,
              extra: r['extra'] as Map<String, dynamic>?,
            ))
        .toList();
  }
}
