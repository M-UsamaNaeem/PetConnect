class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfileImage;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;
  final DateTime timestamp;
  bool isLiked;
  bool isSaved;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLiked = false,
    this.isSaved = false,
  });

  // --- UPDATED MOCK DATA WITH WORKING IMAGES ---
  static List<PostModel> mockPosts = [
    PostModel(
      id: '1',
      userId: '2',
      username: 'bhaggabilla',
      userProfileImage: 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix', // Cute Avatar
      imageUrl: 'https://picsum.photos/id/237/400/400', // cute dog
      caption: 'My adorable puppy enjoying the evening! 🐶✨',
      likes: 234,
      comments: 45,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostModel(
      id: '2',
      userId: '3',
      username: 'catbuddy',
      userProfileImage: 'https://api.dicebear.com/7.x/avataaars/png?seed=Garfield',
      imageUrl: 'https://picsum.photos/id/40/400/400', // cat
      caption: 'Beautiful sunset photoshoot with this cutie 📸',
      likes: 567,
      comments: 89,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PostModel(
      id: '3',
      userId: '4',
      username: 'pawsome_pets',
      userProfileImage: 'https://api.dicebear.com/7.x/avataaars/png?seed=Max',
      imageUrl: 'https://picsum.photos/id/169/400/400', // another dog
      caption: 'Playing time! Who else loves playful pets? 🐾',
      likes: 432,
      comments: 67,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  static List<Map<String, dynamic>> mockStories = [
    {'username': 'You', 'profileImage': 'https://api.dicebear.com/7.x/avataaars/png?seed=You', 'hasStory': false},
    {'username': 'bhagga', 'profileImage': 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix', 'hasStory': true},
    {'username': 'catbuddy', 'profileImage': 'https://api.dicebear.com/7.x/avataaars/png?seed=Garfield', 'hasStory': true},
    {'username': 'paws', 'profileImage': 'https://api.dicebear.com/7.x/avataaars/png?seed=Max', 'hasStory': true},
  ];
}
