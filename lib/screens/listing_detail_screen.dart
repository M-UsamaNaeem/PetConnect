import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class ListingDetailScreen extends StatelessWidget {
  final String listingId;
  final Map<String, dynamic> data;

  const ListingDetailScreen({
    Key? key,
    required this.listingId,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isMine = data['sellerId'] == currentUid;

    ImageProvider? imageProvider;
    if (data['image'] != null && data['image'].toString().isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(data['image']));
      } catch (e) {
        // ignore
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          data['title'] ?? 'Listing Details',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
            Container(
              height: 320,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkSurface : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: imageProvider == null
                  ? const Icon(Icons.broken_image_rounded, size: 80, color: Colors.grey)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Item',
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppConstants.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                        ),
                        child: Text(
                          '\$${data['price']}',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                    child: Text(
                      data['category'] ?? 'Category',
                      style: GoogleFonts.fredoka(
                        color: isDark ? Colors.white70 : AppConstants.textWarm,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? 'No description provided.',
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppConstants.textPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 20),
                  // Seller Card info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                      boxShadow: isDark ? [] : AppConstants.cardShadow,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: data['sellerImage'] != null
                              ? MemoryImage(base64Decode(data['sellerImage']))
                              : null,
                          child: data['sellerImage'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seller',
                              style: GoogleFonts.fredoka(
                                color: AppConstants.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              data['sellerName'] ?? 'Unknown',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!isMine)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Notify seller
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            NotificationService.sendNotification(
                              targetUserId: data['sellerId'],
                              type: 'marketplace',
                              fromUsername: user.displayName ?? 'Someone',
                              fromUserId: user.uid,
                              message: 'is interested in ${data['title']}',
                            );
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                targetUserId: data['sellerId'],
                                targetUsername: data['sellerName'],
                                targetUserImage: data['sellerImage'],
                                preFilledMessage:
                                    "Hi, I'm interested in your listing: ${data['title']}",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                        label: Text(
                          'Contact Seller',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.darkCapsule,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
