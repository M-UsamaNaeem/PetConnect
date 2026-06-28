import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUsername;
  final String? targetUserImage;
  final String? sharedPostImage;
  final String? preFilledMessage;

  const ChatScreen({
    Key? key,
    required this.targetUserId,
    required this.targetUsername,
    this.targetUserImage,
    this.sharedPostImage,
    this.preFilledMessage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  late String chatId;

  @override
  void initState() {
    super.initState();
    List<String> ids = [currentUid, widget.targetUserId];
    ids.sort();
    chatId = ids.join("_");

    _markAsRead();

    if (widget.sharedPostImage != null) sendMessage(type: 'image', content: widget.sharedPostImage!);
    if (widget.preFilledMessage != null) _messageController.text = widget.preFilledMessage!;
  }

  void _markAsRead() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('recent_chats')
          .doc(widget.targetUserId)
          .update({'unreadCount': 0});
    } catch (_) {}
  }

  void _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);
    if (picked != null) {
      List<int> bytes = await picked.readAsBytes();
      String base64Image = base64Encode(bytes);
      sendMessage(type: 'image', content: base64Image);
    }
  }

  void sendMessage({String type = 'text', required String content}) async {
    if (content.trim().isEmpty) return;
    _messageController.clear();

    String timestamp = DateTime.now().toIso8601String();

    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUid, 'receiverId': widget.targetUserId,
      'type': type, 'content': content, 'timestamp': timestamp,
    });

    await FirebaseFirestore.instance.collection('users').doc(currentUid).collection('recent_chats').doc(widget.targetUserId).set({
      'chatWithId': widget.targetUserId, 'username': widget.targetUsername, 'profileImage': widget.targetUserImage,
      'lastMessage': type == 'image' ? 'Sent an image' : content, 'timestamp': timestamp, 'unreadCount': 0,
    });

    var myDoc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
    var myData = myDoc.data() as Map<String, dynamic>;
    await FirebaseFirestore.instance.collection('users').doc(widget.targetUserId).collection('recent_chats').doc(currentUid).set({
      'chatWithId': currentUid, 'username': myData['username'], 'profileImage': myData['profileImage'],
      'lastMessage': type == 'image' ? 'Sent an image' : content, 'timestamp': timestamp, 'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await NotificationService.sendNotification(
      targetUserId: widget.targetUserId,
      type: 'message',
      fromUsername: myData['username'] ?? 'User',
      fromUserId: currentUid,
      userImage: myData['profileImage'],
      message: type == 'image' ? 'sent you an image' : content,
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? targetImgBytes;
    try { if (widget.targetUserImage != null) targetImgBytes = base64Decode(widget.targetUserImage!); } catch (e) {}

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppConstants.storyRingGradient),
            child: CircleAvatar(radius: 16, backgroundImage: targetImgBytes != null ? MemoryImage(targetImgBytes) : null, child: targetImgBytes == null ? const Icon(Icons.person, size: 16) : null),
          ),
          const SizedBox(width: 10),
          Text(widget.targetUsername, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                var msgs = snapshot.data!.docs;
                if (msgs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());
                }
                return ListView.builder(
                  reverse: true, itemCount: msgs.length, itemBuilder: (context, index) {
                  var msg = msgs[index].data() as Map<String, dynamic>;
                  bool isMe = msg['senderId'] == currentUid;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? AppConstants.darkCapsule : (isDark ? AppConstants.darkCard : AppConstants.creamLight),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                        ),
                      ),
                      child: msg['type'] == 'image'
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(msg['content']), fit: BoxFit.cover))
                          : Text(msg['content'], style: GoogleFonts.fredoka(color: isMe ? Colors.white : (isDark ? Colors.white : AppConstants.textPrimary), fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade100)),
            ),
            child: SafeArea(
              child: Row(children: [
                GestureDetector(
                    onTap: _sendImage,
                    child: Container(decoration: BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle), padding: const EdgeInsets.all(10), child: const Icon(Icons.camera_alt, color: Colors.white, size: 20))
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.fredoka(
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: AppConstants.primaryColor,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle: GoogleFonts.fredoka(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => sendMessage(content: _messageController.text),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppConstants.darkCapsule, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
