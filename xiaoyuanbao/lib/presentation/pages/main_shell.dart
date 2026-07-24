import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'home/home_page.dart';
import 'ai_assistant/ai_assistant_page.dart';
import 'timeline/timeline_page.dart';
import 'growth/growth_page.dart';
import 'profile/profile_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    TimelinePage(),
    SizedBox.shrink(),
    GrowthPage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showAIAssistant();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index > 2 ? index - 1 : index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAIAssistant() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AiAssistantPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomePage(),
          TimelinePage(),
          GrowthPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(appTheme),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIAssistant,
        elevation: 4,
        child: const Icon(Icons.mic, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(AppTheme appTheme) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.stageSurface,
        border: Border(
          top: BorderSide(
            color: appTheme.textTertiary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '首页',
                index: 0,
                isSelected: _currentIndex == 0,
                appTheme: appTheme,
              ),
              _buildNavItem(
                icon: Icons.timeline_outlined,
                activeIcon: Icons.timeline,
                label: '记录',
                index: 1,
                isSelected: _currentIndex == 1,
                appTheme: appTheme,
              ),
              const SizedBox(width: 56),
              _buildNavItem(
                icon: Icons.show_chart,
                activeIcon: Icons.bar_chart,
                label: '成长',
                index: 3,
                isSelected: _currentIndex == 3,
                appTheme: appTheme,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '我的',
                index: 4,
                isSelected: _currentIndex == 4,
                appTheme: appTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
    required AppTheme appTheme,
  }) {
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(appTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? appTheme.stageAccent : appTheme.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? appTheme.stageAccent : appTheme.textTertiary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
