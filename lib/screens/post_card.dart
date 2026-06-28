import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/post_detail_screen.dart';
import '../screens/comments_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';
import 'chat_screen.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;
  const PostCard({Key? key, required this.postData, required this.postId}) : super(key: key);
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLiked = false;
  bool isSaved = false;
  int likeCount = 0;

  Uint8List? postImg;

  @override
  void initState() {
    super.initState();
    likeCount = widget.postData['likes'] ?? 0;

    try {
      if (widget.postData['postImage'] != null) {
        postImg = base64Decode(widget.postData['postImage']);
      }
    } catch (e) {}

    checkStatus();
  }

  void checkStatus() async {
    try {
      var likeDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('likes').doc(currentUid).get();
      var saveDoc = await FirebaseFirestore.instance.collection('users').doc(currentUid).collection('saved').doc(widget.postId).get();
      if (mounted) setState(() { isLiked = likeDoc.exists; isSaved = saveDoc.exists; });
    } catch (e) {}
  }

  void toggleLike() async {
    setState(() { isLiked = !isLiked; likeCount += isLiked ? 1 : -1; });
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    if (isLiked) {
      await postRef.collection('likes').doc(currentUid).set({});
      await postRef.update({'likes': FieldValue.increment(1)});

      if (widget.postData['userId'] != currentUid) {
        var existing = await FirebaseFirestore.instance.collection('users').doc(widget.postData['userId']).collection('notifications')
            .where('fromId', isEqualTo: currentUid)
            .where('postId', isEqualTo: widget.postId)
            .where('type', isEqualTo: 'like')
            .get();

        if (existing.docs.isEmpty) {
          var myData = (await FirebaseFirestore.instance.collection('users').doc(currentUid).get()).data()!;
          await NotificationService.sendNotification(
            targetUserId: widget.postData['userId'],
            type: 'like',
            fromUsername: myData['username'] ?? 'User',
            fromUserId: currentUid,
            userImage: myData['profileImage'],
            message: 'liked your post',
          );
        }
      }
    } else {
      await postRef.collection('likes').doc(currentUid).delete();
      await postRef.update({'likes': FieldValue.increment(-1)});
    }
  }

  void toggleSave() async {
    setState(() => isSaved = !isSaved);
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
    if (isSaved) { await userRef.collection('saved').doc(widget.postId).set({'postId': widget.postId, 'date': DateTime.now().toIso8601String()}); }
    else { await userRef.collection('saved').doc(widget.postId).delete(); }
  }

  void showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20), height: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppConstants.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text("Send to...", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('following').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Follow someone to share!", style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)));
                  var followingDocs = snapshot.data!.docs;

                  return ListView.builder(scrollDirection: Axis.horizontal, itemCount: followingDocs.length, itemBuilder: (context, index) {
                    String userId = followingDocs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox();
                        var userData = userSnap.data!.data() as Map<String, dynamic>;
                        Uint8List? img;
                        try { if(userData['profileImage'] != null) img = base64Decode(userData['profileImage']); } catch(e){}

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                                targetUserId: userId,
                                targetUsername: userData['username'] ?? "User",
                                targetUserImage: userData['profileImage'],
                                sharedPostImage: widget.postData['postImage']
                            )));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent to ${userData['username']}")));
                          },
                          child: Padding(padding: const EdgeInsets.only(right: 15), child: Column(children: [
                            CircleAvatar(radius: 30, backgroundColor: Colors.grey[200], backgroundImage: img != null ? MemoryImage(img) : null, child: img == null ? const Icon(Icons.person) : null),
                            const SizedBox(height: 5),
                            SizedBox(width: 60, child: Text(userData['username'] ?? "User", style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center))
                          ])),
                        );
                      },
                    );
                  },
                  );
                },
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppConstants.darkCard : Colors.white;
    final iconColor = isDark ? Colors.white : AppConstants.textPrimary;
    final textColor = isDark ? Colors.white : AppConstants.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // User header
        FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(widget.postData['userId']).get(),
            builder: (context, snapshot) {
              String username = widget.postData['username'] ?? "User";
              Uint8List? userImg;
              if (snapshot.hasData && snapshot.data!.exists) {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                username = userData['username'] ?? username;
                try { if (userData['profileImage'] != null) userImg = base64Decode(userData['profileImage']); } catch (e) {}
              }
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.postData['userId']))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppConstants.storyRingGradient,
                      ),
                      child: CircleAvatar(radius: 18, backgroundColor: Colors.grey[200], backgroundImage: userImg != null ? MemoryImage(userImg) : null, child: userImg == null ? const Icon(Icons.person, size: 18) : null),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(username, style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 14, color: textColor))),
                    Icon(Icons.more_horiz, color: iconColor, size: 20),
                  ]),
                ),
              );
            }
        ),

        // Post image (Stretches edge-to-edge)
        GestureDetector(
          onDoubleTap: toggleLike,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postData: widget.postData, postId: widget.postId))),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 250,
              maxHeight: 500,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : Colors.grey[100],
            ),
            child: postImg != null
                ? Image.memory(postImg!, fit: BoxFit.cover, width: double.infinity)
                : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
        ),

        // Action bar (Instagram style CupertinoIcons)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(children: [
            IconButton(
              icon: Icon(
                isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isLiked ? AppConstants.primaryColor : iconColor,
                size: 26,
              ),
              onPressed: toggleLike,
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.chat_bubble,
                color: iconColor,
                size: 24,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    postId: widget.postId,
                    postOwnerId: widget.postData['userId'],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.paperplane,
                color: iconColor,
                size: 24,
              ),
              onPressed: showShareSheet,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                color: isSaved ? AppConstants.primaryColor : iconColor,
                size: 24,
              ),
              onPressed: toggleSave,
            ),
          ]),
        ),

        // Likes & caption
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$likeCount likes",
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.fredoka(color: textColor, fontSize: 13),
                  children: [
                    TextSpan(
                      text: "${widget.postData['username']} ",
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: widget.postData['caption'] ?? "",
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
