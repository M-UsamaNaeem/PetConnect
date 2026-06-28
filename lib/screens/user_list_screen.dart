import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';

class UserListScreen extends StatelessWidget {
  final String userId;
  final String type; // "followers" or "following"

  const UserListScreen({Key? key, required this.userId, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          type[0].toUpperCase() + type.substring(1),
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(type)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 64,
                    color: AppConstants.primaryColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No $type found 🐾",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              String otherUserId = docs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox();

                  var userData = userSnap.data!.data() as Map<String, dynamic>;

                  Uint8List? imageBytes;
                  try {
                    if (userData['profileImage'] != null) {
                      imageBytes = base64Decode(userData['profileImage']);
                    }
                  } catch (e) {}

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                      boxShadow: isDark ? [] : AppConstants.cardShadow,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppConstants.storyRingGradient,
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                          child: imageBytes == null ? const Icon(Icons.person) : null,
                        ),
                      ),
                      title: Text(
                        userData['username'] ?? "Unknown",
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppConstants.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        userData['bio'] ?? "Hello pet lovers!",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen(userId: otherUserId)),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
