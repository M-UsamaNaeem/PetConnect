import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String? postId;

  const PostDetailScreen({Key? key, required this.postData, this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String currentUid = FirebaseAuth.instance.currentUser!.uid;
    bool isMe = postData['userId'] == currentUid;

    Uint8List? postImageBytes;
    try {
      if (postData['postImage'] != null) {
        postImageBytes = base64Decode(postData['postImage']);
      }
    } catch (e) {
      print("Error decoding image: $e");
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
        title: Text(
          "Post 📸",
          style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (isMe && postId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppConstants.primaryColor),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Post Deleted 🐾", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
                    backgroundColor: AppConstants.primaryColor,
                  ),
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded Image Container
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              constraints: const BoxConstraints(minHeight: 300, maxHeight: 500),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkSurface : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
                image: postImageBytes != null
                    ? DecorationImage(image: MemoryImage(postImageBytes), fit: BoxFit.cover)
                    : null,
              ),
              child: postImageBytes == null
                  ? const Center(child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey))
                  : null,
            ),
            // Caption Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  boxShadow: isDark ? [] : AppConstants.cardShadow,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          postData['username'] ?? "User",
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isDark ? Colors.white : AppConstants.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      postData['caption'] ?? "",
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppConstants.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
