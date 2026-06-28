class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Mock Data
  static List<MessageModel> mockMessages = [
    MessageModel(
      id: '1',
      senderId: '2',
      senderName: 'bhaggabilla',
      senderImage: 'https://via.placeholder.com/150',
      message: 'Hey! Love your pet photos!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    MessageModel(
      id: '2',
      senderId: '3',
      senderName: 'catbuddy',
      senderImage: 'https://via.placeholder.com/150',
      message: 'Thanks for following! 😊',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    MessageModel(
      id: '3',
      senderId: '4',
      senderName: 'pawsome_pets',
      senderImage: 'https://via.placeholder.com/150',
      message: 'Where did you get that cute collar?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
  ];
}

class NotificationModel {
  final String id;
  final String type; // 'like', 'comment', 'follow'
  final String userId;
  final String username;
  final String userImage;
  final String? postImage;
  final String message;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.username,
    required this.userImage,
    this.postImage,
    required this.message,
    required this.timestamp,
  });

  // Mock Data
  static List<NotificationModel> mockNotifications = [
    NotificationModel(
      id: '1',
      type: 'like',
      userId: '2',
      username: 'bhaggabilla',
      userImage: 'https://via.placeholder.com/150',
      postImage: 'https://via.placeholder.com/150',
      message: 'liked your post',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: '2',
      type: 'comment',
      userId: '3',
      username: 'catbuddy',
      userImage: 'https://via.placeholder.com/150',
      postImage: 'https://via.placeholder.com/150',
      message: 'commented on your post: "So cute!"',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: '3',
      type: 'follow',
      userId: '4',
      username: 'pawsome_pets',
      userImage: 'https://via.placeholder.com/150',
      message: 'started following you',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
}
