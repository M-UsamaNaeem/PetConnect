import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import '../utils/constants.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Messages", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('recent_chats')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: AppConstants.secondaryColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text("No messages yet 💬", style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textSecondary)),
                Text("Start chatting with pet lovers!", style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              Uint8List? imgBytes;
              try { if(data['profileImage'] != null) imgBytes = base64Decode(data['profileImage']); } catch(e){}

              int unread = data['unreadCount'] ?? 0;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppConstants.storyRingGradient),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imgBytes != null ? MemoryImage(imgBytes) : null,
                      child: imgBytes == null ? const Icon(Icons.person) : null,
                    ),
                  ),
                  title: Text(
                      data['username'] ?? "Unknown",
                      style: GoogleFonts.fredoka(
                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600,
                          color: isDark ? Colors.white : AppConstants.textPrimary,
                      )
                  ),
                  subtitle: Text(
                    data['lastMessage'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                        color: unread > 0 ? (isDark ? Colors.white : AppConstants.textPrimary) : AppConstants.textSecondary,
                        fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                    ),
                  ),
                  trailing: unread > 0
                      ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
                    child: Text(unread.toString(), style: GoogleFonts.fredoka(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  )
                      : null,
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUid)
                        .collection('recent_chats')
                        .doc(data['chatWithId'])
                        .update({'unreadCount': 0})
                        .catchError((_) {});

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          targetUserId: data['chatWithId'],
                          targetUsername: data['username'],
                          targetUserImage: data['profileImage'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
