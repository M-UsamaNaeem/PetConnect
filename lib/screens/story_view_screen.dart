import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  const StoryViewScreen({Key? key, required this.stories}) : super(key: key);
  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  int currentIndex = 0;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  void _startStory() {
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animController.forward();
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() {
        currentIndex++;
        _animController.dispose();
        _startStory();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _addNewStory() async {
    _animController.stop();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);

    if (picked != null) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Story Added! 🐾", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var story = widget.stories[currentIndex];
    Uint8List? storyImageBytes;
    Uint8List? profileImageBytes;
    try {
      if (story['storyImage'] != null) storyImageBytes = base64Decode(story['storyImage']);
    } catch (e) {}
    try {
      if (story['profileImage'] != null) profileImageBytes = base64Decode(story['profileImage']);
    } catch (e) {}
    bool isMyStory = story['uid'] == uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            if (details.globalPosition.dx > MediaQuery.of(context).size.width / 2) {
              _nextStory();
            } else if (currentIndex > 0) {
              setState(() {
                currentIndex--;
                _animController.dispose();
                _startStory();
              });
            }
          },
          child: Stack(
            children: [
              // Main Story Image
              Center(
                child: storyImageBytes != null
                    ? Image.memory(storyImageBytes, fit: BoxFit.contain)
                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              // Top progress bar list
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(
                    widget.stories.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: index == currentIndex
                              ? AnimatedBuilder(
                                  animation: _animController,
                                  builder: (ctx, child) => LinearProgressIndicator(
                                    value: _animController.value,
                                    backgroundColor: Colors.white30,
                                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                                    minHeight: 3,
                                  ),
                                )
                              : LinearProgressIndicator(
                                  value: index < currentIndex ? 1 : 0,
                                  backgroundColor: Colors.white30,
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                  minHeight: 3,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // User profile header
              Positioned(
                top: 25,
                left: 15,
                right: 15,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppConstants.storyRingGradient,
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: profileImageBytes != null ? MemoryImage(profileImageBytes) : null,
                        child: profileImageBytes == null ? const Icon(Icons.person, size: 20, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      story['username'] ?? "User",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (isMyStory)
                      IconButton(
                        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
                        onPressed: _addNewStory,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Reactions / Info at the bottom
              if (!isMyStory && story['id'] != null)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['❤️', '😍', '🔥', '😂', '😢'].map((emoji) {
                        return GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('stories')
                                .doc(story['id'])
                                .collection('reactions')
                                .doc(uid)
                                .set({'emoji': emoji});

                            if (story['uid'] != uid) {
                              var myDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                              var myData = myDoc.data() as Map<String, dynamic>;
                              var targetDoc = await FirebaseFirestore.instance.collection('users').doc(story['uid']).get();
                              var targetData = targetDoc.data() as Map<String, dynamic>;

                              List<String> ids = [uid, story['uid']];
                              ids.sort();
                              String chatId = ids.join("_");
                              String timestamp = DateTime.now().toIso8601String();

                              // 1. Send the story image to the chat thread
                              if (story['storyImage'] != null && (story['storyImage'] as String).isNotEmpty) {
                                await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
                                  'senderId': uid,
                                  'receiverId': story['uid'],
                                  'type': 'image',
                                  'content': story['storyImage'],
                                  'timestamp': timestamp,
                                });
                              }

                              // 2. Send the emoji message
                              await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
                                'senderId': uid,
                                'receiverId': story['uid'],
                                'type': 'text',
                                'content': 'Story Reaction: $emoji',
                                'timestamp': timestamp,
                              });

                              // 3. Update recent chats for both users
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('recent_chats').doc(story['uid']).set({
                                'chatWithId': story['uid'],
                                'username': targetData['username'] ?? 'User',
                                'profileImage': targetData['profileImage'] ?? '',
                                'lastMessage': 'Reacted $emoji to your story',
                                'timestamp': timestamp,
                                'unreadCount': 0,
                              });

                              await FirebaseFirestore.instance.collection('users').doc(story['uid']).collection('recent_chats').doc(uid).set({
                                'chatWithId': uid,
                                'username': myData['username'] ?? 'User',
                                'profileImage': myData['profileImage'] ?? '',
                                'lastMessage': 'Reacted $emoji to your story',
                                'timestamp': timestamp,
                                'unreadCount': FieldValue.increment(1),
                              }, SetOptions(merge: true));

                              // 4. Send message notification
                              await NotificationService.sendNotification(
                                targetUserId: story['uid'],
                                type: 'message',
                                fromUsername: myData['username'] ?? 'User',
                                fromUserId: uid,
                                userImage: myData['profileImage'],
                                message: 'reacted $emoji to your story',
                              );
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reacted with $emoji', style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                                  duration: const Duration(milliseconds: 500),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 26)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              if (isMyStory && story['id'] != null)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('stories')
                          .doc(story['id'])
                          .collection('reactions')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            '🔥 ${snapshot.data!.docs.length} Reactions',
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
