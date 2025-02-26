import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Message {
  final String text;
  final DateTime timestamp;
  final bool isUser;

  Message({
    required this.text,
    required this.timestamp,
    required this.isUser,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp,
      'isUser': isUser,
    };
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Store message in Firestore
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'text': text,
      'timestamp': DateTime.now(),
      'isUser': true,
    });

    // Clear input field
    _messageController.clear();

    // Simulate bot response (replace with your chatbot logic)
    await _generateBotResponse(text);
  }

  Future<void> _generateBotResponse(String userMessage) async {
    // Add your chatbot logic here
    // This is a simple example - replace with actual NLP or API calls
    String botResponse =
        "Thanks for your message: '$userMessage'. How can I help?";

    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'text': botResponse,
      'timestamp': DateTime.now(),
      'isUser': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        messages[index].data() as Map<String, dynamic>;
                    bool isUser = data['isUser'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['text'] ?? '',
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(
                                    (data['timestamp'] as Timestamp).toDate(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUser
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
