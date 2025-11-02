# 🤖 Hướng Dẫn Setup Chatbot AI PetCare

## 📋 Tổng Quan

Ứng dụng đã được tích hợp chatbot AI tư vấn về quản lý thú cưng sử dụng:
- **Dialogflow**: AI platform của Google
- **dash_chat_2**: UI chat đẹp mắt
- **dialog_flowtter**: Flutter package để kết nối với Dialogflow

## ✨ Tính Năng Chatbot

Chatbot AI có thể tư vấn về:
- ✅ Chăm sóc thú cưng hàng ngày
- ✅ Lịch tiêm chủng định kỳ
- ✅ Dinh dưỡng phù hợp
- ✅ Vệ sinh & sức khỏe
- ✅ Phụ kiện & đồ chơi
- ✅ Xử lý tình trạng bệnh
- ✅ Giải đáp thắc mắc

## 🔧 Cách Setup

### Bước 1: Tạo Dialogflow Agent

1. Truy cập [Dialogflow Console](https://dialogflow.cloud.google.com/)
2. Đăng nhập bằng tài khoản Google
3. Tạo **New Agent**:
   - Name: `PetCareBot`
   - Default Language: `Vietnamese (vi)`
   - Timezone: `(GMT+07:00) Asia/Ho_Chi_Minh`
4. Click **Create**

### Bước 2: Tạo Service Account & Download Credentials

1. Trong Dialogflow Console, click vào **settings** (⚙️)
2. Chọn tab **General**
3. Click **"Service Account"** ở cuối trang
4. Click **"Create Key"** hoặc vào **Google Cloud Console**
5. Chọn **JSON** format
6. Download file JSON về máy

### Bước 3: Thêm File Credentials vào Project

1. Đổi tên file JSON thành: `petcarebot_credentials.json`
2. Copy file vào thư mục: `assets/`
3. Đảm bảo file đã được khai báo trong `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
    - assets/sounds/
    - assets/petcarebot_credentials.json  # Thêm dòng này
```

### Bước 4: Tạo Intents trong Dialogflow

#### Intent 1: Default Welcome Intent
- **Training phrases:**
  - "xin chào"
  - "chào bạn"
  - "hello"
  - "hey"

- **Responses:**
  - "Xin chào! Tôi có thể giúp gì cho bạn về thú cưng?"
  - "Chào bạn! Tôi sẵn sàng tư vấn về quản lý thú cưng!"

#### Intent 2: Chăm Sóc Thú Cưng
- **Training phrases:**
  - "cách chăm sóc mèo"
  - "chăm sóc thú cưng như thế nào"
  - "cho mèo ăn gì"
  - "nên tắm cho chó bao lâu 1 lần"

- **Responses:**
  - "Để chăm sóc thú cưng tốt, bạn cần:\n• Cho ăn đủ bữa, đúng giờ\n• Thường xuyên kiểm tra sức khỏe\n• Tắm rửa và vệ sinh định kỳ\n• Quan tâm và chơi với thú cưng"

#### Intent 3: Lịch Tiêm Chủng
- **Training phrases:**
  - "khi nào nên tiêm vaccine"
  - "lịch tiêm chủng cho chó"
  - "vaccine cho mèo"
  - "nên tiêm phòng bao lâu 1 lần"

- **Responses:**
  - "Lịch tiêm vaccine cho thú cưng:\n• Mũi 1: 6-8 tuần tuổi\n• Mũi 2: 10-12 tuần tuổi\n• Mũi 3: 14-16 tuần tuổi\n• Nhắc lại hàng năm"

#### Intent 4: Dinh Dưỡng
- **Training phrases:**
  - "cho chó ăn gì"
  - "thức ăn cho mèo"
  - "chế độ dinh dưỡng"
  - "nên cho ăn bao nhiêu"

- **Responses:**
  - "Chế độ dinh dưỡng phù hợp:\n• Cho chó: 2-3 bữa/ngày, thức ăn khô chất lượng cao\n• Cho mèo: 2-3 bữa/ngày, có thể mix khô + ướt\n• Uống đủ nước sạch hàng ngày"

### Bước 5: Cài Đặt Package

1. Chạy lệnh trong terminal:
```bash
flutter pub get
```

2. Nếu gặp lỗi, thử:
```bash
flutter clean
flutter pub get
```

### Bước 6: Test Chatbot

1. Chạy app:
```bash
flutter run
```

2. Click vào nút **🤖 AI Chatbot** (purple button)
3. Nhập câu hỏi về thú cưng
4. Kiểm tra response từ AI

## 🎨 UI Features

### Chatbot Screen
- **Purple FAB** (bottom-left, above chat button)
- **Modern UI** với DashChat
- **Auto-scroll** to latest message
- **Typing indicator** khi AI đang trả lời
- **Avatar** cho user và bot
- **Sound feedback** khi gửi tin nhắn

### Color Scheme
- **Purple (Colors.purple)**: AI Chatbot button
- **Teal (Colors.teal)**: Chat button
- **Teal [700]**: AppBar, buttons

## 📝 Code Structure

### Files Created/Modified:
1. **pubspec.yaml**: Thêm dependencies
2. **lib/chatbot_service.dart**: Service xử lý Dialogflow
3. **lib/chatbot_screen.dart**: UI chat screen
4. **lib/home_page.dart**: Thêm AI button
5. **assets/petcarebot_credentials.json**: Credentials (user tạo)

### Key Functions:

#### ChatbotService
```dart
- initialize(): Khởi tạo Dialogflow
- sendMessage(): Gửi và nhận response
- dispose(): Cleanup
```

#### ChatbotScreen
```dart
- _sendMessage(): Gửi message đến chatbot
- _initializeChat(): Khởi tạo chat với welcome message
- handleResponse(): Xử lý response từ AI
```

## 🐛 Troubleshooting

### Lỗi: "Chatbot chưa sẵn sàng"
- **Nguyên nhân**: Chưa có credentials file
- **Giải pháp**: Tạo và thêm file `petcarebot_credentials.json` vào `assets/`

### Lỗi: "No pubspec.yaml found"
- **Nguyên nhân**: Không đúng thư mục
- **Giải pháp**: `cd` vào root project

### Lỗi: "Network error"
- **Nguyên nhân**: Không có internet
- **Giải pháp**: Kiểm tra kết nối mạng

### Lỗi: "Authentication failed"
- **Nguyên nhân**: Credentials file sai
- **Giải pháp**: Download lại credentials từ Dialogflow

## 🚀 Advanced Setup

### Thêm Context & Entities

Trong Dialogflow Console, thêm:
- **Entities**: thú cưng, tuổi, giống
- **Context**: giữ trạng thái hội thoại
- **Fulfillment**: kết nối với database

### Thêm Quick Replies

Có thể thêm quick replies trong code:
```dart
quickReplies: [
  QuickReply(title: "Chăm sóc"),
  QuickReply(title: "Tiêm chủng"),
  QuickReply(title: "Dinh dưỡng"),
]
```

## 📚 References

- [Dialogflow Documentation](https://cloud.google.com/dialogflow/docs)
- [dash_chat_2 Package](https://pub.dev/packages/dash_chat_2)
- [dialog_flowtter Package](https://pub.dev/packages/dialog_flowtter)

---

## ✅ Checklist Setup

- [ ] Tạo Dialogflow Agent
- [ ] Download credentials JSON
- [ ] Thêm file vào assets/
- [ ] Cập nhật pubspec.yaml
- [ ] Chạy `flutter pub get`
- [ ] Test chatbot trong app
- [ ] Tạo các intents cơ bản
- [ ] Test với các câu hỏi khác nhau

Chúc bạn setup thành công! 🎉






