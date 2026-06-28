import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.modernBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppConstants.textPrimary),
        title: const Text(
          "Messages",
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: MessageModel.mockMessages.length,
        itemBuilder: (context, index) {
          final message = MessageModel.mockMessages[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppConstants.softShadow,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(message.senderImage),
                  ),
                  if (!message.isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor, // Pink dot for unread
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                message.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppConstants.textSecondary),
              ),
              trailing: Text(
                "2m ago",
                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
              ),
              onTap: () {
                // Open Chat Details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Chat with ${message.senderName}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
