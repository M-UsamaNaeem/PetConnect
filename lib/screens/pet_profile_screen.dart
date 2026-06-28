import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';

class PetProfileScreen extends StatelessWidget {
  final String userId;

  const PetProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark mode background by default
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildErrorState(context);
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final petName = userData['petName'] as String? ?? 'Mochu';
          final breed = userData['breed'] as String? ?? 'Labrador Retriever';
          final ownerName = userData['username'] as String? ?? 'Eliena Dcruze';

          // Use Mock gender, age, weight if user didn't specify in DB
          final gender = userData['petGender'] as String? ?? 'Boy';
          final age = userData['petAge'] as String? ?? '6 Months';
          final weight = userData['petWeight'] as String? ?? '5.2 Kg';

          Uint8List? ownerBytes;
          try {
            if (userData['profileImage'] != null) {
              ownerBytes = base64Decode(userData['profileImage']);
            }
          } catch (_) {}

          Uint8List? petBytes;
          try {
            if (userData['petImage'] != null) {
              petBytes = base64Decode(userData['petImage']);
            }
          } catch (_) {}

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "Pet Profile",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                          onPressed: () {
                            _showMoreOptions(context, petName);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Central Pet Image with Orange Arch Backdrop
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Arch backdrop (peach/orange)
                          Container(
                            width: 230,
                            height: 260,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8E53), // Accent orange arch
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(115),
                                topRight: Radius.circular(115),
                              ),
                            ),
                          ),
                          // Pet image (using the generated Mochu Labrador image by default)
                          Container(
                            width: 210,
                            height: 240,
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(105),
                                topRight: Radius.circular(105),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: petBytes != null
                                ? Image.memory(petBytes, fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/mochu_labrador.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback icon if asset image not found
                                      return Container(
                                        color: Colors.white12,
                                        child: const Icon(
                                          Icons.pets_rounded,
                                          size: 100,
                                          color: Colors.white54,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Pet Name & Breed
                    Text(
                      petName,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      breed,
                      style: GoogleFonts.fredoka(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Detail Pills (Gender, Age, Weight)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailPill(
                          "Gender",
                          gender,
                          const Color(0xFFCBE3FB), // Light pastel blue
                          const Color(0xFF0F4C81),
                        ),
                        _buildDetailPill(
                          "Age",
                          age,
                          const Color(0xFFE9DEFA), // Light pastel lavender
                          const Color(0xFF6B4C9A),
                        ),
                        _buildDetailPill(
                          "Weight",
                          weight,
                          const Color(0xFFFCDDE9), // Light pastel pink
                          const Color(0xFF9E4B72),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Owner Card Link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: userId),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C2E), // Charcoal dark card background
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white12,
                              backgroundImage: ownerBytes != null ? MemoryImage(ownerBytes) : null,
                              child: ownerBytes == null
                                  ? const Icon(Icons.person, color: Colors.white70)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ownerName,
                                    style: GoogleFonts.fredoka(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Owner",
                                    style: GoogleFonts.fredoka(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white30,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description text
                    Text(
                      (userData['petBio'] != null && (userData['petBio'] as String).isNotEmpty)
                          ? userData['petBio']
                          : "$petName is the most loyal companion I could ask for. He is playful, always full of energy, and somehow knows when I need a friend to cheer me up. He loves running around the park and chasing balls! 🐾",
                      style: GoogleFonts.fredoka(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailPill(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.fredoka(
              color: textColor.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.fredoka(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 60),
          const SizedBox(height: 16),
          Text(
            "Pet not found",
            style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context, String petName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: Colors.white70),
                  title: Text(
                    "Share $petName's Profile",
                    style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profile link copied for $petName! 🐾")),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded, color: Colors.white70),
                  title: Text(
                    "Add to Favorites",
                    style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$petName added to favorites! ❤️")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
