import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/constants.dart';

class BottomNavBar extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const BottomNavBar({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final PageController _pageController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print('--- BOTTOM NAV BAR INIT ---');
    _pageController = PageController();
    _screens = [
      const HomeScreen(),
      const MarketplaceScreen(),
      const CreatePostScreen(),
      ProfileScreen(onThemeToggle: widget.onThemeToggle),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 74,
        decoration: BoxDecoration(
          color: AppConstants.darkCapsule,
          borderRadius: BorderRadius.circular(AppConstants.navBarRadius),
          boxShadow: AppConstants.navShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_rounded, Icons.home_outlined, 0, 'Home'),
            _buildNavItem(Icons.local_mall_rounded, Icons.local_mall_outlined, 1, 'Shop'),
            _buildCenterPawButton(),
            _buildNavItem(Icons.person_rounded, Icons.person_outline, 3, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData active, IconData inactive, int index, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? active : inactive,
                key: ValueKey(isSelected),
                size: 26,
                color: isSelected ? AppConstants.primaryColor : Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppConstants.primaryColor : Colors.white38,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPawButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _navigateTo(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppConstants.warmGradient
              : const LinearGradient(colors: [AppConstants.primaryColor, AppConstants.primaryColor]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.pets_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
