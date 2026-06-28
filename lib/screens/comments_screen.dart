import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const CommentsScreen({Key? key, required this.postId, required this.postOwnerId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    String text = _commentController.text.trim();
    _commentController.clear();

    var userSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    var userData = userSnap.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
      'text': text,
      'uid': uid,
      'username': userData['username'],
      'profileImage': userData['profileImage'],
      'date': DateTime.now().toIso8601String(),
    });

    if (widget.postOwnerId != uid) {
      await FirebaseFirestore.instance.collection('users').doc(widget.postOwnerId).collection('notifications').add({
        'type': 'comment',
        'fromId': uid,
        'username': userData['username'],
        'userImage': userData['profileImage'],
        'message': 'commented: $text',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Comments 💬",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: AppConstants.primaryColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet 🐾',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share your thoughts!',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    Uint8List? userImg;
                    try {
                      if (data['profileImage'] != null) {
                        userImg = base64Decode(data['profileImage']);
                      }
                    } catch (e) {}

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppConstants.storyRingGradient,
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: userImg != null ? MemoryImage(userImg) : null,
                              child: userImg == null ? const Icon(Icons.person, size: 18) : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppConstants.darkCard : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(0),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: const Radius.circular(20),
                                  bottomRight: const Radius.circular(20),
                                ),
                                boxShadow: isDark ? [] : AppConstants.cardShadow,
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['username'] ?? "User",
                                    style: GoogleFonts.fredoka(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: isDark ? Colors.white : AppConstants.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['text'] ?? "",
                                    style: GoogleFonts.fredoka(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : AppConstants.textPrimary.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Comment Input Bar
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade100,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        filled: true,
                        fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        hintStyle: GoogleFonts.fredoka(color: isDark ? Colors.white38 : Colors.grey.shade400, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: postComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppConstants.darkCapsule,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
