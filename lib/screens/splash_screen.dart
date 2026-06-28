import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const SplashScreen({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _glowController;
  late AnimationController _exitController;

  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    print('--- SPLASH SCREEN INIT ---');

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowPulse = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    print('--- SPLASH SEQUENCE: Starting ---');
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      print('--- SPLASH SEQUENCE: Icon forward ---');
      _iconController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      print('--- SPLASH SEQUENCE: Glow repeat ---');
      _glowController.repeat(reverse: true);
      await Future.delayed(const Duration(milliseconds: 400));
      print('--- SPLASH SEQUENCE: Text forward ---');
      _textController.forward();
      await Future.delayed(const Duration(milliseconds: 1800));
      print('--- SPLASH SEQUENCE: Navigating directly ---');
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e, stack) {
      print('--- SPLASH SEQUENCE EXCEPTION: $e ---');
      print(stack);
    }
  }

  void _navigateToLogin() {
    print('--- NAVIGATING FROM SPLASH: ENTERED ---');
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('--- NAVIGATING FROM SPLASH: USER IS ${user?.uid} ---');
      if (user != null) {
        print('--- NAVIGATING TO BOTTOM NAV BAR ---');
        try {
          NotificationService.startListening(user.uid);
          print('--- NOTIFICATION LISTENER STARTED ---');
        } catch (ne, nstack) {
          print('--- ERROR STARTING NOTIFICATION LISTENER: $ne ---');
          print(nstack);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BottomNavBar(onThemeToggle: widget.onThemeToggle),
          ),
        );
        print('--- NAVIGATED TO BOTTOM NAV BAR (pushReplacement called) ---');
      } else {
        print('--- NAVIGATING TO LOGIN SCREEN ---');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(onThemeToggle: widget.onThemeToggle),
          ),
        );
        print('--- NAVIGATED TO LOGIN SCREEN (pushReplacement called) ---');
      }
    } catch (e, stack) {
      print('--- NAVIGATING FROM SPLASH EXCEPTION: $e ---');
      print(stack);
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _glowController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(
            opacity: _exitFade.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B), // Coral
                    Color(0xFFFF8E53), // Peach orange
                    Color(0xFFF8BBD0), // Blush pink
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle paw prints in background
                  ..._buildPawPrints(),

                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Animated icon with glow
                      AnimatedBuilder(
                        animation: Listenable.merge([_iconController, _glowController]),
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _iconRotation.value * pi,
                            child: Transform.scale(
                              scale: _iconScale.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: _glowController.isAnimating
                                            ? _glowPulse.value
                                            : 0.3,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.pets_rounded,
                                  size: 70,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: _textOpacity.value,
                                  child: Text(
                                    "Pet Connect",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Opacity(
                                  opacity: _subtitleOpacity.value,
                                  child: Text(
                                    "Connect with pet lovers worldwide 🐾",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Spacer(flex: 2),

                      // Bottom loading
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loading your world...",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPawPrints() {
    return [
      Positioned(
        top: 80, left: 30,
        child: Opacity(
          opacity: 0.08,
          child: Transform.rotate(
            angle: -0.3,
            child: const Icon(Icons.pets, size: 60, color: Colors.white),
          ),
        ),
      ),
      Positioned(
        top: 200, right: 40,
        child: Opacity(
          opacity: 0.06,
          child: Transform.rotate(
            angle: 0.5,
            child: const Icon(Icons.pets, size: 80, color: Colors.white),
          ),
        ),
      ),
      Positioned(
        bottom: 200, left: 60,
        child: Opacity(
          opacity: 0.07,
          child: Transform.rotate(
            angle: -0.7,
            child: const Icon(Icons.pets, size: 50, color: Colors.white),
          ),
        ),
      ),
      Positioned(
        bottom: 300, right: 30,
        child: Opacity(
          opacity: 0.05,
          child: Transform.rotate(
            angle: 0.3,
            child: const Icon(Icons.pets, size: 70, color: Colors.white),
          ),
        ),
      ),
    ];
  }
}
