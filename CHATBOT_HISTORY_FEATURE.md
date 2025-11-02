# 💾 Tính Năng Lưu Lịch Sử Chat

## ✅ Đã Thêm

Chatbot hiện **TỰ ĐỘNG LƯU** toàn bộ lịch sử chat vào local storage!

## 🎯 Tính Năng

### Auto-Save Chat History
- ✅ **Tự động lưu** mỗi tin nhắn (user + bot response)
- ✅ **Tự động load** khi mở lại chatbot screen
- ✅ **Persistent** - Lưu ngay cả khi tắt app
- ✅ **Không mất data** khi chuyển màn hình

### Xóa Lịch Sử
- 🗑️ Nút **Delete** (🗑️) trên AppBar
- Confirm dialog trước khi xóa
- Reset về welcome message sau khi xóa

## 📱 Cách Hoạt Động

### 1. Chat Bình Thường
```
User gửi: "Cách chăm sóc mèo"
      ↓
Bot trả lời: [Các tips...]
      ↓
✨ AUTO SAVE vào SharedPreferences
```

### 2. Đóng App / Chuyển Màn Hình
```
User click back
      ↓
Messages vẫn được lưu trong storage
      ↓
✨ Data persist
```

### 3. Mở Lại Chatbot
```
User click AI button
      ↓
Loading từ SharedPreferences
      ↓
✨ Hiển thị lại toàn bộ lịch sử chat
```

## 🔧 Technical Details

### Data Storage
- **Technology**: SharedPreferences
- **Format**: JSON
- **Key**: `chatbot_history`
- **Structure**: Array of ChatMessage objects

### ChatMessage Serialization
```dart
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

### Save/Load Logic

#### Save (Auto)
```dart
Future<void> _saveChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final messagesJson = _messages.map((msg) => msg.toJson()).toList();
  final chatHistoryJson = json.encode(messagesJson);
  await prefs.setString('chatbot_history', chatHistoryJson);
}
```

#### Load (Init)
```dart
Future<void> _loadChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final chatHistoryJson = prefs.getString('chatbot_history');
  
  if (chatHistoryJson != null) {
    final List<dynamic> messagesJson = json.decode(chatHistoryJson);
    for (var messageJson in messagesJson) {
      _messages.add(ChatMessage.fromJson(messageJson));
    }
  }
}
```

## 🎨 UI Features

### AppBar Actions
- **Delete button** (🗑️ icon)
- Xác nhận trước khi xóa
- Tooltip: "Xóa lịch sử chat"

### Loading State
- **CircularProgressIndicator** khi đang load
- Hiển thị `_hasLoadedHistory` flag
- Tránh flash welcome message

### Welcome Message
- Chỉ hiển thị nếu **chưa có lịch sử**
- Không thêm nếu đã có tin nhắn cũ
- Timing: Sau khi load xong

## 📊 Data Flow

```
┌─────────────────────────────────┐
│   User sends message           │
│         ↓                      │
│   Message added to _messages   │
│         ↓                      │
│   _saveChatHistory() called    │
│         ↓                      │
│   Convert to JSON              │
│         ↓                      │
│   Save to SharedPreferences    │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   User opens chatbot            │
│         ↓                        │
│   initState() called            │
│         ↓                        │
│   _loadChatHistory() called    │
│         ↓                        │
│   Load from SharedPreferences   │
│         ↓                        │
│   Parse JSON                    │
│         ↓                        │
│   Rebuild ChatMessage objects   │
│         ↓                        │
│   Display messages              │
└─────────────────────────────────┘
```

## ✅ User Experience

### Benefits
- 📝 **Xem lại** câu hỏi và câu trả lời cũ
- 🔍 **Không bị mất** thông tin quan trọng
- 💡 **Gợi nhớ** về các tips đã nhận
- 🎯 **Tiếp tục** cuộc trò chuyện

### Use Cases
1. User hỏi về lịch tiêm chủng → Quay lại xem
2. User quên tips chăm sóc → Vào xem lại
3. User muốn tham khảo lại câu trả lời

## 🧪 Testing

### Test Case 1: Basic Save/Load
```
1. Mở chatbot
2. Gửi 2-3 tin nhắn
3. Quay về home
4. Mở lại chatbot
✅ Phải hiển thị lại 2-3 tin nhắn + response
```

### Test Case 2: Persistent Storage
```
1. Chat với bot
2. Tắt app hoàn toàn
3. Mở lại app
4. Vào chatbot
✅ Phải có lịch sử chat từ session trước
```

### Test Case 3: Clear History
```
1. Có lịch sử chat
2. Click nút delete
3. Confirm
✅ Chat history bị xóa, chỉ còn welcome message
```

## 📝 Code Changes

### New Imports
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
```

### New Fields
```dart
bool _hasLoadedHistory = false;  // Track loading state
```

### New Methods
- `_loadChatHistory()`: Load từ storage
- `_saveChatHistory()`: Save vào storage
- `_clearChatHistory()`: Xóa lịch sử
- `toJson()` / `fromJson()`: Serialization

### Modified Methods
- `initState()`: Thêm load history
- `_sendMessage()`: Thêm save sau mỗi message
- `build()`: Thêm loading indicator

## 🚀 Future Enhancements

Có thể mở rộng:
- [ ] Export chat history thành file
- [ ] Search trong lịch sử chat
- [ ] Pin important messages
- [ ] Share chat history
- [ ] Multi-chat sessions
- [ ] Auto-clear old messages (sau 30 ngày)

---

## ✅ Summary

**Tính năng lưu lịch sử chat đã hoàn thành!**

- ✅ Auto-save mỗi tin nhắn
- ✅ Auto-load khi mở lại
- ✅ Persistent across sessions
- ✅ Delete button để xóa
- ✅ Loading state
- ✅ Perfect UX

Người dùng giờ có thể:
- Chat với bot
- Tắt app
- Mở lại app
- Xem lại toàn bộ lịch sử chat! 🎉






