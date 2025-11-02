// lib/messages.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatDocs = chatSnapshot.data!.docs;

        if (chatDocs.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Start chatting!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final doc = chatDocs[index];
            final text = doc['text'] as String? ?? '';
            final userId = doc['userId'] as String? ?? '';
            final imageUrl = doc['imageUrl'] as String?;
            final createdAt = doc['createdAt'] as Timestamp?;
            
            if (createdAt == null) {
              return const SizedBox.shrink();
            }
            
            return MessageBubble(
              text,
              userId == FirebaseAuth.instance.currentUser?.uid,
              userId,
              createdAt.toDate(),
              imageUrl,
            );
          },
        );
      },
    );
  }
}





