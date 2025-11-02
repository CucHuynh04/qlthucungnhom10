// lib/chatbot_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_helper.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasLoadedHistory = false;

  @override
  void initState() {
    super.initState();
    // Delay nhỏ để đảm bảo widget đã build
    Future.microtask(() => _loadChatHistory());
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = prefs.getString('chatbot_history');
      
      if (chatHistoryJson != null && chatHistoryJson.isNotEmpty) {
        final List<dynamic> messagesJson = json.decode(chatHistoryJson);
        setState(() {
          _messages.clear();
          for (var messageJson in messagesJson) {
            _messages.add(ChatMessage.fromJson(messageJson));
          }
          _hasLoadedHistory = true;
        });
      } else {
        // Chỉ thêm welcome message nếu không có lịch sử
        setState(() {
          _addWelcomeMessage();
          _hasLoadedHistory = true;
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Nếu có lỗi, thêm welcome message
      setState(() {
        if (_messages.isEmpty) {
          _addWelcomeMessage();
        }
        _hasLoadedHistory = true;
      });
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((msg) => msg.toJson()).toList();
      final chatHistoryJson = json.encode(messagesJson);
      await prefs.setString('chatbot_history', chatHistoryJson);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  void _addWelcomeMessage() {
    // Chỉ thêm welcome message nếu chưa có tin nhắn nào
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: 'Xin chào! Tôi là PetCare AI, trợ lý thông minh về quản lý thú cưng. Tôi có thể giúp bạn về:\n\n'
              '🐾 Chăm sóc thú cưng\n'
              '💉 Lịch tiêm chủng\n'
              '🍽️ Dinh dưỡng phù hợp\n'
              '🛁 Vệ sinh & sức khỏe\n'
              '🧸 Phụ kiện & đồ chơi\n\n'
              'Hãy hỏi tôi bất cứ điều gì!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _controller.clear();
    _saveChatHistory(); // Lưu sau khi gửi tin nhắn

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _getResponse(text);
      setState(() {
        _messages.insert(0, ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _saveChatHistory(); // Lưu sau khi bot trả lời
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChatHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat?'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử chat? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('chatbot_history');
        setState(() {
          _messages.clear();
        });
        _addWelcomeMessage();
        _saveChatHistory();
      } catch (e) {
        print('Error clearing chat history: $e');
      }
    }
  }

  String _getResponse(String input) {
    final lowerInput = input.toLowerCase();

    // Chăm sóc thú cưng
    if (lowerInput.contains('chăm sóc') || lowerInput.contains('care')) {
      return 'Để chăm sóc thú cưng tốt, bạn cần:\n\n'
             '✅ Cho ăn đủ bữa, đúng giờ\n'
             '✅ Kiểm tra sức khỏe định kỳ\n'
             '✅ Tắm rửa và vệ sinh thường xuyên\n'
             '✅ Quan tâm và chơi với thú cưng\n'
             '✅ Tạo môi trường thoải mái\n'
             '✅ Đưa đi khám bác sĩ khi cần';
    }

    // Lịch tiêm chủng
    if (lowerInput.contains('tiêm') || lowerInput.contains('vaccine') || 
        lowerInput.contains('chủng') || lowerInput.contains('phòng')) {
      return 'Lịch tiêm vaccine cho thú cưng:\n\n'
             '📅 6-8 tuần tuổi: Mũi đầu tiên\n'
             '📅 10-12 tuần tuổi: Mũi thứ hai\n'
             '📅 14-16 tuần tuổi: Mũi thứ ba\n'
             '📅 Nhắc lại: Hàng năm\n\n'
             'Lưu ý: Nên tiêm phòng các bệnh nguy hiểm như dại, care, parvo...';
    }

    // Dinh dưỡng
    if (lowerInput.contains('ăn') || lowerInput.contains('dinh dưỡng') || 
        lowerInput.contains('thức ăn') || lowerInput.contains('food')) {
      return 'Chế độ dinh dưỡng phù hợp:\n\n'
             '🍽️ Chó: 2-3 bữa/ngày\n'
             '   • Thức ăn khô chất lượng cao\n'
             '   • Có thể thêm pate hoặc thực phẩm tươi\n'
             '   • Tránh thức ăn có hại (socola, hành tỏi)\n\n'
             '🍽️ Mèo: 2-3 bữa/ngày\n'
             '   • Mix thức ăn khô và ướt\n'
             '   • Nhiều protein và ít tinh bột\n'
             '   • Luôn có nước sạch\n\n'
             '⚠️ Nên điều chỉnh lượng phù hợp với tuổi và cân nặng!';
    }

    // Vệ sinh
    if (lowerInput.contains('tắm') || lowerInput.contains('vệ sinh') || 
        lowerInput.contains('clean')) {
      return 'Vệ sinh cho thú cưng:\n\n'
             '🛁 Tắm cho chó: 2-4 tuần/lần\n'
             '   • Dùng sữa tắm chuyên dụng\n'
             '   • Lau khô kỹ sau khi tắm\n'
             '   • Chải lông thường xuyên\n\n'
             '🛁 Tắm cho mèo: 1-2 tháng/lần\n'
             '   • Mèo thường tự vệ sinh\n'
             '   • Chỉ tắm khi cần thiết\n'
             '   • Dùng sữa tắm dành cho mèo\n\n'
             '💅 Cắt móng: 2-4 tuần/lần';
    }

    // Chào hỏi
    if (lowerInput.contains('chào') || lowerInput.contains('hello') || 
        lowerInput.contains('hi') || lowerInput.contains('xin chào')) {
      return 'Xin chào! 😊\n\nTôi có thể giúp bạn về:\n'
             '• Chăm sóc thú cưng\n'
             '• Lịch tiêm chủng\n'
             '• Dinh dưỡng\n'
             '• Vệ sinh\n\n'
             'Hãy cho tôi biết bạn cần gì!';
    }

    // Default response
    return 'Cảm ơn câu hỏi của bạn! 😊\n\n'
           'Tôi có thể giúp bạn về:\n'
           '• Chăm sóc thú cưng\n'
           '• Lịch tiêm chủng\n'
           '• Dinh dưỡng\n'
           '• Vệ sinh & sức khỏe\n\n'
           'Hãy hỏi cụ thể hơn nhé!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            SoundHelper.playClickSound();
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('PetCare AI'),
          ],
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa lịch sử chat',
            onPressed: () {
              SoundHelper.playClickSound();
              _clearChatHistory();
            },
          ),
        ],
      ),
      body: _hasLoadedHistory
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      final messageIndex = _isTyping ? index - 1 : index;
                      return _buildMessage(_messages[messageIndex]);
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.purple[300],
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.teal[700] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.teal[700],
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple[300],
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () {
              SoundHelper.playClickSound();
              _sendMessage(_controller.text);
            },
            backgroundColor: Colors.purple[700],
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
