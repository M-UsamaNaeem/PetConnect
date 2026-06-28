import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/notifications_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription? _firestoreListener;

  static const _channelId = 'petconnect_channel';
  static const _channelName = 'PetConnect Notifications';

  /// Global navigator key — set this on your MaterialApp
  /// so the service can navigate when a notification is tapped.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ─── INITIALIZE (call once in main) ──────────────────────────────────────
  static Future<void> initialize() async {
    // Local notifications setup
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('launcher_icon');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create high-importance Android channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
        ));

    // FCM permission + token
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null) _saveToken(token);
      messaging.onTokenRefresh.listen(_saveToken);

      // FCM foreground handler — show a local banner
      FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n != null) {
          _showLocal(
            n.title ?? 'PetConnect',
            n.body ?? '',
            payload: msg.data['type'] ?? '',
          );
        }
      });

      // When user taps a notification while app is in BACKGROUND
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message.data);
      });

      // When app is launched from TERMINATED state via notification tap
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        // Small delay to let navigator build
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(initialMessage.data);
        });
      }
    } catch (e) {
      print('⚠️ FCM initialization error: $e');
    }
  }

  // ─── START LISTENING TO FIRESTORE NOTIFICATIONS ───────────────────────────
  /// Call this after the user logs in so Firestore notifs appear as banners.
  static void startListening(String uid) {
    _firestoreListener?.cancel();

    // Save FCM token for the user upon starting listeners
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true))
            .catchError((e) {
              print('⚠️ Error saving FCM token on login/restart: $e');
            });
      }
    }).catchError((e) {
      print('⚠️ Error getting FCM token on login/restart: $e');
    });

    _firestoreListener = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snap) {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          
          // Prevent spamming old unread notifications when starting the listener
          final timestampStr = data['timestamp'] as String?;
          if (timestampStr != null) {
            final notifTime = DateTime.tryParse(timestampStr);
            if (notifTime != null) {
              final age = DateTime.now().difference(notifTime);
              if (age.inSeconds > 10) {
                continue; // Skip banner for historical alerts
              }
            }
          }

          final username = data['username'] ?? 'Someone';
          final type = data['type'] ?? '';
          final body = _bodyForType(type, username, data);
          if (body.isNotEmpty) _showLocal('PetConnect 🐾', body, payload: type);
        }
      }
    });
  }

  static void stopListening() {
    _firestoreListener?.cancel();
    _firestoreListener = null;
  }

  // ─── SAVE FCM TOKEN ───────────────────────────────────────────────────────
  static void _saveToken(String token) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true))
          .catchError((_) {});
    }
  }

  // ─── SHOW A LOCAL NOTIFICATION BANNER ────────────────────────────────────
  static Future<void> _showLocal(String title, String body,
      {String payload = ''}) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'launcher_icon',
        ),
      ),
      payload: payload,
    );
  }

  // ─── HANDLE LOCAL NOTIFICATION TAP ──────────────────────────────────────
  static void _onNotificationTapped(NotificationResponse response) {
    final type = response.payload ?? '';
    _handleNotificationTap({'type': type});
  }

  // ─── HANDLE NOTIFICATION TAP (NAVIGATE) ─────────────────────────────────
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Navigate directly to the notifications screen
    navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  // ─── MAP NOTIFICATION TYPE TO BODY TEXT ──────────────────────────────────
  static String _bodyForType(
      String type, String username, Map<String, dynamic> data) {
    switch (type) {
      case 'like':
        return '$username liked your post ❤️';
      case 'follow':
        return '$username started following you 👋';
      case 'comment':
        return '$username commented on your post 💬';
      case 'message':
        return '$username sent you a message 📩';
      case 'marketplace':
        return '$username is interested in your listing 🛍️';
      case 'story_reaction':
        return '$username ${data['message'] ?? 'reacted to'} your story ✨';
      case 'welcome':
        return data['message'] ?? 'Welcome to PetConnect! 🐾';
      case 'marketplace_new':
        return '$username ${data['message'] ?? 'posted a new listing 🛍️'}';
      default:
        return '';
    }
  }

  // ─── HELPERS CALLED FROM OTHER SCREENS ───────────────────────────────────
  /// Save a notification to Firestore so the target user sees it.
  static Future<void> sendNotification({
    required String targetUserId,
    required String type,
    required String fromUsername,
    required String fromUserId,
    String? userImage,
    String? message,
  }) async {
    // Don't send notification to yourself
    if (targetUserId == fromUserId) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .add({
      'type': type,
      'fromId': fromUserId,
      'username': fromUsername,
      'userImage': userImage ?? '',
      'message': message ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
  }
}
