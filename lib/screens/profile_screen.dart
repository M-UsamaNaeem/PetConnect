import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:petconnect/screens/user_list_screen.dart';
import 'package:petconnect/screens/login_screen.dart';
import 'package:petconnect/screens/chat_screen.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import 'post_detail_screen.dart';
import 'pet_health_screen.dart';
import 'pet_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final String? userId;

  const ProfileScreen({Key? key, this.onThemeToggle, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  late String targetUid;
  bool isMe = false;
  bool isFollowing = false;
  bool isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    targetUid = widget.userId ?? currentUid;
    isMe = targetUid == currentUid;

    if (!isMe) checkIfFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void checkIfFollowing() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(targetUid).collection('followers').doc(currentUid).get();
    if (mounted) setState(() => isFollowing = doc.exists);
  }

  void toggleFollow() async {
    setState(() => isLoadingFollow = true);
    try {
      var targetRef = FirebaseFirestore.instance.collection('users').doc(targetUid);
      var myRef = FirebaseFirestore.instance.collection('users').doc(currentUid);

      if (isFollowing) {
        await targetRef.collection('followers').doc(currentUid).delete();
        await myRef.collection('following').doc(targetUid).delete();
        await targetRef.update({'followers': FieldValue.increment(-1)});
        await myRef.update({'following': FieldValue.increment(-1)});
      } else {
        await targetRef.collection('followers').doc(currentUid).set({});
        await myRef.collection('following').doc(targetUid).set({});
        await targetRef.update({'followers': FieldValue.increment(1)});
        await myRef.update({'following': FieldValue.increment(1)});
        _confettiController.play();

        var myData = (await myRef.get()).data()!;
        await targetRef.collection('notifications').add({
          'type': 'follow', 'fromId': currentUid, 'username': myData['username'], 'userImage': myData['profileImage'],
          'message': 'started following you.', 'timestamp': DateTime.now().toIso8601String(), 'isRead': false
        });
      }
      setState(() => isFollowing = !isFollowing);
    } catch (e) { print(e); }
    finally { setState(() => isLoadingFollow = false); }
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    final bioController = TextEditingController(text: userData['bio'] ?? '');
    final petNameController = TextEditingController(text: userData['petName'] ?? '');
    final petTypeController = TextEditingController(text: userData['petType'] ?? '');
    final breedController = TextEditingController(text: userData['breed'] ?? '');
    final petAgeController = TextEditingController(text: userData['petAge'] ?? '');
    final petWeightController = TextEditingController(text: userData['petWeight'] ?? '');
    final petBioController = TextEditingController(text: userData['petBio'] ?? '');
    String petGender = userData['petGender'] ?? 'Boy';

    File? newImage;
    File? newPetImage;

    Uint8List? currentPetBytes;
    try {
      if (userData['petImage'] != null) {
        currentPetBytes = base64Decode(userData['petImage']);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Edit Profile & Pet", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User photo edit
                      Text("Owner Profile Image", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 13, color: AppConstants.textSecondary)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);
                          if (picked != null) setStateDialog(() => newImage = File(picked.path));
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: newImage != null
                              ? FileImage(newImage!)
                              : (userData['profileImage'] != null ? MemoryImage(base64Decode(userData['profileImage'])) as ImageProvider : null),
                          child: (newImage == null && userData['profileImage'] == null) ? const Icon(Icons.add_a_photo) : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: bioController,
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "User Bio",
                          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Pet details section
                      Text("Pet Details 🐾", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 16, color: AppConstants.primaryColor)),
                      const SizedBox(height: 16),

                      // Pet Image upload
                      Text("Pet Image", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 13, color: AppConstants.textSecondary)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);
                          if (picked != null) setStateDialog(() => newPetImage = File(picked.path));
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: newPetImage != null
                              ? FileImage(newPetImage!)
                              : (currentPetBytes != null ? MemoryImage(currentPetBytes) as ImageProvider : null),
                          child: (newPetImage == null && currentPetBytes == null) ? const Icon(Icons.pets) : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: petNameController,
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Pet Name",
                          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: petTypeController,
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Pet Type (e.g. Dog, Cat)",
                          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: breedController,
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Breed",
                          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: petAgeController,
                              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: "Age (e.g. 1 Year)",
                                labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: petWeightController,
                              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: "Weight (e.g. 5 Kg)",
                                labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: petBioController,
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Pet Bio / Description",
                          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // Gender Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Gender:", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14)),
                          DropdownButton<String>(
                            value: petGender,
                            items: ['Boy', 'Girl'].map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(g, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setStateDialog(() => petGender = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> updates = {
                      'bio': bioController.text.trim(),
                      'petName': petNameController.text.trim(),
                      'petType': petTypeController.text.trim(),
                      'breed': breedController.text.trim(),
                      'petAge': petAgeController.text.trim(),
                      'petWeight': petWeightController.text.trim(),
                      'petBio': petBioController.text.trim(),
                      'petGender': petGender,
                    };
                    if (newImage != null) {
                      List<int> bytes = await newImage!.readAsBytes();
                      updates['profileImage'] = base64Encode(bytes);
                    }
                    if (newPetImage != null) {
                      List<int> bytes = await newPetImage!.readAsBytes();
                      updates['petImage'] = base64Encode(bytes);
                    }
                    await FirebaseFirestore.instance.collection('users').doc(currentUid).update(updates);
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text("Save", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _logout() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Logout", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
      content: Text("Are you sure you want to log out?", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700))),
        ElevatedButton(onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen(onThemeToggle: (){})), (route) => false);
        }, child: Text("Logout", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700))),
      ],
    ),
    );
  }

  void _confirmDeletePost(String postId) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Delete Post?", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
      content: Text("This action cannot be undone.", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700))),
        ElevatedButton(onPressed: () async {
          await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Deleted")));
        }, style: ElevatedButton.styleFrom(backgroundColor: AppConstants.errorColor), child: Text("Delete", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: Colors.white))),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(alignment: Alignment.topCenter, children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(targetUid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
            if (!snapshot.data!.exists) return Center(child: Text("User not found", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)));
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            Uint8List? profileBytes;
            try { if (userData['profileImage'] != null) profileBytes = base64Decode(userData['profileImage']); } catch (e) {}

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _buildGradientHeader(userData, profileBytes, isDark),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [Tab(text: "Posts"), Tab(text: "Saved")],
                    ),
                    isDark: isDark,
                  ),
                  pinned: true,
                ),
              ],
              body: TabBarView(controller: _tabController, children: [_buildPostsGrid(), _buildSavedGrid()]),
            );
          },
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [AppConstants.primaryColor, AppConstants.accentMint, AppConstants.accentPink, AppConstants.secondaryColor],
        ),
      ]),
    );
  }

  Widget _buildGradientHeader(Map<String, dynamic> userData, Uint8List? profileBytes, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final petType = userData['petType'] as String?;
    final petName = userData['petName'] as String?;
    final breed = userData['breed'] as String?;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFF8BBD0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (isMe) ...[
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PetHealthScreen())),
                      icon: const Icon(Icons.favorite_rounded, color: Colors.white70),
                      tooltip: 'Health Diary',
                    ),
                    IconButton(
                      onPressed: () => themeProvider.toggleTheme(),
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amber : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Avatar with glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.35), blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: GestureDetector(
                onTap: isMe ? () => _showEditProfileDialog(userData) : null,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileBytes != null ? MemoryImage(profileBytes) : null,
                  child: profileBytes == null ? const Icon(Icons.person, size: 52, color: Colors.grey) : null,
                ),
              ),
            ),

            const SizedBox(height: 14),

             // Username row with pet icon shortcut
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   userData['username'] ?? "User",
                   style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                 ),
                 if (petName != null && petName.isNotEmpty) ...[
                   const SizedBox(width: 8),
                   GestureDetector(
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => PetProfileScreen(userId: targetUid)),
                       );
                     },
                     child: Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.25),
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.pets_rounded, color: Colors.white, size: 16),
                     ),
                   ),
                 ],
               ],
             ),

             // Bio
             if ((userData['bio'] ?? "").isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 4, left: 32, right: 32),
                 child: Text(
                   userData['bio'],
                   style: GoogleFonts.fredoka(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600),
                   textAlign: TextAlign.center,
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
               ),

             // Dedicated Separate Pet Profile Card
             if (petName != null && petName.isNotEmpty)
               Container(
                 margin: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                 padding: const EdgeInsets.all(14),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.16),
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: Colors.white30),
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(2),
                       decoration: const BoxDecoration(
                         shape: BoxShape.circle,
                         gradient: AppConstants.storyRingGradient,
                       ),
                       child: CircleAvatar(
                         radius: 22,
                         backgroundImage: userData['petImage'] != null
                             ? MemoryImage(base64Decode(userData['petImage']))
                             : null,
                         child: userData['petImage'] == null
                             ? const Icon(Icons.pets_rounded, color: Colors.white, size: 20)
                             : null,
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             petName,
                             style: GoogleFonts.fredoka(
                               color: Colors.white,
                               fontSize: 15,
                               fontWeight: FontWeight.w800,
                             ),
                           ),
                           const SizedBox(height: 2),
                           Text(
                             breed ?? petType ?? 'My Pet',
                             style: GoogleFonts.fredoka(
                               color: Colors.white70,
                               fontSize: 11,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ],
                       ),
                     ),
                     ElevatedButton.icon(
                       onPressed: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => PetProfileScreen(userId: targetUid),
                           ),
                         );
                       },
                       icon: const Icon(Icons.arrow_forward_ios_rounded, size: 10),
                       label: Text("Profile", style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w800)),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppConstants.primaryColor,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         elevation: 0,
                       ),
                     ),
                   ],
                 ),
               ),

            const SizedBox(height: 20),

            // Action buttons
            if (isMe)
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(userData),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text("Edit Profile", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
              )
            else
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: isLoadingFollow ? null : toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.white24 : AppConstants.darkCapsule,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(isFollowing ? "Unfollow" : "Follow", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(targetUserId: targetUid, targetUsername: userData['username'] ?? "User", targetUserImage: userData['profileImage']))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text("Message", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
                ),
              ]),

            const SizedBox(height: 20),

            // Stats card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: targetUid).snapshots(),
                  builder: (ctx, snap) => _buildStat(snap.hasData ? snap.data!.docs.length.toString() : "0", "Posts"),
                ),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildStat(userData['followers']?.toString() ?? "0", "Followers",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen(userId: targetUid, type: 'followers')))),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildStat(userData['following']?.toString() ?? "0", "Following",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen(userId: targetUid, type: 'following')))),
              ]),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildPostsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: targetUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No posts yet 🐾", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppConstants.textSecondary)));
        return _buildGrid(snapshot.data!.docs);
      },
    );
  }

  Widget _buildSavedGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(targetUid).collection('saved').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No saved posts 📌", style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppConstants.textSecondary)));

        return GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            String savedPostId = snapshot.data!.docs[index].id;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('posts').doc(savedPostId).get(),
              builder: (context, postSnap) {
                if (postSnap.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryColor),
                      ),
                    ),
                  );
                }
                if (!postSnap.hasData || !postSnap.data!.exists) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.bookmark_border_rounded, color: Colors.grey, size: 24),
                    ),
                  );
                }
                var post = postSnap.data!.data() as Map<String, dynamic>;
                Uint8List? postImg;
                try { if (post['postImage'] != null) postImg = base64Decode(post['postImage']); } catch (e) {}
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postData: post, postId: savedPostId))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: postImg != null ? Image.memory(postImg, fit: BoxFit.cover) : const Icon(Icons.error),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGrid(List<DocumentSnapshot> docs) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final post = docs[index].data() as Map<String, dynamic>;
        Uint8List? postImg;
        try { if (post['postImage'] != null) postImg = base64Decode(post['postImage']); } catch (e) {}
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postData: post, postId: docs[index].id))),
          onLongPress: () {
            if (isMe) _confirmDeletePost(docs[index].id);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: postImg != null ? Image.memory(postImg, fit: BoxFit.cover) : const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Text(value, style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool isDark;
  _SliverAppBarDelegate(this._tabBar, {this.isDark = false});
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppConstants.darkSurface : Colors.white,
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => oldDelegate.isDark != isDark;
}
