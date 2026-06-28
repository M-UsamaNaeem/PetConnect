import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/constants.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // FLOATING CARD STYLE
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.modernSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: AppConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (User Info)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.post.userProfileImage),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    Text(
                      "2 hrs ago", // You can use your timestamp logic here
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_vert_rounded, color: AppConstants.textSecondary),
              ],
            ),
          ),

          // 2. The Image (Rounded Corners)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Inner rounding
              child: Image.network(
                widget.post.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 3. Action Bar (Like, Comment)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isLiked ? Colors.redAccent : AppConstants.textPrimary,
                    size: 28,
                  ),
                  onPressed: () => setState(() => _isLiked = !_isLiked),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline_rounded, size: 26, color: AppConstants.textPrimary),
                const SizedBox(width: 4),
                Text("${widget.post.comments}", style: const TextStyle(fontWeight: FontWeight.w600)),
                
                const Spacer(),
                const Icon(Icons.bookmark_border_rounded, size: 28, color: AppConstants.textPrimary),
              ],
            ),
          ),

          // 4. Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                children: [
                  TextSpan(
                    text: "${widget.post.username} ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
