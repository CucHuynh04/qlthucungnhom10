# Firebase Realtime Database Sync - Hướng dẫn sử dụng

## 🔥 Tổng quan

App đã được tích hợp Firebase Realtime Database để đồng bộ dữ liệu lên đám mây một cách tự động và real-time.

## ✅ Những gì đã tích hợp

### 1. Package `firebase_database: ^11.3.5`
- ✅ Đã thêm vào `pubspec.yaml`
- ✅ Đã cài đặt và sẵn sàng sử dụng

### 2. Service `FirebaseSyncService`
- 📁 File: `lib/firebase_sync_service.dart`
- 🔧 Chức năng:
  - Đồng bộ thú cưng (Pets)
  - Đồng bộ lịch hẹn (Schedules)
  - Lưu/xóa dữ liệu real-time
  - Lắng nghe thay đổi từ Firebase
  - Tải dữ liệu người dùng

### 3. Cập nhật `PetService`
- 📁 File: `lib/pet_service.dart`
- 🔧 Đã tích hợp với Firebase:
  - `addPet()` - Tự động lưu lên Firebase
  - `updatePet()` - Tự động cập nhật lên Firebase
  - `deletePet()` - Tự động xóa khỏi Firebase
  - `addSchedule()` - Tự động lưu lịch hẹn lên Firebase
  - `deleteSchedule()` - Tự động xóa lịch hẹn khỏi Firebase

## 📊 Cấu trúc dữ liệu trên Firebase

```
users/
  {userId}/
    pets/
      {petId1}/
        id: "..."
        name: "..."
        species: "..."
        breed: "..."
        gender: "..."
        birthDate: "..."
        imageUrl: "..."
        weight: ...
        weightHistory: [...]
        careHistory: [...]
        vaccinationHistory: [...]
        accessoryHistory: [...]
        foodHistory: [...]
    schedules/
      {petId}/
        {scheduleId}/
          id: "..."
          petId: "..."
          title: "..."
          type: "..."
          date: "..."
          time: "..."
          notes: "..."
```

## 🎯 Cách hoạt động

### 1. Tự động đồng bộ khi thêm/xóa/cập nhật
Khi user thực hiện các thao tác sau, dữ liệu sẽ tự động lưu lên Firebase:
- ✨ Thêm thú cưng mới
- ✏️ Cập nhật thông tin thú cưng
- 🗑️ Xóa thú cưng
- 📅 Thêm lịch hẹn
- 🗑️ Xóa lịch hẹn

### 2. Chỉ đồng bộ khi đã đăng nhập
- ✅ Kiểm tra `_syncService.isLoggedIn` trước khi sync
- ✅ Chỉ sync khi user đã đăng nhập
- ✅ Mỗi user có dữ liệu riêng (theo userId)

### 3. Xử lý lỗi an toàn
- ✅ Try-catch để không làm crash app
- ✅ Log lỗi để debug
- ✅ Fallback sang local data nếu sync thất bại

## 🚀 Các tính năng

### Real-time Sync
```dart
// Lắng nghe thay đổi dữ liệu thú cưng real-time
_syncService.getPetsStream().listen((event) {
  // Xử lý khi có thay đổi
});
```

### Manual Sync
```dart
// Đồng bộ toàn bộ dữ liệu lên Firebase
await petService.syncAllDataToFirebase();

// Tải dữ liệu từ Firebase
await petService.loadDataFromFirebase();
```

## ⚙️ Firebase Console

Truy cập [Firebase Console](https://console.firebase.google.com/project/flutter-firebase-5592b) để:
- Xem dữ liệu real-time
- Kiểm tra cấu trúc database
- Debug các vấn đề sync

## 📝 Lưu ý

1. **URL Database**: `https://flutter-firebase-5592b-default-rtdb.firebaseio.com/`
2. **Security Rules**: Cần cấu hình trong Firebase Console
3. **Authentication**: Chỉ user đã đăng nhập mới sync được
4. **Data Size**: Mỗi user có giới hạn 1GB data

## 🔒 Security Rules (Khuyến nghị)

Thêm vào Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

Điều này đảm bảo:
- ✅ User chỉ đọc/ghi dữ liệu của chính mình
- ✅ Không thể truy cập dữ liệu user khác
- ✅ Bảo mật tuyệt đối

## 🎉 Kết quả

App bây giờ có:
- ✅ Đồng bộ tự động lên đám mây
- ✅ Real-time updates
- ✅ Backup dữ liệu tự động
- ✅ Sync nhiều thiết bị
- ✅ Không lo mất dữ liệu



