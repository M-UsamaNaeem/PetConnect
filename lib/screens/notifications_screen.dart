import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _markedAsRead = false;

  void _markAllAsRead(List<QueryDocumentSnapshot> docs) {
    if (_markedAsRead) return;
    _markedAsRead = true;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isRead'] == false) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(doc.id)
            .update({'isRead': true}).catchError((_) {});
      }
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'like': return Icons.favorite_rounded;
      case 'follow': return Icons.person_add_rounded;
      case 'comment': return Icons.chat_bubble_rounded;
      case 'message': return Icons.message_rounded;
      case 'story_reaction': return Icons.auto_awesome_rounded;
      case 'marketplace':
      case 'marketplace_new': return Icons.storefront_rounded;
      case 'welcome': return Icons.celebration_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'like': return AppConstants.primaryColor;
      case 'follow': return AppConstants.accentMint;
      case 'comment': return const Color(0xFFFF8E53);
      case 'message': return AppConstants.secondaryColor;
      case 'story_reaction': return const Color(0xFFD0BCFF);
      case 'marketplace': return AppConstants.accentMint;
      case 'marketplace_new': return const Color(0xFFFF8E53);
      case 'welcome': return AppConstants.primaryColor;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 72, color: AppConstants.secondaryColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("No notifications yet 🔔", style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textSecondary)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          WidgetsBinding.instance.addPostFrameCallback((_) => _markAllAsRead(docs));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
            itemBuilder: (context, index) {
              final notif = docs[index].data() as Map<String, dynamic>;
              Uint8List? userImg;
              try { if (notif['userImage'] != null && notif['userImage'] != '') userImg = base64Decode(notif['userImage']); } catch (e) {}
              final bool isUnread = notif['isRead'] == false;
              final String? type = notif['type'];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: isUnread
                    ? AppConstants.primaryColor.withOpacity(isDark ? 0.1 : 0.04)
                    : Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppConstants.storyRingGradient),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userImg != null ? MemoryImage(userImg) : null,
                          child: userImg == null ? const Icon(Icons.person, size: 20) : null,
                        ),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _colorForType(type),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppConstants.darkBackground : AppConstants.modernBackground, width: 2),
                          ),
                          child: Icon(_iconForType(type), size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontSize: 14),
                      children: [
                        TextSpan(text: "${notif['username'] ?? 'Someone'} ", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
                        TextSpan(text: notif['message'] ?? '', style: GoogleFonts.fredoka(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    notif['timestamp'] != null ? notif['timestamp'].toString().substring(0, 10) : "Just now",
                    style: GoogleFonts.fredoka(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  trailing: isUnread
                      ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle))
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
