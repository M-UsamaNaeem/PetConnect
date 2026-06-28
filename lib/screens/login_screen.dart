import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/constants.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const LoginScreen({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured = true;

  void _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppConstants.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
          title: Text("Reset Password", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: AppConstants.primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email address below, and we'll send you a link to reset your password.",
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: GoogleFonts.fredoka(color: isDark ? Colors.white30 : Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppConstants.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset email sent to $email!", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
                        backgroundColor: AppConstants.primaryColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.darkCapsule,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
              ),
              child: Text("Send", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  bool _showAnimation = false;
  AnimationController? _controller;

  late Animation<double> _popAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 60.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.6, 1.0, curve: Curves.linearToEaseOut)),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) NotificationService.startListening(uid);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BottomNavBar(onThemeToggle: widget.onThemeToggle),
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showAnimation = true;
        });
        _controller?.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const CircularProgressIndicator();

    return Scaffold(
      backgroundColor: AppConstants.modernBackground,
      body: Stack(
        children: [
          // Subtle paw prints background
          Positioned(
            top: 60, right: 20,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(angle: 0.3, child: const Icon(Icons.pets, size: 80, color: AppConstants.primaryColor)),
            ),
          ),
          Positioned(
            bottom: 100, left: 30,
            child: Opacity(
              opacity: 0.04,
              child: Transform.rotate(angle: -0.5, child: const Icon(Icons.pets, size: 100, color: AppConstants.primaryColor)),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo circle
                  Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.pets_rounded, size: 60, color: AppConstants.primaryColor),
                  ),
                  const SizedBox(height: 30),

                  // Welcome text
                  Text(
                    "Welcome Back! 🐾",
                    style: GoogleFonts.fredoka(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to continue",
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                      boxShadow: AppConstants.cardShadow,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined, color: AppConstants.primaryColor),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isObscured = !_isObscured),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.fredoka(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button — Dark capsule
                  _isLoading
                      ? const CircularProgressIndicator(color: AppConstants.primaryColor)
                      : SizedBox(
                    width: double.infinity, height: 58,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.darkCapsule,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pets_rounded, size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                          Text("Login", style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "Don't have an account? ", style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontWeight: FontWeight.w600)),
                        TextSpan(text: "Sign Up", style: GoogleFonts.fredoka(color: AppConstants.primaryColor, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animation overlay
          if (_showAnimation)
            Container(
              color: AppConstants.modernBackground,
              width: double.infinity,
              height: double.infinity,
              child: AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) {
                  double currentScale = _popAnimation.value * _zoomAnimation.value;
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: currentScale,
                      child: const Center(child: Icon(Icons.pets_rounded, color: AppConstants.primaryColor, size: 80)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
