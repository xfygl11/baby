import 'dart:async';
import '../../data/dao/baby_repository.dart';
import '../../data/drift/app_database.dart';

class BabyService {
  final BabyRepository _repo = BabyRepository();
  Baby? _currentBaby;
  bool _initialized = false;

  final StreamController<Baby?> _babyController = StreamController<Baby?>.broadcast();
  Stream<Baby?> get babyStream => _babyController.stream;

  Baby? get currentBaby => _currentBaby;

  Future<void> init() async {
    if (_initialized) return;
    _currentBaby = await _repo.getActiveBaby();
    _babyController.add(_currentBaby);
    _initialized = true;
  }

  Future<Baby?> getActiveBaby() async {
    _currentBaby = await _repo.getActiveBaby();
    _babyController.add(_currentBaby);
    return _currentBaby;
  }

  Future<String> createBaby({
    required String name,
    required DateTime birthDate,
    required int gender,
    String? nickname,
    String? birthTime,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? note,
  }) async {
    final id = await _repo.createBaby(
      name: name,
      birthDate: birthDate,
      gender: gender,
      nickname: nickname,
      birthTime: birthTime,
      birthWeight: birthWeight,
      birthHeight: birthHeight,
      birthHeadCircumference: birthHeadCircumference,
      note: note,
    );
    await _repo.setActiveBaby(id);
    _currentBaby = await _repo.getActiveBaby();
    _babyController.add(_currentBaby);
    return id;
  }

  Future<void> updateBaby(String id, {
    String? name,
    String? nickname,
    DateTime? birthDate,
    String? birthTime,
    int? gender,
    double? birthWeight,
    double? birthHeight,
    String? avatarPath,
    String? note,
  }) async {
    await _repo.updateBaby(
      id,
      name: name,
      nickname: nickname,
      birthDate: birthDate,
      birthTime: birthTime,
      gender: gender,
      birthWeight: birthWeight,
      birthHeight: birthHeight,
      avatarPath: avatarPath,
      note: note,
    );
    if (_currentBaby?.id == id) {
      _currentBaby = await _repo.getActiveBaby();
      _babyController.add(_currentBaby);
    }
  }

  Future<List<Baby>> getAllBabies() => _repo.getAllBabies();

  Stream<Baby?> watchActiveBaby() => _repo.watchActiveBaby();

  Future<String?> getActiveBabyId() async {
    final baby = await getActiveBaby();
    return baby?.id;
  }

  int getAgeMonths(DateTime birthDate) {
    final now = DateTime.now();
    var months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    return months;
  }

  double getAgeDays(DateTime birthDate) {
    return DateTime.now().difference(birthDate).inDays.toDouble();
  }

  void dispose() {
    _babyController.close();
  }
}
