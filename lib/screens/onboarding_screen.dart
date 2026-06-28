import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconController;
  late Animation<double> _iconScale;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      circleColor: Color(0xFFC7B8F5), // Pastel Lavender
      imagePath: 'assets/onboarding_poodle.png',
      title: 'Happier Pets',
      subtitle: 'The home for pet lovers.\nShare, discover and connect worldwide.',
    ),
    const _OnboardingPage(
      circleColor: Color(0xFFFFB7B2), // Pastel Peach/Pink
      imagePath: 'assets/mochu_labrador.png',
      title: 'Share Every Moment',
      subtitle: 'Post adorable photos and stories\nof your furry best friends.',
    ),
    const _OnboardingPage(
      circleColor: Color(0xFFFFD4B8), // Pastel Orange/Peach
      imagePath: 'assets/onboarding_cat.png',
      title: 'Marketplace & Shop',
      subtitle: 'Browse the pet marketplace,\nfind food, accessories and more.',
    ),
    const _OnboardingPage(
      circleColor: Color(0xFFFFE5B4), // Pastel Yellow
      imagePath: 'assets/onboarding_retriever.png',
      title: 'Health & Play',
      subtitle: 'Track your pet\'s daily activities,\nhealth logs and fun moments.',
    ),
    const _OnboardingPage(
      circleColor: Color(0xFFBFFCC6), // Pastel Green
      imagePath: 'assets/onboarding_bulldog.png',
      title: 'Join the Community',
      subtitle: 'Follow, chat and grow\nwith pet lovers around the world.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    print('--- ONBOARDING SCREEN INIT ---');
    try {
      _iconController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..forward();
      _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
      );
    } catch (e, st) {
      print('--- ONBOARDING INIT EXCEPTION: $e ---');
      print(st);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _iconController.reset();
    _iconController.forward();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              LoginScreen(onThemeToggle: () {}),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('--- ONBOARDING SCREEN BUILD ---');
    try {
      return Scaffold(
        backgroundColor: AppConstants.modernBackground, // Light cream background
        body: Stack(
          children: [
            // Scattered paw and bone background decorations
            ..._buildBackgroundDecorations(),

            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) =>
                  _buildPage(_pages[index], index),
            ),

            // Skip button
            Positioned(
              top: 50,
              right: 24,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.fredoka(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppConstants.primaryColor
                              : AppConstants.textWarm.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Next / Get Started button — DARK CAPSULE style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finish();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.darkCapsule,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _currentPage < _pages.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.pets_rounded,
                                color: AppConstants.darkCapsule,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _currentPage < _pages.length - 1
                                  ? 'Next'
                                  : 'Get started',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e, st) {
      print('--- ONBOARDING BUILD EXCEPTION: $e ---');
      print(st);
      return Scaffold(body: Center(child: Text('Error: $e')));
    }
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Small pink logo icon only on page 1 above the title
          if (index == 0) ...[
            Icon(
              Icons.pets_rounded,
              color: AppConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
          ],

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppConstants.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Central pet image / icon inside a pastel circle
          ScaleTransition(
            scale: _iconScale,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: page.circleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: page.circleColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: page.imagePath != null
                  ? FractionallySizedBox(
                      widthFactor: 0.85,
                      heightFactor: 0.85,
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: Image.asset(
                            page.imagePath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      page.icon,
                      size: 90,
                      color: Colors.white,
                    ),
            ),
          ),

          const Spacer(),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 15,
                color: AppConstants.textWarm,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    final Color decorColor = AppConstants.textWarm.withOpacity(0.04);
    return [
      Positioned(
        top: 100,
        left: 40,
        child: Icon(Icons.pets_rounded, size: 28, color: decorColor),
      ),
      Positioned(
        top: 180,
        right: 50,
        child: Transform.rotate(
          angle: 0.4,
          child: Text(
            "🦴",
            style: TextStyle(fontSize: 32, color: decorColor),
          ),
        ),
      ),
      Positioned(
        bottom: 250,
        left: 30,
        child: Transform.rotate(
          angle: -0.3,
          child: Text(
            "🦴",
            style: TextStyle(fontSize: 24, color: decorColor),
          ),
        ),
      ),
      Positioned(
        bottom: 180,
        right: 40,
        child: Icon(Icons.pets_rounded, size: 36, color: decorColor),
      ),
      Positioned(
        top: 320,
        left: 20,
        child: Icon(Icons.pets_rounded, size: 20, color: decorColor),
      ),
      Positioned(
        top: 280,
        right: 20,
        child: Icon(Icons.pets_rounded, size: 24, color: decorColor),
      ),
    ];
  }
}

class _OnboardingPage {
  final Color circleColor;
  final String? imagePath;
  final IconData? icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.circleColor,
    this.imagePath,
    this.icon,
    required this.title,
    required this.subtitle,
  });
}
