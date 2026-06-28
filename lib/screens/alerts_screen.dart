import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petconnect/screens/chat_screen.dart';
import '../utils/constants.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _addAlert() {
    TextEditingController descCtrl = TextEditingController();
    TextEditingController colorCtrl = TextEditingController();
    TextEditingController heightCtrl = TextEditingController();
    TextEditingController locationCtrl = TextEditingController();
    TextEditingController phoneCtrl = TextEditingController();
    File? _alertImage;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut).value,
          child: Opacity(
            opacity: anim1.value,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return AlertDialog(
                  backgroundColor: isDark ? AppConstants.darkSurface : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
                  title: Center(child: Text("Post Pet Alert", style: GoogleFonts.fredoka(color: AppConstants.primaryColor, fontWeight: FontWeight.w900, fontSize: 22))),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 700);
                              if (picked != null) setStateDialog(() => _alertImage = File(picked.path));
                            },
                            child: Container(
                              height: 150, width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _alertImage == null ? (isDark ? Colors.white10 : Colors.grey.shade200) : AppConstants.primaryColor, width: 2),
                                image: _alertImage != null ? DecorationImage(image: FileImage(_alertImage!), fit: BoxFit.cover) : null,
                              ),
                              child: _alertImage == null
                                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 40, color: AppConstants.primaryColor.withValues(alpha: 0.5)), const SizedBox(height: 8), Text("Tap to add photo", style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontWeight: FontWeight.w600))])
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text("Pet Details", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : AppConstants.textPrimary)),
                          const SizedBox(height: 10),
                          TextField(controller: descCtrl, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary), decoration: _inputDecoration("Description (e.g. Lost Cat)", Icons.edit, isDark), maxLines: 2),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: TextField(controller: colorCtrl, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary), decoration: _inputDecoration("Color", Icons.color_lens, isDark))),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(controller: heightCtrl, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary), decoration: _inputDecoration("Size", Icons.height, isDark))),
                          ]),
                          const SizedBox(height: 20),
                          Text("Contact Info", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : AppConstants.textPrimary)),
                          const SizedBox(height: 10),
                          TextField(controller: locationCtrl, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary), decoration: _inputDecoration("Last Seen Location", Icons.pin_drop, isDark)),
                          const SizedBox(height: 10),
                          TextField(controller: phoneCtrl, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary), decoration: _inputDecoration("Phone Number", Icons.phone, isDark), keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontSize: 16, fontWeight: FontWeight.w700))),
                    ElevatedButton(
                      onPressed: () async {
                        if (descCtrl.text.isNotEmpty) {
                          String? base64Image;
                          if (_alertImage != null) {
                            List<int> bytes = await _alertImage!.readAsBytes();
                            base64Image = base64Encode(bytes);
                          }
                          Navigator.pop(ctx);
                          var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                          var userData = userDoc.data()!;
                          await FirebaseFirestore.instance.collection('alerts').add({
                            'uid': uid, 'username': userData['username'], 'userImage': userData['profileImage'],
                            'text': descCtrl.text, 'color': colorCtrl.text, 'height': heightCtrl.text, 'location': locationCtrl.text, 'phone': phoneCtrl.text, 'image': base64Image,
                            'timestamp': DateTime.now().toIso8601String(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alert Posted!")));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.darkCapsule, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius))),
                      child: Text("Post Alert", style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint, prefixIcon: Icon(icon, size: 20, color: AppConstants.primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.inputRadius), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.inputRadius), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.inputRadius), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
      filled: true, fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
      hintStyle: GoogleFonts.fredoka(color: isDark ? Colors.white38 : Colors.grey.shade400, fontWeight: FontWeight.w500),
    );
  }

  void _deleteAlert(String alertId) {
    FirebaseFirestore.instance.collection('alerts').doc(alertId).delete();
  }

  String _formatTimeAgo(String? isoString) {
    if (isoString == null) return "Just now";
    try {
      DateTime dt = DateTime.parse(isoString);
      Duration diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) {
        return "Just now";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else {
        return "${diff.inDays}d ago";
      }
    } catch (_) {
      return "Just now";
    }
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppConstants.primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppConstants.textWarm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Pet Alerts", style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w900)),
        automaticallyImplyLeading: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppConstants.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _addAlert,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppConstants.primaryColor, borderRadius: BorderRadius.circular(AppConstants.pillRadius)),
                child: Row(children: [
                  const Icon(Icons.add, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text("Alert", style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('alerts').orderBy('timestamp', descending: true).limit(30).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
            var alerts = snapshot.data!.docs;
            if (alerts.isEmpty) return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets_rounded, size: 60, color: AppConstants.accentMint.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text("No active alerts", style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textSecondary)),
                Text("All pets are safe!", style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ));

            return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  var data = alerts[index].data() as Map<String, dynamic>;
                  bool isMe = data['uid'] == uid;
                  Uint8List? alertImg;
                  try { if(data['image'] != null) alertImg = base64Decode(data['image']); } catch(e){}
                  
                  Uint8List? posterImg;
                  try { if(data['userImage'] != null && data['userImage'] != '') posterImg = base64Decode(data['userImage']); } catch(e){}

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Icon Badge & Delete/Share
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Glowing Squircle Icon Box
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppConstants.coralGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryColor.withOpacity(0.35),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            // Delete button if it's my alert
                            if (isMe)
                              GestureDetector(
                                onTap: () => _deleteAlert(alerts[index].id),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Metadata Subheader
                        Text(
                          "PET ALERT • ${_formatTimeAgo(data['timestamp'])}".toUpperCase(),
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.primaryColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title: Styled Text
                        Text(
                          data['text'] ?? "Urgent Alert",
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Details (bullet points/pills)
                        if ((data['color'] != null && data['color'] != "") || 
                            (data['location'] != null && data['location'] != "") ||
                            (data['height'] != null && data['height'] != ""))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['location'] != null && data['location'] != "")
                                  _buildDetailRow(Icons.location_on_rounded, "Last seen: ${data['location']}", isDark),
                                if (data['color'] != null && data['color'] != "")
                                  _buildDetailRow(Icons.color_lens_rounded, "Color/Appearance: ${data['color']}", isDark),
                                if (data['height'] != null && data['height'] != "")
                                  _buildDetailRow(Icons.height_rounded, "Size/Height: ${data['height']}", isDark),
                              ],
                            ),
                          ),

                        // Alert Image (High fidelity rounded layout)
                        if (alertImg != null)
                          Container(
                            height: 220,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(image: MemoryImage(alertImg), fit: BoxFit.cover),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Posted by user line
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: posterImg != null ? MemoryImage(posterImg) : null,
                              child: posterImg == null ? const Icon(Icons.person, size: 12, color: Colors.grey) : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Posted by ${data['username'] ?? 'Someone'}",
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        // Contact Owner Button (if not me)
                        if (!isMe) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      targetUserId: data['uid'],
                                      targetUsername: data['username'],
                                      targetUserImage: data['userImage'],
                                      sharedPostImage: data['image'],
                                      preFilledMessage: "Hi, regarding your alert '${data['text']}'...",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16),
                              label: Text("Contact Owner", style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.darkCapsule,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}
