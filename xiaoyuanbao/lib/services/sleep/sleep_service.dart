import '../../data/dao/sleep_repository.dart';
import '../../data/drift/tables/sleep_records.dart';

class SleepService {
  final SleepRepository _repo = SleepRepository();

  Future<String> startSleep({
    required String babyId,
    required int type,
    DateTime? startTime,
    String? environment,
    String? note,
  }) => _repo.startSleep(
    babyId: babyId,
    type: type,
    startTime: startTime,
    environment: environment,
    note: note,
  );

  Future<void> endSleep(String id, {DateTime? endTime, int? quality}) =>
      _repo.endSleep(id, endTime: endTime, quality: quality);

  Future<SleepRecord?> getOngoingSleep(String babyId) =>
      _repo.getOngoingSleep(babyId);

  Future<int> getTodayTotalMinutes(String babyId) =>
      _repo.getTodayTotalSleepMinutes(babyId);

  Stream<SleepRecord?> watchOngoingSleep(String babyId) =>
      _repo.watchOngoingSleep(babyId);

  Stream<List<SleepRecord>> watchRecent(String babyId, {int limit = 10}) =>
      _repo.watchRecentSleep(babyId, limit: limit);

  Future<List<SleepRecord>> getRecent(String babyId, {int limit = 20}) =>
      _repo.getRecentSleep(babyId, limit: limit);

  Future<int> getWeekTotalMinutes(String babyId) =>
      _repo.getThisWeekTotalMinutes(babyId);

  Future<double> getAverageSleepMinutes(String babyId, {int days = 7}) async {
    final sleeps = await _repo.getRecentSleep(babyId, limit: days * 10);
    if (sleeps.isEmpty) return 0;
    int total = 0;
    int count = 0;
    final now = DateTime.now();
    for (var s in sleeps) {
      if (s.endTime == null) continue;
      final diff = now.difference(s.startTime).inDays;
      if (diff < days) {
        total += s.durationMinutes ?? 0;
        count++;
      }
    }
    return count == 0 ? 0 : total / days;
  }

  Future<void> deleteSleep(String id) => _repo.deleteSleep(id);
}
