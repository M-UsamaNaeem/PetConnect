import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StoryWidget extends StatelessWidget {
  final String username;
  final String profileImage;
  final bool hasStory;

  const StoryWidget({
    Key? key,
    required this.username,
    required this.profileImage,
    this.hasStory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // 1. THE 3D AVATAR CONTAINER
          Container(
            padding: const EdgeInsets.all(3), // Space between ring and image
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // The "3D" Gradient Ring
              gradient: hasStory
                  ? const LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              // The "Pop" Shadow
              boxShadow: hasStory
                  ? [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2), // White border inside
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 28, // Slightly smaller for better proportion
                backgroundImage: NetworkImage(profileImage),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. Username
          SizedBox(
            width: 70,
            child: Text(
              username,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
