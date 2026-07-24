import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_builder.dart';
import 'core/constants/app_enums.dart';
import 'core/utils/date_time_utils.dart';
import 'services/notification/notification_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/pages/main_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 初始化通知服务
    await NotificationService().init();
    await NotificationService().requestPermissions();

    final babyRepo = ref.read(babyRepositoryProvider);
    final vaccineService = ref.read(vaccineServiceProvider);
    final milestoneService = ref.read(milestoneServiceProvider);

    final activeBaby = await babyRepo.getActiveBaby();

    if (activeBaby == null) {
      final birthDate = DateTime(2026, 7, 22, 11, 42, 54);
      final babyId = await babyRepo.addBaby(
        name: '小元宝',
        gender: 0,
        birthDate: birthDate,
      );

      await babyRepo.setActiveBaby(babyId);
      await vaccineService.generateVaccineSchedule(babyId, birthDate);
      await milestoneService.generateMilestoneTemplates(babyId);
    }

    ref.invalidate(currentBabyProvider);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  GrowthStage _calculateThemeStage(DateTime birthDate) {
    final age = DateTimeUtils.calculateAge(birthDate);
    final months = age.years * 12 + age.months;
    return ThemeBuilder.growthStageFromMonths(months);
  }

  String _stageToKey(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.infant:
        return 'infant';
      case GrowthStage.toddler:
        return 'toddler';
      case GrowthStage.preschool:
        return 'preschool';
      case GrowthStage.school:
        return 'school';
      case GrowthStage.teen:
        return 'teen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final babyAsync = ref.watch(currentBabyProvider);

    String stageKey = 'infant';
    babyAsync.whenData((baby) {
      if (baby != null) {
        final stage = _calculateThemeStage(baby.birthDate);
        stageKey = _stageToKey(stage);
      }
    });

    return MaterialApp(
      title: '小元宝成长记',
      debugShowCheckedModeBanner: false,
      theme: ThemeBuilder.buildTheme(
        stageKey: stageKey,
        isDark: false,
      ),
      darkTheme: ThemeBuilder.buildTheme(
        stageKey: stageKey,
        isDark: true,
      ),
      themeMode: themeMode,
      home: _isInitialized ? const MainShell() : _buildSplashScreen(),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: Colors.pink.shade400),
            const SizedBox(height: 24),
            const Text(
              '小元宝成长记',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
