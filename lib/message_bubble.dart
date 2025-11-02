// lib/message_bubble.dart

import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String userId;
  final DateTime timestamp;
  final String? imageUrl;

  const MessageBubble(
    this.message,
    this.isMe,
    this.userId,
    this.timestamp,
    this.imageUrl, {
    super.key,
  })  : assert(message != null),
        assert(isMe != null),
        assert(userId != null),
        assert(timestamp != null);

  String _formatTimestamp(DateTime timestamp) {
    int hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    if (hour == 0) hour = 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTimestamp(timestamp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe 
                ? Colors.blue[300] 
                : isDark 
                    ? Colors.grey[800] 
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isMe 
                  ? Colors.blue[300]! 
                  : isDark 
                      ? Colors.grey[700]! 
                      : Colors.grey[300]!,
            ),
          ),
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                userId,
                style: TextStyle(
                  color: isMe 
                      ? Colors.white 
                      : isDark 
                          ? Colors.white 
                          : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              // Hiển thị ảnh nếu có
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Hiển thị text nếu có
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    color: isMe 
                        ? Colors.white 
                        : isDark 
                            ? Colors.white 
                            : Colors.black87,
                    fontSize: 17,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: isMe 
                      ? Colors.white70 
                      : isDark 
                          ? Colors.grey[400] 
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





