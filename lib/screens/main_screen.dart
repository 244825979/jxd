import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/common/global_player_overlay.dart';
import 'home/home_screen.dart';
import 'sound_library/sound_library_screen.dart';
import 'plaza/plaza_screen.dart';
import 'messages/messages_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    SoundLibraryScreen(),
    PlazaScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: AppStrings.tabHome,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.headphones),
      label: AppStrings.tabSoundLibrary,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.nature),
      label: AppStrings.tabPlaza,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: AppStrings.tabMessages,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      label: AppStrings.tabProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlobalPlayerOverlay(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: false,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: _buildTabItem(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isActive = _currentIndex == index;
    final item = _bottomNavItems[index];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                (item.icon as Icon).icon,
                size: 24,
                color: isActive ? AppColors.accent : AppColors.textHint,
              ),
              const SizedBox(height: 4),
              Text(
                item.label ?? '',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.accent : AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 