import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../main_shell.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController(text: '萱萱');
  int _selectedGender = 0;
  DateTime _selectedDate = DateTime(2026, 7, 22, 11, 42, 54);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createBabyAndGo() async {
    final babyRepo = ref.read(babyRepositoryProvider);
    final vaccineService = ref.read(vaccineServiceProvider);
    final milestoneService = ref.read(milestoneServiceProvider);

    final babyId = await babyRepo.addBaby(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      birthDate: _selectedDate,
    );

    await babyRepo.setActiveBaby(babyId);

    await vaccineService.generateVaccineSchedule(babyId, _selectedDate);
    await milestoneService.generateMilestoneTemplates(babyId);

    ref.invalidate(currentBabyProvider);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createBabyAndGo();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
          _selectedDate.second,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(appTheme),
                  _buildPage2(appTheme),
                  _buildPage3(appTheme),
                ],
              ),
            ),
            _buildBottomSection(appTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1(AppTheme appTheme) {
    return Padding(
      padding: EdgeInsets.all(appTheme.spacingXxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: appTheme.stageAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_none,
              size: 60,
              color: appTheme.stageAccent,
            ),
          ),
          SizedBox(height: appTheme.spacingXxl),
          Text(
            '说句话，记录爱',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: appTheme.spacingMd),
          Text(
            '只需一句话，AI 帮你自动记录宝宝的喂养、睡眠、尿布等日常。\n简单、快速、不打扰。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(AppTheme appTheme) {
    return Padding(
      padding: EdgeInsets.all(appTheme.spacingXxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: appTheme.stageAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: appTheme.stageAccent,
            ),
          ),
          SizedBox(height: appTheme.spacingXxl),
          Text(
            '封存记忆，等她来',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: appTheme.spacingMd),
          Text(
            '记录宝宝每一个成长瞬间，\n时间胶囊封存珍贵回忆，\n等她长大慢慢开启。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(AppTheme appTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(appTheme.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: appTheme.spacingLg),
          Text(
            '创建宝宝档案',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          SizedBox(height: appTheme.spacingSm),
          Text(
            '让我们从认识宝宝开始~',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                ),
          ),
          SizedBox(height: appTheme.spacingXxl),
          Text(
            '宝宝姓名',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
          ),
          SizedBox(height: appTheme.spacingSm),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '请输入宝宝姓名',
              prefixIcon: Icon(Icons.child_care, color: appTheme.stageAccent),
            ),
          ),
          SizedBox(height: appTheme.spacingLg),
          Text(
            '性别',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
          ),
          SizedBox(height: appTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  appTheme,
                  icon: Icons.female,
                  label: '女宝宝',
                  value: 0,
                  color: Colors.pink,
                ),
              ),
              SizedBox(width: appTheme.spacingMd),
              Expanded(
                child: _buildGenderOption(
                  appTheme,
                  icon: Icons.male,
                  label: '男宝宝',
                  value: 1,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: appTheme.spacingLg),
          Text(
            '出生日期',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
          ),
          SizedBox(height: appTheme.spacingSm),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(appTheme.radiusMd),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: appTheme.spacingMd,
                vertical: appTheme.spacingMd + 2,
              ),
              decoration: BoxDecoration(
                color: appTheme.stageSurface,
                borderRadius: BorderRadius.circular(appTheme.radiusMd),
                border: Border.all(color: appTheme.textTertiary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, color: appTheme.stageAccent),
                  SizedBox(width: appTheme.spacingMd),
                  Expanded(
                    child: Text(
                      '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: appTheme.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    AppTheme appTheme, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      borderRadius: BorderRadius.circular(appTheme.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: appTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : appTheme.stageSurface,
          borderRadius: BorderRadius.circular(appTheme.radiusMd),
          border: Border.all(
            color: isSelected ? color : appTheme.textTertiary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : appTheme.textSecondary, size: 32),
            SizedBox(height: appTheme.spacingXs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : appTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(AppTheme appTheme) {
    return Padding(
      padding: EdgeInsets.all(appTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: appTheme.spacingXs),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? appTheme.stageAccent
                      : appTheme.stageAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          SizedBox(height: appTheme.spacingLg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == 2 ? '开始使用' : '下一步',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_currentPage < 2)
            TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('跳过'),
            ),
        ],
      ),
    );
  }
}
