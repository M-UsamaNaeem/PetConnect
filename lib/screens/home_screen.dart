import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petconnect/screens/story_view_screen.dart';
import 'package:petconnect/screens/chat_list_screen.dart';
import 'package:petconnect/screens/ai_chat_screen.dart';
import 'package:petconnect/screens/marketplace_screen.dart';
import 'package:petconnect/screens/vet_locator_screen.dart';
import 'package:petconnect/screens/alerts_screen.dart';
import 'package:petconnect/screens/search_screen.dart';
import 'package:petconnect/screens/profile_screen.dart';
import 'package:petconnect/screens/pet_profile_screen.dart';
import '../utils/constants.dart';
import 'post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final ConfettiController _promoConfettiController;
  late final PageController _pageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _promoConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _pageController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promoConfettiController.dispose();
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showPromoDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppConstants.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
          title: Text("Special Offer!", style: GoogleFonts.fredoka(fontWeight: FontWeight.w900, color: AppConstants.primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Grab 40% Off on pet toys and accessories. Use the promo code below at checkout:",
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.primaryColor, style: BorderStyle.solid, width: 1.5),
                ),
                child: Text(
                  "PLAYTIME40",
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2, color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: "PLAYTIME40"));
                _promoConfettiController.play();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Coupon code copied to clipboard!", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text("Copy Code", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: AppConstants.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketplaceScreen(initialCategory: 'Accessories')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.darkCapsule,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
              ),
              child: Text("Shop Toys", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner({
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
    required Widget rightWidget,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    color: const Color(0xFF4A2511),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    color: const Color(0xFF6B422B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.darkCapsule,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: rightWidget,
          ),
        ],
      ),
    );
  }

  void uploadStory() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);

    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading Story...")));
      List<int> bytes = await picked.readAsBytes();
      String base64Image = base64Encode(bytes);

      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('stories').add({
        'uid': uid,
        'username': userData['username'],
        'profileImage': userData['profileImage'],
        'storyImage': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story Added! 🐾")));
    }
  }

  void _openChatBot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIChatScreen()),
    );
  }

  Widget _badge(int count) {
    return Positioned(
      right: -2,
      top: -2,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('--- HOME SCREEN BUILD ---');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppConstants.textPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: GestureDetector(
          onTap: _openChatBot,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "AI Assistant",
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            String username = "User";
            Uint8List? myImg;
            String? lastAlertChecked;
            if (userSnap.hasData && userSnap.data!.exists) {
              final data = userSnap.data!.data() as Map<String, dynamic>;
              username = data['username'] ?? "User";
              lastAlertChecked = data['lastAlertChecked'];
              try {
                if (data['profileImage'] != null) {
                  myImg = base64Decode(data['profileImage']);
                }
              } catch (_) {}
            }

            return CustomScrollView(
              slivers: [
                // 1. Personalized Header Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        // Hey, [User] Greeting
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Hey, ",
                                    style: GoogleFonts.fredoka(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppConstants.textPrimary,
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => AppConstants.warmGradient.createShader(
                                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                    ),
                                    child: Text(
                                      username,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Good morning!",
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : AppConstants.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Icons: Search
                        IconButton(
                          icon: Icon(Icons.search_rounded, color: iconColor, size: 24),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                        ),

                        // Action Icons: Map/Vet Locator
                        IconButton(
                          icon: Icon(Icons.map_rounded, color: iconColor, size: 24),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VetLocatorScreen())),
                        ),

                        // Action Icons: Alerts
                        _AlertsBadge(
                          uid: uid,
                          lastAlertCheckedStr: lastAlertChecked,
                          iconColor: iconColor,
                        ),

                        // Action Icons: Chats
                        _ChatsBadge(
                          uid: uid,
                          iconColor: iconColor,
                          badgeBuilder: _badge,
                        ),

                        const SizedBox(width: 8),

                        // Profile Avatar shortcut
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: uid))),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.4), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: myImg != null ? MemoryImage(myImg) : null,
                              child: myImg == null ? const Icon(Icons.person, size: 18) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Stories Section
                SliverToBoxAdapter(
                  child: Container(
                    height: 120,
                    color: isDark ? AppConstants.darkSurface : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      GestureDetector(
                        onTap: uploadStory,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppConstants.storyRingGradient,
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: myImg != null ? MemoryImage(myImg) : null,
                                      child: myImg == null ? const Icon(Icons.person) : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: AppConstants.primaryColor,
                                      child: const Icon(Icons.add, size: 15, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text("Your Story", style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('stories').orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            Map<String, List<Map<String, dynamic>>> grouped = {};
                            for (var doc in snapshot.data!.docs) {
                              var d = doc.data() as Map<String, dynamic>;
                              d['id'] = doc.id;
                              if (d['uid'] != uid) {
                                if (!grouped.containsKey(d['uid'])) grouped[d['uid']] = [];
                                grouped[d['uid']]!.add(d);
                              }
                            }
                            var ids = grouped.keys.toList();
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: ids.length,
                              itemBuilder: (ctx, i) {
                                var stories = grouped[ids[i]]!;
                                var first = stories[0];
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StoryViewScreen(stories: stories))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: AppConstants.storyRingGradient,
                                          ),
                                          child: const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                                        ),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            first['username'] ?? "User",
                                            style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
                // 3. Auto-Rotating Promo Banners Carousel
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                          children: [
                            // Banner 1: Grab 40% Off
                            _buildBanner(
                              color: const Color(0xFFFFD4B8),
                              title: "Grab 40% Off",
                              subtitle: "Its playtime! Get toys & accessories.",
                              buttonText: "Shop Now",
                              onTap: _showPromoDetailsDialog,
                              rightWidget: ClipOval(
                                child: Image.asset(
                                  'assets/onboarding_poodle.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Icon(Icons.pets, size: 40, color: Colors.white),
                                ),
                              ),
                              isDark: isDark,
                            ),
                            // Banner 2: Free Shipping
                            _buildBanner(
                              color: const Color(0xFFE8DEF8),
                              title: "Free Shipping",
                              subtitle: "On orders above \$50. Use code: FREESHIP50",
                              buttonText: "Copy Code",
                              onTap: () async {
                                await Clipboard.setData(const ClipboardData(text: "FREESHIP50"));
                                _promoConfettiController.play();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Free shipping code copied!", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              rightWidget: const Icon(
                                Icons.local_shipping_rounded,
                                size: 40,
                                color: Color(0xFF4A2511),
                              ),
                              isDark: isDark,
                            ),
                            // Banner 3: Vet Clinic Locator
                            _buildBanner(
                              color: const Color(0xFFA8E6CF),
                              title: "Vet Clinic Locator",
                              subtitle: "Find qualified vets nearby for your pet.",
                              buttonText: "Find Vet",
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const VetLocatorScreen()));
                              },
                              rightWidget: const Icon(
                                Icons.medical_services_rounded,
                                size: 40,
                                color: Color(0xFF4A2511),
                              ),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          bool isActive = _currentBannerIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 18 : 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppConstants.primaryColor
                                  : (isDark ? Colors.white24 : Colors.black12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // 4. Categories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category",
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCategoryItem(
                              "Foods",
                              Icons.pets_rounded,
                              const Color(0xFFFCDDE9),
                              const Color(0xFF9E4B72),
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen(initialCategory: 'Food')));
                              },
                              isDark,
                              isSelected: true,
                            ),
                            _buildCategoryItem(
                              "Groom",
                              Icons.brush_rounded,
                              const Color(0xFFECEFF1),
                              Colors.blueGrey,
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen(initialCategory: 'Services')));
                              },
                              isDark,
                            ),
                            _buildCategoryItem(
                              "Toys",
                              Icons.sports_tennis_rounded,
                              const Color(0xFFECEFF1),
                              Colors.blueGrey,
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen(initialCategory: 'Accessories')));
                              },
                              isDark,
                            ),
                            _buildCategoryItem(
                              "Veterinary",
                              Icons.home_work_rounded,
                              const Color(0xFFECEFF1),
                              Colors.blueGrey,
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const VetLocatorScreen()));
                              },
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Tasty Picks for Pets
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tasty Picks for Pets",
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppConstants.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "View All",
                                    style: GoogleFonts.fredoka(
                                      fontSize: 12,
                                      color: AppConstants.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppConstants.primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('users').get(),
                          builder: (context, snap) {
                            if (!snap.hasData || snap.data!.docs.isEmpty) {
                              return const SizedBox();
                            }
                            // Filter users who have a petName set and are not the current user
                            final petUsers = snap.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final hasPet = data['petName'] != null && (data['petName'] as String).isNotEmpty;
                              return hasPet && doc.id != uid;
                            }).toList();

                            if (petUsers.isEmpty) {
                              // Fallback dummy cards if no other users have pets
                              return SizedBox(
                                height: 170,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    _buildTastyPickCard(
                                      "Mochu",
                                      "Labrador",
                                      "assets/mochu_labrador.png",
                                      const Color(0xFFCBE3FB),
                                      const Color(0xFF0F4C81),
                                      () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileScreen(userId: uid)));
                                      },
                                    ),
                                    const SizedBox(width: 14),
                                    _buildTastyPickCard(
                                      "Bella",
                                      "Poodle",
                                      "assets/onboarding_poodle.png",
                                      const Color(0xFFFCDDE9),
                                      const Color(0xFF9E4B72),
                                      () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileScreen(userId: uid)));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SizedBox(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: petUsers.length,
                                itemBuilder: (context, index) {
                                  final userDoc = petUsers[index];
                                  final userData = userDoc.data() as Map<String, dynamic>;
                                  final petName = userData['petName'] ?? "Pet";
                                  final breed = userData['breed'] ?? "Breed";
                                  
                                  // Prefer custom petImage, otherwise fallback to profileImage or null
                                  Uint8List? petBytes;
                                  try {
                                    if (userData['petImage'] != null) {
                                      petBytes = base64Decode(userData['petImage']);
                                    } else if (userData['profileImage'] != null) {
                                      petBytes = base64Decode(userData['profileImage']);
                                    }
                                  } catch (_) {}

                                  final colors = [
                                    [const Color(0xFFCBE3FB), const Color(0xFF0F4C81)],
                                    [const Color(0xFFE9DEFA), const Color(0xFF6B4C9A)],
                                    [const Color(0xFFFCDDE9), const Color(0xFF9E4B72)],
                                  ];
                                  final selectedColor = colors[index % colors.length];

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: _buildTastyPickCardWithBytes(
                                      petName,
                                      breed,
                                      petBytes,
                                      selectedColor[0],
                                      selectedColor[1],
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PetProfileScreen(userId: userDoc.id),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Community Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      "Community Stories & Feed 🐾",
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                  ),
                ),

                // 7. Posts Feed
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).limit(20).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: AppConstants.primaryColor),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(60),
                            child: Column(
                              children: [
                                const Icon(Icons.pets_rounded, size: 60, color: AppConstants.secondaryColor),
                                const SizedBox(height: 16),
                                Text(
                                  "No posts yet 🐾",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    var posts = snapshot.data!.docs;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          var post = posts[i].data() as Map<String, dynamic>;
                          if (post['userId'] == uid) return const SizedBox.shrink();
                          return PostCard(postData: post, postId: posts[i].id);
                        },
                        childCount: posts.length,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _promoConfettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [AppConstants.primaryColor, AppConstants.accentMint, AppConstants.accentPink, AppConstants.secondaryColor],
        ),
      ),
    ],
  ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
    bool isDark, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.primaryColor : (isDark ? AppConstants.darkCard : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey.shade200),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTastyPickCard(
    String title,
    String price,
    String imagePath,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: ClipOval(
                  child: Container(
                    width: 76,
                    height: 76,
                    color: Colors.white.withOpacity(0.4),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: GoogleFonts.fredoka(
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTastyPickCardWithBytes(
    String title,
    String breed,
    Uint8List? imageBytes,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: ClipOval(
                  child: Container(
                    width: 76,
                    height: 76,
                    color: Colors.white.withOpacity(0.4),
                    child: imageBytes != null
                        ? Image.memory(imageBytes, fit: BoxFit.cover)
                        : Image.asset("assets/mochu_labrador.png", fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              breed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsBadge extends StatelessWidget {
  final String uid;
  final String? lastAlertCheckedStr;
  final Color iconColor;

  const _AlertsBadge({
    required this.uid,
    required this.lastAlertCheckedStr,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    DateTime lastChecked = DateTime(2000);
    if (lastAlertCheckedStr != null) {
      try {
        lastChecked = DateTime.parse(lastAlertCheckedStr!);
      } catch (_) {}
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
      builder: (context, alertSnap) {
        int unreadCount = 0;
        if (alertSnap.hasData) {
          for (var doc in alertSnap.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            try {
              DateTime alertTime = DateTime.parse(data['timestamp']);
              if (alertTime.isAfter(lastChecked) && data['uid'] != uid) {
                unreadCount++;
              }
            } catch (_) {}
          }
        }
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(Icons.campaign_rounded, color: iconColor, size: 24),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set({'lastAlertChecked': DateTime.now().toIso8601String()}, SetOptions(merge: true));
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChatsBadge extends StatelessWidget {
  final String uid;
  final Color iconColor;
  final Widget Function(int count) badgeBuilder;

  const _ChatsBadge({
    required this.uid,
    required this.iconColor,
    required this.badgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('recent_chats').snapshots(),
      builder: (context, chatSnap) {
        int unreadTotal = 0;
        if (chatSnap.hasData) {
          for (var doc in chatSnap.data!.docs) {
            unreadTotal += (doc['unreadCount'] as int? ?? 0);
          }
        }
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.chat_bubble_2_fill, color: iconColor, size: 22),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
            ),
            if (unreadTotal > 0) badgeBuilder(unreadTotal),
          ],
        );
      },
    );
  }
}
