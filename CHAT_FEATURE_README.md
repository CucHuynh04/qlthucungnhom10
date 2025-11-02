# Tính năng Chat

## Tổng quan
Tính năng chat được tích hợp vào ứng dụng quản lý thú cưng, cho phép người dùng giao tiếp với nhau thông qua Firebase Firestore.

## Cấu trúc Files

### 1. `message_bubble.dart`
Widget hiển thị từng tin nhắn:
- Hiển thị nội dung tin nhắn
- Hiển thị userId của người gửi
- Hiển thị thời gian gửi (định dạng 12h AM/PM)
- Bubble màu xanh cho tin nhắn của mình, màu trắng cho tin nhắn của người khác

### 2. `messages.dart`
Widget hiển thị danh sách tin nhắn:
- Stream data từ Firestore collection 'chat'
- Sắp xếp tin nhắn theo thời gian (mới nhất ở dưới)
- Map mỗi document thành MessageBubble

### 3. `chat_screen.dart`
Màn hình chat chính:
- TextField để nhập tin nhắn
- IconButton gửi (màu xanh teal)
- AppBar hiển thị ID người dùng
- Menu đăng xuất

### 4. `auth_wrapper.dart`
Widget quản lý authentication:
- Nếu chưa đăng nhập: hiển thị nút "Đăng nhập ẩn danh"
- Nếu đã đăng nhập: chuyển đến ChatScreen
- Sử dụng Firebase Auth Anonymous

## Cách sử dụng

### Bước 1: Cài đặt Firebase
1. Tạo project trên Firebase Console
2. Thêm app Android/iOS vào project
3. Tải file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)

### Bước 2: Cấu hình Firestore Security Rules
Truy cập Firebase Console > Firestore Database > Rules, thêm:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép đọc/ghi chat nếu đã đăng nhập
    match /chat/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Bước 3: Bật Authentication Ẩn danh
1. Vào Firebase Console > Authentication
2. Chọn Sign-in method
3. Bật "Anonymous" provider

### Bước 4: Tạo Index (nếu cần)
Firestore có thể yêu cầu tạo composite index:
- Collection: `chat`
- Fields: `createdAt` (Ascending)

### Bước 5: Chạy ứng dụng
```bash
flutter pub get
flutter run
```

## Tính năng
- ✅ Đăng nhập ẩn danh tự động
- ✅ Gửi/nhận tin nhắn realtime
- ✅ Hiển thị thời gian gửi (AM/PM)
- ✅ Hiển thị ID người gửi
- ✅ Bubble chat giống Messenger
- ✅ Nút chat tròn nổi bật trên HomePage
- ✅ Đăng xuất

## Cấu trúc dữ liệu Firestore

```
chat/
  └── {messageId}/
      ├── text: string (nội dung tin nhắn)
      ├── userId: string (UID của người gửi)
      └── createdAt: timestamp (thời gian gửi)
```

## Giao diện
- Icon chat màu teal khớp với theme ứng dụng
- Floating action button ở góc phải màn hình HomePage
- Chat screen có AppBar màu teal
- TextField bo tròn, màu teal khi focus
- Button gửi tròn, màu teal

## Lưu ý
- Firebase cần được cấu hình đúng cách
- Firestore Security Rules phải cho phép read/write
- Bật Anonymous Authentication
- Có thể cần tạo composite index trong Firestore














