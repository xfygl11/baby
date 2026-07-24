import '../../data/drift/app_database.dart';
import '../../data/drift/daos/photo_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/quote_repository.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../core/utils/date_time_utils.dart';

class OnThisDayMemory {
  final DateTime recordDate;
  final int yearsAgo;
  final String category;
  final String title;
  final String? subtitle;
  final String? photoPath;
  final Map<String, dynamic> raw;

  OnThisDayMemory({
    required this.recordDate,
    required this.yearsAgo,
    required this.category,
    required this.title,
    this.subtitle,
    this.photoPath,
    this.raw = const {},
  });
}

class OnThisDayService {
  final PhotoRepository _photoRepo;
  final DiaryRepository _diaryRepo;
  final MilestoneRepository _milestoneRepo;
  final QuoteRepository _quoteRepo;
  final BabyRepository _babyRepo;

  OnThisDayService(
    this._photoRepo,
    this._diaryRepo,
    this._milestoneRepo,
    this._quoteRepo,
    this._babyRepo,
  );

  Future<List<OnThisDayMemory>> getMemories(String babyId,
      {int maxYears = 18}) async {
    final now = DateTime.now();
    final memories = <OnThisDayMemory>[];
    final baby = await _babyRepo.getBabyById(babyId);
    if (baby == null) return memories;

    for (int yearsAgo = 1; yearsAgo <= maxYears; yearsAgo++) {
      final targetDate = DateTime(now.year - yearsAgo, now.month, now.day);
      final start = DateTimeUtils.startOfDay(targetDate);
      final end = DateTimeUtils.endOfDay(targetDate);

      final photos = await _fetchPhotos(babyId, start, end, yearsAgo);
      memories.addAll(photos);

      final diaries = await _fetchDiaries(babyId, start, end, yearsAgo);
      memories.addAll(diaries);

      final milestones = await _fetchMilestones(babyId, start, end, yearsAgo);
      memories.addAll(milestones);

      final quotes = await _fetchQuotes(babyId, start, end, yearsAgo);
      memories.addAll(quotes);
    }

    memories.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));
    return memories;
  }

  Future<List<OnThisDayMemory>> _fetchPhotos(
      String babyId, DateTime start, DateTime end, int yearsAgo) async {
    try {
      final all = await _photoRepo.getPhotosByBabyId(babyId);
      return all.where((p) {
        return p.captureDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            p.captureDate.isBefore(end.add(const Duration(seconds: 1)));
      }).map((p) => OnThisDayMemory(
            recordDate: p.captureDate,
            yearsAgo: yearsAgo,
            category: '照片',
            title: '📷 ${p.title ?? '照片回忆'}',
            subtitle: p.description ?? '',
            photoPath: p.filePath,
            raw: {'type': 'photo', 'id': p.id},
          )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OnThisDayMemory>> _fetchDiaries(
      String babyId, DateTime start, DateTime end, int yearsAgo) async {
    try {
      final all = await _diaryRepo.getDiariesByBabyId(babyId);
      return all.where((d) {
        return d.recordDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.recordDate.isBefore(end.add(const Duration(seconds: 1)));
      }).map((d) => OnThisDayMemory(
            recordDate: d.recordDate,
            yearsAgo: yearsAgo,
            category: '日记',
            title: '📝 ${d.title ?? '日记'}',
            subtitle: d.content.length > 80
                ? '${d.content.substring(0, 80)}…'
                : d.content,
            raw: {'type': 'diary', 'id': d.id, 'content': d.content},
          )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OnThisDayMemory>> _fetchMilestones(
      String babyId, DateTime start, DateTime end, int yearsAgo) async {
    try {
      final all = await _milestoneRepo.getMilestonesByBabyId(babyId);
      return all.where((m) {
        final d = m.achieveDate;
        if (d == null) return false;
        return d.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(end.add(const Duration(seconds: 1)));
      }).map((m) => OnThisDayMemory(
            recordDate: m.achieveDate!,
            yearsAgo: yearsAgo,
            category: '里程碑',
            title: '🏆 ${m.name}',
            subtitle: m.note ?? m.description ?? '',
            raw: {'type': 'milestone', 'id': m.id},
          )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OnThisDayMemory>> _fetchQuotes(
      String babyId, DateTime start, DateTime end, int yearsAgo) async {
    try {
      final all = await _quoteRepo.getAll(babyId);
      return all.where((q) {
        return q.recordTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            q.recordTime.isBefore(end.add(const Duration(seconds: 1)));
      }).map((q) => OnThisDayMemory(
            recordDate: q.recordTime,
            yearsAgo: yearsAgo,
            category: '语录',
            title: '💬 "${q.content}"',
            subtitle: '—— ${q.speaker}',
            raw: {'type': 'quote', 'id': q.id},
          )).toList();
    } catch (_) {
      return [];
    }
  }
}
